# Pulling data from UKRI portal
# https://gtr.ukri.org/resources/classificationlists.html

gc(reset = T); rm(list = ls()) 
library(RCurl)
# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data"); dir.create(datadir, F, T)

# Keywords to look out for
keywords = readLines(paste0(datadir, "/keywords_file.txt"))

# Search criteria
search_criteria <- gsub("\"","%22", gsub(" ", "+", keywords))

# Function for querying UKRI site
dl_ukri <- function(query,
                    destfile = paste0(query, ".csv"),
                    size = 25L,
                    quiet_download = FALSE) {
  url <- paste0("https://gtr.ukri.org/search/project/csv?term=",
                urltools::url_encode(query),
                "&selectedFacets=&fields=acp.d,is.t,prod.t,pol.oid,acp.oid,rtp.t,pol.in,prod.i,per.pro.abs,acp.i,col.org,acp.t,is.d,is.oid,cpro.rtpc,prod.d,stp.oid,rtp.i,rdm.oid,rtp.d,col.dept,ff.d,ff.c,col.pc,pub.t,kf.d,dis.t,col.oid,pro.t,per.sn,org.orcidId,per.on,ff.dept,rdm.t,org.n,dis.d,prod.oid,so.cn,dis.i,pro.a,pub.orcidId,pol.gt,rdm.i,rdm.d,so.oid,per.fnsn,per.org.n,per.pro.t,pro.orcidId,pub.a,col.d,per.orcidId,col.c,ip.i,pro.gr,pol.i,so.t,per.fn,col.i,ip.t,ff.oid,stp.i,so.i,cpro.rcpgm,cpro.hlt,col.pic,so.d,ff.t,ip.d,dis.oid,ip.oid,stp.d,rtp.oid,ff.org,kf.oid,stp.t&type=&selectedSortableField=score&selectedSortOrder=DESC"
                )
  curl::curl_download(url, destfile, quiet = quiet_download)
  
}

# Download data
dl_ukri(keywords, destfile = paste0(datadir, "/", "UKRI_projects.csv"))