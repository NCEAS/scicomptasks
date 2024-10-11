## ------------------------------------------ ##
#     LNO -- Exporting webpages as PDFs
## ------------------------------------------ ##
# Script author(s): Angel Chen

# Purpose:
## Exports GitHub Enterprise issues as pdf files
## See https://github.com/lter/scicomp/issues/15

## ------------------------------------------ ##
#              Housekeeping -----
## ------------------------------------------ ##

# Load necessary libraries
# install.packages("librarian")
librarian::shelf(chromote, stringr)

# Create necessary sub-folder(s)
dir.create(path = file.path("issue_pdfs"), showWarnings = F)

## ------------------------------------------ ##
#             Getting Cookies -----
#     (Skip if you already did this step)
## ------------------------------------------ ##

# start new Chrome session
b <- ChromoteSession$new()
# open interactive window
b$view()

# navigate to a random Github Enterprise issue
# make sure to log in to GitHub Enterprise
b$Page$navigate("https://github.nceas.ucsb.edu/LTER/lter-wg-scicomp/issues/278")

# save credentials as cookies
cookies <- b$Network$getCookies()
str(cookies)
saveRDS(cookies, "cookies.rds")

# close the browser tab/window
b$close()

## ------------------------------------------ ##
#               Exporting -----
## ------------------------------------------ ##

# after saving cookies, you can restart R and navigate to the page again

# start new Chrome session
b <- ChromoteSession$new()
# open interactive window
b$view()

# read in and set cookies
cookies <- readRDS("cookies.rds")
b$Network$setCookies(cookies = cookies$cookies)

for (i in 50:300){
  
  # specify the url of interest
  url <- paste0("https://github.nceas.ucsb.edu/LTER/lter-wg-scicomp/issues/", i)
  
  # NOTE: see the below link on how to load pages reliably
  # https://github.com/rstudio/chromote?tab=readme-ov-file#loading-a-page-reliably
  
  # get the promise for the loadEventFired
  p <- b$Page$loadEventFired(wait_ = FALSE)  
  
  # navigate to the app that requires a login
  b$Page$navigate(url, wait_ = FALSE)
  
  # Block until p resolves
  b$wait_for(p)
  
  # get the navigation history so we can access the metadata
  x <- b$Page$getNavigationHistory()
  
  # create the pdf name from the webpage title
  title_1 <- str_replace_all(x$entries[[x$currentIndex+1]]$title, "[:punct:]", "")
  title_2 <- str_replace_all(title_1, "`|~", "")
  title_3 <- str_replace_all(title_2, "\\+", "")
  title_4 <- str_extract(title_3, ".*(?=[:blank:]{2,3}Issue)")
  title_5 <- str_replace_all(title_4, "[:space:]{1,2}", "_")
  
  # issue number padding
  if (i < 10) {
    num <- paste0("00", i)
  } else if (i < 100) {
    num <- paste0("0", i)
  } else {
    num <- paste0(i)
  }
  
  # attach the issue number to the pdf name
  pdf_name <- paste0("Issue_", num, "_", title_5, ".pdf")
  
  message(paste("Exporting issue", i))
  
  # export the GitHub issue webpage as a pdf
  b$screenshot_pdf(filename = file.path("issue_pdfs", pdf_name),
                   display_header_footer = TRUE,
                   print_background = TRUE)
}

# close the browser tab/window
b$close()

# feel free to delete cookies when you're done
