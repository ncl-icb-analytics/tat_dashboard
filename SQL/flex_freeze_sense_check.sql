SELECT
dd.CalendarMonthName
,dd.CalendarMonthNumber
,r.data_type
,COUNT(*)
FROM [Data_Lab_NCL_Dev].[PeterS].[turnaround_times_rolltest] r
LEFT JOIN [Dictionary].[dbo].[Dates] dd ON CAST(diagnostic_test_date_time as date) = dd.FullDate
GROUP BY
dd.CalendarMonthName
,dd.CalendarMonthNumber
,r.data_type
ORDER BY 
CalendarMonthNumber

SELECT
dd.CalendarMonthName
,dd.CalendarMonthNumber
,r.DataType
,COUNT(*) 'RowCount'
FROM [Data_Lab_NCL_Dev].[PeterS].[turnaround_times] r
LEFT JOIN [Dictionary].[dbo].[Dates] dd ON CAST(DiagnosticTestDateTime as date) = dd.FullDate
GROUP BY
dd.CalendarMonthName
,dd.CalendarMonthNumber
,r.DataType
ORDER BY 
CalendarMonthNumber