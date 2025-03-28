# This function simply translate the scenario names for figures
scenario_names <- function(data){
  
  data_clean <- data %>% 
    mutate(
      scenario = ifelse(str_detect(scen,"nr"),"No regulations",
                        ifelse(str_detect(scen,"rc"),"Regulations for conservation",
                               ifelse(str_detect(scen,"ri"),"Regulations implemented",
                                      ifelse(str_detect(scen,"rp"),"Regulations for fishing",
                                             ifelse(str_detect(scen,"sq"),"Status quo",scen)
                               )
                               )
                        )
      )
    )
  
  return(data_clean)
}


