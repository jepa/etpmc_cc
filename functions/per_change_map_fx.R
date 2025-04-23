
# This function creates a percentage change map for the fix historical value
per_change_map <- function(df,level,ssp_selected, cat_selected, relative){
  
  map_t <- ggplot() +
    geom_sf(data = sau_sf %>% select(region = name) %>%  left_join(df) %>% filter(ssp == ssp_selected,category == cat_selected), 
            aes(fill = per_change),
            color = "grey"
    ) +
    geom_sf(data = cmar_sf %>%  left_join(df) %>% filter(ssp == ssp_selected,category == cat_selected),
            aes(fill = per_change),
            color = "black"
    ) +
    facet_wrap(~scenario) +
    scale_fill_gradient2("Percentage change relative to the SQ scenario in 2014 by 2040") +
    my_ggtheme_m("Reg",facet_tl_s = 6,ax_tl_s = 6,ax_tx_s = 4,leg_tl_s = 4, leg_tx_s = 4) +
    theme(legend.text = element_text(size = 6),
          legend.title = element_text(size = 6),
          legend.key.height = unit(0.2, "line"),
          title = element_text(size = 6)
    )
  
  
  map_name <- paste0("hist_",level,"_",cat_selected,"_",relative,"_",ssp_selected,".png")
  
  ggsave(
    my_path("R",paste0("figures/historical/",relative,"/all/"),map_name),
    map_t,
    height = 4,
    width = 5)
  
}
