# Create Model Output Function - Drought WG ---------------------

# Clear environment
rm(list = ls())

# Load needed libraries
# devtools::install_github("NCEAS/scicomptools", force = TRUE)
library(lmerTest); library(tidyverse); library(scicomptools)

# Fit Models -----------

# Acquire data
data <- read.csv(file = file.path("data", "DataNick_Tables.csv"))

# Summarize it (for one of the tests)
data_smz <- data %>%
  group_by(site_code) %>%
  dplyr::summarize(mean_DS3 = mean(DS3, na.rm = T))

# Fit mixed-effects model
mod_mem <- lmerTest::lmer(DS3 ~ habitat.type + (1|site_code), data = data)

# Fit linear model
mod_lm <- stats::lm(DS3 ~ drtpct_map100, data = data)

# Fit nonlinear least squares
mod_nls <- stats::nls(DS3 ~ b0 * b1 ** drtpct_map100, data = data,
                      start = list(b0 = max(data$DS3), b1 = 1))

# Fit t-test
mod_t <- stats::t.test(data_smz$mean_DS3, mu = 0, alternative = "less")

# Extracting Summary Statistics ---------------

# Create a directory to save to
dir.create("task_export", showWarnings = FALSE)

# Extract the summary stats from each
scicomptools::stat_export(model_obj = mod_mem,
                          model_type = "lmer",
                          output_path = "task_export",
                          output_name = "Drought_Mixed_Model.csv")
scicomptools::stat_export(model_obj = mod_lm,
                          model_type = "lm",
                          output_path = "task_export",
                          output_name = "Drought_LM_Model.csv")
scicomptools::stat_export(model_obj = mod_nls,
                          model_type = "nls",
                          output_path = "task_export",
                          output_name = "Drought_NLS_Model.csv")
scicomptools::stat_export(model_obj = mod_t,
                          model_type = "t.test",
                          output_path = "task_export",
                          output_name = "Drought_t-test_Model.csv",
                          est_dig = 2,
                          p_dig = 12)

# End ----
