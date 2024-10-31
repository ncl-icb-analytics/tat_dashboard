-- image code lookup
SELECT distinct
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
AND ISNULL([Active?],'Yes') = 'Yes'

SELECT
*
FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_modality]

SELECT
*
FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_patient_source_setting]

SELECT
*
FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_priority_type]

SELECT
*
FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_targets]

SELECT
*
FROM [Data_Lab_NCL_Dev].[PeterS].[tat_lookup_trusts]

SELECT
Organisation_Code
,LEFT(Organisation_Code,3) 'Organisation_Trust_Code'
,Organisation_Name
,SK_OrganisationTypeID
FROM [Dictionary].[dbo].[Organisation]
where 
SK_OrganisationTypeID IN (41,42)

