## --------------------------------------------- ##
             # `neonUtilities` Set-Up
## --------------------------------------------- ##
# Follows this tutorial:
# https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial

# Clear environment
rm(list = ls())

## --------------------------------------------- ##
              # Install Package -----
## --------------------------------------------- ##
# Install neonUtilities package
install.packages("neonUtilities")
## MUST BE >1.3.4 to allow API token functionality

# Load package
library(neonUtilities)

## --------------------------------------------- ##
              # Manual Token Use -----
## --------------------------------------------- ##
# Define token
neon_token <- ""

# Load test data
## WARNING: this takes awhile (~5 min)
foliar <- neonUtilities::loadByProduct(
  dpID = "DP1.10026.001", site = "all",
  package = "expanded", check.size = F,
  token = neon_token)

## --------------------------------------------- ##
# Protected Token Use -----
## --------------------------------------------- ##

# Tutorial suggests two paths to avoid embedding token in script:

## 1. Create a single script that defines the token as "neon_token" and then source that script in all scripts that use `neonUtilities`

## 2. Add the token to the .Renviron file. Does `git` track this file? I don't think so but I wouldn't want to go this road without knowing for sure

# End ----
