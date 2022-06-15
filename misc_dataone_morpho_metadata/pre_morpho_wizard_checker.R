## --------------------------------------- ##
        # Use Morpho Prep Function
## --------------------------------------- ##

# Load needed libraries
library(gdata)

# Script Instructions -----------------------

# Use this script by following these instructions:

# 1) Enter the path variables within the following section *using absolute paths
# 2) Specify the custom code in the data used for missing values (UNLESS missing data are signified by empty cells and/or NAs)
# 3) Source the pre-morpho wizard function script
# 4) Run the pre-morpho wizard function on a directory containing your data
# 5) Open those data in Excel and remove the junk columns manually
# 6) Repeat steps 4-6 until no more issues are identified

# Identify User-Dependent Variables ---------

# Absolute path to folder containing this script and the function script
scripts_path <- file.path("")

# Absolute path to your data-file input
read_dir <- file.path("")

# Absolute path to the directory in which to write script outputs
write_dir <- file.path("")

# A custom string used in your data to indicate any missing data. If your data represents missing values by empty cells, or even R's "NA" (without the quotes), then do not modify this variable's value.
custom_code <- ""

# Clean the environment to retain only these values
gdata::keep(scripts_path, read_dir, write_dir, custom_code, sure = TRUE)

# Use the Wizard Function -----------------

# Source the function script
source(file.path(scripts_path, "WriteUniqueFieldValues.R"))

# Call the function with the strings you defined above
WriteUniqueFieldValues(.read_dir = read_dir,
                       .write_dir = write_dir,
                       .missing_code = custom_code)
