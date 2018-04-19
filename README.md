# customer_cohort_retention
Instrcution to Run cohortretention R script -

1) Set up Bigquery API on Google Cloud Platform.
2) Create dataset and table in Bigquery with the link given below:
   https://storage.googleapis.com/perpule-1248.appspot.com/jugnoo.csv 
3) Open perpule.R file in RStudio.
4) Change the Project ID in the file with your Bigquery Project ID.
5) Change the table name accodingly in the query. My table name is `my-project-1503433822077.perpule.jugnoo` .
6) Save the file.
7) Run the perpule.R script file using source("perpule.R") command.
8) The system will ask for the interval of Cohort Retention, enter Week, Month or Quarter. 
9) Click allow when it will ask for your permission to set up authentication.
10) It will automatically save the Cohort Retention in your currently working directory.
11) It will also display Heatmap for your Customer Cohort Retention.

You can also check the sqlQuery file and directly run the query on Bigquery. 
