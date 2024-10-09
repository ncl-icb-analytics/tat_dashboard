
# Load necessary libraries
library(renv)
library(tidyverse)
library(lubridate)
library(stringr)
library(janitor)
library(odbc)
library(DBI)



# Function to load and process provider data
load_provider_data <- function(input_dir) {
  # List all files in the input directory recursively
  all_files <- list.files(input_dir, recursive = TRUE, full.names = TRUE, pattern = "*.csv")
  
  # Extract metadata from filenames (submission date, provider code, month-year, data type)
  provider_data <- tibble(file_path = all_files) %>%
    mutate(
      file_name = basename(file_path),
      submission_date = str_extract(file_name, "^\\d{8}"),
      submission_date = ymd(submission_date),
      month_year = str_extract(file_name, "[A-Za-z]{3}\\d{2}"),
      data_type = ifelse(str_detect(file_name, "Freeze"), "Freeze", "Flex")
    )
  
  return(provider_data)
}




# Function to clean individual CSVs and normalize column names
process_provider_files <- function(provider_files) {
  processed_data <- provider_files %>%
    # Read CSVs into R
    rowwise() %>%
    mutate(data = list(read_csv(file_path) %>%
                         # Normalize column names: make them lowercase and replace spaces with underscores
                         janitor::clean_names(case = "snake"))) %>%
    unnest(data) %>%
    # Extract month and year
    mutate(
      month = str_sub(month_year, 1, 3),
      year = paste0("20", str_sub(month_year, 4, 5)),
      submission_month = month(submission_date),
      submission_year = year(submission_date)
    ) %>%
    # Reorder and add necessary columns
    select(submission_date, data_type, month, year, everything()) %>%
    ungroup()
  
  return(processed_data)
}