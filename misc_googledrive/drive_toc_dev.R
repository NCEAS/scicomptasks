# Read in needed packages
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls())

# Snag Drive ID
top_url <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/0AIPkWhVuXjqFUk9PVA")

# Check contents
(top_contents <- googledrive::drive_ls(path = top_url, type = "folder", recursive = FALSE))






# End ----
