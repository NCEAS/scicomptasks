## --------------------------------------------- ##
              # Exploring `ecocomDP`
## --------------------------------------------- ##
# Follows this tutorial:
# https://www.neonscience.org/resources/learning-hub/tutorials/neon-biodiversity-ecocomdp-cyverse

# Clear environment
rm(list = ls())

## --------------------------------------------- ##
# Housekeeping -----
## --------------------------------------------- ##
# Load needed packages
# install.packages("librarian")
librarian::shelf(neonUtilities, tidyverse, ecocomDP, vegan)

# Load NEON token
source(file.path("wg_emergent", "neon_token.R"))
## "neon_token.R" creates "neon_token" object of the NEON token string

# Check token loading
if(!exists("neon_token")){
  message("NEON token *NOT* found! Attach token before continuing")
} else { message("NEON token found! Continue") }




# End ----
