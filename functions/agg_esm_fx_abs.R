


# This function aggregates all species per ESM and rcp and scenario

agg_esm_fx_abs <- function(scenario, category){
  
  file_to_read <- my_path("R","dbem_outputs/Rdata",scenario,
                          list_files = "paths",fn = T,
                          system = "juliano")
  
  file_to_read <- file_to_read[grep(category, file_to_read)]
  
  for(i in 1:length(file_to_read)){
    print(file_to_read[i])
    load(file_to_read[i])
    
    # Transform it to df
    spp_data <- as.data.frame(data) %>% 
      rowid_to_column("index")
    
    if(ncol(spp_data) == 251){
      colnames(spp_data) <- c("index",(seq(1851,2100,1)))
    }else{
      colnames(spp_data) <- c("index",(seq(1951,2100,1)))
    }
    rm(data) # remove data for computing power
    
    
    partial_data <- cmar_grid %>% 
      left_join(spp_data) %>% 
      pivot_longer(cols = `1951`:`2100`, names_to = "year", values_to = "value")
    
    # Join data for all three models
    if(i == 1){
      complete_output <- partial_data
    }else{
      
      complete_output <- bind_rows(complete_output,partial_data)
      
    }
    
  } # close for loop in i for species
  
  final_df <-
    complete_output %>% 
    group_by(year,region) %>%
    summarise(
      value_region = sum(value,na.rm =T)
    ) %>% mutate(
      esm = str_sub(scenario,3,6),
      ssp = ifelse(str_sub(scenario,7,8)== 26,"ssp126","ssp585"),
      scen = str_sub(scenario,str_count(scenario)-1,str_count(scenario)),
      category = category
    )
  
  
  return(final_df)
  
}

