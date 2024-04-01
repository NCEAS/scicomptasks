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
librarian::shelf(tidyverse, googledrive, sf, maps, supportR)

# Clear environment
rm(list = ls())

# Get state / country borders
borders <- dplyr::bind_rows(sf::st_as_sf(maps::map(database = "world", plot = F, fill = T)),
                            sf::st_as_sf(maps::map(database = "state", plot = F, fill = T)))

## ------------------------------ ##
    # Initial Exploration ----
## ------------------------------ ##

# Read in 2017 shapefiles
lter_v1 <- sf::st_read(dsn = file.path("data", "lterDomains_110410.shp"))

# Check contents
dplyr::glimpse(lter_v1)

# How many sites are included / which of them?
sort(unique(lter_v1$SITE)); length(unique(lter_v1$SITE))

# Check CRS
sf::st_crs(lter_v1)

## ------------------------------ ##
        # BLE Wrangling ----
## ------------------------------ ##

# Check out 2019 BLE polygons
ble_v1 <- sf::st_read(dsn = file.path("data", "ble_lagoons_polygons.shp"))

# Check contents
dplyr::glimpse(ble_v1)

# Check CRS
sf::st_crs(ble_v1)

# Wrangle BLE polygons for consistency with other polygons
ble_v2 <- ble_v1 %>% 
  # Drop unwanted column(s)
  dplyr::select(-Id) %>% 
  # Rename desired but inconsistent ones
  dplyr::rename(SITE = Site,
                NAME = Name)

# Re-check
dplyr::glimpse(ble_v2)

## ------------------------------ ##
      # New Site Inclusion ----
## ------------------------------ ##

# Attach BLE to the rest of the network
lter_v2 <- dplyr::bind_rows(lter_v1, ble_v2)

# Exploratory base plot 
plot(lter_v2["SITE"], axes = T)

## ------------------------------ ##
    # Exploratory Graphing ----
## ------------------------------ ##


# Plot Continental US
ggplot() +
  # Add relevant country/state borders
  geom_sf(data = borders, fill = "white") +
  # Add site polygons
  geom_sf(data = lter_v2, aes(fill = SITE)) +
  # Define borders
  coord_sf(xlim = c(-140, -50), ylim = c(60, 20), expand = F) +
  # Customize legend / axis elements
  labs(x = "Longitude", y = "Latitude") +
  supportR::theme_lyon() + 
  theme(legend.position = "none")

# Plot Alaska
ggplot() +
  geom_sf(data = global_borders, fill = "white") +
  geom_sf(data = lter_v2, aes(fill = SITE)) +
  coord_sf(xlim = c(-180, -130), ylim = c(80, 50), expand = F) +
  labs(x = "Longitude", y = "Latitude") +
  supportR::theme_lyon() + 
  theme(legend.position = "none")

# Plot Antarctica
ggplot() +
  geom_sf(data = global_borders, fill = "white") +
  geom_sf(data = lter_v2, aes(fill = SITE)) +
  coord_sf(xlim = c(-180, 180), ylim = c(-55, -80), expand = F) +
  labs(x = "Longitude", y = "Latitude") +
  supportR::theme_lyon() + 
  theme(legend.position = "none")

# End ----
