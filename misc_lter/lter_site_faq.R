## -------------------------------------------------- ##
                 # LTER Site FAQ
## -------------------------------------------------- ##
# Script author(s): Nick J Lyon

# PURPOSE:
## Wrangle LTER site information and create frequently-requested products
## LTER = Long Term Ecological Research
## FAQ = Frequently Asked Questions

## ------------------------------ ##
        # Housekeeping ----
## ------------------------------ ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, googledrive, purrr, supportR)

# Clear environment
rm(list = ls())

# Authorize googledrive
googledrive::drive_auth()

## ------------------------------ ##
      # Data Acquisition ----
## ------------------------------ ##

# List all files in relevant Drive folder
site_drive <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/12rNziwHWrnBp-hjSraAqL-9M-eXi7MTT")) %>%
  # Filter to only desired files
  dplyr::filter(name %in% c("site-start-end-dates-only.csv"))

# Create a folder for these locally
dir.create(path = file.path("data"), showWarnings = F)

# Download both files
purrr::walk2(.x = site_drive$name, .y = site_drive$id,
             .f = ~ googledrive::drive_download(file = .y, overwrite = T,
                                                path = file.path("data", .x)))

## ------------------------------ ##
# Wrangling ----
## ------------------------------ ##

# Read in the site start/end dates
site_dates_v1 <- read.csv(file = file.path("data", "site-start-end-dates-only.csv")) %>%
  # Drop empty columns
  dplyr::select(-dplyr::starts_with("X"))

# Check structure
dplyr::glimpse(site_dates_v1)

# Load coordinate information
site_coords_v1 <- read.csv(file = file.path("data", "Site-list.csv"))


# Check structure
dplyr::glimpse(site_coords_v1)


# End ----
