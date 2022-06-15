## ---------------------------------------- ##
              # Polar Maps
## ---------------------------------------- ##

# Housekeeping ------------------------------

# Call needed libraries
library(purrr); library(leaflet)

# Define some key variables
extent <- 11000000 + 9036842.762 + 667
origin = c(-extent, extent)
maxResolution <- ((extent - -extent) / 256)
defZoom <- 4
bounds <- list(c(-extent, extent),c(extent, -extent))
minZoom <- 0
maxZoom <- 18
resolutions <- purrr::map_dbl(minZoom:maxZoom,function(x) maxResolution/(2^x))

# Handle EPSG projections -------------------

# 6 Projection EPSG Codes
projections <- c('3571', '3572', '3573', '3574', '3575', '3576')

# Define corresponding proj4defs codes for each projection
proj4defs <- list(
  '3571' = '+proj=laea +lat_0=90 +lon_0=180 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',
  '3572' = '+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',
  '3573' = '+proj=laea +lat_0=90 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',
  '3574' = '+proj=laea +lat_0=90 +lon_0=-40 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',
  '3575' = '+proj=laea +lat_0=90 +lon_0=10 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',
  '3576' = '+proj=laea +lat_0=90 +lon_0=90 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs'
)

# Create a CRS Instance for Each Projection -----
crses <- purrr::map(projections, function(code) {
  leafletCRS(
    crsClass = 'L.Proj.CRS',
    code = sprintf("EPSG:%s",code),
    proj4def = proj4defs[[code]],
    origin = origin,
    resolutions = resolutions,
    bounds = bounds)
  } )

# Tile URL Template for Each Projection ----
tileURLtemplates <- purrr::map(projections, function(code) {
  sprintf('http://{s}.tiles.arcticconnect.org/osm_%s/{z}/{x}/{y}.png', code)
})

# Assemble `leaflet` Map ----------------

# Note:
## We can't add all 6 tiles to our leaflet map, because each one is in a different projection, and you can have only one projection per map in Leaflet. So we create 6 maps.

# Create the maps
polarmaps <- purrr::map2(crses, tileURLtemplates,
                         function(crs, tileURLTemplate) {
                           leaflet(options = leafletOptions(
                             crs=crs, minZoom = minZoom,
                             maxZoom = maxZoom)) %>%
                             setView(0, 90, defZoom) %>%
                             addTiles(urlTemplate = tileURLTemplate,
                                      attribution = "Map © ArcticConnect. Data © OpenStreetMap contributors",
                                      options = tileOptions(subdomains = "abc", noWrap = TRUE, continuousWorld = FALSE))
                         })

# End ----
