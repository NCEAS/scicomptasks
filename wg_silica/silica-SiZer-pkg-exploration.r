## ----------------------------------------- ##
  # Breakpoint Iteration for Silica Export WG
## ----------------------------------------- ##
# Written by: Joanna Carey & Nick J Lyon
# File original name: "SiZer_ExforNick_6.30.22"

# Housekeeping ----

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, SiZer, cowplot)

# Clear environment
rm(list = ls())

# Preparation for SiZer ----

# Load data
data <- readr::read_csv(file = file.path("wg_silica", "CryoData_forNick_6.29.22.csv"))

# Subset data to look at a single site
example_site <- data %>%
  dplyr::filter(site == "Lena")

# Examine names
names(example_site)

# Exploratory plot
plot(example_site$Year, example_site$FNYield)

# Using SiZer ----
## SiZer == _Si_gnificantly _Zer_o

# Create 1st order derivative to identify slope changes
e <- SiZer::SiZer(x = example_site$Year, y = example_site$FNYield,
                  h = c(2, 10), degree = 1,
                  derv = 1, grid.length = 100)

# Plot it
plot(e)
# Add bandwidth to see where X-axis (year) slope changes
abline(h = 0.5)
## Blue = sign + slope
## Red = sign - slope
## Purple = slope possibly zero
## Gray = not enough data

# Do 2nd order derivative to find an inflection point
## Where this shifts from + to - (or vice versa) is inflection point
e2 <- SiZer::SiZer(x = example_site$Year, y = example_site$FNYield,
                   h = c(2, 10), degree = 2,
                   derv = 2, grid.length = 50)

# Plot this one as well
plot(e2)
abline(h = 0.5)

# Extract Needed Data from SiZer Object -----
# Do a side-by-side plot of trendline with SiZer plot
par(mfrow = c(1, 3))
plot(example_site$Year, example_site$FNYield)
plot(e, main = "1st Derivative")
plot(e2, main = "2nd Derivative")
par(mfrow = c(1, 1))

# Check structure of SiZer Object
str(e)

# Strip slope values into dataframe
sizer_slopes <- as.data.frame(e$slopes)
## Increasing = 1, Possibly Zero = 0,
## Decreasing = -1, Not Enough Data = 2

# Columns are increasing x-axis (left to right)
names(sizer_slopes) <- e$x.grid

# Rows are increasing bandwidth (top to bottom)
sizer_slopes$h_grid <- e$h.grid

# Wrangle this a bit
sizer_df <- sizer_slopes %>%
  # Pivot to long format to make it a little easier to scan through
  tidyr::pivot_longer(cols = -h_grid,
                      names_to = "x_grid",
                      values_to = "slope") %>%
  # Drop all 'insufficient data' rows
  dplyr::filter(slope != 2)

# Examine output
head(sizer_df)
unique(sizer_df$slope)

# Now time to identify state transitions (i.e, change in slope)
sizer_df_v2 <- sizer_df %>%
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
    transition == "change" & slope == 1 ~ 'zero_to_positive',
    transition == "change" & slope == 0 ~ 'change_to_zero',
    transition == "change" & slope == -1 ~ 'zero_to_negative')) %>%
  # End by ungrouping (good practice)
  dplyr::ungroup()

# Take a look at what that yields
as.data.frame(dplyr::filter(sizer_df_v2, h_grid == 2))

# Filter to only those that indicate a state change
sizer_transitions <- sizer_df_v2 %>%
  dplyr::filter(transition == "change"
                # Un-comment below if want to see value before change
                # | dplyr::lead(transition, n = 1) == "change"
                )

# Look at one group of this now
as.data.frame(dplyr::filter(sizer_transitions, h_grid == 2))

# Let's test a method of summarizing across bandwidths
sizer_test <- sizer_transitions %>%
  # Group by change type
  dplyr::group_by(change_type) %>%
  # And average the x_grid value
  dplyr::summarise(slope = dplyr::first(slope),
                   mean_x = mean(as.numeric(x_grid), na.rm = T),
                   sd_x = sd(as.numeric(x_grid), na.rm = T),
                   n_x = dplyr::n(),
                   se_x = sd_x / n_x)

# Check out output
head(sizer_test)

# Now call the original plot of the trendline and add a line at these places
## Graph the yield data
ggplot(example_site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x', se = F, color = 'black') +
  # Add an orange line for the lower SE of each inflection point
  geom_vline(xintercept = (sizer_test$mean_x - sizer_test$se_x),
             color = 'orange') +
  # Add a blue line for the *upper* SE of each inflection pt
  geom_vline(xintercept = (sizer_test$mean_x + sizer_test$se_x),
             color = 'blue') +
  # Add pale blue rectangles for the standard *deviation* of each inflection point
  annotate(geom = 'rect', xmin = (sizer_test$mean_x - sizer_test$sd_x),
           xmax = (sizer_test$mean_x + sizer_test$sd_x), ymin = -Inf,
           ymax = Inf, alpha = 0.2, fill = 'blue') +
  # Add one more line for the mean inflection point
  geom_vline(xintercept = sizer_test$mean_x, color = 'white') +
  # Clean up the theme
  theme_classic()

# Make a simpler version as well
ggplot(example_site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x',
              se = F, color = 'black') +
  geom_vline(xintercept = sizer_test$mean_x, color = 'blue') +
  theme_classic()

# Identify (Singular) Inflection Point ----

# Check out the object we'll use to calculate this inflection pt
sizer_test

# Want to divide distance between each in half
sizer_singular <- sizer_test %>%
  # Sort from lowest to highest X
  dplyr::arrange(mean_x) %>%
  # Calculate distance to next one
  dplyr::mutate( dist_to_next = dplyr::lead(x = mean_x) - mean_x ) %>%
  # Add half the distance between +/0 and 0/- to +/0 to get +/- inflection point
  dplyr::mutate(
    pos_to_neg = ifelse(change_type == "change_to_zero" & dplyr::lead(change_type) == "zero_to_negative",
                 yes = (mean_x + (dist_to_next / 2)),
                 no = NA) )

# Take a look!
sizer_singular

# Graph it
ggplot(example_site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x',
              se = F, color = 'black') +
  geom_vline(xintercept = sizer_singular$pos_to_neg, color = 'blue') +
  geom_vline(xintercept = sizer_test$mean_x, color = 'orange') +
  theme_classic()

# SiZer Extract Function ----

# Read in a function to streamline the above
source(file.path("wg_silica", "sizer-helper-fxns.R"))

# Test the function
fxn_test <- sizer_extract(sizer_object = e)
fxn_test

# Create the demo plot (should be identical to previous plot)
ggplot(example_site, aes(x = Year, y = FNYield)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = 'y ~ x',
              se = F, color = 'black') +
  geom_vline(xintercept = fxn_test$pos_to_neg, color = 'blue',
             na.rm = TRUE) +
  geom_vline(xintercept = fxn_test$neg_to_pos, color = 'red',
             na.rm = TRUE) +
  geom_vline(xintercept = fxn_test$mean_x, color = 'orange',
             linetype = 2, na.rm = TRUE) +
  theme_classic()

# SiZer Loop Test ----

# Now that we have a function, let's loop through it!

# First create a folder to save experimental plots to
dir.create(path = "plots", showWarnings = FALSE)

# And clear the environment of everything except for the function
rm(list = setdiff(ls(), "sizer_extract"))

# Load the data again
data <- readr::read_csv(file = file.path("wg_silica", "CryoData_forNick_6.29.22.csv"))

# How many sites are there?
unique(data$site)

# Okay, now it's for loop time
for(place in unique(data$site)) {
# for(place in "ALBION"){ # testing loop head

  # Subset the full data
  site <- data %>%
    dplyr::filter(site == place)

  # Run SiZer on that subset
  sizer_raw <- SiZer::SiZer(x = site$Year, y = site$FNYield,
                    h = c(2, 10), degree = 1,
                    derv = 1, grid.length = 100)

  # Apply it to the function for the first derivative
  sizer_tidy <- sizer_extract(sizer_object = sizer_raw)

  # Now create a graph of each
  p <- ggplot(site, aes(x = Year, y = FNYield)) +
    geom_point() +
    geom_smooth(method = 'loess', formula = 'y ~ x',
                se = F, color = 'black') +
    geom_vline(xintercept = sizer_tidy$mean_x, color = 'orange',
               linetype = 2) +
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

  # Save both
  ggplot2::ggsave(plot = p, filename = file.path("plots", paste0(place, "_plot.png")), height = 5.06, width = 5.44)

  # Return a success message
  message("Breakpoints identified for site: ", place)
}

# Polynomial Component ----

# SiZer has an answer for locally-weighted polynomials as well
?SiZer::locally.weighted.polynomial



#so once we've done this, we look at graphs to see where slopes significantly change
#(I wish model just spit out a number of x asix where slope changes so it wasn't so much "eyeballing")

#then run linear regression for periods of significant positive or neg slopes to get rate of change
#if date different for each site, is it possible to streamline this? must be! I hope!



# Joanna Carey's Code - SetUp ----

##Trying to get SiZer to work for Si cryo paper
#first looking at annaul WRTDS Si model results

setwd("~/LNO_Si_Synthesis/CyroAnalysis_2022")
Data<-readr::read_csv('WRTDS_GFN_AnnualResults_AllSites_062822.csv')

library(SiZer)

#subset data to look at just one site
Priscu<-subset(Data, Data$site=="Priscu Stream at B1")
names(Priscu)

#let's get idea of what data looks like to make sure Sizer plots look reasonable
plot(Priscu$Year, Priscu$FNYield)


# Joanna Carey's Code - Running SiZer ----
#1st order derivative to look at where we have significant slope changes
e<-SiZer(Priscu$Year, Priscu$FNYield, h=c(2,10), degree=1, derv=1, grid.length = 100)
plot(e)
abline(h=0.5) #plotting the bandwidth, to see where on X axis (year) slope changes
#blue = sign pos slope, red = sign negative slope, purple = slope possibly zero, gray = not enough data


#2nd order derivative allows one to find inflection point, where slope changes from concave up to down (or visa versa)
#Where sign of 2nd order derivative shifts from pos to neg (or visa versa) that's the inflection point

#not as useful for this dataset but could be for others
e2<-SiZer(Priscu$Year, Priscu$FNYield, h=c(2,10), degree=2, derv=2, grid.length = 50)
plot(e2)
abline(h=0.5) #plotting the bandwidth


#so once we've done this, we look at graphs to see where slopes significantly change
#(I wish model just spit out a number of x axis where slope changes so it wasn't so much "eyeballing")

#then run linear regression for periods of significant positive or neg slopes to get rate of change
#if date different for each site, is it possible to streamline this? must be! I hope!
