# Classify ERO projects

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, readxl, purrr, ggVennDiagram, tidyverse)

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data"); dir.create(datadir, F, T)
outdir <- paste0(root, "/outputs"); dir.create(outdir, F, T)

# Reading projects from UKRI
ero_projects <- read_csv(paste0(outdir, "/ero_projects.csv")) %>% 
  filter(Academic.Year >= "2017")

# Keywords to look out for
keywords = readLines(paste0(datadir, "/keywords_file.txt"))

# Replace characters in key words
search_criteria <- gsub("\" OR \"", ",", keywords)
search_criteria <- gsub("\" OR ", ",", search_criteria)
search_criteria <- gsub(" OR \"", ",", search_criteria)
search_criteria <- gsub("* OR ", ",", search_criteria)
search_criteria <- gsub("\"", "", search_criteria)
search_criteria <- gsub("*", "", search_criteria)
search_criteria <- gsub("\\*", "", search_criteria)

# Split into individual keywords
keywords <- unlist(strsplit(search_criteria, ","))

# All lower case
ero_projects$Project.Title<- tolower(ero_projects$Project.Title)

ero_projects <- ero_projects %>% 
  # filter(Status == "Pending")%>%
  # distinct(Project.Title, .keep_all= TRUE) %>% 
  mutate(Project_no = paste0("ERO", "_", row_number()))
  
# Loop through keywords
ero_stats <- lapply(X = 1:length(keywords), FUN = function(i){
  
  key <- keywords[i]
  
  key_result <- ero_projects %>% 
    dplyr::filter(stringr::str_detect(Project.Title, key)) %>% 
    mutate(Keyword = key,
           Keyword_hit = "1")
  
})

# Merge all dataframes
ero_keyword_search <- purrr::map_df(ero_stats, data.frame) %>% 
  select(Project_no, Project.Title, Keyword, Keyword_hit)

# Write extract
write.csv(ero_keyword_search , file = paste0(outdir, "/ero_keyword_search.csv"), row.names = FALSE)