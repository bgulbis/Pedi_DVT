# get encounter list

library(tidyverse)
library(readxl)
library(edwr)

fin <- read_excel("data/external/encounter_list.xlsx") %>%
    # filter(`Inclusion (Y/N)` == "Y")
    filter(Include == 1)

edw_fin <- concat_encounters(fin$FIN)

# run EDW query: Identifiers - by FIN
