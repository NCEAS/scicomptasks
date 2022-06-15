# Adapated from https://github.nceas.ucsb.edu/KNB/arctic-data/blob/master/datateam/training/editingSysMeta.Rmd

## LIBRARIES ----

install.packages("dataone")
install.packages("xml")
library(dataone)

## CONSTANTS ----

#Enter token
options(dataone_token = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1aWQ9bXNsZWNrbWFuLG89dW5hZmZpbGlhdGVkLGRjPWVjb2luZm9ybWF0aWNzLGRjPW9yZyIsImZ1bGxOYW1lIjoiTWFyZ2F1eCBTbGVja21hbiIsImlzc3VlZEF0IjoiMjAxOC0wNC0xM1QxODoyNjoxNS42MTQrMDA6MDAiLCJjb25zdW1lcktleSI6InRoZWNvbnN1bWVya2V5IiwiZXhwIjoxNTIzNzA4Nzc1LCJ1c2VySWQiOiJ1aWQ9bXNsZWNrbWFuLG89dW5hZmZpbGlhdGVkLGRjPWVjb2luZm9ybWF0aWNzLGRjPW9yZyIsInR0bCI6NjQ4MDAsImlhdCI6MTUyMzY0Mzk3NX0.U7TpDnUoqvbqkcuSloZgTth91dgygV9Zws5YWMOvs3g28rpbV6ZrXZ4CYY9eiWd63-A4fC6OrRYROt9no-4faqxamlvMTZO5uHM_QEWQVXOJTWTEqP6BxjfYrs0IlAHhdp-Dk-X0h2pA1Vh1yMLEhPQFsBKkGjws_d3x8SCj77qSTEkxzhJEoJqzD1vdEMMdWdbT3bwYKPd6l7Zo_L5ucgVARtIIYd9vOeKZ7jCTpebJA34Fse2zYQ6arZd85ZHOZpz5QhfxTciY5DPU-2MEyVYV4HxFIdGt_tfIbNTQxPmArznbnqAosZoNaOLa6Zaidk_j1KYWzQd5DYW56qTvyw")

# Check your token status
getTokenInfo(AuthenticationManager())
# If not working get a new token from your user profile page (add the link)

# Get the connection
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")

# Read the Look-up table witht the format types (see https://cn.dataone.org/cn/v2/formats for more)
lut <- read.csv("file_format_LUT.csv", stringsAsFactors = FALSE)


## FUNCTIONS ----

#' Update the system metadata to add the file type based on the file extension
#'
#' @param data_pid 
#' @param file_extension 
#'
#' @return NA
#' @export 
#'
#' @examples
#' sysmeta.format.updater("gdaldegan.11.2", "rar")
sysmeta.format.updater <- function(data_pid, file_extension){
  # get the system metadata
  sysmeta <- getSystemMetadata(mn, data_pid)
  
  # check the object we got back from our query
  sysmeta
  
  # Filter the format info from the LUT using the extension
  extension <- lut[lut$fileExtension == file_extension,] 
  
  # Check the current formatID 
  sysmeta@formatId
  
  # Update the format and Media MIME-type (dataONE formats: https://cn.dataone.org/cn/v2/formats)
  sysmeta@formatId <- extension$formatId
  sysmeta@mediaType <- extension$mediaType
  
  # Update the System metadata file on the node
  updateSystemMetadata(mn, data_pid, sysmeta)
}


## MAIN ----

### set the file unique identifier
pid_r <- c("kengmiller.16.2","kengmiller.17.2","kengmiller.18.2","kengmiller.28.2",
           "kengmiller.30.2","kengmiller.33.2", "karakoenig.58.1",
           "karakoenig.59.1", "karakoenig.60.2", "karakoenig.61.2","karakoenig.65.2",
           "karakoenig.72.2", "karakoenig.73.2", "karakoenig.74.1")

pids_word <- c("brun.53.1","karakoenig.71.2","karakoenig.83.1")

pids_zip <- c("karakoenig.96.1", "karakoenig.95.2")

pids_csv <- c("karakoenig.84.1", "karakoenig.92.1", "karakoenig.93.1", "karakoenig.94.1",
              "kengmiller.31.1")

pids_xls <- c()
for(i in 57:65){
  my_pid <- paste0("brun.", i, ".1")
  pids_xls <- c(pids_xls, my_pid)
}


### Apply the function

# For R
mapply(sysmeta.format.updater, pid_r, "R")

# For MS Word 
mapply(sysmeta.format.updater, pids_word, "docx")

# For MS Excel
mapply(sysmeta.format.updater, pids_xls, "xlsx")

# For zip 
mapply(sysmeta.format.updater, pids_zip, "zip")

# For csv
mapply(sysmeta.format.updater, pids_csv, "csv")
