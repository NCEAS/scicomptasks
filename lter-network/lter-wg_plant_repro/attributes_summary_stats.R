## -------------------------------------------------- ##
#    Calculating & Exporting Stats for Attributes Table
## -------------------------------------------------- ##

# Purpose:
## Calculate & export various summary statistics for the data in the integrated attributes table

# run the trait_integration.R script first to get the integrated attributes table
source("trait_integration.R")

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, googledrive, rstatix, rlang)

# making a folder for our exported csvs
export_folder <- paste0("export_stats_", Sys.Date())
dir.create(path = file.path(export_folder), showWarnings = FALSE)

## -------------------------------------------------- ##
#    Calculating & Exporting Quantitative Stats
## -------------------------------------------------- ##

# calculating overall quantitative stats 
overall_stats_for_quant_atts <- all_traits %>% 
        get_summary_stats(
        Lifespan_years, Seed_mass_mg, 
        show = c("n", "min", "max", "mean", "sd"))

# exporting overall quantitative stats 
write.csv(overall_stats_for_quant_atts, file.path(export_folder, "overall_stats_for_quant_atts.csv"), row.names = FALSE)

# listing the sites we want
sites_we_want <- c("AND", "ADK", "CDR", "HBR",
                   "CWT", "HFR", "BNZ", "SEV", "LUQ")

site_stats_for_quant_atts <- list()

# calculating quantitative stats for each individual site
for (site in sites_we_want){
  some_stats <-  all_traits %>% 
    filter(!!sym(site) == 1) %>%
    get_summary_stats(
      Lifespan_years, Seed_mass_mg, 
      show = c("n", "min", "max", "mean", "sd"))
  
  site_stats_for_quant_atts[[site]] <- some_stats
  
}

# adding a 'site' column and combining all the site dataframes into one dataframe
site_stats_for_quant_atts_df <- site_stats_for_quant_atts %>%
  purrr::imap(.f = ~mutate(.x, site = paste0(.y), .before = everything())) %>%
  purrr::map_dfr(.f = select, everything())

# exporting quantitative stats for each individual site
write.csv(site_stats_for_quant_atts_df, file.path(export_folder, "site_stats_for_quant_atts.csv"), row.names = FALSE)

## -------------------------------------------------- ##
#    Calculating & Exporting Qualitative Stats
## -------------------------------------------------- ##

# listing the columns we want
columns_we_want <- c("Seed_development_1_2or3yrs", "Seed_dispersal_vector",
                     "Seed_dispersal_code",
                     "Pollinator_vector", "Pollinator_code",
                     "Mycorrhiza_AM_EM", "Needleleaf_Broadleaf",
                     "Deciduous_Evergreen_yrs", "Seed_Maturation_Phenology",
                     "Seed_Maturation_Code", "Sexual_system",
                     "Shade_tolerance", "Growth_form",
                     "Growth_habit", "Flowering_season",
                     "Seed_bank", "Fleshy_fruit",
                     "Dispersal_syndrome")

overall_stats_for_qual_atts <- list()

# calculating overall qualitative stats 
for (col in columns_we_want){
 some_stats <- all_traits %>%
  dplyr::group_by(!!sym(col)) %>%
   dplyr::summarize(count = n()) %>%
   dplyr::mutate(variable = col, .before = everything()) %>%
   dplyr::rename(value = !!sym(col))
  
 overall_stats_for_qual_atts[[col]] <- some_stats
  
}

# combining overall qualitative stats into one dataframe
overall_stats_for_qual_atts_df <- overall_stats_for_qual_atts %>%
    purrr::map_dfr(.f = select, everything())

# exporting overall qualitative stats 
write.csv(overall_stats_for_qual_atts_df, file.path(export_folder, "overall_stats_for_qual_atts.csv"), row.names = FALSE)


site_stats_for_qual_atts <- list()

# calculating qualitative stats for each individual site
for (site in sites_we_want){
  for (col in columns_we_want){
    some_stats <- all_traits %>%
      dplyr::filter(!!sym(site) == 1) %>%
      dplyr::group_by(!!sym(col)) %>%
      dplyr::summarize(count = n()) %>%
      dplyr::mutate(variable = col, .before = everything()) %>%
      dplyr::rename(value = !!sym(col))
    
    site_stats_for_qual_atts[[site]][[col]] <- some_stats
   }
}

# adding a 'site' column 
for (site in sites_we_want){
  site_stats_for_qual_atts[[site]] <- site_stats_for_qual_atts[[site]] %>% 
    purrr::map_dfr(.f = select, everything()) %>%
    dplyr::mutate(site = site, .before = everything())
  }

# combining all the site dataframes into one dataframe
site_stats_for_qual_atts_df <- site_stats_for_qual_atts %>%
  purrr::map_dfr(.f = select, everything())

# exporting qualitative stats for each individual site
write.csv(site_stats_for_qual_atts_df, file.path(export_folder, "site_stats_for_qual_atts.csv"), row.names = FALSE)

# End ----


