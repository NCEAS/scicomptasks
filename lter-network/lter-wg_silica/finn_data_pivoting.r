# Load libraries
library(tidyverse)
  ## ggplot2 and dplyr are packages that are automatically loaded by `library(tidyverse)` so you can skip naming them separately (if desired)

# Import data ----

# Bring in Finnish data
FinnData <- readr::read_csv(file.path("wg_silica", "FinnishChemData_08022022.csv"))

# Check structure
str(FinnData) #date is a character and Station.name is chr

# Wrangle data ----

# Make sure date formatting is correct
FinnData$Date2 <- as.Date(FinnData$Date, "%m/%d/%Y")
str(FinnData)

# NOTE:
## Part of the reason the pivot is so hard is because several columns are closely related to the "Parameter" column so that when "Parameter" becomes the column names they introduce all of these NA rows for the other Parameters. The primary offender appears to be "Unit" because each parameter seems to use a single consistent unit (or consistently unknown units). I think if we collapse these columns together (parameter & unit) we can make *that* new column into our column names (and drop the old columns) without introducing all those weird NA columns (or at least fewer).

# Let's first combine Parameter with Units
length(unique(FinnData$Parameter)) # 9 parameters
length(unique(paste0(FinnData$Parameter, "__",FinnData$Unit))) # 9 parameter + units (meaning all parameters each use only one unit)

# However, we'll need to fix the micrograms because the CSV didn't read that special character in correctly
unique(FinnData$Unit)

# Fix the units
FinnData$Unit2 <- gsub("\xb5g/l", "microgram/l", FinnData$Unit)

# Combine the fixed units with parameters
FinnData$Parameter2 <- ifelse(test = is.na(FinnData$Unit),
                              # If units are missing, handle that
                              yes = paste0(FinnData$Parameter, "_unknown-units"),
                              # If units are not missing, include them!
                              no = paste0(FinnData$Parameter, "_", FinnData$Unit2) )

# Check it out!
unique(FinnData$Parameter2)

# Pivot data ----

# Keep only needed columns (i.e., remove those we have replaced with wrangled variants)
FinnData_simp <- select(.data = FinnData, Id:Longitude, Date2, Depth, Pretreatment, `Analytical method code`, Level, Parameter2)
str(FinnData_simp)

# Check to make sure we didn't lose anything by accident (that we wanted to keep)
setdiff(names(FinnData), names(FinnData_simp))
## Looks great! All that info is in "Date2" or "Parameter2"

# Make it wide format
FinnData_wide <- FinnData_simp %>%
  dplyr::mutate(row = dplyr::row_number()) %>%
  tidyr::pivot_wider(names_from = Parameter2, values_from = Level)

# Check that out
str(FinnData_wide)
## Ready for export (maybe?)

# Joanna Carey code ----

#exploring the macrosheds and finnish river data

library(ggplot2)
library(tidyverse)
library(dplyr)

setwd("~/LNO_Si_Synthesis/CyroAnalysis_2022")

################
#importing finnish data to explore it
FinnData<-readr::read_csv('FinnishChemData_08022022.csv')
str(FinnData) #date is a character and Station.name is chr
FinnData$Date2<-as.Date(FinnData$Date, "%m/%d/%Y")
names(FinnData)

#getting rid of columns don't need for master file b/c struggling to turn long data wide
FinnData<-subset(FinnData, select=c(Id, Station.name, Parameter, Date2, Level))

unique(FinnData$Parameter)

#need to make long data wide (turn each paramters into individual column)
FinnDataLong5 <- FinnData %>%
  group_by(Parameter) %>%
  mutate(row = row_number()) %>%
  tidyr::pivot_wider(names_from = Parameter, values_from = c(Level, Date2))
#this kind of works, I think?

