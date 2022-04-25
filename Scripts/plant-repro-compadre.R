## ----------------------------------------------------------------- ##
              # Plant Reproduction - COMPADRE Exploration
## ----------------------------------------------------------------- ##
# Written by Nick J Lyon

# PURPOSE
## Explore plant population projection matrices included in COMPADRE
## Link here: compadre-db.org/Data

# Clear environment
rm(list = ls())

# Call packages
library(tidyverse)

# Load data
load(file.path("Data", "COMPADRE_v.6.22.1.2.RData"))

# Housekeeping ------------------------------------------------

# Strip out species information
compadre_spp <- compadre[["metadata"]] %>%
  dplyr::select(OrganismType, Genus, Species) %>%
  dplyr::filter(OrganismType == "Tree") %>%
  unique()

# Check it out



# End ---------------------------------------------------------
