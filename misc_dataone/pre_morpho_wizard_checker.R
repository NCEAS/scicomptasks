## --------------------------------------- ##
        # Use Morpho Prep Function
## --------------------------------------- ##

# Load needed libraries
# devtools::install_github("NCEAS/scicomptools", force = T)
library(scicomptools); library(gdata)

# Script explanation:
# This function is meant to identify "junk" columns that dataONE's Morpho software would flag as existing even though they are empty. It also handles user-supplied codes for missing data in the supplied dataframe

# For more information:
?scicomptools::morpho_wiz

# Run the function
# morpho_wiz(file = "",
#            read_dir = getwd(),
#            write_dir = getwd(),
#            na_code = "")
