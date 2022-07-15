## ----------------------------------------- ##
   # `SiZer` Handling for Silica Export WG
## ----------------------------------------- ##
# Written by: Nick J Lyon

# Housekeeping ----

# Load libraries
install.packages("librarian")
librarian::shelf(cowplot, SiZer, tidyverse)

# Clear environment
rm(list = ls())

# Load data
data <- readr::read_csv(file = file.path("wg_silica", "CryoData_forNick_6.29.22.csv"))

# Make a test site subset
test_site <- data %>%
  dplyr::filter(site == "ALBION") %>%
  as.data.frame()

# Load helper functions
source("sizer-helper-fxns.R")

# Loop Extract of SiZer Data ----

# Create a folder to save experimental outputs
export_folder <- "plots"
dir.create(path = export_folder, showWarnings = FALSE)

# Make an empty list to store extracted inflection points in
inflection_points <- list()

# Loop through sites and extract information
for(place in unique(data$site)) {
  # for(place in "ALBION"){
  
  # Start with a message!
  message("Processing begun for site: ", place)
  
  # Subset the data
  data_sub <- data %>%
    dplyr::filter(site == place) %>%
    as.data.frame()
  
  # Invoke the SiZer::SiZer function
  e <- SiZer::SiZer(x = data_sub$Year, y = data_sub$FNYield,
                    h = c(2, 10), degree = 1,
                    derv = 1, grid.length = 100)
  
  # Make a shorter place name
  place_short <- stringr::str_sub(string = place, start = 1, end = 8)
  
  # Plot (and export) the SiZer object with horizontal lines of interest
  png(filename = file.path(export_folder, paste0(place_short, "_SiZer-plot.png")), width = 5, height = 5, res = 720, units = 'in')
  sizer_plot(sizer_object = e, bandwidth_vec = c(3, 6, 9))
  dev.off()
  
  # Strip out the aggregated (across all bandwidths) inflection points
  sizer_tidy <- sizer_aggregate(sizer_object = e)
  
  # Identify inflection points at bandwidth of 3, 6, and 9 too
  sizer_h3 <- sizer_slice(sizer_object = e, bandwidth = '3')
  sizer_h6 <- sizer_slice(sizer_object = e, bandwidth = 6)
  sizer_h9 <- sizer_slice(sizer_object = e, bandwidth = 9)
  
  # Plot (and export) the aggregated inflection points
  sizer_ggplot(raw_data = data_sub, sizer_data = sizer_tidy,
               x = "Year", y = "FNYield") +
    ggtitle(label = "Aggregated Inflection Points")
  ggplot2::ggsave(plot = last_plot(), height = 5.06, width = 5.44,
                  filename = file.path(export_folder, paste0(place_short, "_aggregate-plot.png")))
  
  # Plot (and export) the bandwidth-specific plots too!
  ## Bandwidth (h) = 3
  sizer_ggplot(raw_data = data_sub, sizer_data = sizer_h3,
               x = "Year", y = "FNYield") +
    ggtitle(label = "h = 3 Inflection Points")
  ggplot2::ggsave(plot = last_plot(), height = 5.06, width = 5.44,
                  filename = file.path(export_folder, paste0(place_short, "_h3-plot.png")))
  ## Bandwidth (h) = 3
  sizer_ggplot(raw_data = data_sub, sizer_data = sizer_h6,
               x = "Year", y = "FNYield") +
    ggtitle(label = "h = 6 Inflection Points")
  ggplot2::ggsave(plot = last_plot(), height = 5.06, width = 5.44,
                  filename = file.path(export_folder, paste0(place_short, "_h6-plot.png")))
  ## Bandwidth (h) = 9
  sizer_ggplot(raw_data = data_sub, sizer_data = sizer_h9,
               x = "Year", y = "FNYield") +
    ggtitle(label = "h = 9 Inflection Points")
  ggplot2::ggsave(plot = last_plot(), height = 5.06, width = 5.44,
                  filename = file.path(export_folder, paste0(place_short, "_h9-plot.png")))
  
  # Now modify the columns in the provided sizer dataframes
  sizer_tidy_export <- sizer_tidy %>%
    # Make everything a character
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) %>%
    # Add a column for bandwidth and for site name
    dplyr::mutate(site = place, h_grid = "averaged across bandwidths",
                  .before = dplyr::everything() ) %>%
    # Make sure it's a dataframe
    as.data.frame()
  
  # Do the same for the bandwidth specific data
  ## h == 3
  sizer_h3_export <- sizer_h3 %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) %>%
    dplyr::mutate(site = place, .before = dplyr::everything()) %>%
    as.data.frame()
  ## h == 6
  sizer_h6_export <- sizer_h6 %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) %>%
    dplyr::mutate(site = place, .before = dplyr::everything()) %>%
    as.data.frame()
  ## h == 9
  sizer_h9_export <- sizer_h9 %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) %>%
    dplyr::mutate(site = place, .before = dplyr::everything()) %>%
    as.data.frame()
  
  # Combine these data objects
  complete_export <- dplyr::bind_rows(sizer_tidy_export,
                                      sizer_h3_export,
                                      sizer_h6_export,
                                      sizer_h9_export)
  
  # Add these tidied dataframes to our list
  inflection_points[[place]] <- complete_export
  
  # Return a message!
  message("Processing complete for site: ", place)
  
}

# Outside of the loop, unlist our inflection points into a dataframe
export_actual <- inflection_points %>%
  purrr::map_dfr(.f = dplyr::select, dplyr::everything())

# Save the CSV!
write_csv(x = export_actual, na = "",
          file = file.path(export_folder, "all_inflection_pt_numbers.csv"))

# End ----
