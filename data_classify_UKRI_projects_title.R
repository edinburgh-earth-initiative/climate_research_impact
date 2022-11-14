# Classify UKRI projects

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, readxl, purrr, ggVennDiagram, tidyverse)

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data"); dir.create(datadir, F, T)
outdir <- paste0(root, "/outputs"); dir.create(outdir, F, T)


# Reading projects from UKRI
ukri_projects <- read_csv(paste0(root, "/outputs", "/ukri_projects.csv")) %>% 
  mutate_at(vars(StartDate, EndDate), as.Date, format="%d/%m/%y") %>% 
  filter(StartDate > "01/01/2017")

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
ukri_projects$Title<- tolower(ukri_projects$Title)

ukri_projects <- ukri_projects %>% 
  distinct(Title, .keep_all= TRUE) %>% 
  mutate(Project_no = paste0("UKRI", "_", row_number()))

# Loop through keywords
ukri_stats <- lapply(X = 1:length(keywords), FUN = function(i){
  
  key <- keywords[i]
  
  key_result <- ukri_projects %>% 
    dplyr::filter(stringr::str_detect(Title, key)) %>% 
    mutate(Keyword = key,
           Keyword_hit = "1")
  
})

# Merge all dataframes
ukri_keyword_search <- purrr::map_df(ukri_stats, data.frame) %>% 
  select(Project_no, Title, Keyword, Keyword_hit)

# Keyword categories
sheet_names <- excel_sheets(path=paste0(root, "/data", "/Keywords.xlsx"))[2:4] # Grab sheet names

# Loop through sheets
category_sheets <- lapply(sheet_names, function(x) {
  as.data.frame(read_excel(paste0(root, "/data", "/Keywords.xlsx"), sheet = x))})

# rename elements in list by sheet name
names(category_sheets) <- sheet_names

# Projects categorization
ukri_projects_categorised <- list()

for (i in 1:length(category_sheets)){
  
  category_keys <- category_sheets[i]
  
  category_keys <- do.call(rbind.data.frame, category_keys)
  
  categorised_keys <- ukri_keyword_search %>% 
    inner_join(category_keys, by = c("Keyword" = "Keywords")) %>%
    mutate(Category = Research_category) %>%
    select(Project_no) %>% 
    as.character()
  
  ukri_projects_categorised[[i]] <- unlist(strsplit(categorised_keys, ","))
  
}

names(ukri_projects_categorised) <- sheet_names

ggVennDiagram(ukri_projects_categorised, color = 1, lwd = 0.7) + 
  scale_fill_gradient(low = "#F4FAFE", high = "#4981BF") +
  theme(legend.position = "none")
