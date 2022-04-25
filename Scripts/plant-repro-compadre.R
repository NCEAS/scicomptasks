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

# Load COMPADRE data
load(file.path("Data", "COMPADRE_v.6.22.1.2.RData"))

# Load working group data
wg_raw <- read.csv(file.path("Data", "LTER_SEED_SPP_ATTRIBUTES_v1.csv"))

# Housekeeping ------------------------------------------------

# Strip out species information
## COMPADRE
compadre_spp <- compadre[["metadata"]] %>%
  dplyr::select(Genus, Species) %>%
  dplyr::mutate(genus_spp = paste(Genus, Species, sep = '-'),
                has_data = 1) %>%
  # dplyr::filter(OrganismType == "Tree") %>%
  unique()
## Working group list
wg_spp <- wg_raw %>%
  dplyr::select(species) %>%
  dplyr::filter(nchar(species) != 0) %>%
  tidyr::separate(col = species, sep = " ", into = c("Genus", "Species")) %>%
  dplyr::mutate(genus_spp = paste(Genus, Species, sep = '-'))

# Compare Working Group List vs. COMPADRE List ---------------------------

# Combine them to figure out which WG species are in COMPADRE
combo <- wg_spp %>%
  # Grab compadre data to determine which COMPADRE species are in data
  dplyr::left_join(y = compadre_spp, by = "Genus") %>%
  # Remove unneeded column
  dplyr::select(-'Species.y') %>%
  # Get all congeners into their own columns
  tidyr::pivot_wider(id_cols = genus_spp.x,
                     names_from = genus_spp.y,
                     values_from = genus_spp.y) %>%
  # Unite all those new columns into a single 'congeners' column
  tidyr::unite(col = "congeners", -genus_spp.x, sep = '; ', na.rm = T) %>%
  # Fix a naming issue caused by the join
  dplyr::rename(genus_spp = genus_spp.x) %>%
  # Bring the Genus/Species back in
  dplyr::left_join(y = wg_spp, by = "genus_spp") %>%
  # Figure out whether each species/genus has data
  dplyr::mutate(sp_has_data = dplyr::case_when(
    genus_spp %in% compadre_spp$genus_spp ~ "yes", T ~ ''),
    genus_has_data = dplyr::case_when(
      Genus %in% compadre_spp$Genus ~ "yes", T ~ '')) %>%
  # If the species has data, drop the congeners information
  dplyr::mutate(congeners = dplyr::case_when(
    sp_has_data == "yes" ~ '', T ~ congeners)) %>%
  # Reorder the columns as desired
  dplyr::select(genus_spp, Genus, Species,
                sp_has_data, genus_has_data, congeners)

# How many?
plyr::count(combo$sp_has_data)
plyr::count(combo$genus_has_data)

# Save this out
write.csv(x = combo, row.names = F, file = file.path("Data", "PlantReproList_vs_COMPADRE.csv"))

# End ---------------------------------------------------------
