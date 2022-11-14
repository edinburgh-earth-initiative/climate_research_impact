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
keywords = readLines(paste0(datadir, "/keywords_file.txt"))

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


#https://gtr.ukri.org/search/project?term=%22climate+change%22+OR+%22climate+crisis%22+OR+%22global+warming%22+OR+%22carbon+sink%22+OR+biodiversity+OR+conservation+OR+%22global+change%22+OR+%22ocean+acidification%22+OR+microplastic*+OR+pollution+OR+%22greenhouse+gas%22+OR+%22greenhouse+gases%22+OR+%22atmospheric+carbon+dioxide%22+OR+%22stratospheric+ozone%22+OR+%22ozone+depletion%22+OR+coral*+OR+reef*+OR+%22extreme+weather%22+OR+%22sea+level%22+OR+environmental+OR+%22water+quality%22+OR+%22air+quality%22+OR+anthropogenic+OR+%22blue+carbon%22+OR+deforestation+OR+%22circular+economy%22+OR+%22energy+transition%22+OR+%22fossil+fuel%22+OR+%22fossil+fuels%22+OR+renewable+OR+decarbonisation+OR+%22energy+storage%22+OR+%22food+security%22+OR+%22nutrition+security%22+OR+%22nature+based%22+OR+%22Paris+agreement%22+OR+%22eco%22+OR+%22waste%22+OR+%22recycling%22+OR+sustainable+OR+sustainability+OR+anthropocene+OR+%22climate+justice%22+OR+%22climate+action%22+OR+%22natural+hazard%22+OR+%22natural+hazards%22+OR+permafrost+OR+sequestration+OR+%22remote+sensing%22+OR+peatland*+OR+%22species+richness%22+OR+groundwater+OR+%22carbon+footprint%22+OR+IPCC+OR+UNFCCC+OR+methane+OR+%22ecosystem+services%22+OR+overfishing+OR+aquaculture+OR+%22clean+energy%22+OR+biogas+OR+afforestation+OR+%22storm+surge%22+OR+%22endangered+species%22+OR+%22carbon+pump%22+OR+%22carbon+cycle%22+OR+oceanography+OR+%22trophic+cascade%22+OR+%22primary+productivity%22+OR+%22growing+season%22+OR+%22crop+production%22+OR+%22carbon+balance%22+OR+%22urban+heat+island%22+OR+%22green+space%22+OR+eutrophication+OR+biochar+OR+%22radiation+balance%22+OR+upcycling+OR+%22climate+variability%22+OR+%22carbon+source%22+OR+biofuel+OR+%22environmental+justice%22+OR+%22wave+energy%22+OR+retrofit+OR+%22carbon+capture%22+OR+wildlife+OR+biodegradable+OR+%22climate+warming%22+OR+%22marine+energy%22+OR+%22crop+yield%22+OR+pollination+OR+%22zero+emission%22+OR+floodplain+OR+%22nutrient+deposit%22+OR+hydroponic+OR+%22flood+forecast%22+OR+NOx+OR+%22algal+bloom%22+OR+LCA+OR+%22ice+flow%22#csvConfirm


url <- "https://gtr.ukri.org/search/project?term=%22climate+change%22+OR+%22climate+crisis%22&fetchSize=25&selectedSortableField=&selectedSortOrder=&fields=pro.gr%2Cpro.t%2Cpro.a%2Cpro.orcidId%2Cper.fn%2Cper.on%2Cper.sn%2Cper.fnsn%2Cper.orcidId%2Cper.org.n%2Cper.pro.t%2Cper.pro.abs%2Cpub.t%2Cpub.a%2Cpub.orcidId%2Corg.n%2Corg.orcidId%2Cacp.t%2Cacp.d%2Cacp.i%2Cacp.oid%2Ckf.d%2Ckf.oid%2Cis.t%2Cis.d%2Cis.oid%2Ccol.i%2Ccol.d%2Ccol.c%2Ccol.dept%2Ccol.org%2Ccol.pc%2Ccol.pic%2Ccol.oid%2Cip.t%2Cip.d%2Cip.i%2Cip.oid%2Cpol.i%2Cpol.gt%2Cpol.in%2Cpol.oid%2Cprod.t%2Cprod.d%2Cprod.i%2Cprod.oid%2Crtp.t%2Crtp.d%2Crtp.i%2Crtp.oid%2Crdm.t%2Crdm.d%2Crdm.i%2Crdm.oid%2Cstp.t%2Cstp.d%2Cstp.i%2Cstp.oid%2Cso.t%2Cso.d%2Cso.cn%2Cso.i%2Cso.oid%2Cff.t%2Cff.d%2Cff.c%2Cff.org%2Cff.dept%2Cff.oid%2Cdis.t%2Cdis.d%2Cdis.i%2Cdis.oid%2Ccpro.rtpc%2Ccpro.rcpgm%2Ccpro.hlt&type=#/csvConfirm"


library(netstat)
library(RSelenium)
rD <- rsDriver(port= free_port(), browser = "chrome", chromever = "106.0.5249.21", check = TRUE, verbose = TRUE)
remote_driver <- rD[["client"]] 
remDr <- rD$client
remDr$navigate(url)

webElem <- remDr$findElement(using = "css", "content gtr-body d-flex flex-column ng-scope")
webElem$clickElement()

get_search_results <- xml2::read_html(remDr$getPageSource()[[1]])%>%
  rvest::html_nodes("content gtr-body d-flex flex-column ng-scope") %>%
  rvest::html_text() %>%
  dplyr::data_frame(get_search_results = .)

get_search_results


rD[["server"]]$stop()






# Loop through lists
for (i in 1:pages){
  gtr_url <- paste0("http://gtr.ukri.org/search/project?term=", search_criteria,"#csvConfirm")
  
  #download.file(gtr_url, paste0("/Users/s2255815/Downloads/test.csv"), mode = "wb")
  
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
