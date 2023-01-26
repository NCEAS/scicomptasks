## -------------------------------------------------------------- ##
                # Neon Tutorial(s)
## -------------------------------------------------------------- ##

# This script is used for the following tutorials:
### 1) Download and Explore NEON Data
# https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data
### 2) Introduction to Small Mammal Data
# https://www.neonscience.org/resources/learning-hub/tutorials/mammal-data-intro

## -------------------------------------------- ##
            # NEON Tutorial No. 1 ----
## -------------------------------------------- ##

# Load libraries
# install.packages("librarian")
librarian::shelf(neonUtilities, neonOS, raster, tidyverse)

# Clear environment
rm(list = ls())

# Set global option to *not* convert character variables to factors
options(stringsAsFactors = F)

# Load in data
apchem <- neonUtilities::loadByProduct(dpID = "DP1.20063.001", 
                                     site = c("PRLA", "SUGG", "TOOK"), 
                                     package = "expanded", check.size = T)
## NOTE: You can use `neonUtilities::stackByTable` to load a pre-downloaded .zip file

# `loadByProduct` returns a list
names(apchem)
dplyr::glimpse(apchem$apl_plantExternalLabDataPerSample)

# Can create separate objects for each dataframe in that list
list2env(apchem, .GlobalEnv)

# Create a folder for local preservation of NEON data
dir.create("data", showWarnings = F)

# Export some of these dataframes as CSVs for later use
write.csv(apl_clipHarvest, file.path("data", "apl_clipHarvest.csv"), row.names = F)
write.csv(apl_biomass, file.path("data", "apl_biomass.csv"), row.names = F)
write.csv(apl_plantExternalLabDataPerSample, 
          file.path("data", "apl_plantExternalLabDataPerSample.csv"), row.names = F)
write.csv(variables_20063, file.path("data", "variables_20063.csv"), row.names = F)

# Navigate downloads
par30 <- neonUtilities::readTableNEON(
  dataFile = file.path("data", "NEON_par", "stackedFiles", "PARPAR_30min.csv"), 
  varFile = file.path("data", "NEON_par", "stackedFiles", "variables_00024.csv"))

# Load variables information
parvar <- read.csv(file.path("data", "NEON_par", "stackedFiles", "variables_00024.csv"))
dplyr::glimpse(parvar)

# Create a plot of PAR
plot(PARMean ~ startDateTime, 
     data = subset(par30, verticalPosition == "020"),
     type = "l")

# Plot plant isotope ratios
boxplot(analyteConcentration ~ siteID, 
        data = apl_plantExternalLabDataPerSample, 
        subset = analyte == "d13C",
        xlab = "Site", ylab = "d13C")

# Also NEON has made its own joining function
apct <- neonOS::joinTableNEON(apl_biomass, apl_plantExternalLabDataPerSample)

# Now can plot information across several files
boxplot(analyteConcentration ~ scientificName, 
        data = apct, 
        subset = analyte == "d13C", 
        xlab = NA, ylab = "d13C", 
        las = 2, cex.axis = 0.7)

# Download remote sensing data too
neonUtilities::byTileAOP(dpID = "DP3.30015.001", site = "WREF", year = "2017",
                         check.size = T, easting = 580000, northing = 5075000,
                         savepath = file.path("data"))

# Read in the raster of that remote sensing data
chm <- raster::raster(x = file.path("data", "DP3.30015.001", "neon-aop-products",
                                    "2017", "FullSite", "D16", "2017_WREF_1", "L3", 
                                    "DiscreteLidar", "CanopyHeightModelGtif", 
                                    "NEON_D16_WREF_DP3_580000_5075000_CHM.tif"))

# Check out that remote sensing data
plot(chm, col = topo.colors(6))

## -------------------------------------------- ##
# NEON Tutorial No. 2 ----
## -------------------------------------------- ##

# Load libraries
# install.packages("librarian")
librarian::shelf(neonUtilities, neonOS, tidyverse)

# Clear environment
rm(list = ls())


# Workshop offered 1/31/23, will fill this part out then



# End ----
