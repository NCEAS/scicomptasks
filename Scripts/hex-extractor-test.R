## ----------------------------------------------------------------- ##
              # General - Extract HEX Codes from Image
## ----------------------------------------------------------------- ##
# Written by Nick J Lyon

# PURPOSE
## Explore paths to extracting colors from image

# Clear environment
rm(list = ls())

# Call packages
library(tidyverse)

# Housekeeping ------------------------------------------------------

# `colorfindr` Extraction Process
## Library
library(colorfindr)
## Extraction (very slow)
colors <- colorfindr::get_colors(img = file.path("Data", "swallowtail.jpg"),
                                 exclude_col = c("#FFFFFF", "#000000"))
head(colors)

# Custom Path No. 1
## Libraries
library(png)
## Grab image
image <- png::readPNG(source = file.path("Data", "swallowtail.png"), native = F)
## Strip out RGB channels
rgb_list <- list()
for(band in 1:3){
  
  # Message
  print(paste('Channel', band, 'extraction begun at', Sys.time()))
  
  # Strip channel
  out <- stringr::str_sub(
    string = base::as.character(
      base::as.hexmode(
        base::as.integer(image[,,band] * 255)
        ) ), start = 1, end = 1)
  
  # Add it to list
  rgb_list[[band]] <- out
  
  # Message
  print(paste('Channel', band, 'extracted at', Sys.time()))
}
## Combine into single dataframe
rgb_v1 <- base::data.frame(red = rgb_list[[1]],
                           green = rgb_list[[2]],
                           blue = rgb_list[[3]])
## If two of the bands are the same, coerce the third into one of four bins
rgb_v2 <- dplyr::mutate(.data = rgb_v1,
    ## Green
    green = dplyr::case_when(
      red == blue & green %in% c('0', '1', '2', '3') ~ '1',
      red == blue & green %in% c('4', '5', '6', '7') ~ '5',
      red == blue & green %in% c('8', '9', 'a', 'b') ~ '9',
      red == blue & green %in% c('c', 'd', 'e', 'f') ~ 'd',
      TRUE ~ green),
    ## Blue
    blue = dplyr::case_when(
      red == green & blue %in% c('0', '1', '2', '3') ~ '1',
      red == green & blue %in% c('4', '5', '6', '7') ~ '5',
      red == green & blue %in% c('8', '9', 'a', 'b') ~ '9',
      red == green & blue %in% c('c', 'd', 'e', 'f') ~ 'd',
      TRUE ~ blue),
    ## Red
    red = dplyr::case_when(
      blue == green & red %in% c('0', '1', '2', '3') ~ '1',
      blue == green & red %in% c('4', '5', '6', '7') ~ '5',
      blue == green & red %in% c('8', '9', 'a', 'b') ~ '9',
      blue == green & red %in% c('c', 'd', 'e', 'f') ~ 'd',
      TRUE ~ red) )
## Assemble hex codes from those values
hex_v1 <- base::data.frame(hexcode = base::with(data = rgb_v2,
                                                paste0('#', red, red,
                                                       green, green,
                                                       blue, blue)))
## Identify only unique colors
hex_v2 <- base::unique(x = hex_v1) # 890
## Split back out colors for a necessary diagnostic
hex_v3 <- dplyr::mutate(.data = hex_v2,
                        testR = stringr::str_sub(hexcode, start = 2, end = 2),
                        testG = stringr::str_sub(hexcode, start = 4, end = 4),
                        testB = stringr::str_sub(hexcode, start = 6, end = 6),
                        numR = base::suppressWarnings(base::as.numeric(testR)),
                        numG = base::suppressWarnings(base::as.numeric(testG)),
                        numB = base::suppressWarnings(base::as.numeric(testB)))
## Remove really dark colors that are likely less useful
hex_v4 <- dplyr::filter(.data = hex_v3,
                        # If all are <5 AND...
                        dplyr::if_all(numR:numB) >= 7 |
                        # Keep if any are NA (greater than 5 in hex is NA in numeric)
                        dplyr::if_any(numR:numB, is.na))
## Remove really bright colors too
hex_v5 <- dplyr::filter(.data = hex_v4,
                        )
## Drop intermediary columns needed for that filter step
hex_v6 <- dplyr::select(.data = hex_v5, -dplyr::contains('num')) ## 586

head(hex_v6)



data.frame(x = c('a', 'b'), y = 10:10) %>%
  ggplot(aes(x = x, y = y, fill = x)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values = c("#770000", "#000077")) + # rr gg bb
  theme(legend.position = 'none')



# microbenchmark::microbenchmark(unique(rgb_v2), unique(hex_v1), times = 10)
# Unit: milliseconds
# expr        min         lq       mean     median         uq       max neval
# unique(rgb_v2) 13012.1356 14323.3887 15656.8132 15139.5319 16421.7094 19533.277    10
# unique(hex_v1)   167.2555   190.0355   273.5877   277.7436   285.9613   509.486    10





unique(rgb_v2$red)
unique(rgb_v2$green)
unique(rgb_v2$blue)

# rgb_v3 <- rgb_v2 %>%
#   dplyr::filter()






# run <- TRUE; x <- 0
# while(run == TRUE){
#   x <- x + 1
#   print(paste('iteration', x, 'complete'))
#   if(x >= 5){run <- FALSE} }



head(hex_v2)

## 0 - 9, then A - F, then 10 - 19, then 1A - 1F, then ...
hex_digs <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f')
length(hex_digs)


data.frame(x = c('a', 'b'), y = 10:10) %>%
  ggplot(aes(x = x, y = y, fill = x)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values = c("#330000", "#440000")) + # rr gg bb
  theme(legend.position = 'none')







# # Test plot
# data.frame(x = as.factor(1:1000), y = 20) %>%
#   ggplot(aes(x = x, y = y, fill = x)) +
#   geom_bar(stat = 'identity') +
#   # geom_point(pch = 22) +
#   scale_fill_manual(values = colors$col_hex[1:1000])


# HEX ANATOMY
## '# 00 - 00 - 00'
## '# Red - Green - Blue'

# Uses numbers then letters
## 0 - 9, then A - F, then 10 - 19, then 1A - 1F



# Non-Function Extraction -------------------------------------------









# Extraction by Function --------------------------------------------



# End ---------------------------------------------------------------
