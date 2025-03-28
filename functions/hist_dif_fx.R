

# This function estimates the percentage change in value relative to the historical time period
hist_dif <- function(category, var = "abd"){
  
  
  print(category)
  
  name <- paste0(category,"_",var,"_period.csv")
  print(name)
  
  if(is.numeric(category) == F){
    spp_data <- my_path("R","processed/groups/period_data/",name,read = T) %>% 
      rename(category = group) %>% 
      mutate(variable = var)
  }else{
    spp_data <-
      my_path("R","processed/species/period_data/",name,read = T) %>% 
      rename(category = taxon_key)
  }
  
  
  spp_data <- spp_data %>% 
    select(category,everything(),-sd_value_esm) %>%
    pivot_wider(names_from = period, values_from = mean_value_esm) %>% 
    mutate(
      dif_2040 = my_chng(`2014_hist`,`2040_ear`)
      # dif_2060 = my_chng(`2014_hist`,`2060_mid`),
      # dif_2100 = my_chng(`2014_hist`,`2100_end`)
    ) %>% 
    select(
      category:variable,dif_2040
    ) %>% 
    scenario_names() %>% 
    filter(!is.na(dif_2040))
  # gather("scen","per_change",dif_no_reg:per_reg_fish) %>% 
  
  
  for(i in 1:2){
    
    ssps <- c("ssp585","ssp126")[i]
    
    suppressMessages(
      suppressWarnings(
        # species map
        map_t <- ggplot() +
          geom_sf(data = sau_sf %>% select(region = name) %>%  left_join(spp_data) %>% filter(ssp == ssps),
                  aes(fill = dif_2040),
                  color = "grey"
          ) +
          geom_sf(data = cmar_sf %>%  left_join(spp_data) %>% filter(ssp == ssps),
                  aes(fill = dif_2040),
                  color = "black"
          ) +
          facet_wrap(~scenario) +
        scale_fill_gradient2("Diferencia relativa al valor historico (%)") +
          # ggtitle(etpmc_spp %>% filter(taxon_key == taxon) %>% pull(common_name)) +
          # ggtitle(paste(category,var)) +
          my_ggtheme_m("Reg",facet_tl_s = 6,ax_tl_s = 6,ax_tx_s = 4,leg_tl_s = 4,leg_tx_s = 4) +
          theme(legend.text = element_text(size = 6),
                legend.title = element_text(size = 6),
                legend.key.height = unit(0.2, "line"),
                title = element_text(size = 6)
          )
        
      )
    )
    map_name <- paste0(unique(spp_data$category),"_",var,"_",ssps,"_scen_diff.png")
    
    if(is.numeric(category) == F){
      ggsave(
        my_path("R","figures/relative_to_hist/groups/",map_name),
        map_t,
        height = 4,
        width = 5)
    }else{
      ggsave(
        my_path("R","figures/relative_to_hist/species/",map_name),
        map_t,
        height = 4,
        width = 5)
    }
    
  }
}

# Test
# category = 600006
# var = "abd"