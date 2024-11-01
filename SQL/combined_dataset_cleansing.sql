SELECT
--d.provider_site_code
--,
diagnostic_test_date_time 'DiagnosticTestDateTime'
--,diagnostic_test_request_date_and_time
--,service_report_issue_date_and_time
--,patient_source_setting
,pss.[Patient Source Setting] 'PatientSourceTypeName'
,m.Modality
--,ISNULL(imaging_code_nicip,imaging_code_snomed) 'imaging_code'
--,site_code_of_imaging
--,st.Organisation_Name 'SiteName'
,CASE 
	 WHEN d.provider_site_code = 'RALC7' THEN 'RFL - Chase Farm Hospital'
	 WHEN d.provider_site_code = 'RAL01' THEN 'RFL - Royal Free Hospital'
	 WHEN d.provider_site_code = 'RALRA' THEN 'RFL - Edgware Community Hospital'
	 WHEN d.provider_site_code = 'RAL26' THEN 'RFL - Barnet Hospital'
	 WHEN d.provider_site_code = 'RALWH' THEN 'RFL - Whittington Hospital'
	 WHEN d.provider_site_code = 'F0U9Q' THEN 'RFL - Finchley Memorial Hospital CDC'
	 WHEN LEFT(d.provider_site_code,3) = 'RAL' THEN 'RFL - Others'
	 ELSE st.Organisation_Name
	 END AS 'SiteName'
,CASE 
	WHEN d.provider_site_code = 'F0U9Q' THEN 'Royal Free London NHS Foundation Trust'
	WHEN d.provider_site_code = 'C4M4J' THEN 'University College London Hospitals NHS Foundation Trust'
	WHEN d.provider_site_code = 'P5B6O' THEN 'Whittington Health NHS Trust'
	ELSE prv.Organisation_Name 
	END AS 'ProviderTrust'
--,priority_type_code
,pt.[Description] 'PriorityTypeCode'
,CASE WHEN priority_type_code = 3 THEN 1 WHEN priority_type_code IN (1,2) THEN 0 ELSE NULL END AS 'CancerPathwayFlag'
--,data_type
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_scan > IIF(7*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_scan > t.[NCL Scan Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachScan'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_scan > IIF(5*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_scan > t.[NCL Scan Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachScan7Day'
,d.TAT_Scan 'TATScan'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_scan > IIF(3*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_Report > t.[NCL Report Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachReportNCL'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_scan > IIF(2*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_Report > t.[NCL Report Target (hours)]
	THEN 1
	ELSE 0 END AS  'BreachReportNCLCancer7Day'
,CASE 
	WHEN t.[NCL Report Target (hours)] > 4*7*24 
	THEN 1 
	ELSE 0 
	END AS 'BreachReport4Week'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_scan > IIF(3*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_Report > t.[NHSE Report TAT Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachReportNHSE'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_scan > IIF(2*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_Report > t.[NHSE Report TAT Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachReportNHSECancer7Day'
,d.TAT_Report 'TATReport'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_overall > IIF(10*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN TAT_overall > t.[NCL Overall TAT Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachOverall'
,CASE 
	WHEN priority_type_code = 3 AND d.TAT_overall > IIF(7*24 <  t.[NCL Scan Target (hours)], 7*24,  t.[NCL Scan Target (hours)])
	THEN 1
	WHEN d.TAT_overall > t.[NCL Overall TAT Target (hours)]
	THEN 1
	ELSE 0 END AS 'BreachOverallCancer7Day'
,d.TAT_Overall 'TATOverall'
--,t.[NCL Scan Target (hours)]
--,t.[NCL Report Target (hours)]
--,t.[NCL Overall TAT Target (hours)]
--,t.[NHSE Report TAT Target (hours)]
,CASE WHEN d.service_report_issue_date_time IS NULL AND data_type = 'Flex' THEN 1 ELSE 0 END AS 'TestAwaitingReport'
,CASE WHEN d.service_report_issue_date_time IS NULL AND data_type = 'Freeze' THEN 1 ELSE 0 END AS 'TestUnreported'
FROM Data_Lab_NCL_Dev.PeterS.turnaround_times_rolltest d
LEFT JOIN [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_patient_source_setting] pss ON d.patient_source_type = pss.Code
LEFT JOIN (SELECT distinct -- join on cleansed modality lookups
			[NICIP short code] 'Code'
			,Modality
			FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_image_code]
			WHERE [NICIP short code] IS NOT NULL
			AND ISNULL([Active?],'Yes') = 'Yes'

			UNION ALL

			SELECT distinct
			[SNOMED-CT code] 'Code'
			,Modality
			FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_image_code]
			WHERE [SNOMED-CT code] IS NOT NULL
			AND ISNULL([Active?],'Yes') = 'Yes') mi
			ON ISNULL(imaging_code_nicip,imaging_code_snomed) = mi.Code
LEFT JOIN [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_targets] t ON ISNULL(d.priority_type_code,1) = t.[Priority Type] -- If priority is blank when looking up target, apply "Routine" targets
	AND d.patient_source_type = t.[Patient Source Setting]
	AND mi.Modality = t.[Imaging service (split)]
LEFT JOIN [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_modality] m ON mi.Modality = m.[Modality (intermediate) (derived from NICIP/SNOMED)]
LEFT JOIN [Dictionary].[dbo].[Organisation] st ON d.provider_site_code = st.Organisation_Code
LEFT JOIN [Dictionary].[dbo].[Organisation] prv ON LEFT(d.provider_site_code,3) = prv.Organisation_Code
LEFT JOIN [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_priority_type] pt ON d.priority_type_code = pt.Code