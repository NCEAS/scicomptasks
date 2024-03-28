## -------------------------------------------------- ##
                  # LTER Site Polygons
## -------------------------------------------------- ##
# Script author(s): Nick J Lyon

# PURPOSE:
## Wrangle LTER site polygons into a single shapefile

## ------------------------------ ##
        # Housekeeping ----
## ------------------------------ ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, googledrive, sf)

# Clear environment
rm(list = ls())

## ------------------------------ ##
 # 2024 Consolidation Effort ----
## ------------------------------ ##

# Read in 2017 shapefiles
lter_v1 <- sf::st_read(dsn = file.path("data", "lterDomains_110410.shp"))

# Check contents
dplyr::glimpse(lter_v1)

# How many sites are included / which of them?
sort(unique(lter_v1$SITE)); length(unique(lter_v1$SITE))

# And new 2019 BLE polygons
ble_v1 <- sf::st_read(dsn = file.path("data", "ble_lagoons_polygons.shp"))

# Check contents
dplyr::glimpse(ble_v1)

# Wrangle BLE polygons for consistency with other polygons
ble_v2 <- ble_v1 %>% 
  # Drop unwanted column(s)
  dplyr::select(-Id) %>% 
  # Rename desired but inconsistent ones
  dplyr::rename(SITE = Site,
                NAME = Name)

# Re-check
dplyr::glimpse(ble_v2)

# Attach BLE to the rest of the network
lter_v2 <- dplyr::bind_rows(lter_v1, ble_v2)

# Exploratory plot 
plot(lter_v2["SITE"], axes = T)


# End ----
