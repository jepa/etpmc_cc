# This function simply translate the scenario names for figures
scenario_names <- function(data){
  
  data_clean <- data %>% 
    mutate(
      scenario = ifelse(str_detect(scen,"nr"),"Sin regulaciones",
                        ifelse(str_detect(scen,"rc"),"Regulaciones de conservacion",
                               ifelse(str_detect(scen,"ri"),"Regulaciones implementadas",
                                      ifelse(str_detect(scen,"rp"),"Regulaciones de pesca","Status quo")
                               )
                        )
      )
    )
  
  return(data_clean)
}


