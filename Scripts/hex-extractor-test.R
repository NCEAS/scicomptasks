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

# HEX ANATOMY
## '# 00 - 00 - 00'
## '# Red - Green - Blue'

# Uses numbers then letters
## 0 - 9, then A - F, then 10 - 19, then 1A - 1F, then ...
hex_digs <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f')
length(hex_digs)

# Custom Workflow No. 1 ----------------------------------------------

# Libraries
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
# rgb_v2 <- dplyr::mutate(.data = rgb_v1,
#     ## Green
#     green = dplyr::case_when(
#       red == blue & green %in% c('0', '1', '2', '3') ~ '1',
#       red == blue & green %in% c('4', '5', '6', '7') ~ '5',
#       red == blue & green %in% c('8', '9', 'a', 'b') ~ '9',
#       red == blue & green %in% c('c', 'd', 'e', 'f') ~ 'd',
#       TRUE ~ green),
#     ## Blue
#     blue = dplyr::case_when(
#       red == green & blue %in% c('0', '1', '2', '3') ~ '1',
#       red == green & blue %in% c('4', '5', '6', '7') ~ '5',
#       red == green & blue %in% c('8', '9', 'a', 'b') ~ '9',
#       red == green & blue %in% c('c', 'd', 'e', 'f') ~ 'd',
#       TRUE ~ blue),
#     ## Red
#     red = dplyr::case_when(
#       blue == green & red %in% c('0', '1', '2', '3') ~ '1',
#       blue == green & red %in% c('4', '5', '6', '7') ~ '5',
#       blue == green & red %in% c('8', '9', 'a', 'b') ~ '9',
#       blue == green & red %in% c('c', 'd', 'e', 'f') ~ 'd',
#       TRUE ~ red) )
## Assemble hex codes from those values
hex_v1 <- base::data.frame(rgb_combo = base::with(data = rgb_v1, paste0(red, green, blue)))
## Identify only unique colors
hex_v2 <- base::unique(x = hex_v1) # 890
## Split back out colors for a necessary diagnostic
hex_v3 <- dplyr::mutate(.data = hex_v2,
                        red = stringr::str_sub(rgb_combo, start = 1, end = 1),
                        green = stringr::str_sub(rgb_combo, start = 2, end = 2),
                        blue = stringr::str_sub(rgb_combo, start = 3, end = 3),
                        numR = base::suppressWarnings(base::as.numeric(red)),
                        numG = base::suppressWarnings(base::as.numeric(green)),
                        numB = base::suppressWarnings(base::as.numeric(blue)))
## Remove really dark colors that are likely less useful
hex_v4 <- dplyr::filter(.data = hex_v3,
                        # If all are <5 AND...
                        dplyr::if_all(numR:numB) >= 7 |
                        # Keep if any are NA (greater than 5 in hex is NA in numeric)
                        dplyr::if_any(numR:numB, is.na))
## Group by each pairwise combo of R/G/B channels and pick only one observation
### red - green
hex_v5 <- hex_v4 %>%
  dplyr::mutate(RG = paste0(red, green)) %>%
  dplyr::group_by(RG) %>%
  dplyr::summarise(red = dplyr::first(red),
                   green = dplyr::first(green),
                   blue = dplyr::first(blue))
### green - blue
hex_v6 <- hex_v5 %>%
  dplyr::mutate(GB = paste0(green, blue)) %>%
  dplyr::group_by(GB) %>%
  dplyr::summarise(red = dplyr::first(red),
                   green = dplyr::first(green),
                   blue = dplyr::first(blue))
### blue - red
hex_v7 <- hex_v6 %>%
  dplyr::mutate(BR = paste0(blue, red)) %>%
  dplyr::group_by(BR) %>%
  dplyr::summarise(red = dplyr::first(red),
                   green = dplyr::first(green),
                   blue = dplyr::first(blue))
## Create hexadecimal codes from RGB
hex_v8 <- dplyr::mutate(.data = hex_v7,
                        hex_code = paste0('#', red, red, green, green, blue, blue))
## Keep only hex codes
hex_v9 <- dplyr::select(.data = hex_v8, hex_code)

# Test plot
# ggplot(hex_v9, aes(x = hex_code, y = 1, fill = reorder(hex_code, val))) +
ggplot(hex_v9, aes(x = hex_code, y = 1, fill = hex_code)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values = hex_v9$hex_code) + # rr gg bb
  theme(legend.position = 'none',
        axis.text.x = element_text(angle = 35, hjust = 1))






# microbenchmark::microbenchmark(unique(rgb_v2), unique(hex_v1), times = 10)
# Unit: milliseconds
# expr        min         lq       mean     median         uq       max neval
# unique(rgb_v2) 13012.1356 14323.3887 15656.8132 15139.5319 16421.7094 19533.277    10
# unique(hex_v1)   167.2555   190.0355   273.5877   277.7436   285.9613   509.486    10










# # `colorfindr` Extraction Process ---------------------------------
## Library
library(colorfindr)
## Extraction (very slow)
colors <- colorfindr::get_colors(img = file.path("Data", "swallowtail.jpg"),
                                 exclude_col = c("#FFFFFF", "#000000"))
head(colors)


# Non-Function Extraction -------------------------------------------









# Extraction by Function --------------------------------------------



# End ---------------------------------------------------------------
