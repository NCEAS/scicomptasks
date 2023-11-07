## -------------------------------------------------- ##
        # LTER / NEON Publication Checker
## -------------------------------------------------- ##
# Script author(s): Nick J Lyon

# PURPOSE:
## Compare LTER / NEON publication lists

## ------------------------------ ##
         # Housekeeping ----
## ------------------------------ ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, supportR)

# Clear environment
rm(list = ls())

## ------------------------------ ##
        # Library Prep ----
## ------------------------------ ##

# Read in the full library information for both networks
lter_v0 <- read.csv(file = file.path("data", "NEON Publications.csv"))
neon_v0 <- read.csv(file = file.path("data", "LTER Publications.csv"))



# End ----
