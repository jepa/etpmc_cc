
agg_group <- function(group_selected, variable, ignore_taxa = NA) {
  
  message(glue::glue("Processing group: {group_selected}"))
  
  # Filter relevant taxa
  group_taxa <- spp_groups %>%
    filter(group == group_selected, !taxon_key %in% ignore_taxa)
  
  
  # Build file paths
  base_paths <- my_path("R",
                        extra_path = "dbem_outputs/Rdata/",
                        list_files = "paths",
                        fn = TRUE,
                        system = "juliano")
  
  file_df <- expand.grid(
    taxon_key = group_taxa$taxon_key,
    path = base_paths,
    stringsAsFactors = FALSE
  ) %>%
    mutate(full_path = paste0(path, "/", taxon_key, variable, ".RData"),
           esm = str_sub(path, 65, 68),
           ssp = ifelse(str_sub(path, 69, 70) == "26", "ssp126", "ssp585"),
           scen = str_sub(path, 73, 74),
           taxon = as.character(taxon_key))
  
  # Load and process each RData
  complete_output <- purrr::map_dfr(seq_len(nrow(file_df)), function(i) {
    path <- file_df$full_path[i]
    
    tryCatch({
      load(path)
      
      spp_data <- as.data.frame(data) %>%
        rowid_to_column("index") %>%
        filter(index %in% cmar_grid$index)
      
      rm(data)
      
      # Set column names
      col_years <- if (ncol(spp_data) == 251) 1851:2100 else 1951:2100
      colnames(spp_data) <- c("index", as.character(col_years))
      
      spp_data %>%
        pivot_longer(-index, names_to = "year", values_to = "value") %>%
        mutate(
          year = as.numeric(year),
          period = case_when(
            year >= 2021 & year <= 2040 ~ "2030_ear",
            year >= 2041 & year <= 2060 ~ "2050_mid",
            year >= 2081 & year <= 2100 ~ "2100_end",
            year <= 2014 ~ "2014_hist",
            TRUE ~ NA_character_
          ),
          esm = file_df$esm[i],
          ssp = file_df$ssp[i],
          scen = file_df$scen[i],
          group = group_selected,
          taxon = file_df$taxon[i]
        ) %>%
        filter(!is.na(period))
      
    }, error = function(e) {
      message(glue::glue("Skipping file {path}: {e$message}"))
      return(NULL)
    })
  })
  
  # Summarize across groups
  final_output <- complete_output %>%
    # Sum taxa in group
    group_by(index, year, period, esm, ssp, scen, group) %>%
    summarise(sum_v = sum(value, na.rm = TRUE), .groups = "drop") %>%
    filter(sum_v != 0) %>%
    left_join(cmar_grid, by = "index", relationship = "many-to-many") %>%
    # Sum grids per region
    group_by(scen, region, year, period, esm, ssp, group) %>%
    summarise(sum_v = sum(sum_v, na.rm = TRUE), .groups = "drop") %>%
    # Calculate mean and standard deviation per time period
    group_by(scen, region, period, esm, ssp, group) %>%
    summarise(mean_value_tp = mean(sum_v), .groups = "drop") %>%
    # Calculate mean by ESM and scenario
    group_by(scen, region, period, ssp, group) %>%
    summarise(
      mean_value_esm = mean(mean_value_tp),
      sd_value_esm = sd(mean_value_tp),
      .groups = "drop"
    )
  
  # Save results
  name <- paste0(group_selected, "_", variable, "_period.csv")
  message(glue::glue("Writing: {name}"))
  
  write_csv(final_output, 
            paste0("~/Library/CloudStorage/GoogleDrive-jepa88@gmail.com/My Drive/lenfest_mpa_project/manuscripts/scenarios_report/results/processed/groups/",name)
            # my_path("R", "processed/groups/period_data/", name)
            )
  # return(final_output)
}
# Example usage


