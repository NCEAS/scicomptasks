## -------------------------------------------------- ##
#     Time Series of Community Seed Production
## -------------------------------------------------- ##
# Written by: Angel Chen

# PURPOSE
## to explore a potential analysis for the seed synchrony paper
## produces a new time series of total seed mass production (g/year)

## ------------------------------------- ##
#            Housekeeping ----
## ------------------------------------- ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls())

## ------------------------------------- ##
#            Getting Data ----
## ------------------------------------- ##
# find the attributes table in Google Drive
traits_folder <- googledrive::drive_ls(googledrive::as_id("https://drive.google.com/drive/u/0/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"),
                                                          type = "csv",
                                                          pattern = "LTER_integrated_attributes_USDA_2022-12-14.csv")

# download attributes table
googledrive::drive_download(file = traits_folder$id, overwrite = TRUE)

# find the filtered seed data in Google Drive
tidy_data_folder <- googledrive::drive_ls(googledrive::as_id("https://drive.google.com/drive/u/0/folders/1aPdQBNlrmyWKtVkcCzY0jBGnYNHnwpeE"),
                                                             type = "csv",
                                                             pattern = "filtered_seed_data.csv")

# download filtered seed data table
googledrive::drive_download(file = tidy_data_folder$id, overwrite = TRUE)

# read them in
LTER_integrated_attributes_USDA_2022_12_14 <- read_csv("LTER_integrated_attributes_USDA_2022-12-14.csv")
filtered_seed_data <- read_csv("filtered_seed_data.csv")

## ------------------------------------- ##
#           Wrangling Data ----
## ------------------------------------- ##

# filtering to BNZ only
filtered_seed_data_BNZ <- filtered_seed_data %>%
  filter(LTER.Site == "BNZ")

# filtering to BNZ only
seed_mass_BNZ <- LTER_integrated_attributes_USDA_2022_12_14 %>%
  filter(BNZ == 1) %>%
  select(species, Seed_mass_mg) %>%
  mutate(species = gsub(" ", ".", species),
         Seed_mass_g = Seed_mass_mg/1000) 

# combine the filtered seed data with attributes data
combined_BNZ <- left_join(filtered_seed_data_BNZ, seed_mass_BNZ, by = c("Species.Name" = "species")) %>%
  select(LTER.Site, Plot.ID, Trap.ID, Plant.ID, Species.Name, Year, Count, trap.area.m2, Seed_mass_g)

combined_BNZ_v2 <- combined_BNZ %>%
  # filtering to 3 plots only
  filter(Plot.ID %in% c("FP4A", "FP5A", "UP3A")) %>%
  group_by(Plot.ID, Species.Name, Year) %>%
  # summing seed count for each species within a plot for each year
  mutate(total_count = sum(Count), .after = Count) %>%
  ungroup() %>%
  # getting the number of seeds per meter squared
  mutate(num_seeds_per_m2 = total_count/trap.area.m2, .after = trap.area.m2) %>%
  select(-Trap.ID, -Count) %>%
  distinct() %>%
  # multiplying the number of seeds per meter squared with the seed mass
  mutate(g_seed_per_sp_per_year = round(num_seeds_per_m2*Seed_mass_g, 5)) %>%
  group_by(Plot.ID, Year) %>%
  # summing across species within a plot to get the total
  mutate(total_g_seed_per_year = sum(g_seed_per_sp_per_year)) %>%
  ungroup() %>%
  select(-LTER.Site, -Plant.ID) 

# split off the total seed mass production into a separate table for graphing purposes
total_for_each_plot <- combined_BNZ_v2 %>%
  select(Plot.ID, Year, total_g_seed_per_year) %>%
  distinct() %>%
  mutate(Species.Name = "total") %>%
  rename(g_seed_per_sp_per_year = total_g_seed_per_year)

# re-join the total seed mass production data for graphing purposes
combined_BNZ_v3 <- combined_BNZ_v2 %>%
  select(-total_g_seed_per_year) %>%
  bind_rows(total_for_each_plot)

## ------------------------------------- ##
#              Graphing ----
## ------------------------------------- ##

# plot the seed mass production by species
ggplot(combined_BNZ_v3, aes(x = Year, y = g_seed_per_sp_per_year)) +
  geom_line(aes(color = Species.Name)) +
  facet_grid(Plot.ID ~ .) +
  labs(title = "Seed mass production by species") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

