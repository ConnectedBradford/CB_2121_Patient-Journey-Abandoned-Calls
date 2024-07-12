
suppressPackageStartupMessages(library(tidyverse))
library(lubridate)
library(glue)
library(survival)
library(ggplot2)
library(ggfortify)
library(patchwork)
library(ggsurvfit)
library(survminer)
library(gtsummary)
suppressPackageStartupMessages(library(flextable))
suppressPackageStartupMessages(library(Greg))

follow_up_time = 72

follow_up_time_str = ""
if(follow_up_time != 72) {
 follow_up_time_str <- glue::glue("_{follow_up_time}")   
}

imd_ethnicity_fn <- function(df) {
 df %>%
    mutate(
        person_id = bit64::as.integer.integer64(person_id),
        imd_quintile = as.factor(case_when(
            bit64::as.integer.integer64(imd_decile) %in% c(1, 2) ~ 1,
            bit64::as.integer.integer64(imd_decile) %in% c(3, 4) ~ 2,
            bit64::as.integer.integer64(imd_decile) %in% c(5, 6) ~ 3,
            bit64::as.integer.integer64(imd_decile) %in% c(7, 8) ~ 4,
            bit64::as.integer.integer64(imd_decile) %in% c(9, 10) ~ 5,
            TRUE ~ NA_integer_
        )),
        # Small number of cases where birthdate calculation results in age being -1
        age = case_when(
            age < 0 ~ 0.0,
            age > 107 ~ NA_real_,
            TRUE ~ as.numeric(as.character(age))
        ),
        age_cat = case_when(
            between(age, 18, 64) ~ "18-64",
            age > 64 ~ "over 65"
        ),
        ethnicity_simple = fct_relevel(as.factor(str_extract(ethnicity_source_value, "[^:]+")), 'White'),
        gp_visit_non_avoid = as.factor(if_else(!is.na(num_GP_contacts_to_ED_non_avoid_attend), "gp_visit", "no_gp_visit")),
        gp_visit = as.factor(if_else(!is.na(num_GP_contacts_to_ED_attend), "gp_visit", "no_gp_visit")),
    ) %>% filter(!is.na(age))
}

exponentiate <- function(data, col = "estimate") {
  data <- data %>% mutate(across(all_of(col), exp))
  
  if ("conf.low" %in% colnames(data)) {
    data <- data %>% mutate(across(c(conf.low, conf.high), exp))
  }
  
  data
}

tidy_coxme <- function(x, exponentiate = FALSE, conf.int = TRUE, conf.level = 0.95, ...){
  s <- summary(x)
  co <- stats::coef(s)
  se <- sqrt(diag(vcov(x)))
  z <- qnorm((1 + conf.level)/2, 0, 1)
  ret <- tibble(
    "term"      = names(co),
    "estimate"  = co,
    "std.error" = se,
    "statistic" = co/se,
    "p.value"   = 1 - pchisq((co/se)^2, 1),
    "conf.low"  =  co - z * se,
    "conf.high" =  co + z * se
  )
  
  if(!conf.int) {
    ret <- ret %>% select(-starts_with('conf'))
  }
  
  if (exponentiate) {
    ret <- exponentiate(ret)
  }
  ret
}

cox_fn <- function(
    df, 
    grouping = 1, 
    non_avoid = FALSE, 
    basic = FALSE, 
    follow_up_time = 72
) {
 
    cox_df <- df %>%
        filter(!is.na(age) & age >= 18) %>% # 5 rows with no age in this dataset
        transmute(
            person_id,
            fu_time_non_avoid,
            fu_time,
            status_non_avoid,
            status,
            cohort,
            age,
            sex,
            gp_visit_non_avoid,
            gp_visit,
            imd_quintile,
            ethnicity_simple,
            ooh
        ) %>% na.omit()
    
    if(follow_up_time != 72) {
     if(non_avoid) {
         cox_df <- cox_df %>% filter(fu_time_non_avoid <= follow_up_time)
        } else {
         cox_df <- cox_df %>% filter(fu_time <= follow_up_time)
        }
    }
    
    status_str = "status"
    fu_time_str = "fu_time"
    gp_visit_str = "gp_visit"
    
    if(non_avoid == TRUE) {
        status_str = "status_non_avoid"
        fu_time_str = "fu_time_non_avoid"
        gp_visit_str = "gp_visit_non_avoid"
    }
    
    spl_mod_df <- cox_df %>%
      timeSplitter(by = 1,
                   event_var = status_str,
                   time_var = fu_time_str
      ) %>%
        mutate(
            # Some suggestion by the internet that t=0 might cause problems
            Start_time = if_else(Start_time == 0, 0.5, Start_time)
        )
        
    if(basic == FALSE) {
        cox_formula = glue::glue("Surv(Start_time, Stop_time, {status_str}) ~ cohort + age + sex + imd_quintile + ethnicity_simple + strata(ooh) + {gp_visit_str}")
        cox <- coxph(as.formula(cox_formula), data = spl_mod_df, cluster = person_id)
    } else {
        cox_formula = glue::glue("Surv({fu_time_str}, {status_str}) ~ cohort")
        cox <- coxph(as.formula(cox_formula), data = cox_df)
    }
    print(glue::glue("Formula will be: {cox_formula}"))


    final_df <- broom::tidy(cox, exponentiate = TRUE, conf.int = TRUE) %>% 
        select(-statistic, -std.error) %>% 
        mutate(
            across(where(is.numeric), ~round(.x, 3))
        ) %>%
        select(term, estimate, conf.low, conf.high, p.value)   

      return(list(cox, final_df))
    
}

process_group <- function(x) {
    print(glue::glue("** Processing group {x} **"))
    grouping_df <- readRDS(glue::glue('data/grouping{x}_survival_df{follow_up_time_str}.rds'))
    df <- imd_ethnicity_fn(grouping_df)
    
    print(glue::glue("Grouping df has {nrow(get(df))} rows"))
    
    print('Processing basic models')
    
    cox_basic_non_avoid <- cox_fn(get(df), x, non_avoid = TRUE, basic = TRUE)
    saveRDS(cox_basic_non_avoid, glue::glue("output/grouping{x}_cox_basic_non_avoid.rds"))
    
    cox_basic_all <- cox_fn(get(df), x, non_avoid = FALSE, basic = TRUE)
    saveRDS(cox_basic_all, glue::glue("output/grouping{x}_cox_basic_all.rds"))
    
    print('Processing adjusted models')
    
    cox_adj_non_avoid <- cox_fn(get(df), x, non_avoid = TRUE, basic = FALSE)
    saveRDS(cox_adj_non_avoid, glue::glue("output/grouping{x}_cox_adj_non_avoid.rds"))
    
    cox_adj_all <- cox_fn(get(df), x, non_avoid = FALSE, basic = FALSE)
    saveRDS(cox_adj_all, glue::glue("output/grouping{x}_cox_adj_all.rds"))

}