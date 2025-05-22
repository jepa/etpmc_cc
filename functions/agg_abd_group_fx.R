agg_abd_group <- function(group_selected,variable,ignore_taxa = NA){
  
  print(group_selected)
  
  group_taxa <- spp_groups %>% 
    filter(group == group_selected,
           !taxon_key %in% ignore_taxa)
  
  
  
  file_to_read <- paste0(my_path("R",
                                 extra_path = "dbem_outputs/Rdata/",
                                 list_files = "paths",
                                 fn = T,
                                 system = "juliano"),
                         "/",
                         group_taxa$taxon_key,variable,".RData")
  
  
  
  for(i in 1:length(file_to_read)){
    
    # For problematic files
    tryCatch({
      load(file_to_read[i])
    
    
    # Transform it to df
    spp_data <- as.data.frame(data) %>% 
      rowid_to_column("index") %>% 
      filter(index %in% cmar_grid$index)
    
    if(ncol(spp_data) == 251){
      colnames(spp_data) <- c("index",(seq(1851,2100,1)))
    }else{
      colnames(spp_data) <- c("index",(seq(1951,2100,1)))
    }
  
    
    partial_data <- spp_data %>% 
      gather("year","value",`1951`:`2100`) %>% 
      filter(index %in% cmar_grid$index) %>% 
      mutate(period = ifelse(year < 2060 & year > 2041,"2060_mid",
                             ifelse(year < 2040 & year > 2021,"2040_ear",
                                    ifelse(year < 2100 & year > 2081,"2100_end",
                                           ifelse(year < 2014 & year > 1995,"2014_hist",
                                                  NA)
                                    )
                             )
                             
      )
      ) %>% 
      filter(!is.na(period)) %>%
      mutate(
        esm = str_sub(file_to_read[i],65,68),
        ssp = ifelse(str_sub(file_to_read[i],69,70) == 26,"ssp126","ssp585"),
        scen = str_sub(file_to_read[i],73,74),
        group = group_selected,
        taxon = str_sub(file_to_read[i],76,81)
      )
    
    if(i == 1){
      complete_output <- partial_data
    }else{
      
      complete_output <- bind_rows(complete_output,partial_data)
    }
    
    }, error = function(e) {
      message(paste("Error reading file:", file_to_read[i], "\n", e$message))
      next  # skip to next iteration in the loop
    })
  }
    # Estimate aggregated value of all species in each group
    final_output <- complete_output %>% 
      select(index:taxon) %>% 
      # Sum taxon per grid
      group_by(index,year,period,esm,ssp,scen,group) %>% 
      summarise(
        sum_v = sum(value, na.rm = T),
        .groups = "keep"
      ) %>% 
      # Remove cases where results are 0 as these are DBEM residuals
      group_by(index,year,period,esm,ssp,group) %>%
      filter(all(sum_v != 0)) %>%
      # sum value per CMAR area
      left_join(cmar_grid,
                by = "index",
                relationship = "many-to-many") %>% 
      group_by(scen,region,year,period,esm,ssp,group) %>% 
      #aggregate all grids
      summarise(
        sum_v = sum(sum_v, na.rm = T),
        .groups = "keep"
      ) %>% 
      # Average time periods
      group_by(scen,region,period,esm,ssp,group) %>% 
      summarise(
        mean_value_tp = mean(sum_v, na.rm = T),
        .groups = "keep"
      ) %>% 
      # average per ESM
      group_by(scen,region,period,ssp,group) %>% 
      summarise(
        mean_value_esm = mean(mean_value_tp, na.rm = T),
        sd_value_esm = sd(mean_value_tp, na.rm =T),
        .groups = "keep"
      )
      
      
    name <- paste0(group_selected,"_",variable,"_period.csv")
    print(paste(unique(name)))
    
    write_csv(final_output,
              my_path("R","processed/groups/period_data/",name))
}
