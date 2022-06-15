# Facilitating Pre-Morpho Wrangling

## !!WARNING!!

"Morpho" refers to dataONE's metadata software **NOT** the 2022 NCEAS working group request for proposals of the same name. See [here](https://old.dataone.org/software-tools/morpho) for the Morpho these scripts are meant to deal with.

## Script explanation

**"pre_morpho_wizard_fxn.R"**

- R script containing a function for doing useful pre-processing before submitting to dataONE's Morpho wizard. "Useful pre-processing" includes:
    - Identifies junk columns (i.e., columns without real entries that R reads in as "X.1"/"V1"/etc.)
    - Identifies type of numeric data
    - Flags the codes in data that indicate missing values

**"pre_morpho_wizard_checker.R"**

- R script invoking the pre_wizard function to demonstrate to users what it does
