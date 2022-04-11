## ----------------------------------------------------------------- ##
                            # dbplyr Tutorial
## ----------------------------------------------------------------- ##

# This contains a `dbplyr` tutorial

# Clear environment
rm(list = ls())

# Load these libraries
library(tidyverse); library(DBI); library(RSQLite)

# Tutorial #1: R, Databases & SQL ----------------------------------

# T1 - Chapter 1: DBI ----------------------------------------------
# Link: rdbsql.rsquaredacademy.com/dbi.html




# T1 - Chapter 2: dbplyr ---------------------------------------------------
# Link: rdbsql.rsquaredacademy.com/dbplyr.html

# Connect 
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Copy mtcars to database
dplyr::copy_to(con, mtcars)

# Reference data using `tbl()`
mtcars2 <- dplyr::tbl(con, "mtcars")
mtcars2

# Look at some columns
select(mtcars2, mpg, cyl, drat)

# Filter works too
filter(mtcars2, mpg > 25)

# Try summarizing
mtcars2 %>%
  group_by(cyl) %>%
  summarise(mileage = mean(mpg))

# View SQL query for a given operation
## 1) Perform operation & assign to object
mileages <- mtcars2 %>%
  group_by(cyl) %>%
  summarise(mileage = mean(mpg, na.rm = T))

## 2a) Show query
dplyr::show_query(mileages)

## 2b) Explain query
dplyr::explain(mileages)

# Interestingly, `dplyr` doesn't actually get the data into R until you explicitly ask for it (e.g., printing the object)

# To get the data into R for subsequent use, we need `collect`
dplyr::collect(mileages)

# When done with connection:
dbDisconnect(con)

# T1 - Chapter 3: SQL Basics --------------------------------------------
# Link: rdbsql.rsquaredacademy.com/sqlbasics.html



# T1 - Chapter 4: SQL Advanced ------------------------------------------
# Link: rdbsql.rsquaredacademy.com/sql2.html



# End -------------------------------------------------------------------
