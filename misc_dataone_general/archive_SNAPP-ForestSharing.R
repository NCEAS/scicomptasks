### Library
library(dataone)
library(devtools)
library(dataone)
library(EML)
library(XML)
# devtools::install_github("nceas/arcticdatautils")
library(arcticdatautils)
# devtools::install_github("jeroen/curl@v2.8")
library(curl)
# devtools::install_github("NCEAS/datamgmt") 
library(datamgmt)
library(stringr)

### 1 Set up: 

#url to use to look at: https://knb.ecoinformatics.org/knb/d1/mn/v2/meta/resource_map_urn:uuid:5dbb21e4-5c26-4403-84d4-59d90801e0ef

##1.1 File paths:
path <- "~/Google Drive File Stream/Team Drives/NCEAS-SciComp/SNAPP/SNAPP-Forest_sharing/DataPack"
files_in_path <- list.files(path="~/Google Drive File Stream/Team Drives/NCEAS-SciComp/SNAPP/SNAPP-Forest_sharing/DataPack")
files_in_path

for (i in 1:length(files_in_path)){
  listfiles[i] <-assign(sprintf("path_%s", files_in_path[i]),
         paste(path, files_in_path[i], sep = "/"),
         envir = .GlobalEnvem)
  }  

##1.2 auth token: 
  # enter in console

##1.3 set environment 
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")

#create package metadata on knb and get metadata_pid 
metadata_pid <- "urn:uuid:c93619ee-12b2-4cbb-936c-67c08594ffa6"
metadata_pid

###2. Creating Data package
##2.1 Publish 1 data object to set up package and get resource_map_pid

# pid <- publish_object(mn,
#                       path = path_pu_NPV.csv,
#                       format_id = "text/csv")

pid_pu_NPV <- "urn:uuid:893dada2-543a-4bac-aea3-d0ee9631b966"

##2.2 Create resource map pid:
# resource_map_pid <- create_resource_map(mn,
#                                         metadata_pid = metadata_pid,
#                                         data_pids = pid_pu_NPV)

# resource_map_pid <- "resource_map_urn:uuid:f1f0ed90-7574-4f5e-a555-9f68ea26509d"

##2.3 Verify package is updated: 
 
resource_map_pid
pkg <- get_package(mn, resource_map_pid, file_names = T)  # if running for first time, may need to rerun resource_map_pid

pkg$metadata                        #should be one file
pkg$data                            # should be 5 datafiles
pkg$resource_map                    # should be same as entered resource_map_pid written above.

#read eml and create eml path 
eml <- read_eml(rawToChar(getObject(mn, pkg$metadata)))
eml_path <- paste0(path, "/ForestSharing_eml.xml")
# write_eml(eml, eml_path)
eml_validate(eml_path)


### 2.4 Add all other data objected

#load the pids for everydata opbject

# pid_Biodiv <- publish_object(mn,
#                       path = path_BiodiversityBenefit.csv,
#                       format_id = "text/csv")
pid_Biodiv <- "urn:uuid:2581f424-9a88-4710-87e6-e676d0c3155a"

# pid_doc <- publish_object(mn,
#                       path = path__Documentation.docx,
#                       format_id = "text/plain")
pid_doc <- "urn:uuid:21be198d-f9d5-4a6b-86ff-d93e6720941e"

# pid_forestManagementImpact <- publish_object(mn,
#                             path = path_ForestManagementImpactAllSpecies.csv,
#                             format_id = "text/csv")
pid_forestManagementImpact <- "urn:uuid:e05d4a04-ad46-49a7-bc06-75a1b8607400"

# pid_EastKal <- publish_object(mn, path = path_EastKal_ForestEstate_50N_clean.zip,
#                               format_id = "application/zip")

pid_EastKal <- "urn:uuid:306a019f-78d9-4c8e-9100-da626ff16d21"

#resource_map
# resource_map_pid <- create_resource_map(mn,
#                                         metadata_pid = metadata_pid,
#                                         data_pids = pid_pu_NPV)

resource_map_pid <- "resource_map_urn:uuid:5dbb21e4-5c26-4403-84d4-59d90801e0ef"
resource_map_pid <- "resource_map_urn:uuid:d4e14d00-b3d8-4e18-9fd7-e823fce1734f"

## 2.5 eml_path update

# eml <- read_eml(rawToChar(getObject(mn, pkg$metadata)))
eml_path <- paste0(path, "/ForestSharing_eml.xml")
write_eml(eml, eml_path)
eml_validate(eml_path)
eml@dataset@intellectualRights

##2.6 Perform the update: 

#combining all data object pids for the update: 
data_pids <- c(pid_Biodiv, pid_doc, pid_EastKal, pid_forestManagementImpact, pid_pu_NPV)

# run update from above
update <- publish_update(mn, 
                         metadata_pid = pkg$metadata,
                         resource_map_pid = pkg$resource_map,
                         data_pids = data_pids,
                         metadata_path = eml_path, 
                         public = TRUE)

#check updated pkg:
pkg <- get_package(mn, resource_map_pid, file_names = T)
# pkg$data
# pkg$metadata
# pkg$resource_map

# 2.6. set rights and access

set_rights_and_access(mn, c(pkg$metadata, pkg$data, pkg$resource_map),
                      'CN=snapp-scicomp,DC=dataone,DC=org',
                      permissions = c('read', 'write', 'changePermission'))

eml@dataset@intellectualRights <- new('intellectualRights', 
                                      .Data = "This research was supported by ARC Discovery Project grant DP160101397. Support was also provided by funding from the Doris Duke Charitable Foundation and the Science for Nature and People Partnership (SNAPP), a partnership of The Nature Conservancy, the Wildlife Conservation Society and the National Center for Ecological Analysis and Synthesis (NCEAS) at University of California, Santa Barbara (https://snappartnership.net).")



##########EML configuration ########### 

## set up name description
dataset_biodiv <- arcticdatautils::pid_to_eml_physical(mn, pid_Biodiv) 


dataTable1 <- new('dataTable',
                  entityName = "BiodiversityBenefit.csv",
                  physical = dataset_biodiv, 
                  attributeList = )

create_attributes_table(read.csv(path_BiodiversityBenefit.csv)) # may need to be patient for attribute names to populate in table

# eml@dataset@dataTable[[1]] <- otherEntity


