# Mapping climate, environment and sustainability research
# Variables: impacts, outcomes 
# Aggregation and visualization of data

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, dplyr, readxl)

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data")
outdir <- paste0(root, "/outputs")
dir.create(datadir, F, T)
dir.create(outdir, F, T)

# Reading projects from UKRI
projects_gtr <- read_csv(paste0(datadir, "/projectsearch-1657097606835.csv"))

projects_gtr <- projects_gtr %>%
  filter(LeadROId == "2DB7ED73-8E89-457A-A395-FAC12F929C1A",
         ProjectCategory != "Studentship")


# Clean up school, unit names
ukri_projects <- projects_gtr %>% 
  mutate(School = ifelse(Department %in% c("Sch of Geosciences", "School of Geosciences"), "School of Geosciences", 
                         ifelse(Department %in% c("Royal (Dick) School of Veterinary Scienc", "The Roslin Institute", "Roslin Institute", "Veterinary Clinical Studies", "Genetics and Genomics"), "Royal (Dick) School of Veterinary Science", 
                                ifelse(Department %in% c("Business School"), "Business School", 
                                       ifelse(Department %in% c("Edinburgh College of Art"), "Edinburgh College of Art", 
                                              ifelse(Department %in% c("Edinburgh College of Art"), "Edinburgh College of Art", 
                                                     ifelse(Department %in% c("MRC Centre for Inflammation Research", "Centre for Inflammation Research", "MRC Centre for Regenerative Medicine", "MRC Centre for Reproductive Health"), "Institute for Regeneration and Repair", 
                                                            ifelse(Department %in% c("MRC Human Genetics Unit", "Centre for Molecular Medicine", "Ctr for Genomic & Experimental Medincine", "Edinburgh Cancer Research Centre"), "Institute of Genetics and Cancer", 
                                                                   ifelse(Department %in% c("Sch of Molecular. Genetics & Pop Health","Sch of Biomedical Sciences","Centre for Discovery Brain Sciences","School of Clinical Sciences","Centre of Population Health Sciences","Centre for Integrative Physiology","Centre for Clinical Brain Sciences","Biomedical Sciences"), "Medical School", 
                                                                          ifelse(Department %in% c("Moray House School of Education"), "Moray House School of Education and Sport", 
                                                                                 ifelse(Department %in% c("Sch of Biological Sciences", "Inst for Molecular Plant Science"), "School of Biological Sciences", 
                                                                                        ifelse(Department %in% c("Sch of Divinity"), "School of Divinity", 
                                                                                               ifelse(Department %in% c("Sch of Economics"), "School of Economics", 
                                                                                                      ifelse(Department %in% c("Sch of Engineering"), "School of Engineering", 
                                                                                                             ifelse(Department %in% c("Sch of Health in Social Science"), "School of Health in Social Science", 
                                                                                                                    ifelse(Department %in% c("Sch of Health in Social Science", "History"), "School of History, Classics and Archaeology", 
                                                                                                                           ifelse(Department %in% c("Sch of Informatics", "Centre for Speech Technology Research"), "School of Informatics", 
                                                                                                                                  ifelse(Department %in% c("Sch of Law"), "School of Law", 
                                                                                                                                         ifelse(Department %in% c("Sch of Literature Languages & Culture", "Div of European Languages and Cultures"), "School of Literatures, Languages & Culture", 
                                                                                                                                                ifelse(Department %in% c("Sch of Mathematics"), "School of Mathematics", 
                                                                                                                                                       ifelse(Department %in% c("Sch of Physics and Astronomy"), "School of Physics and Astronomy", 
                                                                                                                                                              ifelse(Department %in% c("Sch of Social and Political Science", "Science  Technology & Innovation Studies"), "School of Social and Political Science", 
                                                                                                                                                                     ifelse(Department %in% c("Sch of Chemistry"), "School of Chemistry", "Other")))))))))))))))))))))))



# Clean up college names
ukri_projects <- ukri_projects %>% 
  mutate(College = ifelse(Department %in% c("Sch of Geosciences", "School of Geosciences"), "College of Science and Engineering", 
                          ifelse(Department %in% c("Royal (Dick) School of Veterinary Scienc", "The Roslin Institute", "Roslin Institute", "Veterinary Clinical Studies", "Genetics and Genomics"), "College of Medicine & Veterinary Medicine", 
                                 ifelse(Department %in% c("Business School"), "College of Arts, Humanities & Social Sciences", 
                                        ifelse(Department %in% c("Edinburgh College of Art"), "College of Arts, Humanities & Social Sciences", 
                                               ifelse(Department %in% c("MRC Centre for Inflammation Research", "Centre for Inflammation Research", "MRC Centre for Regenerative Medicine", "MRC Centre for Reproductive Health"), "College of Medicine & Veterinary Medicine", 
                                                      ifelse(Department %in% c("MRC Human Genetics Unit", "Centre for Molecular Medicine", "Ctr for Genomic & Experimental Medincine", "Edinburgh Cancer Research Centre"), "College of Medicine & Veterinary Medicine", 
                                                             ifelse(Department %in% c("Sch of Molecular. Genetics & Pop Health","Sch of Biomedical Sciences","Centre for Discovery Brain Sciences","School of Clinical Sciences","Centre of Population Health Sciences","Centre for Integrative Physiology","Centre for Clinical Brain Sciences","Biomedical Sciences"), "College of Medicine & Veterinary Medicine", 
                                                                    ifelse(Department %in% c("Moray House School of Education"), "College of Arts, Humanities & Social Sciences", 
                                                                           ifelse(Department %in% c("Sch of Biological Sciences", "Inst for Molecular Plant Science"), "College of Science and Engineering", 
                                                                                  ifelse(Department %in% c("Sch of Divinity"), "College of Arts, Humanities & Social Sciences", 
                                                                                         ifelse(Department %in% c("Sch of Economics"), "College of Arts, Humanities & Social Sciences", 
                                                                                                ifelse(Department %in% c("Sch of Engineering"), "College of Science and Engineering", 
                                                                                                       ifelse(Department %in% c("Sch of Health in Social Science"), "College of Arts, Humanities & Social Sciences", 
                                                                                                              ifelse(Department %in% c("Sch of Health in Social Science", "History"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                     ifelse(Department %in% c("Sch of Informatics", "Centre for Speech Technology Research"), "College of Science and Engineering", 
                                                                                                                            ifelse(Department %in% c("Sch of Law"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                                   ifelse(Department %in% c("Sch of Literature Languages & Culture", "Div of European Languages and Cultures"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                                          ifelse(Department %in% c("Sch of Mathematics"), "College of Science and Engineering", 
                                                                                                                                                 ifelse(Department %in% c("Sch of Physics and Astronomy"), "College of Science and Engineering", 
                                                                                                                                                        ifelse(Department %in% c("Sch of Social and Political Science", "Science  Technology & Innovation Studies"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                                                               ifelse(Department %in% c("Sch of Chemistry"), "College of Science and Engineering", "Other"))))))))))))))))))))))




# Write extract
write.csv(ukri_projects, file = paste0(outdir, "/ukri_projects.csv"), row.names = FALSE)