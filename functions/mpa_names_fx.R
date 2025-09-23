# This function simply translate the scenario names for figures
mpa_names <- function(data){
  
  data_clean <- data %>% 
    mutate(
      region = ifelse(str_detect(region,"Galapagos_"),"RMG",
                      ifelse(str_detect(region,"Hermandad"),"RMH",
                             ifelse(str_detect(region,"Yurupari _Malpelo_Colombia"),"DNMIYM",
                                    ifelse(str_detect(region,"IslaCoco"),"PNIC",
                                           ifelse(str_detect(region,"AMM"),"AMMB",
                                                  ifelse(str_detect(region,"Gorgona"),"PNNG",
                                                         ifelse(str_detect(region,"CLomas"),"DCLS",
                                                                ifelse(str_detect(region,"CoibaCoord"),"ARMCC",
                                                                       ifelse(str_detect(region,"Coiba_Panama"),"PNC",
                                                                              ifelse(region == "Ecuador","Ecuador (Continental EEZ)",
                                                                                     ifelse(str_detect(region,"Malpelo"),"SFFM",
                                                                                            region)
                                                                              )
                                                                       )
                                                                )
                                                         )
                                                  )
                                           )
                                    )
                             )
                      )
      ),
      region = sub("(Pacific)", "EEZ", region),
      region = ifelse(region == "Galapagos Isl. (Ecuador)", "Ecuador (Insular EEZ)", region)
    )
  
  return(data_clean)
}




# mpa_names <-
#   
#   Galápagos, Hermandad, Isla del Coco, Bicentenario, Coiba, Cordillera Coiba, , Malpelo, Colinas y lomas submarinas de la cuenca y Gorgona


