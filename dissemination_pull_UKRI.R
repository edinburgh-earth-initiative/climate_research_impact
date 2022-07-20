# Pulling outcome data from UKRI portal

# library(devtools)
# devtools::install_github("MatthewSmith430/GtR")

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load("GtR", "dplyr")

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
url_page <- paste0("https://gtr.ukri.org/search/outcomes?term=", search_criteria, "&fetchSize=25&selectedSortableField=&selectedSortOrder=&fields=acp.d%2Cis.t%2Cprod.t%2Cpol.oid%2Cacp.oid%2Crtp.t%2Cpol.in%2Cprod.i%2Cper.pro.abs%2Cacp.i%2Ccol.org%2Cacp.t%2Cis.d%2Cis.oid%2Ccpro.rtpc%2Cprod.d%2Cstp.oid%2Crtp.i%2Crdm.oid%2Crtp.d%2Ccol.dept%2Cff.d%2Cff.c%2Ccol.pc%2Cpub.t%2Ckf.d%2Cdis.t%2Ccol.oid%2Cpro.t%2Cper.sn%2Corg.orcidId%2Cper.on%2Cff.dept%2Crdm.t%2Corg.n%2Cdis.d%2Cprod.oid%2Cso.cn%2Cdis.i%2Cpro.a%2Cpub.orcidId%2Cpol.gt%2Crdm.i%2Crdm.d%2Cso.oid%2Cper.fnsn%2Cper.org.n%2Cper.pro.t%2Cpro.orcidId%2Cpub.a%2Ccol.d%2Cper.orcidId%2Ccol.c%2Cip.i%2Cpro.gr%2Cpol.i%2Cso.t%2Cper.fn%2Ccol.i%2Cip.t%2Cff.oid%2Cstp.i%2Cso.i%2Ccpro.rcpgm%2Ccpro.hlt%2Ccol.pic%2Cso.d%2Cff.t%2Cip.d%2Cdis.oid%2Cip.oid%2Cstp.d%2Crtp.oid%2Cff.org%2Ckf.oid%2Cstp.t2")
search_test <- httr::GET(url_page)
pages <- search_test$headers$`link-pages`

# Store dataframes
search_results <- list()

# Columns to retain in final dataframe
key_columns <- c("outcomeType.title",
                 "outcomeType.projectId",
                 "outcomeType.typeDisplayString",
                 "outcomeType.additionalDetails",
                 "outcomeType.grantRefNumber",
                 "outcomeType.id",
                 "outcomeType.url")

# Loop through lists
for (i in 1:pages){
  gtr_url <- paste0("https://gtr.ukri.org/search/outcomes?term=", search_criteria, "&fetchSize=100&selectedSortableField=&selectedSortOrder=&fields=acp.d%2Cis.t%2Cprod.t%2Cpol.oid%2Cacp.oid%2Crtp.t%2Cpol.in%2Cprod.i%2Cper.pro.abs%2Cacp.i%2Ccol.org%2Cacp.t%2Cis.d%2Cis.oid%2Ccpro.rtpc%2Cprod.d%2Cstp.oid%2Crtp.i%2Crdm.oid%2Crtp.d%2Ccol.dept%2Cff.d%2Cff.c%2Ccol.pc%2Cpub.t%2Ckf.d%2Cdis.t%2Ccol.oid%2Cpro.t%2Cper.sn%2Corg.orcidId%2Cper.on%2Cff.dept%2Crdm.t%2Corg.n%2Cdis.d%2Cprod.oid%2Cso.cn%2Cdis.i%2Cpro.a%2Cpub.orcidId%2Cpol.gt%2Crdm.i%2Crdm.d%2Cso.oid%2Cper.fnsn%2Cper.org.n%2Cper.pro.t%2Cpro.orcidId%2Cpub.a%2Ccol.d%2Cper.orcidId%2Ccol.c%2Cip.i%2Cpro.gr%2Cpol.i%2Cso.t%2Cper.fn%2Ccol.i%2Cip.t%2Cff.oid%2Cstp.i%2Cso.i%2Ccpro.rcpgm%2Ccpro.hlt%2Ccol.pic%2Cso.d%2Cff.t%2Cip.d%2Cdis.oid%2Cip.oid%2Cstp.d%2Crtp.oid%2Cff.org%2Ckf.oid%2Cstp.t2")
  page_response <- httr::GET(gtr_url)
  page_text <- httr::content(page_response, as="text")
  page_results <- jsonlite::fromJSON(page_text, flatten=TRUE)
  page_table <- page_results$searchResult$results
  tidy_table <- dplyr::select(page_table, tidyselect::all_of(key_columns))
  colnames(tidy_table) <- c("project_title", 
                            "project_id",
                            "outcome_type",
                            "outcome_additional_details",
                            "outcome_grant_ref_number",
                            "outcome_type_id",
                            "outcome_type_url")
  
  search_results[[i]] <- tidy_table
}

# Combine search results
results_df <- purrr::map_df(search_results, data.frame)

# Write extract
write.csv(results_df, file = paste0(outdir, "/dissemination_gtr.csv"), row.names = FALSE)
