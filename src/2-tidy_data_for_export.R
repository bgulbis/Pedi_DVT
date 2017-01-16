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
    filter(lab %in% keep_labs)

measures <- read_data("data/raw", "measures") %>%
    as.measures()
