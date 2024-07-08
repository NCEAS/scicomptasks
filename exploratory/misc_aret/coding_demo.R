## ------------------------------------------------------- ##
#                    Data Exploration ----
## ------------------------------------------------------- ##

# load in R packages
library(lterdatasampler)
library(tidyverse)

# prints the column names of my data
colnames(and_vertebrates)

# first 6 lines of the data
head(and_vertebrates)

# summary of each column of data
summary(and_vertebrates)

# prints unique values in a column (in this case, the species)
unique(and_vertebrates$species)

# opens data frame in its own tab to see each row and column of the data (do in console)
# View(and_vertebrates)

## ------------------------------------------------------- ##
#                    Data Wrangling ----
## ------------------------------------------------------- ##

vert_categories <- and_vertebrates %>%
  # filter out rows that contain Cascade torrent salamander
  filter(species != "Cascade torrent salamander") %>%
  # create a new column called "length_category" according to the conditions below
  mutate(length_category = case_when(
    # if species is "Cascade torrent salamander" and length is less than 32.5mm, categorize it as "Short"
    species == "Cascade torrent salamander" & length_1_mm < 32.5 ~ "Short",
    # if species is "Cascade torrent salamander" and length between 32.5mm and 39.5mm, categorize it as "Medium"
    species == "Cascade torrent salamander" & length_1_mm >= 32.5 & length_1_mm < 39.5 ~ "Medium",
    # etc ...
    species == "Cascade torrent salamander" & length_1_mm >= 39.5 ~ "Long",
    species == "Coastal giant salamander" & length_1_mm < 42 ~ "Short",
    species == "Coastal giant salamander" & length_1_mm >= 42 & length_1_mm < 67 ~ "Medium",
    species == "Coastal giant salamander" & length_1_mm >= 67 ~ "Long",
    species == "Cutthroat trout" & length_1_mm < 49 ~ "Short",
    species == "Cutthroat trout" & length_1_mm >= 49 & length_1_mm < 110~ "Medium",
    species == "Cutthroat trout" & length_1_mm >= 110 ~ "Long",
    T ~ NA
  )) 

# check dataframe
# View(vert_categories)

# How many vertebrates are in each of the length categories across species and site?
vert_categories_count <- vert_categories %>%
  # keep the rows where the species and length_category columns are non-empty
  filter(!is.na(species) & !is.na(length_category)) %>%
  # group by sitecode, species, and length_category
  group_by(sitecode, species, length_category) %>%
  # count how many rows are in each grouping
  summarize(count = n())

# check dataframe
# View(vert_categories_count)

## ------------------------------------------------------- ##
#                    Data Visualization ----
## ------------------------------------------------------- ##

# Are you more prone to catching vertebrates of certain lengths at some sites?

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
