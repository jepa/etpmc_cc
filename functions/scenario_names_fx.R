# This function simply translate the scenario names for figures
scenario_names <- function(data){
  
  
  data_clean <- data %>% 
    mutate(
      scenario = ifelse(scen == "nr","Sin regulaciones",
                        ifelse(scen == "rc","Regulaciones de conservacion",
                               ifelse(scen == "ri","Regulaciones implementadas",
                                      ifelse(scen == "rp","Regulaciones de pesca","Status quo")
                               )
                        )
      )
    )
  
  return(data_clean)
}


