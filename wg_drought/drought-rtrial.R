# Drought WG Example R Workflow -------------------------------

# Written by: Angel Chen & Nick J Lyon

# Needed libraries
library(tidyverse); library(janitor); library(lubridate); library(WorldFlora)

# install.packages("devtools")
devtools::install_github("njlyon0/helpR")

# Clear environment
rm(list = ls())

# Grab working directory
myWD <- getwd()
myWD

# Retrieve Raw Data ----------------------------------------

# Identify every file in the folder
raw_full <- dir(file.path("data", "drought wg"))

# Identify all data types
data_type <- c("biomass", "cover", "plan", "sites", "taxa", "treatments")

# Make an empty list (we'll need it later)
raw_list <- list()

# Set working directory to data folder (would be set to Dropbox folder)
setwd(file.path("data", "drought wg"))

# For each data type...
for(type in data_type) {
  
  # Identify files of that data type
  data_list <- as.list(raw_full[str_detect(string = raw_full, pattern = type)])
  
  # Create index connecting integers to true filenames
  data_codes <- data.frame(filename = unlist(data_list)) %>%
    mutate(filecode = as.character(seq_along(filename)))
  
  # Do the following for each data type:
  data_v1 <- data_list %>%
    # Read in data
    purrr::map(.f = read.csv, colClasses = "character",
               blank.lines.skip = T) %>%
    # Bind them together preserving unique columns
    dplyr::bind_rows(.id = "filecode") %>%
    # Get filenames into a column
    dplyr::left_join(data_codes, by = "filecode") %>%
    # Ditch intermediary file code & any blank columns
    dplyr::select(-filecode, -starts_with('X', ignore.case = F)) %>%
    # Relocate filename before everything
    dplyr::relocate(filename, .before = everything()) %>%
    # Remove data type suffix from filename
    dplyr::mutate(filename = gsub(paste0("_", type), "", filename)) %>%
    # Remove rows that are entirely empty except filename
    filter(if_any(-filename, ~ nchar(.x) != 0))
  
  # Assign it to a list with the name of the data type
  raw_list[[type]] <- data_v1 }

# Re-set working directory broadly
setwd(myWD)

# Split out the taxa dataframe because it has different formatting
taxa_v1 <- raw_list[["taxa"]]

# Retrieve Site Codes --------------------------------

# Snag the site code lookup table 
site_lookup <- read_csv(file = "./Data/drought wg/Site_Elev-Disturb.csv",
                        show_col_types = F) %>%
  # While we're here, make the site names lowercase
  mutate(site_name = site_name)

# Identify all site names currently in the data (incl. typos)
raw_list[names(raw_list) != "taxa"] %>%
  purrr::map_dfr(select, site) %>%
  unique() %>%
  filter(site != "")

# Retrieve true site names from what was entered and get site codes
raw_list_v2 <- raw_list[names(raw_list) != "taxa"] %>%
  purrr::map(.f = mutate,
             site_name = case_when(
               # If site is in the correct site name lookup table, don't change it
               site %in% site_lookup$site_name ~ site,
               # Syntax: site_names == "WRONG" ~ "WHAT YOU WANT IT TO BE",
               site == "Cedar Creek sIDE" ~ "Cedar Creek Savanna",
               # site == "" ~ "",
               T ~ 'NOT INCLUDED IN FUNCTION'),
             .before = site) %>%
  purrr::map(.f = mutate,
             site_code = site_lookup$site_code[match(site_name, site_lookup$site_name)], .before = site) %>%
  # Re-name the site column to be clearer about its origins/status
  purrr::map(.f = rename, site_raw = site)

# Check to see if more `case_when()` conditions need adding
raw_list_v2 %>%
  purrr::map_dfr(select, site_raw, site_name) %>%
  unique() %>%
  filter(site_name == 'NOT INCLUDED IN FUNCTION')
## If anything is returned, add a new `case_when` condition to fix it

# Now split out the treatment, plan, and sites
sites_v1 <- raw_list_v2[["sites"]]
trt_v1 <- raw_list_v2[["treatments"]] %>%
  mutate(treatment_name = tolower(treatment_name))
plan_v1 <- raw_list_v2[["plan"]] %>%
  rename(treatment_name = treatment) %>%
  mutate(treatment_name = tolower(treatment_name))

# Combine plan and treatment for later use
design_v1 <- plan_v1 %>%
  dplyr::full_join(trt_v1, by = c('site_name', 'site_code', 'treatment_name')) %>%
  select(site_code, treatment_name, plot, first_appl) %>%
  unique()

# Identify Days Since Start ------------------------------------

# Identify all dates in the dataframe
raw_list_v2[names(raw_list_v2) == "biomass" | names(raw_list_v2) == "cover"] %>%
  purrr::map_dfr(.f = select, date) %>%
  unique()

# Identify days since first application
raw_list_v3 <- raw_list_v2[names(raw_list_v2) == "biomass" | names(raw_list_v2) == "cover"] %>%
  # First, standardize special characters
  purrr::map(.f = mutate, date_new = gsub("\\-", "/", date)) %>%
  # Separate year from rest of date
  purrr::map(mutate,
             date_year = str_extract(string = date_new, pattern = '[:digit:]{4}')) %>%
  # Make a date without the year info (that we just extracted)
  purrr::map(mutate,
             date_simp = str_replace(string = date_new, pattern = '[:digit:]{4}', replacement = '')) %>%
  # And separate out the month/day (or day/month) information
  purrr::map(mutate,
             date_simp2 = str_extract(string = date_simp, pattern = '[:digit:]{1,2}/[:digit:]{1,2}')) %>%
  purrr::map(separate, col = date_simp2, sep = '/', into = c("date_num1", "date_num2")) %>%
  # Make them both numeric
  purrr::map(mutate, date_num1 = as.numeric(date_num1),
             date_num2 = as.numeric(date_num2)) %>%
  # Count frequency of each number within files
  purrr::map(group_by, filename, date_num1) %>%
  # add_count(webinar_useful, name = "useful_freq") %>%
  purrr::map(add_count, name = "num1_freq") %>%
  # Group by other number and count it
  purrr::map(group_by, filename, date_num2) %>%
  purrr::map(add_count, name = "num2_freq") %>%
  # Then, un-group
  purrr::map(ungroup) %>%
  # Use those frequencies to identify month and day
  purrr::map(mutate,
             ## MONTH
             date_month = case_when(
               # If one number has more occurrences, it is the month
               num1_freq > num2_freq ~ date_num1,
               num1_freq < num2_freq ~ date_num2,
               # If they are equal (i.e., all sampling on one day)...
               ## ...and one is greater than 12, the other is month
               num1_freq == num2_freq & date_num1 > 12 & date_num2 <= 12 ~ date_num2,
               num1_freq == num2_freq & date_num1 <= 12 & date_num2 > 12 ~ date_num1,
               ##...and both numbers are less than 12 (this is the toughie)...
               num1_freq == num2_freq & date_num1 <= 12 & date_num2 <= 12 ~ date_num1
             ),
             ## DAY
             date_day = case_when(
               num1_freq > num2_freq ~ date_num2,
               num1_freq < num2_freq ~ date_num1,
               num1_freq == num2_freq ~ date_num2,
               num1_freq == num2_freq & date_num1 > 12 & date_num2 <= 12 ~ date_num1,
               num1_freq == num2_freq & date_num1 <= 12 & date_num2 > 12 ~ date_num2,
               num1_freq == num2_freq & date_num1 <= 12 & date_num2 <= 12 ~ date_num2
             )) %>%
  # Paste them together to become date
  purrr::map(mutate,
             date_fix_char = paste(date_day, date_month, date_year, sep = '/'),
             date_fix = lubridate::dmy(date_fix_char)) %>%
  # Drop intermediary columns
  purrr::map(select, -date_new, -date_simp, -date_num1, -date_num2, -num1_freq, -num2_freq, -date_month, -date_day, -date_fix_char) %>%
  # Identify first date for each site
  purrr::map(left_join, y = design_v1, by = c("site_code", "plot")) %>%
  # Make that column truly a date
  purrr::map(mutate, first_appl_date = lubridate::ymd(first_appl)) %>%
  # And find the difference between each date in the data and the first application
  purrr::map(mutate, n_treat_days = as.numeric(first_appl_date - date_fix),
             first_treatment_year = str_extract(string = first_appl_date, pattern = '[:digit:]{4}')) %>%
  # And finally, re-name the original date column more informatively
  purrr::map(rename, date_raw = date)

# Check structure
str(raw_list_v3)

# And look at new date columns
raw_list_v3[names(raw_list_v2) == "biomass" | names(raw_list_v2) == "cover"] %>%
  purrr::map_dfr(select, date_raw, date_fix, first_appl_date, n_treat_days) %>%
  unique()

# Split biomass and cover off
biomass_v1 <- as.data.frame(raw_list_v3[["biomass"]])
cover_v1 <- as.data.frame(raw_list_v3[["cover"]])

# Check Numeric Columns - Biomass & Cover ----------------------

# Check for non-numbers in biomass "mass" column
helpR::num_chk(data = biomass_v1, col = "mass")

# If any problems, fix them here


# Then re-check
helpR::num_chk(data = biomass_v1, col = "mass")

# Then make it (officially) numeric
biomass_v1$mass <- as.numeric(biomass_v1$mass)

# Check for non-numbers in cover "cover" column (same workflow)
helpR::num_chk(data = cover_v1, col = "cover")

helpR::num_chk(data = cover_v1, col = "cover")
cover_v1$cover <- as.numeric(cover_v1$cover)

# Tidy Taxa Information - Biomass -------------------------------

# Strip out the biomass data
biomass_v2 <- biomass_v1 %>%
  # Standardize it
  dplyr::mutate(taxa_fix = gsub("0|1|2|3|4|5|6|7|8|9| ", "", taxa)) %>%
  dplyr::mutate(taxa_fix = case_when(
    # Litter
    taxa_fix == "Dead" ~ "Litter",
    taxa_fix == "Deadold" ~ "Litter",
    # Forbs
    taxa_fix == "Forbs" ~ "Forb",
    # Graminoids
    taxa_fix == "Graminoids" ~ "Graminoid",
    taxa_fix == "Grass" ~ "Graminoid",
    taxa_fix == "Grasses" ~ "Graminoid",
    taxa_fix == "Sedge" ~ "Graminoid",
    taxa_fix == "Sedges" ~ "Graminoid",
    # Legumes
    taxa_fix == "Legumes" ~ "Legume",
    # Woody
    taxa_fix == "Shrub" ~ "Woody",
    taxa_fix == "Shrubleaves" ~ "Woody",
    taxa_fix == "Shrubs" ~ "Woody",
    # taxa_fix == "" ~ "",
    # If not specified, don't modify name
    T ~ taxa_fix) ) %>%
  # Group by everything except old taxa, mass, and notes
  dplyr::group_by(across(c(-taxa, -mass, -note_biomass))) %>%
  # Summarize through that
  dplyr::summarise(note_biomass = paste(note_biomass, collapse = '. '),
                   mass = sum(mass, na.rm = T) )

# Look at contents
unique(biomass_v2$taxa_fix)
summary(biomass_v2$mass)

# Tidy Taxa Information - Cover -------------------------

# Wrangle cover information (coarse)
cover_v2 <- cover_v1 %>%
  # Remove underscores (in favor of spaces)
  dplyr::mutate(taxa_fix = gsub("_", " ", taxa)) %>%
  # Make "spp." into "sp."
  dplyr::mutate(taxa_fix = gsub(" spp\\.", " sp.", taxa_fix)) %>%
  # Separate taxa into all possible components
  separate(col = taxa_fix, into = c("genus", "epithet", "extra_one", "extra_two", "extra_three", "extra_four", "extra_five"), sep = " ", extra = "warn", fill = "right") %>%
  # Remove the "extra" columns
  select(-starts_with("extra_")) %>%
  # And paste the remaining parts back together
  dplyr::mutate(taxa_data = paste(genus, epithet, sep = ' '))

# Look at unique products of that
cover_v2 %>%
  select(taxa_data, genus, epithet) %>%
  unique()

# Tidy Taxa Information - Taxa ---------------------------------

# Check out taxa dataframe
str(taxa_v1)

# Wrangle taxa information
taxa_v2 <- taxa_v1 %>%
  # Remove underscores (in favor of spaces)
  dplyr::mutate(taxa_fix = gsub("_", " ", taxa)) %>%
  # Make "spp." into "sp."
  dplyr::mutate(taxa_fix = gsub(" spp\\.", " sp.", taxa_fix)) %>%
  # Separate taxa into all possible components
  separate(col = taxa_fix, into = c("genus", "epithet", "extra_one", "extra_two", "extra_three", "extra_four", "extra_five"), sep = " ", extra = "warn", fill = "right") %>%
  # Remove the "extra" columns
  select(-starts_with("extra_")) %>%
  # And paste the remaining parts back together
  dplyr::mutate(taxa_data = paste(genus, epithet, sep = ' '))

# Look at unique products of that
taxa_v2 %>%
  select(taxa_data, genus, epithet) %>%
  unique()

# Wrangle WorldFlora Information -------------------------------

# Download WorldFlora Data (done only once)
# WFO.download(save.dir = file.path(myWD, 'Data', 'drought wg', 'WorldFlora'))
## Manually unzip it (if it's your first time) and continue

# Set R to remember WFO data
WFO.remember(file.path(myWD, 'Data', 'drought wg', 'WorldFlora', 'WFO_Backbone', 'classification.txt'))

# Now bind taxa and cover data together with the WFO data
wfo_cover_lookup <- WFO.match(WFO.data = WFO.data, spec.data = cover_v2$taxa_data, counter = 1, verbose = T)
wfo_taxa_lookup <- WFO.match(WFO.data = WFO.data, spec.data = taxa_v2$taxa_data, counter = 1, verbose = T)

# Process the lookup table to just what we need
wfo_cover_simp <- wfo_cover_lookup %>%
  dplyr::select(spec.name.ORIG, spec.name, family) %>%
  # Rename columns as desired
  dplyr::rename(taxa_data = spec.name.ORIG,
                taxa_wfo = spec.name,
                Family = family) %>%
  # Return only unique rows
  unique()

wfo_taxa_simp <- wfo_taxa_lookup %>%
  dplyr::select(spec.name.ORIG, spec.name, family) %>%
  dplyr::rename(taxa_data = spec.name.ORIG, taxa_wfo = spec.name, Family = family) %>%
  unique()

# Now join those lookup tables to the data named in their object names
cover_v3 <- cover_v2 %>%
  left_join(wfo_cover_simp, by = "taxa_data")
taxa_v3 <- taxa_v2 %>%
  left_join(wfo_taxa_simp, by = "taxa_data")

# Now, using the reliable WFO taxa, bring the taxa_v3 info into cover_v3
cover_v4 <- cover_v3 %>%
  left_join(taxa_v3, by = c("filename", "taxa_wfo")) %>%
  # Remove any column ending with ".y" (i.e., "duplicate" col from taxa_v3)
  select(-ends_with('.y'), -taxa.x) %>%
  # Re-order/remove additional columns
  select(filename, site_name, site_code, plot, subplot, date_year,
         first_treatment_year, first_appl_date, date_fix, 
         n_treat_days, treatment_name, family, taxa_wfo,
         provenance, lifeform, lifespan) %>%
  # Re-name some of these columns
  rename(year = date_year, first_treatment_date = first_appl_date,
         cover_date = date_fix, trt = treatment_name,
         Taxon = taxa_wfo, local_provenance = provenance,
         local_lifeform = lifeform, local_lifespan = lifespan)

# One last look :')
names(cover_v4)

# Export Tidy Data -------------------------------------

# Write out "final" files
write.csv(x = cover_v4, row.names = F,
          file = file.path("data", "drought_cover.csv"))
write.csv(x = biomass_v2, row.names = F,
          file = file.path("data", "drought_biomass.csv"))
write.csv(x = plan_v1, row.names = F,
          file = file.path("data", "drought_plan.csv"))
write.csv(x = trt_v1, row.names = F,
          file = file.path("data", "drought_treatment.csv"))
write.csv(x = taxa_v3, row.names = F,
          file = file.path("data", "drought_taxa.csv"))
write.csv(x = sites_v1, row.names = F,
          file = file.path("data", "drought_sites.csv"))

# End ----
