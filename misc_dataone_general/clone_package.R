library(dataone)
library(datamgmt)


# Add your resource map here
resource_map_pid <- 'urn:uuid:935a93f3-f9a8-4f4c-bce6-cc2a976bb019'

# Define origin and destinaltion node
my_to <- dataone::D1Client("STAGING2", "urn:node:mnTestKNB")
my_from <- my_to

# Clone the package
datamgmt::copy_package(resource_map_pid, from = my_from, to = my_to)


# # Loop
# for(i in 1:7){
#   print(i)
#   datamgmt::copy_package(resource_map_pid, from = my_from, to = my_to)
# }
