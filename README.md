# EXPECT study
EXploring the journeys of Patients who End their Calls prior to Triage by NHS111: The EXPECT study

# Introduction

The National Health Service (NHS) 111 service aims to assist members of the public with urgent medical care needs and is the successor to the NHS Direct service in England. Its key founding objective was to provide easy access to support for the public with urgent care needs, to ensure they received the "right care, from the right person, in the right place, at the right time" [@uk_government_nhs_2011]. It is also the key component of the 24/7 Integrated Urgent Care Service outlined in the NHS Long Term Plan [@nhs_england_nhs_2019].

However, in 2022, nearly 3.7 million callers to 111 ended the call prior to speaking to a health advisor. This represents nearly 18% of the 20.6 million calls to 111 each year [@nhs_england_integrated_2023] and has raised concerns about callers with urgent care needs not receiving timely care and advice [@gregory_tory_2023]. While the scale of the issue has been quantified, there appears to be no research exploring what happens to callers who are unable to speak to a 111 health advisor or why callers do not wait to be triaged, although the delay in answering calls has been mooted as a factor [@gregory_tory_2023]. In addition, there are concerns that callers may seek alternative healthcare services, such as the ambulance service and emergency departments, but there is no evidence to confirm or refute this. 

The aim of this study was to explore the patient journey for callers who contact 111 but end the call prior to speaking to a health advisor. The primary objective was to determine whether callers to NHS 111 who end the call prior to triage attend an ED with a non-avoidable cause sooner that those are triaged by a 111 call handler. The secondary objective was to determine whether callers to NHS 111 who end the call prior to triage attend an ED for any reason sooner that those are triaged by a 111 call handler.

# Methods

## Data

We obtained routine, retrospective data from the Connected Bradford research database, which provides linked data for approximately 1.1 million citizens across the Bradford and Airedale region of Yorkshire [@sohal_connected_2022]. Datasets include 111 and 999 call data (including abandoned calls to NHS 111 since 2022), as well as primary and secondary care (including emergency department and in-patient activity). All datasets are pseudonymised so that researchers cannot identify individual participants.

We obtained a convenience sample of all 111 calls made by adult patients registered with a General Practitioner (GP) in the Bradford area at the time of the call between the 1st January 2022 and 30th June 2023. Subsequent healthcare system access in the following 72 hours following the first (index) call (whether triaged or not) was identified, by searching the 111 and 999 call, primary care, and hospital emergency department and in-patient admission datasets.

## Groupings

We defined three cohorts of abandoned calls as it was suspected that there might be important differences between them:

1. Abandoned calls that followed a triaged NHS 111 call in the 72 hours prior to the index call.
2. Abandoned calls that did not follow a triaged NHS 111 call in the 72 hours prior to the index call.
3. All abandoned calls irrespective of whether there had been a previous triaged NHS 111 call in the 72 hours prior to the index call.


## Analysis

We conducted a time-to-event analysis comparing the two cohorts (those triaged by a NHS 111 call handler vs callers who ended the call prior to triage). The 'event' was defined as an emergency department (ED) attendance within 72 hours for a non-avoidable cause.

For the primary outcome analysis we utilised Kaplan–Meier (KM) curves and conducted a log-rank test to compare the time to first non-avoidable ED attendance between groupings for each cohort. In addition, a Cox proportional hazards model was used to adjust for clustering of results by caller, and for baseline characteristics that have been implicated as potentially effecting the outcome, including age, sex, index of multiple deprivation (IMD) and GP consultation prior to ED attendance [@lewis_patient_2021; @pilbery_analysis_2023]. The KM plots were also used to test that the proportional hazards assumption had been met. This enabled us to calculate the hazard ratio (HR) of attending an ED with a non-avoidable cause for callers who ended the call prior to triage compared to those who were triaged by a 111 call handler.

The secondary outcome analysis was conducted as for the primary outcome, except for the event, which was ED attendance for any cause.

## Ethical approval
This study was approved by the Bradford Learning Health System Board in accordance with the Connected Yorkshire NHS Research Ethics Committee (REC) approval relating to the Connected Yorkshire research database (17/EM/0254). No separate Health Research Authority (HRA) approval was required for this study.


## PPI
The application and protocol for this study was review by the Yorkshire Ambulance Service NHS Trust patient research ambassador. In addition, Connected Bradford have an active patient and public involvement group who were involved in the decision to approve this study.
