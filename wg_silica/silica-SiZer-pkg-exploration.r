## ----------------------------------------- ##
  # Breakpoint Iteration for Silica Export WG
## ----------------------------------------- ##
# Written by: Joanna Carey & Nick J Lyon
# File original name: "SiZer_ExforNick_6.30.22"

# Housekeeping ----

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, SiZer)

# Clear environment
rm(list = ls())

# Preparation for SiZer ----

# Load data
data <- readr::read_csv(file = file.path("wg_silica", "CryoData_forNick_6.29.22.csv"))

# Subset data to look at a single site
priscu <- data %>%
  dplyr::filter(site == "Priscu Stream at B1")

# Examine names
names(priscu)

# Exploratory plot
plot(priscu$Year, priscu$FNYield)

# Using SiZer ----
## SiZer == _Si_gnificantly _Zer_o

# Create 1st order derivative to identify slope changes
e <- SiZer::SiZer(x = priscu$Year, y = priscu$FNYield,
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
e2 <- SiZer::SiZer(x = priscu$Year, y = priscu$FNYield,
                   h = c(2, 10), degree = 2,
                   derv = 2, grid.length = 50)

# Plot this one as well
plot(e2)
abline(h = 0.5)








#so once we've done this, we look at graphs to see where slopes significantly change
#(I wish model just spit out a number of x asix where slope changes so it wasn't so much "eyeballing")

#then run linear regression for periods of significant positive or neg slopes to get rate of change
#if date different for each site, is it possible to streamline this? must be! I hope!



# Joanna Carey's Code ----

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


###==========================================
#running Sizer
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
#(I wish model just spit out a number of x asix where slope changes so it wasn't so much "eyeballing")

#then run linear regression for periods of significant positive or neg slopes to get rate of change
#if date different for each site, is it possible to streamline this? must be! I hope!
