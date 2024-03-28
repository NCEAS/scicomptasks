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

# Clear environment
rm(list = ls())

## ------------------------------------- ##
          # Function Variant ----
## ------------------------------------- ##
# Define function
drive_toc <- function(url = NULL, ignore_names = NULL, quiet = FALSE){
  
  # Error out for missing folder URL
  if(is.null(url))
    stop("URL must be provided")
  
  # Also if URL is not wrapped with `googledrive::as_id`
  if(!methods::is(object = url, class = "drive_id"))
    stop("URL must be a Drive ID (wrap URL with `googledrive::as_id`")
  
  # Identify top-level folders
  top_conts <- googledrive::drive_ls(path = url, type = "folder", recursive = FALSE)
  
  # Duplicate to preserve that object
  contents <- top_conts %>%
    # Make columns for whether that directory has been listed and its path
    dplyr::mutate(listed = FALSE,
                  parent_path = ".")
  
  # While any folders are not identified
  while(FALSE %in% contents$listed){
    
    # Remove any folders marked to be ignored (if any are)
    if(length(x = ignore_names) != 0){
      contents <- dplyr::filter(contents, !name %in% ignore_names)
    }
    
    # Loop across these folders to identify their subfolders
    for(k in 1:nrow(contents)){
      
      # Skip if already listed
      if(contents[k,]$listed == TRUE & quiet != TRUE){ 
        message("Skipping already listed folder (folder ", k, ")") 
        
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
        
        # Message success (if `quiet` is FALSE)
        if(quiet != TRUE){ message("Subfolders identified for folder ", k) }
        } } # Close conditional & `for` loop
    
  } # Close `while` loop
  
  # Process this a little
  paths <- contents %>%
    # Complete the path by adding in each folder's name
    dplyr::mutate(path = paste0(parent_path, "/", name)) %>%
    # Strip out ONLY paths
    dplyr::pull(var = path)
  
  # Split into a list of dataframes where each path is a dataframe with a column for each folder
  contents_list <- base::lapply(X = base::strsplit(x = paths, split = "/"),
                                FUN = function(z) base::as.data.frame(base::t(z)))
  
  # Bind back together
  contents_df <- contents_list %>%
    dplyr::bind_rows() %>%
    # Also re-gain the full path string
    dplyr::mutate(pathString = paths)
  
  # Strip out folder paths
  drive_tree <- data.tree::as.Node(contents_df)
  
  # Return this
  return(drive_tree) }

# Use the function
my_tree <- drive_toc(url = googledrive::as_id("https://drive.google.com/drive/u/0/folders/1JsdILSmvKZX8c22jtcQF2LXB-nNGOMo0"), quiet = F)

# Check it out
my_tree

# Plot it
plot(my_tree)

# Try for a real top-level folder (will definitely take longer but *should* still work)
full_tree <- drive_toc(url = googledrive::as_id("https://drive.google.com/drive/u/0/folders/0AIPkWhVuXjqFUk9PVA"), ignore_names = c("Backups"), quiet = F)

# Check this one out
full_tree

# Is the plot informative or does it get too cluttered?
plot(full_tree)

# End ----
