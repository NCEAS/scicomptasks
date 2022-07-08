## ----------------------------------------- ##
  # Breakpoint Iteration for Silica Export WG
## ----------------------------------------- ##
# Written by: Nick J Lyon

# Housekeeping ----

# Load libraries
install.packages("librarian")
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
sizer_extract <- function(sizer_x = NULL, sizer_y = NULL,
                          deriv = 1, bandwidth = c(2, 10)){
  ## Argument explanation
  # sizer_x = data$column specification of x-axis of trend line
  # sizer_y = data$column specification of y-axis
  # deriv = (numeric) specification of derivative for `SiZer::SiZer`

  # Error out if arguments aren't specified
  if(is.null(sizer_x) | is.null(sizer_y))
    stop("All arguments must be specified")

  # Error out for unsupported derivative
  if(!as.numeric(deriv) %in% c(1, 2))
    stop("Unsupported derivative! Must be either 1 or 2")

  # Identify inflection points (for either derivative)
  if(as.numeric(deriv) == 1){
    sizer_mod <- SiZer::SiZer(x = sizer_x, y = sizer_y,
                              h = bandwidth, degree = 1,
                              derv = 1, grid.length = 100) }
  if(as.numeric(deriv) == 2){
    sizer_mod <- SiZer::SiZer(x = sizer_x, y = sizer_y,
                              h = bandwidth, degree = 2,
                              derv = 2, grid.length = 50) }

  # Strip out the relevant information
  sizer_raw <- as.data.frame(sizer_mod$slopes)
  names(sizer_raw) <- sizer_mod$x.grid
  sizer_raw$h_grid <- sizer_mod$h.grid

  # Perform necessary wrangling
  sizer_data <- sizer_raw %>%
    # Pivot to long format to make it a little easier to scan through
    tidyr::pivot_longer(cols = -h_grid,
                        names_to = "x_grid",
                        values_to = "slope") %>%
    # Drop all 'insufficient data' rows
    dplyr::filter(slope != 2) %>%
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
    # Lets also identify what type of change the transition was
    dplyr::mutate(change_type = dplyr::case_when(
      transition == "change" & slope == 1 ~ 'change_to_positive',
      transition == "change" & slope == 0 ~ 'change_to_zero',
      transition == "change" & slope == -1 ~ 'change_to_negative')) %>%
    # Account for if multiple of the same change happen in a curve
    dplyr::group_by(h_grid, change_type) %>%
    dplyr::mutate(change_count = seq_along(unique(x_grid))) %>%
    # Ungroup for subsequent operations
    dplyr::ungroup() %>%
    # Filter to retain only those rows that indicate a slope change
    dplyr::filter(transition == "change") %>%
    # Group by change type
    dplyr::group_by(change_count, change_type) %>%
    # And average the x_grid value
    dplyr::summarise(slope = dplyr::first(slope),
                     mean_x = mean(as.numeric(x_grid), na.rm = T),
                     sd_x = sd(as.numeric(x_grid), na.rm = T),
                     n_x = dplyr::n(),
                     se_x = sd_x / n_x,
                     .groups = 'keep') %>%
    # Ungroup
    dplyr::ungroup() %>%
    # Filter out lines that don't show up a lot
    dplyr::filter(n_x > 10) %>%
    # Sort from lowest to highest X
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

# Apply it to the function for the first derivative
first_drv <- sizer_extract(sizer_x = site$Year,
                           sizer_y = site$FNYield,
                           deriv = 1, bandwidth = c(2, 10))
# Change bandwidth here -------------------------> (^^^) ----

# Use the actual function
e <- SiZer::SiZer(x = site$Year, y = site$FNYield,
                  h = c(2, 10), degree = 1,
                  derv = 1, grid.length = 100)

# Now create a graph of each
## First derivative
p <- ggplot(site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x',
              se = F, color = 'black') +
  geom_vline(xintercept = first_drv$mean_x, color = 'orange') +
  theme_classic()

# Add the positive to negative inflection point line(s) if one exists
if(!all(is.na(first_drv$pos_to_neg))){
  p <- p +
    geom_vline(xintercept = first_drv$pos_to_neg, color = 'blue',
               na.rm = TRUE) }

# Add *negative to positive* inflection point line(s) if one exists
if(!all(is.na(first_drv$neg_to_pos))){
  p <- p +
    geom_vline(xintercept = first_drv$neg_to_pos, color = 'red',
               na.rm = TRUE) }

# Export the graph
ggplot2::ggsave(plot = p, filename = file.path(export_folder_name, paste0(place, "_first-drv_plot.png")), height = 5.06, width = 5.44)

# Export the data too
write.csv(x = first_drv, file = file.path(export_folder_name, paste0(place, "_first-drv_numbers.csv")), na = "", row.names = F)

# Report back
message("Export complete for site: ", place)

}

# Create plots outside loop if desired
plot(e, main = "1st Derivative")
p

# End ----
