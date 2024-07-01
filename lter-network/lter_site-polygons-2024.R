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
librarian::shelf(tidyverse, googledrive, sf, maps, geojsonio, supportR)

# Make needed folder(s)
dir.create(path = file.path("graphs"), showWarnings = F)
dir.create(path = file.path("data"), showWarnings = F)
dir.create(path = file.path("data", "site-polys_2024"), showWarnings = F)

# Turn off S2 Processing
sf::sf_use_s2(FALSE)

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
  # Transform CRS (is already right but better safe than sorry)
  sf::st_transform(x = ., crs = sf::st_crs(lter_v1)) %>% 
  # Drop unwanted column(s)
  dplyr::select(-Id) %>% 
  # Rename desired but inconsistent ones
  dplyr::rename(SITE = Site,
                NAME = Name)

# Re-check
dplyr::glimpse(ble_v2)

# Visual demo
plot(ble_v2["SITE"], axes = T)

## ------------------------------ ##
          # CDR Update ----
## ------------------------------ ##

# Read in new boundary
cdr_v1 <- sf::st_read(dsn = file.path("data", "CDR_Border.shp"))

# Check contents
dplyr::glimpse(cdr_v1)

# Check CRS
sf::st_crs(cdr_v1)

# Wrangle polygons for consistency with other polygons
cdr_v2 <- cdr_v1 %>% 
  # Transform to desired CRS
  sf::st_transform(crs = sf::st_crs(lter_v1)) %>% 
  # Create desired column(s)
  dplyr::mutate(SITE = "CDR",
                NAME = "Cedar Creek") %>% 
  # Drop unwanted columns
  dplyr::select(SITE, NAME) %>% 
  # Reorder (slightly)
  dplyr::relocate(SITE:NAME, .before = dplyr::everything()) %>% 
  # Make it the right polygon shape
  sf::st_polygonize()

# Re-check
dplyr::glimpse(cdr_v2)

# Visual demo
plot(cdr_v2["SITE"], axes = T)

## ------------------------------ ##
          # FCE Update ----
## ------------------------------ ##

# Read in new boundary
fce_v1 <- sf::st_read(dsn = file.path("data", "FCE_study_area_2022.shp"))

# Check contents
dplyr::glimpse(fce_v1)

# Check CRS
sf::st_crs(fce_v1)

# Wrangle polygons for consistency with other polygons
fce_v2 <- fce_v1 %>% 
  # Transform to desired CRS
  sf::st_transform(crs = sf::st_crs(lter_v1)) %>% 
  # Create desired column(s)
  dplyr::mutate(SITE = "FCE",
                NAME = "Florida Coastal Everglades") %>% 
  # Drop unwanted columns
  dplyr::select(SITE, NAME) %>% 
  # Reorder (slightly)
  dplyr::relocate(SITE:NAME, .before = dplyr::everything())

# Re-check
dplyr::glimpse(fce_v2)

# Visual demo
plot(fce_v2["SITE"], axes = T)

## ------------------------------ ##
        # MSP Wrangling ----
## ------------------------------ ##
# Available here: https://deims.org/dc6949fb-2771-4e31-8279-cdb0489842f0

# Check out 2022 MSP polygons
msp_v1 <- sf::st_read(dsn = file.path("data", "msp_deims_sites_boundariesPolygon.shp"))

# Check contents
dplyr::glimpse(msp_v1)

# Check CRS
sf::st_crs(msp_v1)

# Wrangle polygons for consistency with other polygons
msp_v2 <- msp_v1 %>% 
  # Transform CRS (is already right but better safe than sorry)
  sf::st_transform(x = ., crs = sf::st_crs(lter_v1)) %>% 
  # Create desired column(s)
  dplyr::mutate(SITE = "MSP",
                NAME = "Minneapolis-St.Paul") %>% 
  # Pare down to just those columns
  dplyr::select(SITE, NAME)

# Re-check
dplyr::glimpse(msp_v2)

# Visual demo
plot(msp_v2["SITE"], axes = T)

## ------------------------------ ##
        # NES Wrangling ----
## ------------------------------ ##

# Check out NES polygons
nes_v1 <- sf::st_read(dsn = file.path("data", "EPU_extended.shp"))

# Check contents
dplyr::glimpse(nes_v1)

# Check CRS
sf::st_crs(nes_v1)

# Wrangle polygons for consistency with other polygons
nes_v2 <- nes_v1 %>% 
  # Transform to desired CRS
  sf::st_transform(crs = sf::st_crs(lter_v1)) %>% 
  # Combine sub-polygons to make just one shape for the whole site
  sf::st_union(x = .) %>% 
  # Create desired column(s)
  merge(x = ., y = data.frame("SITE" = "NES",
                              "NAME" = "Northeast U.S. Shelf")) %>% 
  # Reorder (slightly)
  dplyr::relocate(SITE:NAME, .before = dplyr::everything())

# Re-check
dplyr::glimpse(nes_v2)

# Visual demo
plot(nes_v2["SITE"], axes = T)

## ------------------------------ ##
      # NGA Wrangling ----
## ------------------------------ ##

# Read in NGA GeoJSON and transform to sf
nga_v1 <- geojsonio::geojson_read(x = file.path("data", "nga_bb.geojson"), what = "sp") %>%
  sf::st_as_sf(x = .)

# Glimpse it
dplyr::glimpse(nga_v1)

# Wrangle NGA polygons for consistency with other polygons
nga_v2 <- nga_v1 %>% 
  # Transform CRS (is already right but better safe than sorry)
  sf::st_transform(x = ., crs = sf::st_crs(lter_v1)) %>% 
  # Drop unwanted column(s)
  dplyr::select(-FID) %>% 
  # Add in desired columns
  dplyr::mutate(SITE = "NGA",
                NAME = "Northern Gulf of Alaska",
                .before = dplyr::everything())

# Check the structure of that
dplyr::glimpse(nga_v2)

# Visual demo
plot(nga_v2["SITE"], axes = T)

## ------------------------------ ##
    # Integration & Export ----
## ------------------------------ ##

# Combine the previously missing sites into the rest of the network's polygons
lter_v2 <- lter_v1 %>% 
  # Remove outdated polygons
  dplyr::filter(!SITE %in% c("FCE", "CDR")) %>% 
  # Beaufort Lagoon Ecosystem
  dplyr::bind_rows(ble_v2) %>%
  # Cedar Creek
  dplyr::bind_rows(fce_v2) %>% 
  # Florida Coastal Everglades
  dplyr::bind_rows(cdr_v2) %>% 
  # Minneapolis-St. Paul
  dplyr::bind_rows(msp_v2) %>% 
  # Northern Gulf of Alaska
  dplyr::bind_rows(nga_v2) %>% 
  # Northeast US Shelf
  dplyr::bind_rows(nes_v2)

# Pick a final object name for the site boundaries
lter_final <- lter_v2

# Check the final spatial extent
sf::st_bbox(lter_final)

# Check new sites
supportR::diff_check(old = unique(lter_v1$SITE), new = unique(lter_final$SITE))

# Generate a file name / path
poly_name <- file.path("data", "site-polys_2024", "lter_site-boundaries.shp")

# Export locally
sf::st_write(obj = lter_final, dsn = poly_name, delete_layer = T)

# Generate a CSV name
poly_csv <- gsub(pattern = "boundaries.shp", replacement = "names.csv", x = poly_name)

# Drop the geometry information
lter_csv <- sf::st_drop_geometry(x = lter_final)

# Check structure
dplyr::glimpse(lter_csv)

# Export that too
write.csv(x = lter_csv, file = poly_csv, row.names = F, na = '')

## ------------------------------ ##
    # Per-Site Map Making ----
## ------------------------------ ##

# Clear environment of everything that is not needed
rm(list = setdiff(ls(), c("borders", "lter_final")))

# Define a coordinate cutoff (in degrees)
coord_cutoff_lat <- 2.25
coord_cutoff_lon <- 3.5

# Loop across sites
for(one_name in sort(unique(lter_final$SITE))){
  
  # Processing message
  message("Creating map for LTER site: ", one_name)
  
  # Subset to a single site
  one_site <- dplyr::filter(lter_final, SITE == one_name)
  
  # Cast to "POINT" type
  one_pts <- suppressWarnings(sf::st_cast(x = one_site, to = "POINT"))
  
  # Strip as a dataframe
  one_df <- as.data.frame(unique(sf::st_coordinates(x = one_pts)))
  
  # Identify min/max coordinates
  one_box <- data.frame("max_lat" = max(one_df$Y), "min_lat" = min(one_df$Y),
                        "max_lon" = max(one_df$X), "min_lon" = min(one_df$X)) %>% 
    # Calculate range for both
    dplyr::mutate(rng_lat = abs(max_lat - min_lat),
                  rng_lon = abs(max_lon - min_lon)) %>% 
    # Bump up those values if they're beneath a threshold
    dplyr::mutate(rng_lat = ifelse(rng_lat < coord_cutoff_lat, 
                                   yes = coord_cutoff_lat, no = rng_lat),
                  rng_lon = ifelse(rng_lon < coord_cutoff_lon, 
                                   yes = coord_cutoff_lon, no = rng_lon)) %>% 
    # Now use it to identify more reasonable limits
    dplyr::mutate(top = ifelse(max_lat > 0, 
                               yes = max_lat + rng_lat, 
                               no = max_lat - rng_lat),
                  bottom = ifelse(min_lat > 0, 
                                  yes = min_lat - rng_lat, 
                                  no = min_lat + rng_lat),
                  left = ifelse(max_lon > 0, 
                                yes = max_lon + rng_lon, 
                                no = max_lon - rng_lon),
                  right = ifelse(min_lon > 0, 
                                 yes = min_lon - rng_lon, 
                                 no = min_lon + rng_lon))
  
  # Graph this site
  ggplot() +
    # Add country/state borders
    geom_sf(data = borders, fill = "white") +
    # Add site polygons
    geom_sf(data = one_site, aes(fill = SITE), alpha = 0.7) +
    # Define borders
    coord_sf(xlim = c(one_box$left, one_box$right), 
             ylim = c(one_box$top, one_box$bottom)) +
    # Customize legend / axis elements
    labs(x = "Longitude", y = "Latitude",
         title = paste0(one_name, " Boundary")) +
    supportR::theme_lyon() + 
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 35, hjust = 1))
  
  # Assemble file name / path
  one_file <- file.path("graphs", paste0("lter-site-polygon_", one_name, "_2024.png"))
  
  # Export
  ggsave(filename = one_file, width = 5, height = 5, units = "in")
  
} # Close loop

# Identify exported map file names
lter_maps <- dir(path = file.path("graphs"), pattern = "lter-site-polygon_")

# Send these files to the Google Drive
purrr::walk(.x = lter_maps, 
            .f = ~ googledrive::drive_upload(media = file.path("graphs", .x), overwrite = T,
                                             path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/1mqhSuYgun-OA_50ET2vD-u9niCb9f6-R")))

# End ----
