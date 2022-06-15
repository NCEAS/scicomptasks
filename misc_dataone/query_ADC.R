library(dataone)

cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:ARCTIC")

qr <- query(mn, 'q=formatType:METADATA+-obsoletedBy:*+"carbon flux"&fl=identifier,title,origin&rows=1000')

qr_enhanced <- lapply(qr, function(r) {
  # Collapse multi-valued origin into comma-separated char vector
  r$origin <- paste0(unlist(r$origin), collapse = ", ")
  
  # Provide the best possible URL for the identifier
  if (grepl("doi", r$identifier)) {
    r$url <- paste0("https://doi.org/", r$identifier)  
  } else {
    r$url <- paste0("https://arcticdata.io/catalog/#view/", r$identifier)
  }
  
  r
})

write.csv(as.data.frame(matrix(unlist(qr_enhanced), ncol = 4, byrow = TRUE, dimnames = list(c(), c("identiifer", "title", "creator", "url"))), stringsAsFactors = FALSE),
          file = "query.csv",
          row.names = FALSE)