# Extra welcome data
library(readxl)
library(dplyr)
library(writexl)

# ERo download
ero_data<- read_excel(paste0("/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/Work/Projects/PhD/Earth_Initiative/eei_analysis/climate_research_impact/data/ERO_all_projects.xlsx"))

# Applications sinces 01/01/2022, wellcome trust
data <- ero_data %>% 
  mutate_at(vars(`Application Period Start`, `Application Period End`), as.Date, format="%y-%m-%d") %>% 
  filter(Status == "Pending",
         `Application Date` >= "2022-01-01",
         `Sponsor Name` == "wellcome trust")


write_xlsx(data, "/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/Work/Projects/PhD/Earth_Initiative/eei_analysis/climate_research_impact/outputs/wellcome_trust_applications.xlsx")
