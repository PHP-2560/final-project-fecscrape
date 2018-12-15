# Initialize libraries
required_packages <- c("devtools","httr", "rvest", "jsonlite", "dplyr", "stringr", "purrr", "tidyr") # list of packages required
# Check if any listed packages are not installed
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
# Install packages_new if it's not empty
if(length(new_packages)) install.packages(new_packages)
# Load packages
lapply(required_packages, library, character.only = TRUE)



my_api <- "jFTYk34OsWkFoEHLcUDa7G1Ax4GCyhJyAgCwB8oz"
# statelist <-c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")

statelist <- c("HI",
               "ID",
               "IL",
               "IN",
               "IA")

for (s in statelist) {
   state = s
   
   source("query_candidate_list.R")
   source("query_openfec.R")
   source("query_contributions_all.R")
   source("query_itemized_contributions.R")
   clist<-query_candidate_list(api_key= my_api, state = state, election_year = 2018, office = "S")
   print(clist)
   if (class(clist)=="character") next
   df<-query_contributions_all(clist, my_api)
   save(df, file = paste0("./data/contributoins_", state))      
}
