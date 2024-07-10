## -------------------------------------------- ##
      # LTER Site Polygon Custom Functions
## -------------------------------------------- ##

## -------------------------------- ##
# Polygon Tidying ----
## -------------------------------- ##

poly_tidy <- function(site_sf = NULL, network_sf = NULL,
                      code = NULL, name = NULL, plot = FALSE){
  
  
  
  
  
}


# Read in NGA GeoJSON and transform to sf
arc_v1 <- geojsonio::geojson_read(x = file.path("data", "ARCLTER_bounday_2024.geojson"),
                                  what = "sp") %>%
  sf::st_as_sf(x = .)

# Glimpse it
dplyr::glimpse(arc_v1)

# Wrangle NGA polygons for consistency with other polygons
arc_v2 <- arc_v1 %>% 
  # Transform CRS (is already right but better safe than sorry)
  sf::st_transform(x = ., crs = sf::st_crs(lter_v1)) %>% 
  # Add in desired columns
  dplyr::mutate(SITE = "ARC",
                NAME = "Arctic",
                .before = dplyr::everything()) %>% 
  # Pare down to just the desired columns
  dplyr::select(SITE, NAME)

# Check the structure of that
dplyr::glimpse(arc_v2)

# Visual demo
plot(arc_v2["SITE"], axes = T)

# End ----

