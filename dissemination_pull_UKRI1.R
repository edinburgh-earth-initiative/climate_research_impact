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
outcome_types <- c("dissemination", 
                   "collaboration", 
                   "keyfindings", 
                   "impactsummary", 
                   "policyinfluence",
                   "furtherfunding",
                   "researchdatabaseandmodel",
                   "researchmaterial",
                   "artisticandcreativeproduct",
                   "softwareandtechnicalproduct",
                   "intellectualproperty",
                   "spinout",
                   "productintervention")

# Loop through outcomes and web pages
outcome_stats <- lapply(X = outcome_types, FUN = function(outcome){
  
  url_page <- paste0("https://gtr.ukri.org/search/outcomes?term=", search_criteria, "&page=1&fetchSize=25&fields=pro.gr,pro.t,pro.a,pro.orcidId,per.fn,per.on,per.sn,per.fnsn,per.orcidId,per.org.n,per.pro.t,per.pro.abs,pub.t,pub.a,pub.orcidId,org.n,org.orcidId,acp.t,acp.d,acp.i,acp.oid,kf.d,kf.oid,is.t,is.d,is.oid,col.i,col.d,col.c,col.dept,col.org,col.pc,col.pic,col.oid,ip.t,ip.d,ip.i,ip.oid,pol.i,pol.gt,pol.in,pol.oid,prod.t,prod.d,prod.i,prod.oid,rtp.t,rtp.d,rtp.i,rtp.oid,rdm.t,rdm.d,rdm.i,rdm.oid,stp.t,stp.d,stp.i,stp.oid,so.t,so.d,so.cn,so.i,so.oid,ff.t,ff.d,ff.c,ff.org,ff.dept,ff.oid,dis.t,dis.d,dis.i,dis.oid,cpro.rtpc,cpro.rcpgm,cpro.hlt&type=", outcome, "&selectedFacets=")
  
  search_test <- httr::GET(url_page)
  pages <- search_test$headers$`link-pages`
  
  # Columns to retain in final dataframe
  key_columns <- c("outcomeType.title",
                   "outcomeType.type",
                   "outcomeType.projectId",
                   "outcomeType.additionalDetails",
                   "outcomeType.grantRefNumber",
                   "outcomeType.id",
                   "outcomeType.url")
  
  page_stats <- lapply(X = 1:pages, FUN = function(i){
    
    gtr_url <- paste0("https://gtr.ukri.org/search/outcomes?term=", search_criteria, "&page=", i, "&fetchSize=25&fields=pro.gr,pro.t,pro.a,pro.orcidId,per.fn,per.on,per.sn,per.fnsn,per.orcidId,per.org.n,per.pro.t,per.pro.abs,pub.t,pub.a,pub.orcidId,org.n,org.orcidId,acp.t,acp.d,acp.i,acp.oid,kf.d,kf.oid,is.t,is.d,is.oid,col.i,col.d,col.c,col.dept,col.org,col.pc,col.pic,col.oid,ip.t,ip.d,ip.i,ip.oid,pol.i,pol.gt,pol.in,pol.oid,prod.t,prod.d,prod.i,prod.oid,rtp.t,rtp.d,rtp.i,rtp.oid,rdm.t,rdm.d,rdm.i,rdm.oid,stp.t,stp.d,stp.i,stp.oid,so.t,so.d,so.cn,so.i,so.oid,ff.t,ff.d,ff.c,ff.org,ff.dept,ff.oid,dis.t,dis.d,dis.i,dis.oid,cpro.rtpc,cpro.rcpgm,cpro.hlt&type=", outcome, "&selectedFacets=")
    
    page_response <- httr::GET(gtr_url)
    page_text <- httr::content(page_response, as="text")
    page_results <- jsonlite::fromJSON(page_text, flatten=TRUE)
    page_table <- page_results$searchResult$results
    tidy_table <- dplyr::select(page_table, tidyselect::all_of(key_columns))
    colnames(tidy_table) <- c("project_title", 
                              "outcome_type",
                              "project_id",
                              "outcome_additional_details",
                              "outcome_grant_ref_number",
                              "outcome_type_id",
                              "outcome_type_url")
    
    cat(paste("Extracted : ", outcome, " ", "page", i, "\n"))

  })
  
  page_stats <- do.call(rbind, page_stats)
  return(page_stats)
  
})

# Combine search results
outcome_stats <- do.call(rbind, outcome_stats)

# Write extract
write.csv(results_df, file = paste0(outdir, "/dissemination_gtr.csv"), row.names = FALSE)