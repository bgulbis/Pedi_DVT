# tidy and export

library(tidyverse)
library(stringr)
library(edwr)
library(icd)

dir_raw <- "data/raw"

demographics <- read_data(dir_raw, "demographics") %>%
    as.demographics() %>%
    select(pie.id:race)

diagnosis <- read_data(dir_raw, "diagnosis") %>%
    as.diagnosis() %>%
    tidy_data()

icd9 <- read_csv("data/external/icd9_thrombosis_codes.csv") %>%
    dmap_at("icd9", as.character)

icd9_map <- list(thrombosis = icd9$icd9) %>%
    as.icd9cm() %>%
    as.icd_comorbidity_map()

thrombosis_icd9 <- diagnosis %>%
    filter(icd9) %>%
    icd_comorbid(icd9_map, return_df = TRUE, icd_name = "diag.code")

cols <- fwf_empty("data/external/2016_I9gem.txt", col_names = c("icd9", "icd10", "other"))
icd10_gem <- read_fwf("data/external/2016_I9gem.txt", cols) %>%
    filter(icd10 != "NoDx")

icd10 <- icd9 %>%
    inner_join(icd10_gem, by = "icd9") %>%
    select(-icd9_description, -other)

icd10_map <- list(thrombosis = icd10$icd10) %>%
    as.icd10cm() %>%
    as.icd_comorbidity_map()

thrombosis_icd10 <- diagnosis %>%
    filter(!icd9) %>%
    icd_comorbid(icd10_map, return_df = TRUE, icd_name = "diag.code")

diagnosis_thrombosis <- full_join(thrombosis_icd9, thrombosis_icd10, by = c("pie.id", "thrombosis")) %>%
    group_by(pie.id) %>%
    summarize_all(sum) %>%
    mutate(thrombosis = thrombosis >= 1)

keep_labs <- c("anti-xa low molecular heparin", "platelet", "inr", "ptt", "creatinine lvl")

labs <- read_data(dir_raw, "labs") %>%
    as.labs() %>%
    tidy_data() %>%
    filter(lab %in% keep_labs,
           !is.na(lab.result))

measures <- read_data(dir_raw, "measures") %>%
    as.measures()

meds_freq <- read_data(dir_raw, "meds_freq") %>%
    as.meds_freq() %>%
    dmap_at("med.dose", as.numeric)

meds_home <- read_data(dir_raw, "meds_home") %>%
    as.meds_home() %>%
    filter(med.type == "Recorded / Home Meds")

meds_sched <- read_data(dir_raw, "meds_sched") %>%
    as.meds_sched()

tpn <- tibble(name = c("parenteral nutrition solution", "parenteral nutrition solution w/ lytes"),
              type = "med",
              group = "cont")

meds_cont <- read_data(dir_raw, "meds_cont") %>%
    as.meds_cont() %>%
    mutate(med.rate = str_replace_all(event.tag, "Begin Bag| mL", "")) %>%
    dmap_at("med.rate", as.numeric) %>%
    calc_runtime() %>%
    summarize_data()

rad <- read_data(dir_raw, "radiology") %>%
    as.radiology() %>%
    filter(str_detect(rad.type, "US") | str_detect(rad.type, "CT"))

id <- read_data(dir_raw, "identifiers") %>%
    as.id() %>%
    select(-person.id)

# export data ------------------------------------------

patients <- left_join(demographics, diagnosis_thrombosis, by = "pie.id")

write_csv(patients, "data/external/patients.csv")
write_csv(id, "data/external/linking_log.csv")
write_csv(labs, "data/external/labs.csv")
write_csv(measures, "data/external/height_weight.csv")
write_csv(meds_cont, "data/external/tpn.csv")
write_csv(meds_freq, "data/external/enoxaparin.csv")
write_csv(meds_home, "data/external/home_meds.csv")
write_csv(rad, "data/external/radiology_reports.csv")
