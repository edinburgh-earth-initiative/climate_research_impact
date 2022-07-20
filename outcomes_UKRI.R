# Mapping climate, environment and sustainability research
# Impacts and outcomes 

library(readr)
library(dplyr)

# Paths, directories
root <- getwd()
datadir <- paste0(root, "/data")
outdir <- paste0(root, "/outputs")
dir.create(datadir, F, T)
dir.create(outdir, F, T)

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
