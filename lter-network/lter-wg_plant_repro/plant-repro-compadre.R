## -------------------------------------------------------- ##
         # Plant Reproduction - COMPADRE Exploration
## -------------------------------------------------------- ##
# Written by Nick J Lyon

# PURPOSE
## Explore plant population projection matrices included in COMPADRE
## Link here: compadre-db.org/Data

# Clear environment
rm(list = ls())

# Load needed packages
# install.packages("librarian")
librarian::shelf(tidyverse)

# Load COMPADRE data
load(file.path("data", "COMPADRE_v.6.22.1.2.RData"))

# Load working group data
wg_raw <- read.csv(file.path("Data", "LTER_SEED_SPP_ATTRIBUTES_v1.csv"))

# Wrangling ----------------------------------------

# Wrangle COMPADRE metadata
compadre_spp <- compadre[["metadata"]] %>%
  # Retain only genus/species
  dplyr::select(Genus, Species) %>%
  # Retain only unique values
  unique() %>%
  # Paste them together into a single column
  dplyr::mutate(genus_spp = paste(Genus, Species, sep = '-'),
                in_compadre = 1)

# Wrangle Plant Reproduction WG species list
wg_spp <- wg_raw %>%
  # Keep only 'species' (is actually 'Genus species') column
  dplyr::select(species) %>%
  # Remove empty rows
  dplyr::filter(nchar(species) != 0) %>%
  # Separate genus and species
  tidyr::separate(col = species, sep = " ", into = c("Genus", "Species")) %>%
  # Recombine them with our desired separator
  dplyr::mutate(genus_spp = paste(Genus, Species, sep = '-'))

# Compare Working Group List vs. COMPADRE List ---------------

# Combine them to figure out which WG species are in COMPADRE
combo <- wg_spp %>%
  # Left join together to see which COMPADRE species are in data
  dplyr::left_join(y = compadre_spp, by = "Genus") %>%
  # Remove unneeded column
  dplyr::select(-'Species.y') %>%
  # Get all congeners (spp in the same genus) into their own columns
  tidyr::pivot_wider(id_cols = genus_spp.x,
                     names_from = genus_spp.y,
                     values_from = genus_spp.y) %>%
  # Unite all those new columns into a single congeners column
  tidyr::unite(col = "congeners", -genus_spp.x,
               sep = '; ', na.rm = T) %>%
  # Fix a naming issue caused by the join
  dplyr::rename(genus_spp = genus_spp.x) %>%
  # Bring the Genus/Species back in
  dplyr::left_join(y = wg_spp, by = "genus_spp") %>%
  # Figure out whether each species/genus has data
  dplyr::mutate(sp_in_compadre = dplyr::case_when(
    genus_spp %in% compadre_spp$genus_spp ~ "yes", T ~ ''),
    genus_in_compadre = dplyr::case_when(
      Genus %in% compadre_spp$Genus ~ "yes", T ~ '')) %>%
  # If the species has data, drop the congeners information
  dplyr::mutate(congeners_in_compadre = dplyr::case_when(
    sp_in_compadre == "yes" ~ '', T ~ congeners)) %>%
  # Reorder the columns as desired
  dplyr::select(genus_spp, Genus, Species, sp_in_compadre, genus_in_compadre, congeners_in_compadre)

# How many?
plyr::count(combo$sp_in_compadre)
plyr::count(combo$genus_in_compadre)

# Save this out
write.csv(x = combo, row.names = F,
          file = file.path("data", "PlantReproList_vs_COMPADRE.csv"))

# End ---------------------------------------------------------
