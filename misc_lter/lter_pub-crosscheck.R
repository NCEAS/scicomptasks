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
        # Library Import ----
## ------------------------------ ##

# Make some empty lists
lter_list <- list()
neon_list <- list()

# Get all collections' citations (for LTER)
for(colxn in dir(path = file.path("data", "LTER Collections"))){
  
  # Processing message
  message("Retrieving collection: ", colxn)
  
  # Read in file and add to list
  lter_list[[colxn]] <- read.csv(file = file.path("data", "LTER Collections", colxn)) %>% 
    # Make all columns into characters
    dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                                .fns = as.character)) }

# Do the same for NEON
for(colxn in dir(path = file.path("data", "NEON Collections"))){
  
  # Processing message
  message("Retrieving collection: ", colxn)
  
  # Read in file and add to list
  neon_list[[colxn]] <- read.csv(file = file.path("data", "NEON Collections", colxn)) %>% 
    dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                                .fns = as.character)) }

# Unlist into a dataframe (for both) and drop duplicates (if Zotero made any)
lter_v0 <- dplyr::distinct(purrr::list_rbind(x = lter_list))
neon_v0 <- dplyr::distinct(purrr::list_rbind(x = neon_list))

# Tidy environment
rm(list = setdiff(x = ls(), y = c("lter_v0", "neon_v0")))

## ------------------------------ ##
# Library Prep ----
## ------------------------------ ##

# Check structure of one (same columns in both)
dplyr::glimpse(lter_v0)



## ------------------------------ ##
# Library Integration ----
## ------------------------------ ##



## ------------------------------ ##
# Visuals ----
## ------------------------------ ##


# End ----
