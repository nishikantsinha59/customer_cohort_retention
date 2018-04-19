# Set your project ID here
project <- "my-project-1503433822077" # replace this with your project ID here

# Set the working directory
#setwd('F://Data Science//perpule_assignment')

# Load required packages
#install.packages("bigrquery")
#install.packages('devtools')
#devtools::install_github("rstats-db/bigrquery")
#install.packages("formatR")
#Load SystematicInvestor's plot.table (https://github.com/systematicinvestor/SIT)
con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

library(stringr)    # For string operation
library(forcats)  
library(bigrquery)  # For connecting and running SQL query from Bigquery
library(devtools)   # Required for using.table()
library(reshape2)


# Input the type of retention report you like monthly, weekly
print("*************Customer Cohort Retention*************")
print("Enter the type of cohort retention report you want to view")

# Read user input
input = as.character(readline(prompt="Sample Input[week/2weeks/month/2months/quarter/2quarter/etc] : "))

# Split integer and string
digit <- (str_extract(input, "[0-9]+"))
digit <- as.integer((ifelse(is.na(digit), 1, digit)))
word <- toupper(str_extract(input, "[aA-zZ]+"))


# Define array for storing the type of report  
month <- c("MONTH","MONTHS")
week <- c("WEEK","WEEKS")
quarter <- c("QUARTER","QUARTERS")

# Deciding parameters based on user input   
if(any(month==word)) { 
  mul <-floor(12/digit)
  duration <- "MONTH" 
} else if(any(week==word)) {
  mul <- floor(52/digit)  
  duration <- "WEEK"
} else if(any(quarter==word)) {
  mul <- floor(4/digit)
  duration <- "QUARTER" 
} else {
  stop("Invalid input!!!!!!!", call. = FALSE)
}

# Build SQL query
varSQL <- sprintf("WITH visit_log AS
                  (
                  SELECT
                  customerId,
                  orderId,
                  FORMAT_TIMESTAMP('%%F', orderProcessingTime) AS firstOrderProcessingTime,
                  (visitYear-2017)*(%s)+visitTime AS calcTime,
                  ROW_NUMBER() OVER (PARTITION BY customerId ORDER BY orderProcessingTime) AS visitNumber
                  FROM (
                  SELECT
                  customerId,
                  orderId,
                  orderProcessingTime,
                  if(MOD(visitTime,%s)=0,visitTime/%s, (CEILING(visitTime/%s))) AS visitTime, 
                  EXTRACT(YEAR FROM orderProcessingTime) AS visitYear
                  FROM (SELECT 
                  customerId,
                  orderId,
                  orderProcessingTime,
                  EXTRACT(MONTH FROM orderProcessingTime) visitTime
                  FROM `my-project-1503433822077.perpule.jugnoo` 
                  GROUP BY 1,2,3
                  )
                  )
                  ),
                  first_visit AS
                  (
                  SELECT 
                  customerId,
                  min(calcTime) AS firstVisit,
                  min(firstOrderProcessingTime) AS firstOrderProcessingTime
                  FROM visit_log
                  GROUP BY 1
                  ),
                  new_user AS
                  (
                  SELECT firstVisit,
                  MIN(firstOrderProcessingTime) AS firstOrderProcessingTime,
                  COUNT(DISTINCT customerId) AS newUsers
                  FROM first_visit
                  GROUP BY 1
                  ),
                  tracker AS
                  (
                  SELECT 
                  visit_tracker.customerId,
                  (visit_tracker.calcTime - visit_log.calcTime) AS retentionDuration
                  FROM visit_log
                  LEFT JOIN visit_log AS visit_tracker
                  ON visit_log.customerId = visit_tracker.customerId
                  AND visit_log.calcTime < visit_tracker.calcTime
                  GROUP BY 1,2
                  )
                  SELECT 	
                  firstOrderProcessingTime,
                  firstVisit, 
                  newUsers, 
                  retentionDuration, 
                  retained, 
                  (ROUND(retention*100,0)) AS retentionPercent 
                  FROM (SELECT 
                  new_user.firstOrderProcessingTime,
                  first_visit.firstVisit, 
                  new_user.newUsers, 
                  retentionDuration, 
                  COUNT(DISTINCT tracker.customerId) AS retained, 
                  COUNT(DISTINCT tracker.customerId) / newUsers AS retention
                  FROM first_visit 
                  LEFT JOIN new_user 
                  ON new_user.firstVisit = first_visit.firstVisit
                  LEFT JOIN tracker
                  ON tracker.customerId = first_visit.customerId
                  WHERE tracker.retentionDuration != 0      
                  GROUP BY 1,2,3,4
                  )
                  ORDER BY 1,2,4"
                  ,mul
                  ,digit
                  ,digit
                  ,digit
                  ,duration
)


# Execute the query and store the result
retention_table <- query_exec(varSQL, project = project, use_legacy_sql = FALSE)

# find max of retention duration
maximum <- max(retention_table$retentionDuration)

# Append % sign
plotData <- retention_table
plotData$retentionPercent <- paste(retention_table$retentionPercent, "%")

# cast data in to appropriate form so it can be plotted
plotData <- dcast(plotData, firstOrderProcessingTime + newUsers ~ retentionDuration, value.var = "retentionPercent")
# Then convert dataframe to matrix
plotData <- as.matrix(plotData)

# Change the column name from newUsers to New Users 
colnames(plotData)[colnames(plotData) == "newUsers"] <- "New Users"

# Print retention table
print(plotData)

# Write CSV in R
write.csv(plotData, file = "cohortRetention.csv",row.names=FALSE, na="")

# Plot the heatmap using plot.table
plot.table(plotData, smain='First Visit', highlight = TRUE, colorbar = FALSE)

# Specify Retention Interval
interval <- paste("INTERVAL -> ",digit,word)
mtext(interval, side=3, cex = 0.7)
