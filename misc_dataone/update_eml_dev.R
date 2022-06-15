library(dataone)
library(arcticdatautils)
library(EML)
library(datamgmt)

cn_staging2 <- CNode("STAGING2")
knb_test <- getMNode(cn_staging2,"urn:node:mnTestKNB")

# Add your resource map here
resource_map_pid <- 'urn:uuid:935a93f3-f9a8-4f4c-bce6-cc2a976bb019'
                       
pkg <- get_package(knb_test, resource_map_pid)
eml <- read_eml(getObject(knb_test, pkg$metadata))

# If you want to read the documenation look at 'eml_party', eml_personnel is just a wrapper for that
# Update the index [[1]] if you need to 
# eml@dataset@project@personnel[[1]] <- eml_personnel('FIRST_NAME', 'LAST_NAME', 'ORGANIZATION',
#                                                     email = 'EMAIL', address = 'ADDRESS',
#                                                     role = 'Principal Investigator')

# # You can modify these fields also 
# eml@dataset@project@funding <- read_eml('<funding>1234567</funding>')
# eml@dataset@project@title[[1]] <- read_eml('<title>Title of the Project</title>')
# eml@dataset@project@abstract <- read_eml("<abstract>
#                                          <para>PARAGRAPH 1</para>
#                                          <para>PARAGRAPH 2</para>
#                                          <para>PARAGRAPH 3</para>
#                                          </abstract>")

# Validate and write eml

eml_path <- file.path("/Users/brun/Desktop/Financing the sustainable management of Rwandas protected areas.xml")
# write_eml(eml, eml_path)
## Manually edited the beast
eml <-read_eml(eml_path) 
eml_validate(eml)

# Publish, make sure to change 'public' and 'use_doi' if you need to
# pkg <- publish_update(knb, pkg$metadata, pkg$resource_map, pkg$data,
                      # metadata_path = eml_path, public = TRUE)

