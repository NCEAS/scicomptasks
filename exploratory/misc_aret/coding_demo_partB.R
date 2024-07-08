## ---------------------------------------- ##
          # Coding Demo - Part B
## ---------------------------------------- ##

# Load needed packages
library(tidyverse); library(lterdatasampler)

# "Catch up" with Angel's code demo
source(file.path("exploratory", "misc_aret", "coding_demo_partA.R"))

# Check structure of starting data
str(vert_categories)

## ---------------------------------------- ##
              # Demo Graphs ----
## ---------------------------------------- ##

# Make a boxplot
ggplot(data = vert_categories, mapping = aes(x = species, y = length_1_mm, fill = species)) +
  geom_boxplot()

# Make violin plots with the same aesthetics
ggplot(data = vert_categories, mapping = aes(x = species, y = length_1_mm, fill = species)) +
  geom_violin()

## ---------------------------------------- ##
            # Basement ----
## ---------------------------------------- ##

# indicate variables of interest in my plot
ggplot(data = vert_categories_count,
       mapping = aes(x = species, y = count, fill = length_category)) +
  # make it into a bar plot
  geom_col() +
  # set a built-in theme
  theme_classic() +
  # make multiple plots according to site
  facet_wrap(~sitecode) +
  # adjust labels
  labs(x = "Species",
       y = "Count",
       fill = "Length Category",
       title = "Number of vertebrates caught across site by length category") +
  # adjust x-axis label rotation
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

# How about checking the correlation between vertebrate length and weight?

# indicate variables of interest in my plot
ggplot(data = vert_categories,
       mapping = aes(x = length_1_mm, y = weight_g, color = species)) +
  # make it into a scatter plot
  geom_point() +
  # set a built-in theme
  theme_classic() +
  # adjust labels
  labs(x = "Length",
       y = "Weight",
       fill = "Species",
       title = "Vertebrate length versus weight")

# End ----

