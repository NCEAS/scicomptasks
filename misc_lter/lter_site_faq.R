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
site_df <- read.csv(file = file.path("data", "site_faq_info.csv")) %>%
  # Rename site name column
  dplyr::rename(site_name = name)

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

# Flip site data to long format
site_long <- site_actual %>%
  tidyr::pivot_longer(cols = ends_with("_year"),
                      values_to = "year")

# Check structure
dplyr::glimpse(site_long)

# Get vector of habitat colors
habitat_colors <- c("Coastal" = "#34a0a4", 
                    "Freshwater" = "#48cae4", 
                    "Marine" = "#1e6091", 
                    "Forest" = "#007200",
                    "Grassland" = "#9ef01a", 
                    "Mixed Landscape" = "#7f5539",
                    "Tundra" = "#bb9457", 
                    "Urban" = "#9d4edd")

# Make timeline
timeline <- ggplot(site_long, aes(x = year, y = code)) +
  geom_path(aes(group = code, color = habitat), lwd = 1, lineend = 'round') +
  geom_point(aes(fill = habitat), pch = 21, size = 2) +
  # Custom color
  scale_fill_manual(values = habitat_colors) +
  scale_color_manual(values = habitat_colors) +
  # Customize theme elements
  theme_bw() +
  theme(panel.border = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text(size = 12),
        legend.title = element_blank()); timeline

## ------------------------------ ##
# Site Map ----
## ------------------------------ ##



## ------------------------------ ##
# Export ----
## ------------------------------ ##

# End ----
