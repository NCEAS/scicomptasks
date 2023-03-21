## ----------------------------------------------- ##
        # Drive Table of Contents Exploration
## ----------------------------------------------- ##

# Purpose:
## Explore whether some use of `drive_ls` would allow for algorithmic creation of full table of contents for a user-supplied top-level Drive folder URL

## ------------------------------------- ##
            # Housekeeping ----
## ------------------------------------- ##

# Read in needed packages
librarian::shelf(tidyverse, googledrive, magrittr,
                 data.tree, DiagrammeR)

# Clear environment
rm(list = ls())

## ------------------------------------- ##
        # Scripted Exploration ----
## ------------------------------------- ##
# Snag Drive ID (not actually top to make testing faster)
top_url <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/1JsdILSmvKZX8c22jtcQF2LXB-nNGOMo0")

# Check folders within this top-level folder
(top_contents <- googledrive::drive_ls(path = top_url, type = "folder", recursive = FALSE))

# Make a new column for whether that directory has been listed
top_contents

# Duplicate to preserve that object
contents <- top_contents %>%
  # Also make a column for whether that directory has been listed and which folder it is nested in
  dplyr::mutate(listed = FALSE,
                parent_path = ".")

# Look at that
contents

# While any folders are not identified
while(FALSE %in% contents$listed){
  
  # Loop across these folders to identify their subfolders
  for(k in 1:nrow(contents)){
    
    # Skip if already listed
    if(contents[k,]$listed == TRUE){ message("Skipping already listed folder (folder ", k, ")") 
      
      # Otherwise...
    } else {
      
      # List out the folders within that folder
      sub_conts <- googledrive::drive_ls(path = googledrive::as_id(contents[k,]$id), 
                                         type = "folder", recursive = FALSE) %>%
        # Add the columns we added to the first `drive_ls` return
        dplyr::mutate(listed = FALSE,
                      parent_path = paste0(contents[k,]$parent_path, "/", contents[k,]$name))
      
      # Combine that output with the contents object
      contents %<>%
        # Row bind nested folders
        dplyr::bind_rows(sub_conts) %>%
        # Flip this folder's "listed" entry to TRUE
        dplyr::mutate(listed = ifelse(test = (id == contents[k,]$id),
                                      yes = TRUE,
                                      no = listed))
      
      # Message success
      message("Subfolders identified for folder ", k) } } 
  
} # Close `while` loop

# Process this a little
paths <- contents %>%
  # Complete the path by adding in each folder's name
  dplyr::mutate(path = paste0(parent_path, "/", name)) %>%
  # Strip out ONLY paths
  dplyr::pull(var = path)
  
# Check that out
paths

# Split into a list of dataframes where each path is a dataframe with a column for each folder
contents_list <- base::lapply(X = base::strsplit(x = paths, split = "/"),
                              FUN = function(z) base::as.data.frame(base::t(z)))

# Bind back together
contents_df <- contents_list %>%
  dplyr::bind_rows() %>%
  # Also re-gain the full path string
  dplyr::mutate(pathString = paths)
  
# Check out visual table of contents
(drive_tree <- data.tree::as.Node(contents_df))

# Plot it!
plot(drive_tree)

# End ----
