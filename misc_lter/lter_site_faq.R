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
site_drive <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/1HSB6LWEbXrTCEzHppfmTHWGZSX5qa30B")) %>%
  # Filter to only desired files
  dplyr::filter(name %in% c("site_faq_info.csv"))

# Create a folder for these locally
dir.create(path = file.path("data"), showWarnings = F)

# Download both files
purrr::walk2(.x = site_drive$name, .y = site_drive$id,
             .f = ~ googledrive::drive_download(file = .y, overwrite = T,
                                                path = file.path("data", .x)))

# Read in data
site_df <- read.csv(file = file.path("data", "site_faq_info.csv"))

# Check structure
dplyr::glimpse(site_df)

## ------------------------------ ##
# Filter ----
## ------------------------------ ##

# Skip (for now)
## Eventually filtering to 'sites of interest' will be done here

# Make sure object is named appropriately
site_actual <- site_df

## ------------------------------ ##
# Site Timeline ----
## ------------------------------ ##

## ------------------------------ ##
# Site Map ----
## ------------------------------ ##

# End ----
