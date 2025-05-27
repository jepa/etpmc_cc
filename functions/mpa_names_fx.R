# This function simply translate the scenario names for figures
mpa_names <- function(data){
  
  data_clean <- data %>% 
    mutate(
      region = ifelse(str_detect(region,"Galapagos_"),"Galapagos",
                         ifelse(str_detect(region,"Hermandad"),"Hermandad",
                                ifelse(str_detect(region,"Yurupari _Malpelo_Colombia"),"Yuripari-Malpelo",
                                       ifelse(str_detect(region,"IslaCoco"),"Isla del Coco",
                                              ifelse(str_detect(region,"AMM"),"Bicentenario",
                                                     ifelse(str_detect(region,"CLomas"),"Colinas y lomas submarinas",
                                                            ifelse(str_detect(region,"CoibaCoord"),"Cordillera Coiba",
                                                                   ifelse(str_detect(region,"Coiba_Panama"),"Coiba",
                                                            ifelse(str_detect(region,"Malpelo"),"Malpelo",region)
                                                     )
                                                            )
                                                     )
                                              )
                                       )
                                )
                         )
      )
    )
  
  return(data_clean)
}




# mpa_names <-
#   
#   Galápagos, Hermandad, Isla del Coco, Bicentenario, Coiba, Cordillera Coiba, , Malpelo, Colinas y lomas submarinas de la cuenca y Gorgona


