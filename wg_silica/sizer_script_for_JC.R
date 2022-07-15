## ----------------------------------------- ##
  # Breakpoint Iteration for Silica Export WG
## ----------------------------------------- ##
# Written by: Nick J Lyon

# Housekeeping ----

# Load libraries
# install.packages("librarian")
librarian::shelf(SiZer, tidyverse)

# Clear environment
rm(list = ls())

# Load data
data <- readr::read_csv(file = file.path("wg_silica", "CryoData_forNick_6.29.22.csv"))

# First create a folder to save experimental plots to
# Create folders like this (vvv) ----
export_folder_name <- "plots"
dir.create(path = export_folder_name, showWarnings = FALSE)

# Custom Function for Inflection Point ID ----

# Run this to be able to use the function later
sizer_extract <- function(sizer_object = NULL){
  
  # Error out if object isn't provided or isn't a SiZer object
  if(is.null(sizer_object) | class(sizer_object) != "SiZer")
    stop("`sizer_object` must be provided and must be class 'SiZer'")
  
  # Strip SiZer object content into dataframe
  sizer_raw <- as.data.frame(sizer_object)
  
  # Perform necessary wrangling
  sizer_data <- sizer_raw %>%
    # Rename columns
    dplyr::rename(x_grid = x, h_grid = h, slope = class) %>%
    # Drop all 'insufficient data' rows
    dplyr::filter(slope != "insufficient data") %>%
    # Within bandwidth levels (h_grid)
    dplyr::group_by(h_grid) %>%
    # Identify whether the next value is the same or different
    dplyr::mutate(transition = dplyr::case_when(
      # First identify start of each group
      is.na(dplyr::lag(slope, n = 1)) ~ 'start',
      # is.na(dplyr::lead(slope, n = 1)) ~ 'end',
      # Now identify whether each value is the same as or different than previous
      slope == dplyr::lag(slope, n = 1) ~ 'same',
      slope != dplyr::lag(slope, n = 1) ~ 'change'
      # slope == dplyr::lead(slope, n = 1) ~ 'no'
    )) %>%
    # Filter to retain only those rows that indicate a slope change
    dplyr::filter(transition == "change") %>%
    # Lets also identify what type of change the transition was
    dplyr::mutate(change_type = dplyr::case_when(
      transition == "change" & slope == "increasing" ~ 'change_to_positive',
      transition == "change" & slope == "flat" ~ 'change_to_zero',
      transition == "change" & slope == "decreasing" ~ 'change_to_negative')) %>%
    # Account for if multiple of the same change happen in a curve
    dplyr::group_by(h_grid, change_type) %>%
    dplyr::mutate(change_count = seq_along(unique(x_grid))) %>%
    # Ungroup for subsequent operations
    dplyr::ungroup() %>%
    # Group by change type
    dplyr::group_by(change_count, change_type) %>%
    # And average the x_grid value
    dplyr::summarise(slope = dplyr::first(slope),
                     mean_x_v1 = mean(as.numeric(x_grid), na.rm = T),
                     sd_x_v1 = sd(as.numeric(x_grid), na.rm = T),
                     n_x_v1 = dplyr::n(),
                     se_x_v1 = sd_x_v1 / n_x_v1,
                     .groups = 'keep') %>%
    # Ungroup
    dplyr::ungroup() %>%
    # Sort from lowest to highest X
    dplyr::arrange(mean_x_v1) %>%
    # Handle the same "change" occurring twice
    ## Identify these cases
    dplyr::mutate(diagnostic = cumsum(ifelse(slope != dplyr::lag(slope) | base::is.na(dplyr::lag(slope)), yes = 1, no = 0))) %>%
    ## Group by that diagnostic and the change type
    dplyr::group_by(change_type, diagnostic) %>%
    ## Summarize
    dplyr::summarise(change_count = dplyr::first(change_count),
                     slope = dplyr::first(slope),
                     mean_x = mean(as.numeric(mean_x_v1), na.rm = T),
                     sd_x = mean(as.numeric(sd_x_v1)),
                     n_x = sum(n_x_v1, na.rm = T),
                     se_x = mean(as.numeric(se_x_v1)),
                     .groups = 'keep') %>%
    ## Ungroup
    dplyr::ungroup() %>%
    ## Remove the diagnostic column
    dplyr::select(-diagnostic) %>%
    # Sort from lowest to highest X (again)
    dplyr::arrange(mean_x) %>%
    # Calculate distance to next one
    dplyr::mutate(dist_to_next = dplyr::lead(x = mean_x) - mean_x) %>%
    # Add half the distance between +/0 and 0/- to +/0 to get +/- inflection point
    dplyr::mutate(
      pos_to_neg = ifelse(change_type == "change_to_zero" &
                            dplyr::lead(change_type) == "change_to_negative",
                          yes = (mean_x + (dist_to_next / 2)),
                          no = NA),
      neg_to_pos = ifelse(change_type == "change_to_zero" &
                            dplyr::lead(change_type) == "change_to_positive",
                          yes = (mean_x + (dist_to_next / 2)),
                          no = NA)
    ) %>%
    # Make it a dataframe
    as.data.frame()
  
  # Return that data object
  return(sizer_data)
}

# Use Function to ID Inflection Points ----

for(place in unique(data$site)) {
# for(place in "Ob") {

# Subset the full data
site <- data %>%
  dplyr::filter(site == place)

# Run it through the SiZer function
e <- SiZer::SiZer(x = site$Year, y = site$FNYield,
                  h = c(2, 10), degree = 1,
                  derv = 1, grid.length = 100)

# Put that object into the function we built
sizer_tidy <- sizer_extract(sizer_object = e)

# Now create a graph of each
## First derivative
p <- ggplot(site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x',
              se = F, color = 'black') +
  geom_vline(xintercept = sizer_tidy$mean_x, color = 'orange',
             linetype = 2, na.rm = TRUE) +
  theme_classic()

# Add the positive to negative inflection point line(s) if one exists
if(!all(is.na(sizer_tidy$pos_to_neg))){
  p <- p +
    geom_vline(xintercept = sizer_tidy$pos_to_neg, color = 'blue',
               na.rm = TRUE) }

# Add *negative to positive* inflection point line(s) if one exists
if(!all(is.na(sizer_tidy$neg_to_pos))){
  p <- p +
    geom_vline(xintercept = sizer_tidy$neg_to_pos, color = 'red',
               na.rm = TRUE) }

# Export the graph
ggplot2::ggsave(plot = p, filename = file.path(export_folder_name, paste0(place, "_plot.png")), height = 5.06, width = 5.44)

# Export the data too
write.csv(x = sizer_tidy, file = file.path(export_folder_name, paste0(place, "_numbers.csv")), na = "", row.names = F)

# Report back
message("Export complete for site: ", place)
}

# Create plots outside loop if desired
plot(e, main = "1st Derivative")
p

# End ----
