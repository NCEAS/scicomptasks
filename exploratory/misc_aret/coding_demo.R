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
    # if species is "Coastal giant salamander" and length is less than 42mm, categorize it as "Short"
    species == "Coastal giant salamander" & length_1_mm < 42 ~ "Short",
    # if species is "Coastal giant salamander" and length between 42mm and 67mm, categorize it as "Medium"
    species == "Coastal giant salamander" & length_1_mm >= 42 & length_1_mm < 67 ~ "Medium",
    # etc ...
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

