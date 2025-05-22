
# This function estimates the percentage change in value relative to the historical time period
hist_dif_sq <- function(category, var, map = T, bar = T, bar_abs = T, points = T){
  
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
  
  # standard_data <- spp_data %>%
  #   group_by(period, region, category, ssp) %>%
  #   mutate(
  #      mean_value_esm_std = mean_value_esm / sum(mean_value_esm, na.rm = TRUE)
  #     # mean_value_esm_std = mean_value_esm / mean(mean_value_esm, na.rm = TRUE)
  #     ) %>%
  #   ungroup()
  
  # tday <- standard_data %>%
  #   filter(scen == "sq",
  #          period == "2014_hist") %>%
  #   select(region:4,hist_sq=mean_value_esm_std)
  
  tday <- spp_data %>%
    filter(scen == "sq",
           period == "2014_hist") %>%
    select(region:4,hist_sq=mean_value_esm)
  
  # spp_data <- standard_data %>% 
  spp_data <- spp_data %>%
    # select(category,everything(),-mean_value_esm,-sd_value_esm) %>%
    select(category,everything(),-sd_value_esm) %>%
    # pivot_wider(names_from = period, values_from = mean_value_esm_std) %>%
    pivot_wider(names_from = period, values_from = mean_value_esm) %>%
    left_join(tday) %>%
    mutate(
      dif_2040 = my_chng(hist_sq,`2040_ear`)
      # dif_2060 = my_chng(`2014_hist`,`2060_mid`),
      # dif_2100 = my_chng(`2014_hist`,`2100_end`)
    ) %>% 
    # select(
    #   category:variable,dif_2040
    # ) %>% 
    scenario_names() %>% 
    filter(!is.na(dif_2040))
  # gather("scen","per_change",dif_no_reg:per_reg_fish) %>% 
  

  
  if(map == T){
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
            scale_fill_gradient2("Change in value relative to hisotric (%)") +
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
      map_name <- paste0("map_",unique(spp_data$category),"_",var,"_",ssps,"_scen_diff_sq.png")
      
      if(is.numeric(category) == F){
        ggsave(
          my_path("R","figures/relative_to_hist/groups_sq/",map_name),
          map_t,
          height = 4,
          width = 5)
      }else{
        ggsave(
          my_path("R","figures/relative_to_hist/species_sq/",map_name),
          map_t,
          height = 4,
          width = 5)
      }
      
    }
  }
  
  if(bar == T){
    
    for(i in 1:2){
      
      ssps <- c("ssp585","ssp126")[i]
      
      spp_data %>% 
        filter(ssp == ssps,
               variable == var) %>% 
        mutate(region = gsub("_"," ",region)) %>% 
        ggplot() + 
        geom_bar(
          aes(
            x = region,
            y = dif_2040,
            fill = scenario
          ),
          stat = "identity"
          # position = "dodge"
        ) +
        facet_wrap(~scenario,
                   nrow = 1) +
        scale_fill_viridis_d() +
        coord_flip() +
        labs(x="",
             y = "Biomass change per Scenario")+
        my_ggtheme_p(leg_pos = "") +
        scale_x_discrete(limits = rev(sort(spp_data %>% mutate(region = gsub("_"," ",region)) %>% pull(region) %>% unique())))
      
      
      bar_name <- paste0("bar_",unique(spp_data$category),"_",var,"_scen_diff_",ssps,"_sq.png")
      
      
      if(is.numeric(category) == F){
        ggsave(
          my_path("R","figures/relative_to_hist/groups_sq/",bar_name),
          last_plot(),
          height = 7,
          width = 13)
      }else{
        ggsave(
          my_path("R","figures/relative_to_hist/species_sq/",bar_name),
          last_plot(),
          height = 4,
          width = 7)
      }
      
    }
  }
  
  
  
  # Higher values
  heat_data <- spp_data %>% 
    group_by(region, category, ssp,variable) %>%
    # mutate(std_2040_ear = `2040_ear` / max(`2040_ear`, na.rm = TRUE)) %>%
    # ungroup() %>% 
    mutate(
      esm_bin = cut(
        `2040_ear`,
        breaks = quantile(`2040_ear`, probs = seq(0, 1, by = 0.2), na.rm = TRUE),
        labels = c("lowest", "low", "moderate", "high", "highest"),
        include.lowest = TRUE
      )
      # std_2040_ear = ifelse(std_2040_ear < 0.5, std_2040_ear * -1,std_2040_ear)
    )
  
  
  if(bar_abs == T){
    
    for(i in 1:2){
      
      ssps <- c("ssp585","ssp126")[i]
      
      heat_data %>% 
        filter(ssp == ssps, variable == var) %>%
        mutate(region = gsub("_", " ", region)) %>%
        ggplot() + 
        geom_bar(
          aes(
            x = tidytext::reorder_within(scen, `2040_ear`, region),
            y = esm_bin,
            fill = scenario  # use binned labels, not numeric
          ),
          stat = "identity",
        ) +
        # scale_fill_manual(
        #   name = "Biomass Level",
        #   values = c(
        #     "lowest" = "#F21A00",
        #     "low" = "#E1AF00",
        #     "moderate" = "#EBCC2A",
        #     "high" = "#78B7C5",
        #     "highest" = "#3B9AB2"
        #   ),
        # guide = guide_legend(reverse = TRUE)
        # ) +
        scale_fill_viridis_d(direction = -1) +
        coord_flip() +
        labs(
          x = "",
          y = "Biomass level per Scenario"
        ) +
        my_ggtheme_p(leg_pos = "right", x_hjust = 0.5) +
        tidytext::scale_x_reordered(labels = ~gsub("___.*$", "", .)) +  # ✅ this strips the '___region'
        # scale_x_discrete(
        #   limits = rev(sort(spp_data %>% mutate(region = gsub("_", " ", region)) %>% pull(region) %>% unique()))
        # ) +
        facet_wrap(~region,
                   scale = "free_y",
                   nrow = 5) 
      
      bar_abs_name <- paste0("abs_bar_",unique(spp_data$category),"_",var,"_scen_diff_",ssps,".png")
      
      
      if(is.numeric(category) == F){
        ggsave(
          my_path("R","figures/relative_to_hist/groups_sq/",bar_abs_name),
          last_plot(),
          height = 10,
          width = 10)
      }else{
        ggsave(
          my_path("R","figures/relative_to_hist/species_sq/",bar_abs_name),
          last_plot(),
          height = 6,
          width = 6)
      }
      
    }
  }
  
  if(points == T){
    
    for(i in 1:2){
      
      ssps <- c("ssp585","ssp126")[i]
      
      
      point_data <- heat_data %>% 
        filter(ssp == ssps, variable == var) %>%
        mutate(region = gsub("_", " ", region)) %>%
        gather("time_period","value",hist_sq,`2040_ear`) 
      
      # Example: define custom breaks
      my_breaks <- pretty(range(point_data$value, na.rm = TRUE), n = 5)
      
      
      point_data %>% 
        ggplot() + 
        geom_point(
          aes(
            x = tidytext::reorder_within(scen, value, region),
            y = value,
            color = scenario,
            shape = time_period
          ),
          size = 3,
          alpha = 0.5,
          stat = "identity",
        ) +
        scale_color_viridis_d(direction = -1) +
        coord_flip() +
        labs(
          x = "",
          y = "Biomass level per Scenario"
        ) +
        my_ggtheme_p(leg_pos = "right", x_hjust = 0.5) +
        tidytext::scale_x_reordered(labels = ~gsub("___.*$", "", .)) +  # this strips the '___region
        facet_wrap(~region,
                   scale = "free",
                   nrow = 5) 
      
      point_name <- paste0("abs_pnt_",unique(spp_data$category),"_",var,"_scen_diff_",ssps,".png")
      
      
      if(is.numeric(category) == F){
        ggsave(
          my_path("R","figures/relative_to_hist/groups_sq/",point_name),
          last_plot(),
          height = 10,
          width = 10)
      }else{
        ggsave(
          my_path("R","figures/relative_to_hist/species_sq/",point_name),
          last_plot(),
          height = 6,
          width = 6)
      }
      
    }
  }
  
}
