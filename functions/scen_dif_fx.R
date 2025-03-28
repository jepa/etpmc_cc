
#Function to create maps of differences between scenarios relative to the SQ scenario

scen_dif_fx <- function(category, var = "abd"){
  
  print(category)
  
  if(var == "abd"){
    name <- paste0(category,"_",var,"_period.csv")
  }else{
    name <- paste0(category,"_",var,"_period.csv")
  }
  
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
      dif_nr = my_chng(sq,nr),
      dif_rc = my_chng(sq,rc),
      dif_ri = my_chng(sq,ri),
      per_rp = my_chng(sq,rp)
    ) %>% 
    select(
      period,category:ssp,region, dif_nr:per_rp
    ) %>% 
    gather("scen","per_change",dif_nr:per_rp) %>% 
    filter(period == "2040_ear") %>% 
    scenario_names()
  
  
  # species map
  map_t <- ggplot() +
    geom_sf(data = sau_sf %>% select(region = name) %>%  left_join(spp_data) %>% filter(ssp == "ssp585"),
            aes(fill = per_change),
            color = "grey"
    ) +
    geom_sf(data = cmar_sf %>%  left_join(spp_data) %>% filter(ssp == "ssp585"),
            aes(fill = per_change),
            color = "black"
    ) +
    # facet_grid(period~scen) +
    facet_wrap(~scenario) +
    scale_fill_gradient2("Diferencia relativa al escenario de SQ\n en 2040 (%)") +
    # ggtitle(etpmc_spp %>% filter(taxon_key == taxon) %>% pull(common_name)) +
    # ggtitle(paste(category,var)) +
    my_ggtheme_m("Reg",facet_tl_s = 6,ax_tl_s = 6,ax_tx_s = 4,leg_tl_s = 4,leg_tx_s = 4) +
    theme(legend.text = element_text(size = 6),
          legend.title = element_text(size = 6),
          legend.key.height = unit(0.2, "line"),
          title = element_text(size = 6)
    )
  
  
  map_name <- paste0(unique(spp_data$category),"_",var,"_scen_diff.png")
  
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
