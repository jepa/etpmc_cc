
# This function aggregates the ESM outputs for a given scenario and category, returning either a grid or region-based summary.

agg_esm_fx_abs <- function(scenario, category, output = "NA") {
  
  file_to_read <- my_path("G", "etpmc_cc/Results/dbem_outputs/R", scenario,
                          list_files = "paths", fn = TRUE,
                          system = "juliano")
  
  file_to_read <- file_to_read[grep(category, file_to_read)]
  
  complete_output <- NULL  # Initialize outside loop
  
  for (i in seq_along(file_to_read)) {
    file <- file_to_read[i]
    message("Processing: ", file)
    
    # Attempt to load the file safely
    load_successful <- tryCatch({
      load(file)
      TRUE
    }, error = function(e) {
      warning(paste("Skipping file due to error:", file, "\n", e$message))
      FALSE
    })
    
    if (!load_successful) next  # Skip to next file if load failed
    
    spp_data <- as.data.frame(data) %>%
      rowid_to_column("index")
    
    if (ncol(spp_data) == 251) {
      colnames(spp_data) <- c("index", 1851:2100)
    } else {
      colnames(spp_data) <- c("index", 1951:2100)
    }
    
    rm(data)  # free memory
    
    partial_data <- cmar_grid %>%
      left_join(spp_data, by = "index") %>%
      pivot_longer(cols = `1951`:`2100`, names_to = "year", values_to = "value")
    
    complete_output <- bind_rows(complete_output, partial_data)
  }
  
  if (is.null(complete_output)) {
    warning("No valid data processed for scenario: ", scenario)
    return(NULL)
  }
  
  if (output == "grid") {
    final_df <- complete_output %>%
      group_by(year, index) %>%
      summarise(value_region = sum(value, na.rm = TRUE), .groups = "drop") %>%
      mutate(
        esm = str_sub(scenario, 3, 6),
        ssp = ifelse(str_sub(scenario, 7, 8) == "26", "ssp126", "ssp585"),
        scen = str_sub(scenario, str_count(scenario) - 1, str_count(scenario)),
        category = category
      )
  } else {
    final_df <- complete_output %>%
      group_by(year, region) %>%
      summarise(value_region = sum(value, na.rm = TRUE), .groups = "drop") %>%
      mutate(
        esm = str_sub(scenario, 3, 6),
        ssp = ifelse(str_sub(scenario, 7, 8) == "26", "ssp126", "ssp585"),
        scen = str_sub(scenario, str_count(scenario) - 1, str_count(scenario)),
        category = category
      )
  }
  
  return(final_df)
}
