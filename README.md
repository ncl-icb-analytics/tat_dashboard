# TAT Dashboard Data Processing Pipeline

This pipeline is designed to automate the ingestion, cleaning, transformation, and uploading of data from various providers into a Sandpit Table. 
Providers submit data each month for the previous three months in two formats: flex (subject to revisions) and freeze (finalized data). 
The pipeline processes this data, replaces older flex data with freeze data, and handles the appropriate logic for new flex data in Sandpit.


# Pipeline Workflow
1.	Monthly Data Submission:
   
Each month, providers submit data for the last three months. One month's data is freeze data, while the other two are flex data.
Example for October 2024:
 - Freeze: July 2024 data.
 - Flex: August 2024 and September 2024 data.

2.	Ingestion and Processing:
   
Files are read from their respective provider folders. The folders have been added to the "data" folder to avoid issues with Sharepoint/OneDrive.
The file names contain metadata (submission date, provider code, month-year, and data type) that is extracted to add columns like submission_date, provider_code, month, year, and data_type to the data.
  	
4.	Data Upload:

Freeze data replaces old flex data for the same month.
Flex data is checked if it already exists in the SQL Server table:
 - If it exists, it's replaced.
 - If it doesn't exist, it's appended.

5.	SQL Server Upload:

Data is uploaded or updated in a Sandpit Table following the logic mentioned.

### Detailed information can be found in the supporting document stored in the "docs" folder. 

## To use this template, please use the following practises:

* Put any data files in the `data` folder.  This folder is explicitly named in the .gitignore file.  A further layer of security is that all xls, xlsx, csv and pdf files are also explicit ignored in the whole folder as well.  ___If you need to commit one of these files, you must use the `-f` (force) command in `commit`, but you must be sure there is no identifiable data.__
* Save any documentation in the `docs` file.  This does not mean you should avoid commenting your code, but if you have an operating procedure or supporting documents, add them to this folder.
* Please save all output: data, formatted tables, graphs etc. in the output folder.  This is also implicitly ignored by git, but you can use the `-f` (force) command in `commit` to add any you wish to publish to github.


### Please also consider the following:
* Linting your code.  This is a formatting process that follows a rule set.  We broadly encourage the tidyverse standard, and recommend the `lintr` package.
* Comment your code to make sure others can follow.
* Consider your naming conventions: we recommend `snake case` where spaces are replaced by underscores and no capitals are use. E.g. `outpatient_referral_data`


This repository is dual licensed under the [Open Government v3]([https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) & MIT. All code can outputs are subject to Crown Copyright.
