#devtools::install_github("jeroen/curl@v2.7")
library(curl)
library(dataone)
#devtools::install_github("nceas/arcticdatautils")
library(arcticdatautils)
library(EML)

# Input KNB token (find in knb settings tab)
# Options(dataone_test_token = " ")

# Get the connection - Setting up nodes
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")

# PID is package unique identifier, find under package header on knb webpage
ressurcem_pid <- "resourceMap_csparks_knb.65.16"

# Load data package into R
pkg <- get_package(mn,
                   ressurcem_pid,
                   file_names = TRUE)

# Load eml file into R
eml <- read_eml(rawToChar(getObject(mn, pkg$metadata))) # Use rawToChar to avoid errors with binary format and make it human readable

# Set path and format types of data to be added

path_GPI <- "/Volumes/GoogleDrive/Team Drives/NCEAS-SciComp/SNAPP/SNAPP-Aquaculture/Climate_change/To_Archive/For Julien Input/Finifsh/GPI.zip"
path_Prop <- "/Volumes/GoogleDrive/Team Drives/NCEAS-SciComp/SNAPP/SNAPP-Aquaculture/Climate_change/To_Archive/For Julien Input/Finifsh/Proportions.zip"
formatId <- "application/zip"


pid <- publish_object(mn,
                      path = path,
                      format_id = formatId)

# Set name and description

otherEntity <- arcticdatautils::pid_to_eml_entity(mn, pid, entityName = "input_Finfish_GPI.zip", entityDescription = "Growth Performance Index (GPI) multispecies averages for the different timesteps")

# Set other Entity to the next numbered entity (ie if there are 8 existing entities )
# S4 object: @ breaks down into progressively smaller categories
eml@dataset@otherEntity[[9]] <- otherEntity


# For second dataset, call it a different pid_ name
pid_prop <- publish_object(mn,
                      path = path_Prop,
                      format_id = formatId)

otherEntity_Prop <- arcticdatautils::pid_to_eml_entity(mn, pid_prop, entityName = "input_Finfish_Proportions.zip",
                                                       entityDescription = "Change in production potential proportion values for each interval (‘Prop’ files) and cumulatively (‘CumProp’ files)")

# This is the 10th other entity to be created
eml@dataset@otherEntity[[10]] <- otherEntity_Prop


# Validate eml
eml_validate(eml)

# Write eml
eml_path <- "/Volumes/GoogleDrive/Team Drives/NCEAS-SciComp/SNAPP/SNAPP-Aquaculture/Climate_change/To_Archive/eml.xml"
write_eml(eml, eml_path)

# Publish update
update <- publish_update(mn, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = c(pkg$data, pid, pid_prop),
                         metadata_path = eml_path, 
                         public = TRUE)


