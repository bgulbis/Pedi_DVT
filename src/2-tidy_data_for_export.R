# tidy and export

library(tidyverse)
library(edwr)

demographics <- read_data("data/raw", "demographics") %>%
    as.demographics()

diagnosis <- read_data("data/raw", "diagnosis") %>%
    as.diagnosis() %>%
    tidy_data()

keep_labs <- c("anti-xa low molecular heparin", "creatinine lvl")

labs <- read_data("data/raw", "labs") %>%
    as.labs() %>%
    tidy_data() %>%
    filter(lab %in% keep_labs,
           !is.na(lab.result))

measures <- read_data("data/raw", "measures") %>%
    as.measures()

meds_freq <- read_data("data/raw", "meds_freq") %>%
    as.meds_freq()

meds_home <- read_data("data/raw", "meds_home") %>%
    as.meds_home() %>%
    filter(med.type == "Recorded / Home Meds")

rad <- read_data("data/raw", "radiology") %>%
    as.radiology()

id <- read_data("data/raw", "identifiers") %>%
    as.id()
