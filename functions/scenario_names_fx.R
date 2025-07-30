# This function simply translate the scenario names for figures
scenario_names <- function(data, leng = "spa"){
  
  if(leng == "spa"){
  data_clean <- data %>% 
    mutate(
      scenario = ifelse(str_detect(scen,"nr"),"Regulaciones no implementadas",
                        ifelse(str_detect(scen,"rc"),"Regulaciones de conservación",
                               ifelse(str_detect(scen,"ri"),"Regulaciones implementadas",
                                      ifelse(str_detect(scen,"rp"),"Regulaciones de pesca",
                                             ifelse(str_detect(scen,"sq"),"Status quo",scen)
                               )
                               )
                        )
      )
    )
  }else{
  data_clean <- data %>% 
    mutate(
      scenario = ifelse(str_detect(scen,"nr"),"Regulations not implemented",
                        ifelse(str_detect(scen,"rc"),"Regulations for conservation",
                               ifelse(str_detect(scen,"ri"),"Regulations implemented",
                                      ifelse(str_detect(scen,"rp"),"Regulations for fishing",
                                             ifelse(str_detect(scen,"sq"),"Status quo",scen)
                                      )
                               )
                        )
      )
    )
  }
  
  return(data_clean)
}


