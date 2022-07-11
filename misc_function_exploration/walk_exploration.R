## ------------------------------------------- ##
          # `purrr::walk` Exploration
## ------------------------------------------- ##
# Written by Nick J Lyon

# Purpose:
## Explore the `purrr::walk` function

# Housekeeping ---------------------------------

# Clear environment
rm(list = ls())

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse)

# Create faux "data"
test_df <- list("x" = c(1, 2, 3),
                "y" = c(4, 5, 6),
                "z" = c(7, 8, 9) )

# `walk` Exploration ---------------------------

# Check help file
?purrr::walk

# Write a simple `for` loop
for(element in names(test_df)){
  avg <- mean(test_df[[element]])
  message("Average for ", element, " = ", avg) }

# Attempt its equivalent with `map`
purrr::map(.x = test_df, .f = mean)

# Attempt its equivalent with `walk`
purrr::walk(.x = test_df, .f = mean)
## Returns nothing...

# Documentation says `walk` is called "for its side effects" which makes sense that it would be useful for downloading stuff
## `walk` also returns whatever is in the `.x` argument without modification


# End ----
