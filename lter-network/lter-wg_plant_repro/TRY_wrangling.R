## ----------------------------------------------------- ##
                # Pre-Analysis TRY Wrangling
## ----------------------------------------------------- ##
# Written by Angel Chen & Nick Lyon

## --------------------------------- ##
          # Housekeeping ----
## --------------------------------- ##
# Load packages
# install.packages("librarian")
librarian::shelf(rtry, googledrive, data.table, tidyverse, supportR)

# Clear environment
rm(list = ls())

# Read in original TRY data
TRYdata <- rtry::rtry_import(input = file.path("traits", "TRY_request-1_public-only.txt"))

# And the fruit data
TRYfruits <- rtry::rtry_import(input = file.path("traits", "Try_fruit-request_public-only.txt"))

## --------------------------------- ##
 # Main Request - Initial Tweaks ----
## --------------------------------- ##
# Perform initial wrangling
TRYdata2 <- TRYdata %>%
  # Filter to the traits we want
  dplyr::filter(TraitID %in% c(205, 213, 915, 99, 59, 347, 343, 335, 29, 26, 2807)) %>%
  # Drop duplicate rows
  dplyr::distinct() %>%
  # select only relevant columns
  dplyr::select(AccSpeciesName, TraitName, DataName, OrigValueStr, OrigUnitStr) %>%
  # also fix some funny characters in OrigValueStr
  dplyr::mutate(OrigValueStr = case_when(
    OrigValueStr == "disk flowers with nectar \xb1 hidden in centre of flower" ~ "disk flowers with nectar hidden in centre of flower",
    OrigValueStr == "poly-annuals < 5 years (short-lived perennials)" ~ "poly-annuals less than 5 years (short-lived perennials)",
    OrigValueStr == "other|polygamodioecy" ~ "other/polygamodioecy",
    OrigValueStr == "long lived perennial >= 50 yrs." ~ "long lived perennial greater than or equal 50 yrs.",
    TRUE ~ OrigValueStr)) %>%
  # filter out the rows with nothing in OrigValueStr
  dplyr::filter(nchar(OrigValueStr) != 0) %>%
  # simplify species name
  tidyr::separate(col = AccSpeciesName,
                  into = c("genus", "epithet", "extra"),
                  fill = "right", extra = "merge", sep = " ") %>%
  # reassemble species name and drop "extra" column
  dplyr::mutate(species = paste(genus, epithet), .before = everything()) %>%
  dplyr::select(-extra) %>%
  # convert month numbers to characters
  dplyr::mutate(OrigValueStr = case_when(
    OrigUnitStr == "month" & OrigValueStr == "1" ~ "Jan",
    OrigUnitStr == "month" & OrigValueStr == "2" ~ "Feb",
    OrigUnitStr == "month" & OrigValueStr == "3" ~ "Mar",
    OrigUnitStr == "month" & OrigValueStr == "4" ~ "Apr",
    OrigUnitStr == "month" & OrigValueStr == "5" ~ "May",
    OrigUnitStr == "month" & OrigValueStr == "6" ~ "Jun",
    OrigUnitStr == "month" & OrigValueStr == "7" ~ "Jul",
    OrigUnitStr == "month" & OrigValueStr == "8" ~ "Aug",
    OrigUnitStr == "month" & OrigValueStr == "9" ~ "Sep",
    OrigUnitStr == "month" & OrigValueStr == "10" ~ "Oct",
    OrigUnitStr == "month" & OrigValueStr == "11" ~ "Nov",
    OrigUnitStr == "month" & OrigValueStr == "12" ~ "Dec",
    TRUE ~ OrigValueStr))
  
# Take a quick look at this object
dplyr::glimpse(TRYdata2)

# checking to see if there are any more funny characters
supportR::num_check(data = TRYdata2, col = "OrigValueStr")

# split TRY data into a dataframe where OrigValueStr consists of all letters
TRYdata3A <- TRYdata2 %>%
  dplyr::filter(suppressWarnings(is.na(as.numeric(OrigValueStr))) == TRUE) %>%
  dplyr::mutate(OrigValueStr = tolower(OrigValueStr)) %>%
  unique()

# split TRY data into a dataframe where OrigValueStr consists of all numbers
TRYdata3B <- TRYdata2 %>%
  dplyr::filter(suppressWarnings(is.na(as.numeric(OrigValueStr))) == FALSE)

# Double check that this worked
supportR::num_check(data = TRYdata3B, col = "OrigValueStr")

## --------------------------------- ##
  # Main Request - Characters ----
## --------------------------------- ##
# Look at data names
unique(TRYdata3A$DataName)

# Standardize this object
TRYdata3A_v2 <- TRYdata3A %>%
  # filter out the "not applicable" and "not available" values
  dplyr::filter(!tolower(OrigValueStr) %in% c("not applicable", "not available") & 
         !DataName %in% c("Plant phenology: Annual", "Plant phenology: Biennial", "Plant phenology: Perennial")) %>%
  # fix the trait names
  dplyr::mutate(trait_fixed = dplyr::case_when(
    DataName %in% c("Plant life form (Raunkiaer life form)") ~ "plant_life_form",
    DataName %in% c("Plant life span") ~ "plant_lifespan",
    DataName %in% c("Onset of flowering (first flowering date, beginning of flowering period)") ~ "flowering_begin",
    DataName %in% c("End of flowering") ~ "flowering_end",
    DataName %in% c("Flower sexual system", "Dicliny (monoeceous, dioecious, hermaphrodite)") ~ "flower_sexual_system",
    DataName %in% c("Apomixis") ~ "apomixis",
    DataName %in% c("Flower: pollinator and type of reward", "Pollination syndrome (pollen vector)", "Pollination syndrom 2") ~ "pollinator",
    DataName %in% c("Flower type") ~ "flower_type",
    DataName %in% c("Fruit type") ~ "fruit_type",
    DataName %in% c("Fruit/Seed Period Begin", "Seed shedding season (time of seed dispersal)") ~ "fruit_seed_begin",
    DataName %in% c("Fruit/Seed Period End") ~ "fruit_seed_end",
    DataName %in% c("Fruit/Seed Persistence") ~ "fruit_seed_persist",
    DataName %in% c("Plant lifespan, longevity, plant maximum age", "Perennation 1 (plant age)", "Perenniality") ~ "perenniality",
    DataName %in% c("Flowering season", "Flowering Period Length (duration of flowering period)", "Flowering periode: peak month") ~ "flowering_season",
    DataName %in% c("Time (season) of germination (seedling emergence)") ~ "germination_season"
  ), .before = DataName) %>%
  dplyr::select(-DataName, -TraitName) %>%
  # make the values and units into lowercase
  dplyr::mutate(OrigValueStr = tolower(OrigValueStr),
         OrigUnitStr = tolower(OrigUnitStr)) %>%
  unique() %>%
  # fix the trait units
  dplyr::mutate(trait_units = ifelse(test = nchar(OrigUnitStr) == 0 |
                                       is.na(OrigValueStr), 
                              yes = trait_fixed,
                              no = paste0(trait_fixed, "_", OrigUnitStr))) %>%
  dplyr::select(-OrigUnitStr, -trait_fixed, -genus, -epithet) %>%
  # collapse the values into one string for each species/trait combo
  dplyr::group_by(species, trait_units) %>%
  dplyr::summarize(value_entry = paste(OrigValueStr, collapse ="; ")) %>%
  # Ungroup
  dplyr::ungroup()

# checking to make sure everything looks ok
glimpse(TRYdata3A_v2)
unique(TRYdata3A_v2$trait_units)

# convert to wide format
TRYdata3A_wide <- TRYdata3A_v2 %>%
  pivot_wider(names_from = "trait_units", values_from = "value_entry")

# export csv
write.csv(x = TRYdata3A_wide, row.names = F, na = '',
          file = file.path("traits", "TRYdata_qualitative_wide.csv"))

# upload csv to google drive
googledrive::drive_upload(media = file.path("traits", "TRYdata_qualitative_wide.csv"), 
             name = "TRYdata_qualitative_wide.csv",
             path = googledrive::as_id("https://drive.google.com/drive/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"),
             overwrite = T)

## --------------------------------- ##
    # Main Request - Numbers ----
## --------------------------------- ##
# Tweak as needed
TRYdata3B_v2 <- TRYdata3B %>%
  dplyr::select(-genus, -epithet) %>%
  # filter out the "extreme" values
  dplyr::filter(DataName != "Plant lifespan (longevity) extreme") %>%
  # convert OrigValueStr to numeric so we can do some math on it
  dplyr::mutate(OrigValueStr = as.numeric(OrigValueStr)) %>%
  # fix the trait names
  dplyr::mutate(trait_fixed = dplyr::case_when(
    DataName %in% c("Plant lifespan (longevity) min", "Plant lifespan (longevity) max", "Plant lifespan, longevity, plant maximum age", 
                    "Plant life span", "Plant longevity") ~ "plant_lifespan",
    DataName %in% c("Seed mass original value: min", "Seed mass original value: max", "Seed mass min", "Seed mass max", 
                    "Seed mass", "Seed mass original value: mean") ~ "seed_mass",
    DataName %in% c("Seed dry mass") ~ "seed_dry_mass",
    DataName %in% c("Onset of flowering (first flowering date, beginning of flowering period)") ~ "flowering_begin",
    DataName %in% c("Flowering season") ~ "flowering_season",
    DataName %in% c("Plant life form (Raunkiaer life form)") ~ "plant_life_form"
    
  ), .before = DataName) %>%
  dplyr::select(-TraitName, -DataName) %>%
  # convert the trait units
  dplyr::mutate(converted_value = dplyr::case_when(
    OrigUnitStr == "mg" ~ OrigValueStr/1000,
    OrigUnitStr == "gr" ~ OrigValueStr,
    OrigUnitStr == "g / 1000 seeds" ~ OrigValueStr/1000,
    OrigUnitStr %in% c("1/lb", "1/pound") ~ OrigValueStr*2.2,
    TRUE ~ OrigValueStr)) %>%
  # consolidate the trait units
  dplyr::mutate(converted_unit = dplyr::case_when(
    OrigUnitStr %in% c("mg", "gr", "g / 1000 seeds") ~ "g",
    OrigUnitStr %in% c("years", "yr", "yrs") ~ "year",
    OrigUnitStr %in% c("1/lb", "1/pound", "1/kg") ~ "1_per_kg",
    OrigUnitStr == "doy" ~ "day_of_year",
    TRUE ~ OrigUnitStr)) %>%
  select(-starts_with("Orig")) %>%
  # attach the name of the unit to the trait name
  dplyr::mutate(trait_units = paste0(trait_fixed, "_", converted_unit)) %>%
  dplyr::select(-trait_fixed, -converted_unit) %>%
  # calculate the mean across all species/trait combos
  dplyr::group_by(species, trait_units) %>%
  dplyr::summarize(value_entry = mean(converted_value, na.rm = T)) %>%
  dplyr::ungroup()
  
# checking to make sure everything looks ok
dplyr::glimpse(TRYdata3B_v2)

# convert to wide format
TRYdata3B_wide <- TRYdata3B_v2 %>%
  tidyr::pivot_wider(names_from = "trait_units",
                     values_from = "value_entry")

# export csv
write.csv(x = TRYdata3B_wide, row.names = F, na = "",
          file = file.path("traits", "TRYdata_quantitative_wide.csv"))

# upload csv to google drive
googledrive::drive_upload(media = file.path("traits", "TRYdata_quantitative_wide.csv"),
                          name = "TRYdata_quantitative_wide.csv",
                          path = googledrive::as_id("https://drive.google.com/drive/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"),
                          overwrite = T)

## --------------------------------- ##
 # Fruit Request - Initial Tweaks ----
## --------------------------------- ##

# Check out data
dplyr::glimpse(TRYfruits)

# Do needed wrangling
TRYfruits2 <- TRYfruits %>%
  # Filter to only traits we asked for
  dplyr::filter(TraitID %in% c(99, 2939, 4076, 3981)) %>%
  # Drop duplicate rows
  dplyr::distinct() %>%
  # Select only relevant columns
  dplyr::select(AccSpeciesName, TraitName, OrigValueStr, OrigUnitStr) %>%
  # also fix some funny characters in OrigValueStr
  # filter out the rows with nothing in OrigValueStr
  dplyr::filter(nchar(OrigValueStr) != 0 & 
                  OrigValueStr != "missing") %>%
  # simplify species name
  tidyr::separate(col = AccSpeciesName,
                  into = c("genus", "epithet", "extra"),
                  fill = "right", extra = "merge", sep = " ") %>%
  # reassemble species name and drop "extra" column
  dplyr::mutate(species = paste(genus, epithet), 
                .before = everything()) %>%
  dplyr::select(-extra) %>%
  # Clean up two non-numeric entries
  dplyr::mutate(OrigValueStr = dplyr::case_when(
    OrigValueStr == "Berry" ~ "berry",
    OrigValueStr == "(partly) fleshy" ~ "partly fleshy",
    TRUE ~ OrigValueStr)) %>%
  # Now tidy the trait values
  dplyr::mutate(TraitName = dplyr::case_when(
    TraitName == "Fruit type" ~ "fruit_type",
    TraitName == "Fruit pericarp type" ~ "fruit_pericarp_type",
    TraitName == "Fruit fresh mass" ~ "fruit_fresh_mass",
    TRUE ~ TraitName)) %>%
  # And append units if any are provided
  dplyr::mutate(TraitName = ifelse(
    test = nchar(OrigUnitStr) != 0,
    yes = paste(TraitName, OrigUnitStr, sep = "_"),
    no = TraitName)) %>%
  dplyr::select(-OrigUnitStr) %>%
  # Keep only unique values
  unique() %>%
  # Assign a new column for whether each row is a numeric or character
  dplyr::mutate(format = ifelse(
    test = is.na(suppressWarnings(as.numeric(OrigValueStr))) == TRUE,
    yes = "char",
    no = "num"))
  
# Glimpse that
dplyr::glimpse(TRYfruits2)

# Look at only values that aren't numbers
supportR::num_check(data = TRYfruits2, col = "OrigValueStr")
unique(TRYfruits2$TraitName)

## --------------------------------- ##
  # Fruit Request - Characters ----
## --------------------------------- ##
# Now we want to reshape this object to summarize
TRYfruits3A <- TRYfruits2 %>%
  # Filter to only characters
  dplyr::filter(format == "char") %>%
  # Drop format column
  dplyr::select(-format) %>%
  # Pivot wider
  tidyr::pivot_wider(names_from = TraitName,
                     values_from = OrigValueStr)

# Glimpse
dplyr::glimpse(TRYfruits3A)

# Export as a csv
write.csv(x = TRYfruits3A, row.names = F, na = '',
          file = file.path("traits", "TRYfruits_qualitative_wide.csv"))

# upload csv to google drive
googledrive::drive_upload(media = file.path("traits", "TRYfruits_qualitative_wide.csv"), 
                          name = "TRYfruits_qualitative_wide.csv",
                          path = googledrive::as_id("https://drive.google.com/drive/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"),
                          overwrite = T)

## --------------------------------- ##
    # Fruit Request - Numbers ----
## --------------------------------- ##
# Now we want to reshape this object to summarize
TRYfruits3B <- TRYfruits2 %>%
  # Filter to only characters
  dplyr::filter(format == "num") %>%
  # Drop format column
  dplyr::select(-format) %>%
  # Average within species (across multiple observations)
  ## Lose *a lot* of rows because only four species include info
  dplyr::group_by(species, genus, epithet, TraitName) %>%
  dplyr::summarize(mean_value = mean(as.numeric(OrigValueStr),
                                     na.rm = TRUE)) %>%
  dplyr::ungroup() %>%
  # Pivot wider
  tidyr::pivot_wider(names_from = TraitName,
                     values_from = mean_value)

# Glimpse
dplyr::glimpse(TRYfruits3B)

# Export as a csv
write.csv(x = TRYfruits3B, row.names = F, na = '',
          file = file.path("traits", "TRYfruits_quantitative_wide.csv"))

# upload csv to google drive
googledrive::drive_upload(media = file.path("traits", "TRYfruits_quantitative_wide.csv"), 
                          name = "TRYfruits_quantitative_wide.csv",
                          path = googledrive::as_id("https://drive.google.com/drive/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"),
                          overwrite = T)

# End ----
