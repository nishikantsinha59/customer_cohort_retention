--Parameters--
@parameter1			-- Interval of cohort retention i.e. weekly, monthly or quarterly
					-- replace the parameter2 with MONTH, WEEK or QUARTER

@parameter2 		-- Multiplication factor for each type of interval
					-- replace the parameter2 with following given values 
					-- 12 for month
					-- 7 for week
					-- 4 for quarter

@parameter3			-- Number of week, month or quarter as interval
					-- replace the parameter3 with following given values 
					-- 1 for one (week or month or quarter)
					-- 2 for two (weeks or months or quarters)
					-- and so on.....

#standardSQL
--Build user activities details
WITH visit_log AS
(
SELECT
    customerId,
    orderId,
    FORMAT_TIMESTAMP('%F', orderProcessingTime) AS firstOrderProcessingTime,
    (visitYear-2017)*FLOOR(@parameter2/@parameter3)+visitTime AS calcTime,
    ROW_NUMBER() OVER (PARTITION BY customerId ORDER BY orderProcessingTime) AS visitNumber
FROM (
    SELECT
        customerId,
        orderId,
        orderProcessingTime,
        if(MOD(visitTime,@parameter3)=0,visitTime/@parameter3, (CEILING(visitTime/@parameter3))) AS visitTime, 
        EXTRACT(YEAR FROM orderProcessingTime) AS visitYear
    FROM (SELECT 
              customerId,
              orderId,
              orderProcessingTime,
              EXTRACT(@parameter1 FROM orderProcessingTime) visitTime
          FROM `my-project-1503433822077.perpule.jugnoo` 
          GROUP BY 1,2,3
          )
     )
),

--Find initial visit of each customer
first_visit AS
(
SELECT 
    customerId,
    min(calcTime) AS firstVisit,
    min(firstOrderProcessingTime) AS firstOrderProcessingTime
FROM visit_log
GROUP BY 1
),

--Count the number of new users in each time interval
new_user AS
(
SELECT firstVisit,
    MIN(firstOrderProcessingTime) AS firstOrderProcessingTime,
    COUNT(DISTINCT customerId) AS newUsers
FROM first_visit
GROUP BY 1
),

--Check whether a particular users visited further or not
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

--Finally putting all together
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
ORDER BY 1,2,4