# Free-hand play for testing bits of the function out of the map_dfr() loop

file_path <- r"{C:\Users\PeterShakeshaft\OneDrive - NHS\Turnaround Times\Provider Submissions\RNOH\20250225_DIDNCL_RAN_Feb25.csv}"


raw_data_RNOH <-  read_csv(file_path,na = c("NULL","",NULL,"1900-01-00 00:00","1900-01-00 00:00:00"), show_col_types = FALSE)
  
processed_data_RNOH <- read_csv(file_path,na = c("NULL","",NULL,"1900-01-00 00:00","1900-01-00 00:00:00"), show_col_types = FALSE) %>%  # NAs and column types
  
  # clean names
  janitor::clean_names(case = "snake") %>%
  
  # remove entirely blank rows
  filter(!if_all(everything(), ~ is.na(.x))) %>%
  # remove rows with no test date
  drop_na(diagnostic_test_date_time) %>%
  # remove rows with no referral date
  drop_na(diagnostic_test_request_date_time) %>%
  
  # data transformations
  mutate(
    # metadata
    file_name = basename(file_path),
    submission_date = str_extract(file_name, "^\\d{8}"),
    submission_date = ymd(submission_date),
    month_year = str_extract(file_name, "[A-Za-z]{3}\\d{2}"),
    month = str_sub(month_year, 1, 3),
    year = paste0("20", str_sub(month_year, 4, 5)),
    submission_month = month(submission_date),
    submission_year = year(submission_date),
    data_period = as.Date(paste0("01",month_year), format = "%d%b%y"),
    trust_code = str_sub(file_name,17,19)
  ) %>%
  mutate(
    # data type cleansing
    diagnostic_test_request_date_time = as.POSIXct(diagnostic_test_request_date_time, format="%d/%m/%Y %H:%M"),
    diagnostic_test_request_received_date_time = as.POSIXct(diagnostic_test_request_received_date_time, format="%d/%m/%Y %H:%M"),
    diagnostic_test_date_time = as.POSIXct(diagnostic_test_date_time, format="%d/%m/%Y %H:%M"),
    service_report_issue_date_time = as.POSIXct(service_report_issue_date_time, format="%d/%m/%Y %H:%M"),
    patient_source_type = as.integer(patient_source_type),
    priority_type_code = as.integer(priority_type_code),
    imaging_code_snomed = as.character(imaging_code_snomed),
    combined_imaging_code = as.character(ifelse(is.na(imaging_code_nicip),imaging_code_snomed, imaging_code_nicip)),
    priority_type_code_routine_default = ifelse(is.na(priority_type_code), 1, priority_type_code), # set priority type code to one if don't have - used for target join
    # output fields
    TAT_scan = round(interval(diagnostic_test_request_date_time,diagnostic_test_date_time)/hours(1)),
    TAT_report = round(interval(diagnostic_test_date_time,service_report_issue_date_time)/hours(1)),
    TAT_overall = round(interval(diagnostic_test_request_date_time,service_report_issue_date_time)/hours(1)),
    datedifftest = round(interval(data_period,floor_date(diagnostic_test_date_time, 'month'))/months(1), digits = 0),
    data_type = case_when(basename(file_path) == "20241028_DIDNCL_RAN_Jul24.csv" ~ "Freeze",
                          datedifftest == -3 ~ "Freeze",
                          datedifftest %in% c(-1,-2) ~ "Flex",
                          .default = "Out of range"),
    cancer_pathway_flag_string = case_when(cancer_pathway_flag == TRUE ~ "Y",
                                           cancer_pathway_flag == FALSE ~ "N",
                                           .default = "Unclassified") # need to convert to character for "unclassified"s
    
  ) %>% 
  #filter out out-of-range dates
  #filter(data_type != "Out of range") %>% 
  # select
  select(submission_date, data_type, month, year, everything())