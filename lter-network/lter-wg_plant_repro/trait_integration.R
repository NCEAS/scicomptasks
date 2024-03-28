## -------------------------------------------------- ##
      # Combine Attributes Table & TRY Data
## -------------------------------------------------- ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, googledrive, readxl, stringr)

# Clear environment
rm(list = ls())

# Make a folder to save to if it doesn't exist already
dir.create(path = "trait_files", showWarnings = F)

## ------------------------------------- ##
            # Housekeeping ----
## ------------------------------------- ##
# List all files in 
traits_folder <- googledrive::drive_ls(googledrive::as_id("https://drive.google.com/drive/u/0/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"))

# Name the files we want
wanted_files <- c(
  # No.1: traits GoogleSheet
  "LTER_Attributes_USDA_Oct2022", 
  # No.2-3: TRY request (first)
  "TRYdata_qualitative_wide.csv", 
  "TRYdata_quantitative_wide.csv"
  # No.4-5: TRY fruit data request
#  "TRYfruits_qualitative_wide.csv",
#  "TRYfruits_quantitative_wide.csv"
    )

# Download these files
for(file in wanted_files){
  
  # Identify the file
  file_id <- traits_folder %>%
    dplyr::filter(name == file)
  
  # Download it
  googledrive::drive_download(file = googledrive::as_id(file_id),
                              path = file.path("trait_files",
                                               file_id$name),
                              overwrite = TRUE)
  
}

# Read them in!
att <- readxl::read_xlsx(path = file.path("trait_files", paste0(wanted_files[1], ".xlsx")))
try_qual <- read.csv(file = file.path("trait_files", wanted_files[2]))
try_quant <- read.csv(file = file.path("trait_files", wanted_files[3]))
#fruit_qual <- read.csv(file = file.path("trait_files", wanted_files[4]))
#fruit_quant <- read.csv(file = file.path("trait_files", wanted_files[5]))

# Take a look
dplyr::glimpse(att)
dplyr::glimpse(try_qual)
dplyr::glimpse(try_quant)
#dplyr::glimpse(fruit_qual)
#dplyr::glimpse(fruit_quant)

## ------------------------------------- ##
         # Prep for Integration ----
## ------------------------------------- ##
# Define undesireable species
undesirables <- c("Abies balsamea", "Acer negundo", "Acer pensylvanicum", "Betula lenta", "Betula papyrifera", "Carpinus caroliniana", "Casearia guianensis", "Cercis canadensis", "Frangula caroliniana", "Hamamelis virginiana", "Liquidambar styraciflua", "Ostrya virginiana", "Picea rubens", "Pinus contorta", "Pinus flexilis", "Pinus rigida", "Pinus strobus", "Piper glabrescens", "Platanus occidentalis", "Prunus virginiana", "Quercus coccinea", "Quercus falcata", "Quercus michauxii", "Quercus velutina", "Sambucus canadensis", "Sassafras albidum", "Solanum rugosum", "Sorbus americana", "Thuja occidentalis", "Ulmus americana", "Viburnum lantanoides", "Viburnum nudum")

# Standardize
try_qual_v2 <- try_qual %>%
  # Drop unwanted species
  dplyr::filter(!species %in% undesirables) %>%
  # Pivot long
  tidyr::pivot_longer(col = -species,
                      names_to = "columns",
                      values_to = "entries") %>%
  # Add good info to columns
  dplyr::mutate(columns = paste0("TRY_qual_", columns)) %>%
  # Pivot back to wide format
  tidyr::pivot_wider(names_from = columns,
                     values_from = entries) %>%
  # Make REF columns
  dplyr::mutate(TRY_qual_flowering_season_REF = ifelse(
    test = nchar(TRY_qual_flowering_season) == 0,
    yes = NA, no = "TRY_Kattge_etal_2020"), 
    .after = TRY_qual_flowering_season) %>%
  dplyr::mutate(TRY_qual_fruit_seed_persist_REF = ifelse(
    test = nchar(TRY_qual_fruit_seed_persist) == 0,
    yes = NA, no = "TRY_Kattge_etal_2020"), 
    .after = TRY_qual_fruit_seed_persist)

# Process
try_quant_v2 <- try_quant %>%
  # Drop unwanted species
  dplyr::filter(!species %in% undesirables) %>%
  # Pivot long
  tidyr::pivot_longer(col = -species,
                      names_to = "columns",
                      values_to = "entries") %>%
  # Fix a weird issue with some of the col names
  dplyr::mutate(columns = dplyr::case_when(
    columns == "plant_life_form_" ~ "plant_life_form",
    columns == "plant_lifespan_" ~ "plant_lifespan",
    TRUE ~ columns)) %>%
  # Add good info to columns
  dplyr::mutate(columns = paste0("TRY_quant_", columns)) %>%
  # Pivot back to wide format
  tidyr::pivot_wider(names_from = columns,
                     values_from = entries) %>%
  # Make REF columns
  dplyr::mutate(TRY_quant_seed_dry_mass_REF = ifelse(
    test = nchar(TRY_quant_seed_dry_mass_g) == 0,
    yes = NA, no = "TRY_Kattge_etal_2020"), .after = TRY_quant_seed_dry_mass_g) %>%
  dplyr::mutate(TRY_quant_plant_lifespan_year_REF = ifelse(
    test = nchar(TRY_quant_plant_lifespan_year) == 0,
    yes = NA, no = "TRY_Kattge_etal_2020"), .after = TRY_quant_plant_lifespan_year)

# Standardize fruit pull
# fruit_qual_v2 <- fruit_qual %>%
#   # Drop genus/epithet columns
#   dplyr::select(-genus, -epithet) %>%
#   # Add references
#   dplyr::mutate(fruit_type_REF = ifelse(
#     test = nchar(fruit_type) == 0, yes = NA, 
#     no = "TRY_Kattge_etal_2020"), .after = fruit_type) %>%
#   dplyr::mutate(fruit_pericarp_type_REF = ifelse(
#     test = nchar(fruit_pericarp_type) == 0, yes = NA, 
#     no = "TRY_Kattge_etal_2020"), .after = fruit_pericarp_type)

# Fruit quantitative processing
# fruit_quant_v2 <- fruit_quant %>%
#   # Drop genus/epithet columns
#   dplyr::select(-genus, -epithet) %>%
#   # Add references
#   dplyr::mutate(fruit_fresh_mass_REF = "TRY_Kattge_etal_2020")

## ------------------------------------- ##
              # Integrate! ----
## ------------------------------------- ##

# Combine them!
all_traits_v1 <- att %>%
  # Attach qualitative information
  dplyr::left_join(try_qual_v2, by = "species") %>%
  # Attach quantitative too
  dplyr::left_join(try_quant_v2, by = "species") #%>%
  # Attach fruit qualitative
#  dplyr::left_join(fruit_qual_v2, by = "species") %>%
  # Attach fruit quantitative
#  dplyr::left_join(fruit_quant_v2, by = "species")

# Take a lightning fast look
dplyr::glimpse(all_traits_v1)

## ------------------------------------- ##
      # Further Collapse Traits ----
## ------------------------------------- ##

# Final standardization
all_traits <- all_traits_v1 %>%
  # Filter to only spp in data
  dplyr::filter(included_in_data == 1) %>%
  # Do special unit conversions
  dplyr::mutate(TRY_quant_seed_dry_mass_mg = TRY_quant_seed_dry_mass_g * 1000, .before = TRY_quant_seed_dry_mass_g) %>%
  # Drop unwanted values
  dplyr::select(-included_in_data, -TRY_quant_plant_lifespan, -TRY_quant_flowering_season_month, -TRY_quant_seed_mass_g,	-TRY_quant_plant_life_form, -TRY_quant_seed_dry_mass_g, -TRY_quant_flowering_season_day_of_year, -TRY_quant_flowering_begin_month, -TRY_quant_seed_dry_mass_1_per_kg,	-TRY_quant_seed_mass_1_per_kg, -TRY_qual_fruit_type, -TRY_qual_flowering_begin_month, -TRY_qual_flower_type, -TRY_qual_apomixis, -TRY_qual_germination_season, -TRY_qual_flowering_end_month,	-TRY_qual_flowering_season_month, -TRY_quant_seed_mass_1_per_kg, -TRY_quant_seed_dry_mass_1_per_kg, -TRY_qual_plant_life_form, -TRY_qual_flowering_end_month, -TRY_qual_flowering_season_month, -TRY_qual_germination_season, -TRY_qual_apomixis, -TRY_qual_flower_type, -TRY_qual_flowering_begin_month, -TRY_qual_fruit_type, -TRY_qual_perenniality, -TRY_qual_plant_lifespan, -TRY_qual_fruit_seed_begin, -TRY_qual_fruit_seed_end, -Seeds_per_lb, -Seeds_per_lb_REF, -TRY_qual_flower_sexual_system) %>%
  # Fix the seedbank (seed persistence) issue
  dplyr::mutate(TRY_qual_fruit_seed_persist = ifelse(
    test = species %in% c("Cecropia schreberiana", "Picea mariana", "Pinus contorta", "Pinus rigida", "Prunus virginiana", "Amelanchier arborea", "Acer rubrum", "Betula alleghanienesis", "Betula papyrifera", "Nyssa sylvatica", "Robinia pseudoacacia", "Sassafras albidum"),
    yes = "yes", no = TRY_qual_fruit_seed_persist)) %>%
  # Coalesce columns
  dplyr::mutate(
    trait_seed_mass_mg = coalesce(TRY_quant_seed_dry_mass_mg, as.numeric(Seed_mass_mg)),
    trait_lifespan_years = coalesce(TRY_quant_plant_lifespan_year, Lifespan_yrs),
    trait_flowering_season = coalesce(Flowering_season, TRY_qual_flowering_season),
    trait_fruit_seed_persist = coalesce(Fruit_seed_persist, TRY_qual_fruit_seed_persist)) %>%
  # Coalesce the REF columns
  dplyr::mutate(
    trait_seed_mass_mg_REF = coalesce(TRY_quant_seed_dry_mass_REF, Seed_mass_REF),
    trait_lifespan_years_REF = coalesce(TRY_quant_plant_lifespan_year_REF, Lifespan_yrs_REF),
    trait_flowering_season_REF = coalesce(Flowering_season_REF, TRY_qual_flowering_season_REF),
    trait_fruit_seed_persist_REF = coalesce(Fruit_seed_persist_REF, TRY_qual_fruit_seed_persist_REF)) %>%
  # Rename some columns
  dplyr::rename(Sexual_system = Monoecious_or_Dioecious,
                Sexual_system_REF = Monoecious.or.Dioecious_REF) %>%
  # Drop coalesced columns
  dplyr::select(-TRY_quant_seed_dry_mass_mg, -Seed_mass_mg, -TRY_quant_plant_lifespan_year, -Lifespan_yrs, -TRY_qual_pollinator, 
                -Flowering_season, -TRY_qual_flowering_season, -Fruit_seed_persist, -TRY_qual_fruit_seed_persist,
                -TRY_quant_seed_dry_mass_REF, -Lifespan_yrs_REF, -TRY_quant_plant_lifespan_year_REF, -Seed_mass_REF, 
                -Flowering_season_REF, -TRY_qual_flowering_season_REF, -Fruit_seed_persist_REF, -TRY_qual_fruit_seed_persist_REF) %>%
  # Even more fine-tuning after office hours on Oct 19, Oct 26, Nov 9 2022
  # Rename some columns
  dplyr::rename(AND = Andrews,
                ADK = Adirondack,
                CDR = CedarCreek,
                HBR = HubbardBrook,
                CWT = Coweeta,
                HFR = Harvard,
                BNZ = Bonanza,
                SEV = Sevilleta,
                LUQ = Luquillo,
                Seed_development_1_2or3yrs = Seed_development_2yrsOR3yrs,
                Seed_development_1_2or3yrs_REF = Seed_development_2yrsOR3yrs_REF,
                Growth_form = GrowthForm,
                Growth_form_REF = GrowthForm_REF,
                Growth_habit = Growth.Habit,
                Seed_mass_mg = trait_seed_mass_mg,
                Lifespan_years = trait_lifespan_years,
                Flowering_season = trait_flowering_season,
                Seed_bank = trait_fruit_seed_persist,
                Seed_mass_REF = trait_seed_mass_mg_REF,
                Lifespan_years_REF = trait_lifespan_years_REF,
                Flowering_season_REF = trait_flowering_season_REF,
                Seed_bank_REF = trait_fruit_seed_persist_REF) %>%
  # Making a REF column that was missing from the LTER_Attributes_USDA_Oct2022 googlesheet
  dplyr::mutate(Growth_habit_REF = ifelse(
    test = nchar(Growth_habit) == 0,
    yes = NA, no = "Pearse, I (pers comm)"), .after = Growth_habit) %>%
  # Fine-tuning the REF column even more
  dplyr::mutate(Growth_habit_REF = ifelse(
    test = species == "Clusia gundlachii" | species == "Clusia rosea",
    yes = "Zimmerman (pers comm)", no = Growth_habit_REF)) %>%
  # Relocating some REF columns
  dplyr::relocate(Lifespan_years, .after = Seed_Maturation_Phenology_REF) %>%
  dplyr::relocate(Lifespan_years_REF, .after = Lifespan_years) %>%
  dplyr::relocate(Seed_mass_mg, .after = Lifespan_years_REF) %>%
  dplyr::relocate(Seed_mass_REF, .after = Seed_mass_mg) %>%
  dplyr::relocate(Flowering_season_REF, .after = Flowering_season) %>%
  dplyr::relocate(Seed_bank_REF, .after = Seed_bank) %>%
  dplyr::relocate(Fleshy_fruit, .after = Seed_bank_REF) %>%
  dplyr::relocate(Fleshy_fruit_REF, .after = Fleshy_fruit) %>%
  dplyr::relocate(Dispersal_syndrome, .after = Fleshy_fruit_REF) %>%
  dplyr::relocate(Dispersal_syndrome_REF, .after = Dispersal_syndrome) %>%
  # If "wind" is detected in Pollinator_vector, then we put "wind" in Pollinator_code. Otherwise, we put "animal"
  dplyr::mutate(Pollinator_code = ifelse(
    test = str_detect(Pollinator_vector, "wind"),
    yes = "wind", no = "animal"), .after = Pollinator_vector) %>%
  # If "wind" is detected in Seed_dispersal_vector, then we put "wind" in Seed_dispersal_code. If it's "water" then we put "water". Otherwise, we put "animal"
  dplyr::mutate(Seed_dispersal_code = case_when(
    str_detect(Seed_dispersal_vector, "wind") ~ "wind",
    Seed_dispersal_vector == "water" ~ "water", 
    TRUE ~ "animal"), .after = Seed_dispersal_vector) %>%
  # Capitalize the values in Shade_tolerance
  dplyr::mutate(Shade_tolerance = str_to_title(Shade_tolerance)) %>%
  # Replace the blank values in Flowering_season with NA's
  dplyr::mutate(Flowering_season = ifelse(
    test = nchar(Flowering_season) == 0,
    yes = NA, no = Flowering_season)) %>%
  # Add some common names
  dplyr::mutate(common = ifelse(
    test = species == "Quercus ellipsoidalis",
    yes = "northern pin oak", no = common)) %>%
  dplyr::mutate(common = ifelse(
    test = species == "Quercus macrocarpa",
    yes = "bur oak", no = common))

# Glimpse it
dplyr::glimpse(all_traits)

## ------------------------------------- ##
                # Export ----
## ------------------------------------- ##

# Name exported file
(file_name <- paste0("LTER_integrated_attributes_USDA_", Sys.Date(), ".csv"))

# Write the CSV
write.csv(x = all_traits, row.names = F, na = "",
          file.path("trait_files", file_name))

# And upload to google!
googledrive::drive_upload(media = file.path("trait_files", file_name),
             name = file_name, overwrite = T,
             path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"))

# End ----
