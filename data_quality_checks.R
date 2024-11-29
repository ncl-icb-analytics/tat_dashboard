library(daiquiri)

start_time = Sys.time()

fts <- field_types(
  diagnostic_test_date_time = ft_timepoint(includes_time = TRUE), # , format = "%Y-%m-%d"
  service_report_issue_date_time = ft_datetime(includes_time = TRUE),
  patient_source_type = ft_numeric(na = NULL),
  priority_type_code = ft_numeric(na = NULL),
  imaging_code_nicip = ft_freetext(na = NULL),
  imaging_code_snomed = ft_freetext(na = NULL),
  provider_site_code = ft_categorical(aggregate_by_each_category = TRUE),
  trust_code = ft_categorical(aggregate_by_each_category = TRUE),
  TAT_scan = ft_numeric(na = NULL),
  TAT_report = ft_numeric(na = NULL),
  TAT_overall = ft_numeric(na = NULL),
  data_type = ft_freetext(na = NULL),
  data_period = ft_datetime(includes_time = FALSE),
  month_year = ft_freetext(na = NULL),
  cancer_pathway_flag = ft_categorical(aggregate_by_each_category = FALSE)
)


# create a report in the output directory
daiq_obj <- daiquiri_report(
  combined_data_pared,
  field_types = fts,
  save_directory = "output/daiquiri",
  aggregation_timeunit = "month"  # day or month? day may get unwieldly in several years' time.
) # save this as an RDS

end_time = Sys.time()
end_time - start_time