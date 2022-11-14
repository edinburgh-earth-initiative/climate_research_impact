# Mapping climate, environment and sustainability research
# Impacts and outcomes 

library(readr)
library(dplyr)

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data"); dir.create(datadir, F, T)
outdir <- paste0(root, "/outputs"); dir.create(outdir, F, T)

# Reading UKRI data
outcomes_files <- list.files(paste0(datadir, "/outcomes"), pattern ="*.csv", full.names = TRUE)

projects_ukri <- read_csv(paste0(outdir, "/ukri_projects.csv"))

# Combine all CSVs
outcomes_data <- lapply(outcomes_files, read_csv) %>% 
  bind_rows()

# Filter by Edinburgh Uni and bring in projects titles from main dataset
outcomes <- outcomes_data %>% 
  filter(LeadROId == "2DB7ED73-8E89-457A-A395-FAC12F929C1A") %>% 
  rename(ProjectReference = `Project Reference`) %>% 
  # inner_join(projects_ukri, by = "ProjectReference") %>% 
  inner_join(projects_ukri, "ProjectId") %>% 
  filter(College != "Other")


# Clean up school, unit names
ukri_outcomes <- outcomes %>% 
  mutate(School = ifelse(Department.x %in% c("Sch of Geosciences", "School of Geosciences"), "School of Geosciences", 
                         ifelse(Department.x %in% c("Royal (Dick) School of Veterinary Scienc", "The Roslin Institute", "Roslin Institute", "Veterinary Clinical Studies", "Genetics and Genomics"), "Royal (Dick) School of Veterinary Science", 
                                ifelse(Department.x %in% c("Business School"), "Business School", 
                                       ifelse(Department.x %in% c("Edinburgh College of Art"), "Edinburgh College of Art", 
                                              ifelse(Department.x %in% c("Edinburgh College of Art"), "Edinburgh College of Art", 
                                                     ifelse(Department.x %in% c("MRC Centre for Inflammation Research", "Centre for Inflammation Research", "MRC Centre for Regenerative Medicine", "MRC Centre for Reproductive Health"), "Institute for Regeneration and Repair", 
                                                            ifelse(Department.x %in% c("MRC Human Genetics Unit", "Centre for Molecular Medicine", "Ctr for Genomic & Experimental Medincine", "Edinburgh Cancer Research Centre"), "Institute of Genetics and Cancer", 
                                                                   ifelse(Department.x %in% c("Sch of Molecular. Genetics & Pop Health","Sch of Biomedical Sciences","Centre for Discovery Brain Sciences","School of Clinical Sciences","Centre of Population Health Sciences","Centre for Integrative Physiology","Centre for Clinical Brain Sciences","Biomedical Sciences"), "Medical School", 
                                                                          ifelse(Department.x %in% c("Moray House School of Education"), "Moray House School of Education and Sport", 
                                                                                 ifelse(Department.x %in% c("Sch of Biological Sciences", "Inst for Molecular Plant Science"), "School of Biological Sciences", 
                                                                                        ifelse(Department.x %in% c("Sch of Divinity"), "School of Divinity", 
                                                                                               ifelse(Department.x %in% c("Sch of Economics"), "School of Economics", 
                                                                                                      ifelse(Department.x %in% c("Sch of Engineering"), "School of Engineering", 
                                                                                                             ifelse(Department.x %in% c("Sch of Health in Social Science"), "School of Health in Social Science", 
                                                                                                                    ifelse(Department.x %in% c("Sch of Health in Social Science", "History"), "School of History, Classics and Archaeology", 
                                                                                                                           ifelse(Department.x %in% c("Sch of Informatics", "Centre for Speech Technology Research"), "School of Informatics", 
                                                                                                                                  ifelse(Department.x %in% c("Sch of Law"), "School of Law", 
                                                                                                                                         ifelse(Department.x %in% c("Sch of Literature Languages & Culture", "Div of European Languages and Cultures"), "School of Literatures, Languages & Culture", 
                                                                                                                                                ifelse(Department.x %in% c("Sch of Mathematics"), "School of Mathematics", 
                                                                                                                                                       ifelse(Department.x %in% c("Sch of Physics and Astronomy"), "School of Physics and Astronomy", 
                                                                                                                                                              ifelse(Department.x %in% c("Sch of Social and Political Science", "Science  Technology & Innovation Studies"), "School of Social and Political Science", 
                                                                                                                                                                     ifelse(Department.x %in% c("Sch of Chemistry"), "School of Chemistry", "Other")))))))))))))))))))))))



# Clean up college names
ukri_outcomes <- ukri_outcomes %>% 
  mutate(College = ifelse(Department.x %in% c("Sch of Geosciences", "School of Geosciences"), "College of Science and Engineering", 
                          ifelse(Department.x %in% c("Royal (Dick) School of Veterinary Scienc", "The Roslin Institute", "Roslin Institute", "Veterinary Clinical Studies", "Genetics and Genomics"), "College of Medicine & Veterinary Medicine", 
                                 ifelse(Department.x %in% c("Business School"), "College of Arts, Humanities & Social Sciences", 
                                        ifelse(Department.x %in% c("Edinburgh College of Art"), "College of Arts, Humanities & Social Sciences", 
                                               ifelse(Department.x %in% c("MRC Centre for Inflammation Research", "Centre for Inflammation Research", "MRC Centre for Regenerative Medicine", "MRC Centre for Reproductive Health"), "College of Medicine & Veterinary Medicine", 
                                                      ifelse(Department.x %in% c("MRC Human Genetics Unit", "Centre for Molecular Medicine", "Ctr for Genomic & Experimental Medincine", "Edinburgh Cancer Research Centre"), "College of Medicine & Veterinary Medicine", 
                                                             ifelse(Department.x %in% c("Sch of Molecular. Genetics & Pop Health","Sch of Biomedical Sciences","Centre for Discovery Brain Sciences","School of Clinical Sciences","Centre of Population Health Sciences","Centre for Integrative Physiology","Centre for Clinical Brain Sciences","Biomedical Sciences"), "College of Medicine & Veterinary Medicine", 
                                                                    ifelse(Department.x %in% c("Moray House School of Education"), "College of Arts, Humanities & Social Sciences", 
                                                                           ifelse(Department.x %in% c("Sch of Biological Sciences", "Inst for Molecular Plant Science"), "College of Science and Engineering", 
                                                                                  ifelse(Department.x %in% c("Sch of Divinity"), "College of Arts, Humanities & Social Sciences", 
                                                                                         ifelse(Department.x %in% c("Sch of Economics"), "College of Arts, Humanities & Social Sciences", 
                                                                                                ifelse(Department.x %in% c("Sch of Engineering"), "College of Science and Engineering", 
                                                                                                       ifelse(Department.x %in% c("Sch of Health in Social Science"), "College of Arts, Humanities & Social Sciences", 
                                                                                                              ifelse(Department.x %in% c("Sch of Health in Social Science", "History"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                     ifelse(Department.x %in% c("Sch of Informatics", "Centre for Speech Technology Research"), "College of Science and Engineering", 
                                                                                                                            ifelse(Department.x %in% c("Sch of Law"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                                   ifelse(Department.x %in% c("Sch of Literature Languages & Culture", "Div of European Languages and Cultures"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                                          ifelse(Department.x %in% c("Sch of Mathematics"), "College of Science and Engineering", 
                                                                                                                                                 ifelse(Department.x %in% c("Sch of Physics and Astronomy"), "College of Science and Engineering", 
                                                                                                                                                        ifelse(Department.x %in% c("Sch of Social and Political Science", "Science  Technology & Innovation Studies"), "College of Arts, Humanities & Social Sciences", 
                                                                                                                                                               ifelse(Department.x %in% c("Sch of Chemistry"), "College of Science and Engineering", "Other"))))))))))))))))))))))





# %>% 
#   select(-ends_with(".x"),-ends_with(".y"))

# %>% 
#   filter(`Year Produced` >= "2020")

# Geographic reach
outcomes_reach_colleges <- outcomes %>% 
  group_by(College, `Geographical Reach`) %>% 
  summarise(Number_outcomes = n()) %>% 
  filter(!is.na(`Geographical Reach`))

outcomes_reach_schools <- outcomes %>% 
  group_by(College, School, `Geographical Reach`) %>% 
  summarise(Number_outcomes = n()) %>% 
  filter(!is.na(`Geographical Reach`))
  
# Where
outcome_reach_geo <- outcomes %>% 
  group_by(College, School, Country) %>% 
  summarise(Number_outcomes = n())


# Write
write.csv(outcomes, file = paste0(outdir, "/ukri_outcomes.csv"), row.names = FALSE)
