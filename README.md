# Customer Cohort Retention
Nishikant Sinha - April 2018

This Customer Cohort Retention system is aimed to generate Cohort Retention Report for the selected time interval.

Prerequisites-
          
    a) R and RStudio
    b) Google Bigquery API
    c) Customer Dataset

This repository contains R script for genrating cohort retention report. This script takes interval as input and generate and save the retention report in your working directory. It also produces Heatmap based on generated report.

This repository has one more file which contains the SQL query for generating Cohort Retention. You can execute this query directly on Google Bigquery by changing few table name and parameters which is already given in the file. 

Instructions for runninng customer cohort retention system

      1) Set up Bigquery API on Google Cloud Platform.
      2) Create dataset with Bigquery and import your data by creating table in your dataset.
      3) Open cohortRetention.R script file in RStudio.
      4) Change the Project ID in this R script with your Bigquery Project ID.
      5) Change the table name accoding to your Bigquery table in the query. My table name is `my-project-xxxxxxxx.perpule.jugnoo` .
      6) Save the changes done iin R script.
      7) Run the cohortRetention.R script file using source("cohortRetention.R") command.
      8) The system will ask for the interval of Cohort Retention, then enter Week/2Weeks/Month/2Months/Quarter/etc.
      9) The system will check for valid input, if it is invalid then execution will be terminated else it will continue execution.
      10) Click allow when it will prompt you for your permission to set up authentication.
      11) It will automatically save the Cohort Retention in your currently working directory as .csv file.
      12) Finally one Heatmap will be displayed in RStudio for your Customer Cohort Retention.
      13) You can exit the  system any time by pressing "esc" key.
      
You can also checkout sample Cohort Retention Heatmap present in this repository for reference and better understanding.

If you notice any bugs or typos, or have any suggestions on making it better and efficient, please send me a direct message through any of the following

Email : nishikantsinha59@gmail.com

Kaggle: https://www.kaggle.com/nishikantsinha59

Kind regards,

Nishikant Sinha
