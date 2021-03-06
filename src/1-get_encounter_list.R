# get encounter list

library(tidyverse)
library(readxl)
library(edwr)

fin <- read_excel("data/external/encounter_list.xlsx") %>%
    # filter(`Inclusion (Y/N)` == "Y")
    filter(Include == 1)

edw_fin <- concat_encounters(fin$FIN)

# run EDW query: Identifiers - by FIN

id <- read_data("data/raw", "identifiers") %>%
    as.id()

edw_pie <- concat_encounters(id$pie.id)

# run EDW queries:
#   * Demographics
#   * Diagnosis Codes (ICD-9/10-CM) - All
#   * Labs - CBC
#   * Labs - Coags
#   * Labs - Renal
#   * Measures (Height and Weight) - Pedi
#   * Medications - Home and Discharge - All
#   * Medications - Inpatient Continuous - Prompt
#       - parenteral nutrition solution; parenteral nutrition solution w/ lytes
#   * Medications - Inpatient Intermittent - Prompt
#       - enoxaparin; parenteral nutrition solution; parenteral nutrition solution w/ lytes
#   * Medications - Inpatient Intermittent with Frequency - Prompt
#       - enoxaparin
#   * Radiology Reports
