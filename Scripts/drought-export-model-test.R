# Create Model Output Function - Drought WG --------------------------------

# Clear environment
rm(list = ls())

# Load needed libraries
library(lmerTest); library(tidyverse)

# Fit Models --------------------------------------------------------------

# Acquire data
data <- read.csv(file = "./Data/DataNick_Tables.csv")

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

# Extract Relevant Components ----------------------------------------------

# `lmer` Extract
str(mod_mem)
mem_smz <- summary(mod_mem)
mem_ext <- as.data.frame(mem_smz$coefficients) %>%
  dplyr::mutate(term = row.names(as.data.frame(mem_smz$coefficients)),
                Estimate = round(Estimate, digits = 2),
                SE = round(`Std. Error`, digits = 2),
                df = round(df, digits = 2),
                t = round(`t value`, digit = 2),
                p = round(`Pr(>|t|)`, digits = 3)) %>%
  dplyr::select(term, Estimate, SE, df, t, p)
rownames(mem_ext) <- NULL
mem_ext

# `lm` Extract
str(mod_lm)
lm_smz <- summary(mod_lm)
lm_ext <- as.data.frame(lm_smz$coefficients) %>%
  dplyr::mutate(
    term = row.names(as.data.frame(lm_smz$coefficients)),
    Estimate = round(Estimate, digits = 2),
    SE = round(`Std. Error`, digits = 2),
    df = lm_smz$df[1:nrow(as.data.frame(lm_smz$coefficients))],
    t = round(`t value`, digits = 2),
    p = round(`Pr(>|t|)`, digits = 3)
                ) %>%
  dplyr::select(term, Estimate, SE, df, t, p)
rownames(lm_ext) <- NULL
lm_ext

# `nls` Extract
str(mod_nls)
nls_smz <- summary(mod_nls)
nls_ext <- as.data.frame(nls_smz$coefficients) %>%
  dplyr::mutate(term = row.names(as.data.frame(nls_smz$coefficients)),
                Estimate = round(Estimate, digits = 2),
                SE = round(`Std. Error`, digits = 2),
                df = nls_smz$df[1:nrow(as.data.frame(nls_smz$coefficients))],
                t = round(`t value`, digits = 2),
                p = round(`Pr(>|t|)`, digits = 8),
                ) %>%
  dplyr::select(term, Estimate, SE, df, t, p)
rownames(nls_ext) <- NULL
nls_ext

# `t.test` Extract
str(mod_t)
t_ext <- data.frame(
  "Estimate" = round(mod_t$estimate, digits = 2),
  "df" = round(mod_t$parameter, digits = 2),
  "t" = round(mod_t$statistic, digits = 2),
  "p" = round(mod_t$p.value, digits = 12))
rownames(t_ext) <- NULL
t_ext

# Quick check of exported dataframe for each model type
mem_ext
lm_ext
nls_ext
t_ext

# And remove everything but the models from the environment
rm(list = setdiff(ls(), c("mod_mem", "mod_lm", "mod_nls", "mod_t")))

# Design Function ----------------------------------------------------------

# Custom function
ide_mod_export <- function(model_obj, model_type = "lmer",
               output_path = getwd(),
               output_name = paste0(model_type, "_", Sys.time(), "_model.csv"),
               est_dig = 2, se_dig = 2, df_dig = 2, t_dig = 2, p_dig = 4){
  # Argument description
  ## model_obj = output of `lmerTest::lmer()`, `stats::lm()`, `stats::nls()`, `stats::t.test()`
  ## output_path = file path to save file to
  ## output_name = desired name of file (defaults to model type and system time)
  ## ..._dig = number of digits to round each component to
  
  
  # Ensure dplyr is loaded in
  library(dplyr)
  
  # If the model type is not one of the accepted four, print an error
  if(!model_type %in% c("lmer", "lm", "nls", "t.test")){
    print("Model type not supported. Please supply one of 'lmer', 'lm', 'nls', or 't.test' to `model_type` argument.")
  } else {
  
    # Otherwise, process the supplied model type
  if(model_type == "lmer"){
    
    # Extract summary from data
    lmer_smry <- summary(model_obj)
    
    # Strip out coefficients
    lmer_coef <- as.data.frame(lmer_smry$coefficients)
    
    # Calculate new columns
    lmer_new <- dplyr::mutate(.data = lmer_coef,
                              term = row.names(lmer_coef),
                              Estimate = round(Estimate, digits = est_dig),
                              SE = round(`Std. Error`, digits = se_dig),
                              df = round(df, digits = df_dig),
                              t = round(`t value`, digit = t_dig),
                              p = round(`Pr(>|t|)`, digits = p_dig))
    
    # Get a final version of just desired columns in the correct order
    lmer_actual <- dplyr::select(.data = lmer_new, term, Estimate, SE, df, t, p)
    
    # Remove rownames
    rownames(lmer_actual) <- NULL

    # And name the object more broadly
    results <- lmer_actual
    
    # Export file
    write.csv(x = results, file = file.path(output_path, output_name),
              row.names = F) }
  
    # Now do linear model
  if(model_type == "lm") {
    
    # Get summary
    lm_smry <- summary(model_obj)
    
    # Get coefficients from that
    lm_coef <- as.data.frame(lm_smry$coefficients)
    
    # Round columns as needed
    lm_new <- dplyr::mutate(.data = lm_coef,
                            term = row.names(lm_coef),
                            Estimate = round(Estimate, digits = est_dig),
                            SE = round(`Std. Error`, digits = se_dig),
                            df = round(lm_smry$df[1:nrow(lm_coef)], df_dig),
                            t = round(`t value`, digits = t_dig),
                            p = round(`Pr(>|t|)`, digits = p_dig))
      
    # Strip out desired columns in preferred order
    results <- dplyr::select(.data = lm_new, term, Estimate, SE, df, t, p)
      
    # Ditch row names
    rownames(results) <- NULL
    
    # Export file
    write.csv(x = results, file = file.path(output_path, output_name),
              row.names = F) }
    
  # Now do non-linear least squares
  if(model_type == "nls") {
    
    # Get model summary
    nls_smry <- summary(model_obj)
    
    # Extract coefficients
    nls_coef <- as.data.frame(nls_smry$coefficients)
    
    # Get new columns
    nls_new <- dplyr::mutate(.data = nls_coef,
                             term = row.names(nls_coef),
                             Estimate = round(Estimate, digits = est_dig),
                             SE = round(`Std. Error`, digits = se_dig),
                             df = round(nls_smry$df[1:nrow(nls_coef)],
                                                    digits = df_dig),
                             t = round(`t value`, digits = t_dig),
                             p = round(`Pr(>|t|)`, digits = p_dig))
    
    # Get just desired columns
    results <- dplyr::select(.data = nls_new, term, Estimate, SE, df, t, p)

    # Remove row names
    rownames(results) <- NULL
    
    # Export file
    write.csv(x = results, file = file.path(output_path, output_name),
              row.names = F) }
  
    # Process t-test model
  if(model_type == "t.test") {
   
    # Extract relevant bit
    results <- data.frame(
      "Estimate" = round(mod_t$estimate, digits = est_dig),
      "df" = round(mod_t$parameter, digits = df_dig),
      "t" = round(mod_t$statistic, digits = t_dig),
      "p" = round(mod_t$p.value, digits = p_dig))
    
    # Remove rownames
    rownames(results) <- NULL

    # Export file
    write.csv(x = results, file = file.path(output_path, output_name),
              row.names = F)
    } } }

# Test it
ide_mod_export(model_obj = mod_mem, model_type = "lmer",
               output_name = "Drought_Mixed_Model.csv")
ide_mod_export(model_obj = mod_lm, model_type = "lm",
               output_name = "Drought_LM_Model.csv")
ide_mod_export(model_obj = mod_nls, model_type = "nls",
               output_name = "Drought_NLS_Model.csv")
ide_mod_export(model_obj = mod_t, model_type = "t.test",
               output_name = "Drought_t-test_Model.csv", p_dig = 12)

# End ----------------------------------------------------------------------
