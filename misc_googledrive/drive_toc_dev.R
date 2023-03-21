## ----------------------------------------------- ##
        # Drive Table of Contents Exploration
## ----------------------------------------------- ##

# Purpose:
## Explore whether some use of `drive_ls` would allow for algorithmic creation of full table of contents for a user-supplied top-level Drive folder URL

## ------------------------------------- ##
# Housekeeping ----
## ------------------------------------- ##

# Read in needed packages
librarian::shelf(tidyverse, googledrive, magrittr)

# Clear environment
rm(list = ls())

## ------------------------------------- ##
# Scripted Exploration ----
## ------------------------------------- ##
# Snag Drive ID
top_url <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/0AIPkWhVuXjqFUk9PVA")

# Check folders within this top-level folder
(top_contents <- googledrive::drive_ls(path = top_url, type = "folder", recursive = FALSE))

# Make a new column for whether that directory has been listed
top_contents

# Duplicate to preserve that object
contents <- top_contents %>%
  # Also make a column for whether that directory has been listed and which folder it is nested in
  dplyr::mutate(listed = FALSE,
                parent_name = "top_level",
                parent_id = "top_level")

# Look at that
contents

# While any folders are not identified
while(FALSE %in% contents$listed){
  
  # Loop across these folders to identify their subfolders
  for(k in 1:nrow(contents)){
    
    # Identify that folder's ID
    sub_id <- contents[k,]$id
    
    # List out the folders within that folder
    sub_conts <- googledrive::drive_ls(path = googledrive::as_id(sub_id), type = "folder") %>%
      # Add the columns we added to the first `drive_ls` return
      dplyr::mutate(listed = FALSE,
                    parent_name = contents[k,]$name,
                    parent_id = sub_id)
    
    # Combine that output with the contents object
    contents %<>%
      # Row bind nested folders
      dplyr::bind_rows(sub_conts) %>%
      # Flip this folder's "listed" entry to TRUE
      dplyr::mutate(listed = ifelse(test = (id == sub_id),
                                    yes = TRUE,
                                    no = listed))
    
    # Message success
    message("Subfolders identified for folder ", k) } 
  
} # Close `while` loop

# Check what we're left with
contents





# End ----
