## ----------------------------------------- ##
   # `SiZer` Handling for Silica Export WG
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

# Make a test site subset
test_site <- data %>%
  dplyr::filter(site == "ALBION")

# Create a folder to save experimental outputs
export_folder_name <- "plots"
dir.create(path = export_folder_name, showWarnings = FALSE)

# Load helper functions
source(file.path("wg_silica", "sizer-helper-fxns.R"))

# Test Extraction of SiZer Data ------------------

# Invoke the SiZer::SiZer function
e <- SiZer::SiZer(x = test_site$Year, y = test_site$FNYield,
                  h = c(2, 10), degree = 1,
                  derv = 1, grid.length = 100)

# Plot the SiZer object with horizontal lines of interest
sizer_plot(sizer_object = e, bandwidth_vec = c(3, 6, 9))

# Put that object into the function we built
sizer_tidy <- sizer_aggregate(sizer_object = e)

# Test workflow to 










# Now create a graph of each
## First derivative
p <- ggplot(test_site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x',
              se = F, color = 'black') +
  geom_vline(xintercept = sizer_tidy$mean_x, color = 'orange',
             linetype = 2, na.rm = TRUE) +
  geom_vline(xintercept = sizer_tidy$pos_to_neg, color = 'blue',
             na.rm = TRUE) +
  geom_vline(xintercept = sizer_tidy$neg_to_pos, color = 'red',
             na.rm = TRUE) +
  theme_classic()





# For loop stuff:

# Make a shorter place name
place_shorthand <- stringr::str_sub(string = place, start = 1, end = 8)

# Export the graph
ggplot2::ggsave(plot = p, filename = file.path(export_folder_name, paste0(place, "_plot.png")), height = 5.06, width = 5.44)




# End ----
