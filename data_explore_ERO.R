# Search by keywords in the title of ERO extract

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, readxl, purrr)

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data")
outdir <- paste0(root, "/outputs")
dir.create(datadir, F, T)
dir.create(outdir, F, T)

# Reading projects from UKRI
ero_extract <- read_excel(paste0(datadir, "/ERO_all_projects.xlsx"))

ero_schools <- read_excel(paste0(datadir, "/ERO_schools_corrected.xlsx"))

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

# All lower case
keywords <- tolower(search_criteria)

# Split into individual keywords
keywords <- unlist(strsplit(keywords, ","))

# All lower case
ero_extract$`Project Title`<- tolower(ero_extract$`Project Title`)

ero_extract <- ero_extract %>%
  distinct(across(everything()))
           
# distinct(Status, `Project Title`, .keep_all= TRUE)

# ero_extract %>% 
#   group_by(Status, `Project Title`) %>% 
#   mutate(dupe = n()>1)

# Loop through keywords
ero_stats <- lapply(X = 1:length(keywords), FUN = function(j){
  
  key <- keywords[j]
  
  search_result <- dplyr::filter(ero_extract, 
                       stringr::str_detect(`Project Title`, 
                                           key))
})

# Merge all dataframes
ero_projects <- purrr::map_df(ero_stats, data.frame) %>% 
  mutate_at(vars(Application.Period.Start, Application.Period.End), as.Date, format="%y-%m-%d") %>% 
  mutate(School = recode(School,
                         "Law" =  "School of Law",                                                      
                         "Deanery of Clinical Sciences" = "Deanery of Clinical Sciences",                                
                         "Edinburgh College of Art" = "Edinburgh College of Art",                                    
                         "Physics and Astronomy" =  "School of Physics and Astronomy",                                     
                         "Royal (Dick) School of Veterinary Studies" =  "Royal (Dick) School of Veterinary Studies",                 
                         "Literatures, Languages and Cultures" = "School of Literatures, Languages & Culture",                       
                         "Deanery of Molecular, Genetic and Population Health Sciences" = "Deanery of Molecular, Genetic and Population Health Sciences",
                         "Divinity" = "School of Divinity",                                                     
                         "Engineering" =  "School of Engineering",                                                
                         "Social and Political Science" =  "School of Social and Political Science",                              
                         "Health in Social Science" =  "School of Health in Social Science",                                  
                         "Geosciences" = "School of GeoSciences",                                                 
                         "Philosophy, Psychology and Language Sciences" =  "School of Philosophy, Psychology and Language Sciences",                
                         "Biological Sciences" = "School of Biological Sciences",                                         
                         "Informatics" =  "School of Informatics",                                                 
                         "Moray House School of Education and Sport" =  "Moray House School of Education and Sport",                   
                         "History, Classics and Archaeology" =  "School of History, Classics and Archaeology",                         
                         "Deanery of Biomedical Sciences" = "Deanery of Biomedical Sciences",                              
                         "College of Science and Engineering ll" = "Others", 
                         "College of Medicine and Veterinary Medicine ll" = "Others",
                         "College of Science and Engineering lll" = "Others",
                         "College of Science and Engineering lV" = "Others",
                         "Mathematics" = "School of Mathematics",                                               
                         "Edinburgh Research Office"  =  "Others", 
                         "Edinburgh Research and Innovation" = "Others",
                         "Economics" = "School of Economics",
                         "Business School" = "Business School",                                             
                         "Chemistry"  = "School of Chemistry"))

ero_duplicates <- ero_projects %>% 
  group_by(Project_ID) %>% 
  mutate(isDuplicated = n() > 1) %>% 
  ungroup() %>% 
  filter(Scheme.Name == "research grant",
         isDuplicated == "TRUE")

# Write extract
write.csv(ero_projects , file = paste0(outdir, "/ero_projects.csv"), row.names = FALSE)