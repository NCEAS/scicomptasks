## ----------------------------------------------------- ##
              # Rarefy Package Exploration
## ----------------------------------------------------- ##

## ------------------------------------- ##
             # Housekeeping ----
## ------------------------------------- ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, Rarefy, ade4, adiv, ape, vegan, phyloregion, raster)
## Note that "Rarefy" requires (at least) Mac users to have XQuartz installed

# Clear environment
rm(list = ls())

## ------------------------------------- ##
   # Spatially Explicit Rarefaction ----
## ------------------------------------- ##
# See: https://cran.r-project.org/web/packages/Rarefy/vignettes/Rarefy_basics.html

# Load data
data("duneFVG") #plot/species matrix
data("duneFVG.xy") #plots geographic coordinates

# Calculates pairwise Euclidean distances among sample units
dist_sp <- stats::dist(x = duneFVG.xy$tot.xy, method = "euclidean")

# Calculate directional and non-directional accumulation curves
ser_rarefaction <- Rarefy::directionalSAC(community = duneFVG$total, gradient = dist_sp)

# Make exploratory plot
base::plot(x = 1:128, y = ser_rarefaction$N_Exact,
           xlab = "M", ylab = "Species richness",
           ylim = c(0, 71), pch = 1)
graphics::points(x = 1:128, y = ser_rarefaction$N_SCR, pch = 2)
graphics::legend(x = "bottomright",
                 legend = c("Classic Rarefaction",
                            "Spatially-explicit Rarefaction"),
                 pch = 1:2)

# End ----
