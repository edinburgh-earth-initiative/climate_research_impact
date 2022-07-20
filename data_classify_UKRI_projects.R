# Classify UKRI projects

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load("httr", "dplyr", "jsonlite", "purrr")

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data")
outdir <- paste0(root, "/outputs")
dir.create(datadir, F, T)
dir.create(outdir, F, T)

# Keywords to look out for
keywords = readLines(paste0(root, "/keywords_file.txt"))

# Fix search criteria
search_criteria <- gsub("OR", ",", keywords)
search_criteria <- gsub("\"","%22", search_criteria)
search_criteria <- gsub(" , ", ",", search_criteria)
search_criteria <- gsub(" ", "+", search_criteria)

# Split into individual keywords
search_criteria <- unlist(strsplit(search_criteria, ","))

search_stats <- lapply(X = 1:length(search_criteria), FUN = function(i){
  
  key <- search_criteria[i]
  
  url_page <- paste0("http://gtr.ukri.org/search/project?term=", key, "&page=1&fetchSize=100")
  search_test <- httr::GET(url_page)
  pages <- search_test$headers$`link-pages`
  
  # Columns to retain in final dataframe
  key_columns <- c("projectComposition.project.title",
                   "projectComposition.project.grantCategory",
                   "projectComposition.project.id",
                   "projectComposition.project.url",
                   "projectComposition.project.fund.valuePounds",
                   "projectComposition.project.fund.start",
                   "projectComposition.project.fund.end",
                   "projectComposition.project.fund.funder.name",
                   "projectComposition.project.fund.funder.id",
                   "projectComposition.leadResearchOrganisation.name",
                   "projectComposition.leadResearchOrganisation.id")
  
  key_stats <- lapply(X = 1:pages, FUN = function(j){
    
    gtr_url <- paste0("http://gtr.ukri.org/search/project?term=", key,"&page=", j, "&fetchSize=100")
    page_response <- httr::GET(gtr_url)
    page_text <- httr::content(page_response, as="text")
    page_results <- jsonlite::fromJSON(page_text, flatten=TRUE)
    page_table <- page_results$searchResult$results
    
    # if(is.list(page_table)) {break} 
    
    # tidy_table <- dplyr::select(page_table, tidyselect::all_of(key_columns))
    
    tidy_table <- page_table %>% purrr::keep(names(.) %in% key_columns)

    colnames(tidy_table) <- c("project_title", 
                              "grant_category",
                              "project_id",
                              "project_url",
                              "value",
                              "start_date",
                              "end_date",
                              "funder_name",
                              "funder_id",
                              "lead_org",
                              "lead_org_id")
    

    tidy_table <- tidy_table %>%
      filter(lead_org_id == "2DB7ED73-8E89-457A-A395-FAC12F929C1A")
    
    
    if(nrow(tidy_table) == 0){
      tidy_table[nrow(tidy_table) + 1,] = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)
    }
    
    return(tidy_table)
    
  })
  
  key_stats <- do.call(rbind, key_stats)
  
  search_term <- gsub("%22", "", key)
  search_term <- gsub("\\+"," ", search_term)
  
  key_stats <- key_stats %>%
    na.omit() %>% 
    mutate(keyword = search_term,
           keyword_hit = "1")
  
  return(key_stats)

})

search_stats <- do.call(rbind, search_stats)












# Loop through lists
for (i in 1:pages){
  gtr_url <- paste0("http://gtr.ukri.org/search/project?term=", search_criteria,"&page=", i, "&fetchSize=100")
  page_response <- httr::GET(gtr_url)
  page_text <- httr::content(page_response, as="text")
  page_results <- jsonlite::fromJSON(page_text, flatten=TRUE)
  page_table <- page_results$searchResult$results
  tidy_table <- dplyr::select(page_table, tidyselect::all_of(key_columns))
  colnames(tidy_table) <- c("project_title", 
                            "grant_category",
                            "project_id",
                            "project_url",
                            "value",
                            "start_date",
                            "end_date",
                            "funder_name",
                            "funder_id",
                            "lead_org",
                            "lead_org_id")
  
  search_results[[i]] <- tidy_table
}

# Combine search results
results_df <- purrr::map_df(search_results, data.frame)

# Write extract
write.csv(results_df, file = paste0(datadir, "/projects_gtr.csv"), row.names = FALSE)
