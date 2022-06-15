library(arcticdatautils)

library(dataone)


## CONSTANTS ----

# Check your token status
getTokenInfo(AuthenticationManager())
# If not working get a new token from your user profile page (add the link)

# Get the connection
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")

resource_map_pid <- "urn:uuid:645fc8a3-7df6-454e-864f-489f5734ceaf"

# Manually set ORCiD
subject <- 'http://orcid.org/0000-0003-0614-1456'

ids <- get_package(mn, resource_map_pid)
set_access(mn, unlist(ids), subjects = subject, permissions = c("read", "write", "changePermission"))

# Check

sysmeta <- getSystemMetadata(mn, resource_map_pid)
sysmeta@accessPolicy
