
#Function to create maps of differences between scenarios relative to the SQ scenario

scen_dif_fx <- function(category, var = "abd", ssp_selected = "ssp585", map = T, bar = T){
  
  print(category)
  
  name <- paste0(category,"_",var,"_period.csv")
  
  if(is.numeric(category) == F){
    spp_data <- my_path("R","processed/groups/period_data/",name,read = T) %>% 
      rename(category = group)
  }else{
    spp_data <-
      my_path("R","processed/species/period_data/",name,read = T) %>% 
      rename(category = taxon_key)
  }
  
  
  spp_data <- spp_data %>% 
    select(-sd_value_esm) %>% 
    pivot_wider(names_from = scen, values_from = mean_value_esm) %>% 
    mutate(
      dif_nr = my_chng(sq,nr, limit = 100),
      dif_rc = my_chng(sq,rc, limit = 100),
      dif_ri = my_chng(sq,ri, limit = 100),
      dif_rp = my_chng(sq,rp, limit = 100)
    ) %>% 
    select(
      period,category:ssp,region, dif_nr:dif_rp
    ) %>% 
    gather("scen","per_change",dif_nr:dif_rp) %>% 
    filter(period == "2040_ear") %>% 
    scenario_names() %>% 
    filter(!is.na(per_change)) %>% 
    mutate(
      per_change = ifelse(per_change == "Inf",100,per_change)
    )
  
  if(map == T){
    # species map
    map_t <- ggplot() +
      geom_sf(data = sau_sf %>% select(region = name) %>%  left_join(spp_data) %>% filter(ssp == ssp_selected),
              aes(fill = per_change),
              color = "grey"
      ) +
      geom_sf(data = cmar_sf %>%  left_join(spp_data) %>% filter(ssp == ssp_selected),
              aes(fill = per_change),
              color = "black"
      ) +
      # facet_grid(period~scen) +
      facet_wrap(~scenario) +
      scale_fill_gradient2("Percentage change relative to the SQ scenario by 2040") +
      # ggtitle(etpmc_spp %>% filter(taxon_key == taxon) %>% pull(common_name)) +
      # ggtitle(paste(category,var)) +
      my_ggtheme_m("Reg",facet_tl_s = 6,ax_tl_s = 6,ax_tx_s = 4,leg_tl_s = 4,leg_tx_s = 4) +
      theme(legend.text = element_text(size = 6),
            legend.title = element_text(size = 6),
            legend.key.height = unit(0.2, "line"),
            title = element_text(size = 6)
      )
    
    
    map_name <- paste0(unique(spp_data$category),"_",var,"_",ssp_selected,"_scen_diff.png")
    
    if(is.numeric(category) == F){
      ggsave(
        my_path("R","figures/scen_diff/groups/",map_name),
        map_t,
        height = 4,
        width = 5)
    }else{
      ggsave(
        my_path("R","figures/scen_diff/species/",map_name),
        map_t,
        height = 4,
        width = 5)
    }
    
  }
  if(bar == T){
    
    
    spp_data %>% 
      filter(ssp == ssp_selected) %>% 
      mutate(region = gsub("_"," ",region)) %>% 
      ggplot() + 
      geom_bar(
        aes(
          x = region,
          y = per_change,
          fill = scenario
        ),
        stat = "identity",
        position = "dodge"
      ) +
      # facet_grid(~period) +
      scale_fill_viridis_d() +
      coord_flip() +
      labs(x="",
           y = "Change in value relative to historic (%)")+
      my_ggtheme_p(leg_pos = "right") +
      scale_x_discrete(limits = rev(sort(spp_data %>% mutate(region = gsub("_"," ",region)) %>% pull(region) %>% unique())))
    
    
    bar_name <- paste0("bar_",unique(spp_data$category),"_",var,"_scen_diff_",ssps,".png")
    
    
    if(is.numeric(category) == F){
      ggsave(
        my_path("R","figures/scen_diff/groups/",bar_name),
        last_plot(),
        height = 4,
        width = 7)
    }else{
      ggsave(
        my_path("R","figures/scen_diff/species/",bar_name),
        last_plot(),
        height = 4,
        width = 7)
    }
    
    
  }
  
  
}
