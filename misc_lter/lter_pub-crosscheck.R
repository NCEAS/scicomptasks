## -------------------------------------------------- ##
        # LTER / NEON Publication Checker
## -------------------------------------------------- ##
# Script author(s): Nick J Lyon

# PURPOSE:
## Compare LTER / NEON publication lists

## ------------------------------ ##
         # Housekeeping ----
## ------------------------------ ##

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, supportR)

# Clear environment
rm(list = ls())

## ------------------------------ ##
        # Library Import ----
## ------------------------------ ##

# Make some empty lists
lter_list <- list()
neon_list <- list()

# Get all collections' citations (for LTER)
for(colxn in dir(path = file.path("data", "LTER Collections"))){
  
  # Processing message
  message("Retrieving collection: ", colxn)
  
  # Read in file and add to list
  lter_list[[colxn]] <- read.csv(file = file.path("data", "LTER Collections", colxn)) %>% 
    # Make all columns into characters
    dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                                .fns = as.character)) }

# Do the same for NEON
for(colxn in dir(path = file.path("data", "NEON Collections"))){
  
  # Processing message
  message("Retrieving collection: ", colxn)
  
  # Read in file and add to list
  neon_list[[colxn]] <- read.csv(file = file.path("data", "NEON Collections", colxn)) %>% 
    dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                                .fns = as.character)) }

# Unlist into a dataframe (for both) and drop duplicates (if Zotero made any)
lter_v0 <- dplyr::distinct(purrr::list_rbind(x = lter_list))
neon_v0 <- dplyr::distinct(purrr::list_rbind(x = neon_list))

# Tidy environment
rm(list = setdiff(x = ls(), y = c("lter_v0", "neon_v0")))

## ------------------------------ ##
        # Library Prep ----
## ------------------------------ ##

# Check structure of one (same columns in both)
dplyr::glimpse(lter_v0)

# Wrangle the full information into just what we need
lter_v1 <- lter_v0 %>% 
  # Pare LTER pubs down to just the desired columns
  dplyr::select(Item.Type, dplyr::starts_with("Publication."), 
                Author, Title, ISBN:DOI) %>% 
  # Add a column indicating which library these publications are in
  dplyr::mutate(library = "LTER", .before = dplyr::everything()) %>% 
  # Make empty cells true NAs (across all columns)
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = ~ ifelse(test = nchar(.x) == 0,
                                              yes = NA, no = .x))) %>% 
  # Make the contents of all columns lowercase
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = tolower)) %>% 
  # Make publication year numeric and drop any pubs missing year info
  dplyr::mutate(Publication.Year = as.numeric(Publication.Year)) %>% 
  dplyr::filter(!is.na(Publication.Year)) %>% 
  # Drop any publications before LTER was founded
  dplyr::filter(Publication.Year >= 1980) %>% 
  # Drop non-unique rows
  dplyr::distinct()

# Check structure
dplyr::glimpse(lter_v1)
## view(lter_v1)

# Do the same for NEON
neon_v1 <- neon_v0 %>% 
  dplyr::select(Item.Type, dplyr::starts_with("Publication."), 
                Author, Title, ISBN:DOI) %>% 
  dplyr::mutate(library = "NEON", .before = dplyr::everything()) %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = ~ ifelse(test = nchar(.x) == 0,
                                              yes = NA, no = .x))) %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = tolower)) %>% 
  dplyr::mutate(Publication.Year = as.numeric(Publication.Year)) %>% 
  dplyr::filter(!is.na(Publication.Year)) %>% 
  dplyr::filter(Publication.Year >= 1980) %>% 
  dplyr::distinct()

# Check structure of this too
dplyr::glimpse(neon_v1)

## ------------------------------ ##
    # Library Integration ----
## ------------------------------ ##

# Stack the publications into a single object
combo_v1 <- lter_v1 %>% 
  dplyr::bind_rows(neon_v1) %>% 
  # Identify whether each was in the other
  dplyr::mutate(shared = dplyr::case_when(
    # LTER pubs in NEON
    library == "lter" & !is.na(Title) & Title %in% neon_v1$Title ~ 1,
    library == "lter" & !is.na(ISBN) & ISBN %in% neon_v1$ISBN ~ 1,
    library == "lter" & !is.na(ISSN) & ISSN %in% neon_v1$ISSN ~ 1,
    library == "lter" & !is.na(DOI) & DOI %in% neon_v1$DOI ~ 1,
    # NEON pubs in LTER
    library == "neon" & !is.na(Title) & Title %in% lter_v1$Title ~ 1,
    library == "neon" & !is.na(ISBN) & ISBN %in% lter_v1$ISBN ~ 1,
    library == "neon" & !is.na(ISSN) & ISSN %in% lter_v1$ISSN ~ 1,
    library == "neon" & !is.na(DOI) & DOI %in% lter_v1$DOI ~ 1,
    # Otherwise, assume not in publication list
    T ~ NA)) %>% 
  # Tweak the name of two key visualization columns
  dplyr::rename(type = Item.Type,
                pub_year = Publication.Year) %>% 
  # Count instances per year and publication type
  dplyr::group_by(library, type, pub_year) %>% 
  dplyr::summarize(total_ct = dplyr::n(),
                   shared_ct = sum(shared, na.rm = T)) %>% 
  dplyr::ungroup() %>% 
  # Calculate proportion shared
  dplyr::mutate(shared_prop = shared_ct / total_ct)

# Check structure
dplyr::glimpse(combo_v1)

# Make a version for shared only (LTER focal)
shared_only <- combo_v1 %>% 
  dplyr::filter(library == "lter" & shared_ct != 0)

## ------------------------------ ##
            # Visuals ----
## ------------------------------ ##

# Graph 1 - Shared paper *count* over time
ggplot(shared_only, aes(x = pub_year, y = shared_ct)) +
  geom_smooth(method = "loess", formula = "y ~ x", se = F, color = 'black') +
  geom_point(aes(fill = shared_ct), shape = 21, size = 3) +
  labs(y = "Shared Publication Count", x = "Publication Year") +
  supportR::theme_lyon() +
  theme(legend.position = "none")

# Graph 2 - Shared paper *proportion* over time
ggplot(shared_only, aes(x = pub_year, y = shared_prop)) +
  geom_smooth(method = "loess", formula = "y ~ x", se = F, color = 'black') +
  geom_point(aes(fill = shared_prop), shape = 21, size = 3) +
  labs(y = "Shared Publication Proportion", x = "Publication Year") +
  supportR::theme_lyon() +
  theme(legend.position = "none")




# End ----
