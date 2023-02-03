################################################
# Cross species correlations and traits
# Data management - getting the data ready for analysis
# 
# January 18 2023
#
################### R.S. Snell #################

library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(googledrive)

####
# Note: can start at line ~ 180 and make some graphs. 

#### download files from Google drive

# # species correlations in "all data/tidy data/"
# folder_url<- "https://drive.google.com/drive/folders/1aPdQBNlrmyWKtVkcCzY0jBGnYNHnwpeE"
# folder <- drive_get(as_id(folder_url), shared_drive = "LTER-WG_Plant_Reproduction")
# csv_files <- drive_ls(folder, type = "csv")
# walk(csv_files$id, ~ drive_download(as_id(.x), overwrite=TRUE))
# 
# pair_cor<- read.csv("pairwise_corr.csv")
# mast_summary<- read.csv("masting_summary_stats.csv")
# 
# 
# # trait data in "LTER Synthesis - 1st Paper - Synchrony & Species Attributes/Team #2 - Attributes/" 
# folder_url<- "https://drive.google.com/drive/folders/1PGaPAkNz1lmvZQMwwthmS-ZjQ97BS2Am"
# folder <- drive_get(as_id(folder_url), shared_drive = "LTER-WG_Plant_Reproduction")
# csv_files <- drive_ls(folder, type = "csv")
# walk(csv_files$id, ~ drive_download(as_id(.x), overwrite=TRUE))
# 
# traits <- read.csv("LTER_integrated_attributes_USDA_2022-12-14.csv")
# 
# # phylogeny distance data
# folder_url<- "https://drive.google.com/drive/u/0/folders/1IVY6i79REaF59kZEBbrJCRNOlcxE7Tel"
# folder <- drive_get(as_id(folder_url), shared_drive = "LTER-WG_Plant_Reproduction")
# csv_files <- drive_ls(folder, type = "csv")
# walk(csv_files$id, ~ drive_download(as_id(.x), overwrite=TRUE))
# 
# phylo <- read.csv("phylo distance matrix.csv")
# 
# # reshape the phylo data (from matrix to long)
# # There is an issue with the column name Dolichandra_unguis-cati 
# # R is changing the - to a . which is causing issues during the merge later.
# # Line 50 below, changes it back.
# phylo_reshape <- phylo %>%
#   pivot_longer(2:105, names_to = "SpeciesY", values_to = "Phylo_distance") %>%
#   mutate(SpeciesY = case_when(
#     SpeciesY =="Dolichandra_unguis.cati" ~ "Dolichandra_unguis-cati",
#     TRUE ~ SpeciesY)) %>%
#   mutate(Species1 = gsub("_",".",X),
#          Species2 = gsub("_",".",SpeciesY)) %>%
#   select(Species1, Species2, Phylo_distance)
# 
# 
# # merge the correlation data with trait data, and select just the traits we want. 
# traits <- traits %>%
#   mutate(Species.Name = gsub(" ",".",species))
# 
# head(pair_cor)
# 
# trait_sub <- traits %>%
#   select(Species.Name, Seed_development_1_2or3yrs,Pollinator_code,Mycorrhiza_AM_EM,
#          Needleleaf_Broadleaf,Deciduous_Evergreen_yrs,Dispersal_syndrome,
#          Sexual_system, Shade_tolerance, Growth_form, Fleshy_fruit, Seed_bank,Seed_mass_mg)
# 
# mast_metric_sub <- mast_summary %>%
#   select(lter, Species.Name, Plot.ID,CV.raw,ACL1.raw)
# 
# # For categorical traits: 1 = same trait, 0 = different trait
# # For numeric traits: 1 = most similar, 0 = most different. 
# # The formula was used for numeric values: 1 - (Sp1_value - Sp2_value)/MAX_value_at_the_lter_site
# 
# merge_cor <- pair_cor %>%
#   filter(overlap>=10)%>%
#   left_join(trait_sub, by =c("Species1"="Species.Name")) %>%
#   left_join(mast_metric_sub, by = c("lter"="lter", "Plot.ID"="Plot.ID", "Species1"="Species.Name"))%>%
#   rename(Pollinator_code_Sp1 = Pollinator_code,
#          Seed_development_1_2or3yrs_Sp1 = Seed_development_1_2or3yrs,
#          Mycorrhiza_AM_EM_Sp1 = Mycorrhiza_AM_EM,
#          Needleleaf_Broadleaf_Sp1 = Needleleaf_Broadleaf,
#          Deciduous_Evergreen_yrs_Sp1 = Deciduous_Evergreen_yrs,
#          Dispersal_syndrome_Sp1 = Dispersal_syndrome,
#          Sexual_system_Sp1 = Sexual_system, 
#          Shade_tolerance_Sp1 = Shade_tolerance, 
#          Growth_form_Sp1 = Growth_form,
#          Fleshy_fruit_Sp1 = Fleshy_fruit, 
#          Seed_bank_Sp1 = Seed_bank,
#          Seed_mass_Sp1 = Seed_mass_mg,
#          CV_Sp1 = CV.raw,
#          ACL1_Sp1 = ACL1.raw) %>%
#   left_join(trait_sub, by =c("Species2"="Species.Name")) %>%
#   left_join(mast_metric_sub, by = c("lter"="lter", "Plot.ID"="Plot.ID", "Species2"="Species.Name"))%>%
#     rename(Pollinator_code_Sp2 = Pollinator_code,
#          Seed_development_1_2or3yrs_Sp2 = Seed_development_1_2or3yrs,
#          Mycorrhiza_AM_EM_Sp2 = Mycorrhiza_AM_EM,
#          Needleleaf_Broadleaf_Sp2 = Needleleaf_Broadleaf,
#          Deciduous_Evergreen_yrs_Sp2 = Deciduous_Evergreen_yrs,
#          Dispersal_syndrome_Sp2 = Dispersal_syndrome,
#          Sexual_system_Sp2 = Sexual_system, 
#          Shade_tolerance_Sp2 = Shade_tolerance, 
#          Growth_form_Sp2 = Growth_form,
#          Fleshy_fruit_Sp2 = Fleshy_fruit, 
#          Seed_bank_Sp2 = Seed_bank,
#          Seed_mass_Sp2 = Seed_mass_mg,
#          CV_Sp2 = CV.raw,
#          ACL1_Sp2 = ACL1.raw) %>%
#     mutate(Pollinator_code_shared = ifelse(Pollinator_code_Sp1 == Pollinator_code_Sp2, 1,0),
#          Seed_development_shared = ifelse(Seed_development_1_2or3yrs_Sp1 == Seed_development_1_2or3yrs_Sp2, 1,0),
#          Mycorrhiza_shared = ifelse(Mycorrhiza_AM_EM_Sp1 == Mycorrhiza_AM_EM_Sp2, 1,0),
#          Needleleaf_Broadleaf_shared = ifelse(Needleleaf_Broadleaf_Sp1 == Needleleaf_Broadleaf_Sp2, 1,0),
#          Deciduous_Evergreen_shared = ifelse(Deciduous_Evergreen_yrs_Sp1 == Deciduous_Evergreen_yrs_Sp2, 1,0),
#          Dispersal_syndrome_shared = ifelse(Dispersal_syndrome_Sp1 == Dispersal_syndrome_Sp2, 1,0),
#          Sexual_system_shared = ifelse(Sexual_system_Sp1 == Sexual_system_Sp2, 1,0), 
#          Shade_tolerance_shared = ifelse(Shade_tolerance_Sp1 == Shade_tolerance_Sp2, 1,0), 
#          Growth_form_shared = ifelse(Growth_form_Sp1 == Growth_form_Sp2, 1,0), 
#          Fleshy_fruit_shared = ifelse(Fleshy_fruit_Sp1 == Fleshy_fruit_Sp2, 1,0),  
#          Seed_bank_shared = ifelse(Seed_bank_Sp1 == Seed_bank_Sp2, 1,0))%>%
#   group_by(lter)%>% # divide by max value for each site (seed mass, CV and ACL1)
#   mutate(maxSeed = max(Seed_mass_Sp1,Seed_mass_Sp2),
#          Seed_mass_similarity = 1 - abs((Seed_mass_Sp1 - Seed_mass_Sp2)/maxSeed),
#          maxCV = max(CV_Sp1,CV_Sp2),
#          CV_similarity = 1 - abs((CV_Sp1 - CV_Sp2)/maxCV)) %>%
#   ungroup()%>%
#   mutate(maxACL1 = pmax(ACL1_Sp1,ACL1_Sp2),
#           minACL1 = pmin(ACL1_Sp1,ACL1_Sp2),
#           ACL1_similarity = 1-(maxACL1 - minACL1),
#           Pollinator_code_values = ifelse(Pollinator_code_Sp1<Pollinator_code_Sp2,
#                                          paste(Pollinator_code_Sp1,Pollinator_code_Sp2, sep="-"),
#                                          paste(Pollinator_code_Sp2,Pollinator_code_Sp1, sep="-")),
#          Seed_development_values = ifelse(Seed_development_1_2or3yrs_Sp1<Seed_development_1_2or3yrs_Sp2,
#                                           paste(Seed_development_1_2or3yrs_Sp1,Seed_development_1_2or3yrs_Sp2, sep="-"),
#                                          paste(Seed_development_1_2or3yrs_Sp2,Seed_development_1_2or3yrs_Sp1, sep="-")),
#          Mycorrhiza_values = ifelse(Mycorrhiza_AM_EM_Sp1<Mycorrhiza_AM_EM_Sp2,
#                                     paste(Mycorrhiza_AM_EM_Sp1,Mycorrhiza_AM_EM_Sp2, sep="-"),
#                                     paste(Mycorrhiza_AM_EM_Sp2,Mycorrhiza_AM_EM_Sp1, sep="-")),
#          Needleleaf_Broadleaf_values = ifelse(Needleleaf_Broadleaf_Sp1<Needleleaf_Broadleaf_Sp2,
#                                           paste(Needleleaf_Broadleaf_Sp1,Needleleaf_Broadleaf_Sp2, sep="-"),
#                                           paste(Needleleaf_Broadleaf_Sp2,Needleleaf_Broadleaf_Sp1, sep="-")),
#          Deciduous_Evergreen_values = ifelse(Deciduous_Evergreen_yrs_Sp1<Deciduous_Evergreen_yrs_Sp2,
#                                           paste(Deciduous_Evergreen_yrs_Sp1,Deciduous_Evergreen_yrs_Sp2, sep="-"),
#                                           paste(Deciduous_Evergreen_yrs_Sp2,Deciduous_Evergreen_yrs_Sp1, sep="-")),
#          Dispersal_syndrome_values = ifelse(Dispersal_syndrome_Sp1<Dispersal_syndrome_Sp2,
#                                           paste(Dispersal_syndrome_Sp1,Dispersal_syndrome_Sp2, sep="-"),
#                                           paste(Dispersal_syndrome_Sp2,Dispersal_syndrome_Sp1, sep="-")),
#          Sexual_system_values = ifelse( Sexual_system_Sp1< Sexual_system_Sp2,
#                                           paste( Sexual_system_Sp1, Sexual_system_Sp2, sep="-"),
#                                           paste( Sexual_system_Sp2, Sexual_system_Sp1, sep="-")),
#          Shade_tolerance_values = ifelse(Shade_tolerance_Sp1<Shade_tolerance_Sp2,
#                                           paste(Shade_tolerance_Sp1,Shade_tolerance_Sp2, sep="-"),
#                                           paste(Shade_tolerance_Sp2,Shade_tolerance_Sp1, sep="-")),
#          Growth_form_values = ifelse(Growth_form_Sp1<Growth_form_Sp2,
#                                           paste(Growth_form_Sp1,Growth_form_Sp2, sep="-"),
#                                           paste(Growth_form_Sp2,Growth_form_Sp1, sep="-")),
#          Fleshy_fruit_values = ifelse(Fleshy_fruit_Sp1<Fleshy_fruit_Sp2,
#                                           paste(Fleshy_fruit_Sp1,Fleshy_fruit_Sp2, sep="-"),
#                                           paste(Fleshy_fruit_Sp2,Fleshy_fruit_Sp1, sep="-")),
#          Seed_bank_values = ifelse(Seed_bank_Sp1<Seed_bank_Sp2,
#                                           paste(Seed_bank_Sp1,Seed_bank_Sp2, sep="-"),
#                                           paste(Seed_bank_Sp2,Seed_bank_Sp1, sep="-")))%>%
#   select(1:9, contains("shared"), contains("similarity"),contains("values"),
#          Seed_mass_Sp1,Seed_mass_Sp2,CV_Sp1,CV_Sp2,ACL1_Sp1,ACL1_Sp2)
# 
# # merge the phylo distance to the final data set and calculate similarity
# maxPhylo <- max(phylo_reshape$Phylo_distance)
# merge_cor_phylo <- merge_cor %>%
#   left_join(phylo_reshape)%>%
#   mutate(Phylogenetic_similarity = 1 - (Phylo_distance/maxPhylo))
#   
# 
# # Save the data frame
# #write.csv(merge_cor_phylo, "~/LTER_Masting/Merged_Data_Jan_2023/merge_cor_traits_Jan18.csv", quote = FALSE, row.names = FALSE)
# 
# # Read in the csv file
# #Set wd
# setwd("C:/Jalene/DePaul/Research/Projects/LTER Synthesis Working Group")
# merge_cor_phylo<-read.csv("merge_cor_traits_Jan18.csv")
# 
# # Some quick graphs to look at traits one by one
# 
# site.colours <- c("red","orange","gold","green","skyblue",
#                        "violet","purple","grey")
# 
# 
# 
# ggplot(merge_cor_phylo, aes(Phylogenetic_similarity))+geom_histogram(bins = 50)+
#   theme_bw()
# ggplot(merge_cor_phylo, aes(x=lter, y=Phylogenetic_similarity))+geom_boxplot()+
#   geom_jitter(height = 0, width = 0.1, alpha = 0.2, size = 3)+
#   theme_bw()
# ggplot(merge_cor_phylo, aes(x = ACL1_Sp1, y = ACL1_Sp2, colour = ACL1_similarity))+
#   geom_point()+
#   theme_bw()+
#   scale_colour_gradientn(colours = rainbow(10))
# ggplot(merge_cor_phylo, aes(x = CV_Sp1, y = CV_Sp2, colour = CV_similarity))+
#   geom_point()+
#   theme_bw()+
#   scale_colour_gradientn(colours = rainbow(10))
# ggplot(merge_cor_phylo, aes(x = CV_Sp1, y = CV_Sp2, colour = CV_similarity))+
#   geom_point()+
#   theme_bw()+
#   facet_wrap(~lter, scales = "free")+
#   scale_colour_gradientn(colours = rainbow(10))
# ggplot(merge_cor_phylo, aes(x = Seed_mass_Sp1, y = Seed_mass_Sp2, colour = Seed_mass_similarity))+
#   geom_point()+
#   theme_bw()+
#   facet_wrap(~lter, scales = "free")+
#   scale_colour_gradientn(colours = rainbow(10))
# 
# 
# 
# ggplot(merge_cor_phylo, aes(x = Pollinator_code_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Seed_development_values, y = r.spearman))+geom_boxplot()+
# geom_jitter(height = 0, width = 0.1, aes(colour = lter))+
#   scale_colour_manual(values = site.colours)
# ggplot(merge_cor_phylo, aes(x = Mycorrhiza_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Needleleaf_Broadleaf_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Deciduous_Evergreen_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Dispersal_syndrome_values, y = r.spearman))+geom_boxplot()+
#   theme(axis.text.x = element_text(angle = 45, hjust=1))
# ggplot(merge_cor_phylo, aes(x = Sexual_system_values, y = r.spearman))+geom_boxplot()+
#   theme(axis.text.x = element_text(angle = 45, hjust=1))
# ggplot(merge_cor_phylo, aes(x = Shade_tolerance_values, y = r.spearman))+geom_boxplot()+
#   geom_jitter(height = 0, width = 0.1, aes(colour = lter))+
#   scale_colour_manual(values = site.colours)+
#   theme(axis.text.x = element_text(angle = 45, hjust=1))
# 
# ggplot(merge_cor_phylo, aes(x = Growth_form_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Fleshy_fruit_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Seed_bank_values, y = r.spearman))+geom_boxplot()
# ggplot(merge_cor_phylo, aes(x = Seed_mass_similarity, y = r.spearman,color = lter))+geom_point()+
#   facet_wrap(~lter)
# ggplot(merge_cor_phylo, aes(x = CV_similarity, y = r.spearman,color = lter))+geom_point()+
#   facet_wrap(~lter)
# ggplot(merge_cor_phylo, aes(x = ACL1_similarity, y = r.spearman,color = lter))+geom_point()+
#   facet_wrap(~lter)
# 
# 
# 
# # an interesting graph?
# cor_graph <- merge_cor_phylo %>%
#   select(1:5, contains("shared")) %>%
#   pivot_longer(6:16,names_to = "Trait", values_to = "Shared")
# 
# cor_graph_summary <- cor_graph %>%
#   group_by(lter, Trait, Shared) %>%
#   summarise(meanCor.spearman = mean(r.spearman))
# 
# ggplot() +
#   geom_jitter(data = cor_graph, aes(x = factor(Shared), y = r.spearman, colour = lter),
#               height = 0, width = 0.1, alpha = 0.1)+
#   geom_line(data = cor_graph_summary, aes(x = factor(Shared), y = meanCor.spearman, colour =lter, group = lter),
#             size = 1)+
#   geom_point(data = cor_graph_summary, aes(x = factor(Shared), y = meanCor.spearman, fill =lter),
#              shape = 21, colour = "black", size = 3)+
#   facet_wrap(~Trait)+
#   theme_bw()+
#   xlab("Shared trait")+
#   scale_x_discrete(labels = c("No","Yes"))+
#   ylab("Spearmans r")+
#   scale_color_manual(values = site.colours)+
#   scale_fill_manual(values = site.colours)
# 
# 
# ## Feb 2023 - Jalene LaMontagne
# 
# # Looking at distributions of ACL1
# hist(merge_cor_phylo$ACL1_Sp1)
# hist(merge_cor_phylo$ACL1_Sp2)
# hist(merge_cor_phylo$ACL1_similarity)
# hist(merge_cor_phylo$CV_Sp1)
# hist(merge_cor_phylo$CV_Sp2)
# hist(merge_cor_phylo$CV_similarity)


# Read in the csv file
#Set wd
# setwd("C:/Jalene/DePaul/Research/Projects/LTER Synthesis Working Group")
merge_cor_phylo <- read.csv(file.path("data", "merge_cor_traits_Jan18.csv"))

library(ecodist)
library(tidyverse)
library(lme4)
options(scipen = 999)

#Analysis
#Super simple model - this works
linear_model_output <- merge_cor_phylo %>%
  group_by(lter) %>%
  reframe(broom::tidy(lm(r.spearman ~ CV_similarity, .)))


#All continuous variables - this works
linear_model_output_Continuous <- merge_cor_phylo %>%
  group_by(lter) %>%
  reframe(broom::tidy(lm(r.spearman ~ CV_similarity+Seed_mass_similarity+ACL1_similarity+Phylogenetic_similarity, .)))

#All variables - for some LTER sites this doesn't work - all variables have P-values of NA or NAN, even when there are data.
#The problem might be related to when there's no variation for an attribute within a site
linear_model_output_Full <- merge_cor_phylo %>%
  group_by(lter) %>%
  reframe(broom::tidy(lm(r.spearman ~ Pollinator_code_shared+Seed_development_shared+Needleleaf_Broadleaf_shared+Deciduous_Evergreen_shared+
                      Dispersal_syndrome_shared+Sexual_system_shared+Shade_tolerance_shared+Growth_form_shared+Fleshy_fruit_shared+
                      Seed_bank_shared+CV_similarity+Seed_mass_similarity+ACL1_similarity+Phylogenetic_similarity, .)))


#MRM analysis time! (Hopefully)
# MRM Synchrony - all sites together - super simple model - this works
mdist <- MRM((dist(r.spearman) ~ dist(CV_similarity)),data=merge_cor_phylo,nperm=100,mrank=T)
mdist

#MRM - all sites together - all continuous independent variables only - this works
mdist_continuous <- MRM(dist(r.spearman) ~ dist(Seed_mass_similarity)+dist(CV_similarity)+dist(ACL1_similarity)+dist(Phylogenetic_similarity),data=merge_cor_phylo,nperm=100,mrank=T)
mdist_continuous


#MRM - FULL MODEL with all of the variables - this also works
mdist_full <- MRM(dist(r.spearman) ~ dist(Pollinator_code_shared)+dist(Seed_development_shared)+dist(Needleleaf_Broadleaf_shared)+dist(Deciduous_Evergreen_shared)+
                    dist(Dispersal_syndrome_shared)+dist(Sexual_system_shared)+dist(Shade_tolerance_shared)+dist(Growth_form_shared)+
                    dist(Fleshy_fruit_shared)+dist(Seed_bank_shared)+dist(Seed_mass_similarity)+dist(CV_similarity)+dist(ACL1_similarity)+dist(Phylogenetic_similarity),data=merge_cor_phylo,nperm=100,mrank=T)
mdist_full


#MRM - trying to get this to loop across sites to do them separately
#This doesn't work - trying to add MRM to code that ran as lm earlier
MRM_output <- merge_cor_phylo %>%
  group_by(lter) %>%
  do(broom::tidy(MRM((dist(r.spearman) ~ dist(CV_similarity)),nperm=10,mrank=T, .)))

#MRM - trying to get this to loop across sites to do them separately
#This might work, but the output is a mess - don't want to see all of the data each time
merge_cor_phylo %>%
  group_by(lter) %>%
  summarise(result = list(MRM((dist(r.spearman) ~ dist(CV_similarity)),nperm=10,mrank=T), 
                              data = merge_cor_phylo, 
                              start =  list(w = 2))) %>%
  pull(result)


#Code from Nick
#For each LTER in the data - this gives output as files, and each file has the data for all sites.
for(site in unique(merge_cor_phylo$lter)){
  
  # Subset the data to that site
  data_sub <- dplyr::filter(merge_cor_phylo, lter == site)
  
  # Fit the linear model for that site
  linear_model_output1 <- data_sub %>%
    do(broom::tidy(lm(r.spearman ~ CV_similarity, .)))
  
  # Export a CSV of that output with the sitename in the filename
  write.csv(linear_model_output, file = paste0(site, "_lm_output.csv"))
  
  # Print success message
  message("Processing complete for LTER, ", site)
  
} # Close loop curly brace

