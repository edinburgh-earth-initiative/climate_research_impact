# Pulling data from UKRI portal
# https://gtr.ukri.org/resources/classificationlists.html

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

# Search criteria
search_criteria <- gsub(" ", "+", keywords)
search_criteria <- gsub("\"","%22", search_criteria)
url_page <- paste0("http://gtr.ukri.org/search/project?term=", search_criteria, "&page=1&fetchSize=100")
search_test <- httr::GET(url_page)
pages <- search_test$headers$`link-pages`

# Store dataframes
search_results <- list()

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
