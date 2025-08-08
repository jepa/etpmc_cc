# Deal with duplicates, prioritize 'protected' status if there are multiple statuses for the same index
# Used on scenarios_building.Rmd

prior_prot <- function(data){
  
non_duplicated_data <- data %>% 
  group_by(index) %>%
  # Create a flag column to mark protected status rows (if any) for each index
  mutate(priority_status = if_else(status == "protected", 1, 0)) %>%
  arrange(index, desc(priority_status)) %>%  # Ensure 'protected' rows come first for each index
  # Keep only the first occurrence for each index, effectively keeping 'protected' if it exists
  distinct(index, .keep_all = TRUE) %>%
  ungroup()
  
return(non_duplicated_data)
}
