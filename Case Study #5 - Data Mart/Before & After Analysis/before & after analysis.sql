
----------Question 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?


SELECT DISTINCT
    DATEADD(week, -4, '2020-06-15') AS Date_Before, 
    DATEADD(week, 4, '2020-06-15') AS Date_After
FROM clean_weekly_sales;


WITH SalesComparison AS (
    SELECT 
        SUM(CASE 
                WHEN week_date >= '2020-05-18' AND week_date < '2020-06-15' 
                THEN CAST(sales AS BIGINT) 
            END) AS total_sales_before,
        SUM(CASE 
                WHEN week_date >= '2020-06-15' AND week_date <= '2020-07-13' 
                THEN CAST(sales AS BIGINT) 
            END) AS total_sales_after
    FROM clean_weekly_sales
)


SELECT 
    total_sales_before AS before_sales, 
    total_sales_after AS after_sales,  
    (total_sales_after - total_sales_before) AS sales_difference, 
    ROUND(CAST((total_sales_after - total_sales_before) * 100.0 / total_sales_before AS FLOAT), 2) AS percent_change
FROM SalesComparison;


-- Question 2. What about the entire 12 weeks before and after?
SELECT DISTINCT
    DATEADD(week, -12, '2020-06-15') AS Date_Before, --2020-03-23 00:00:00.000
    DATEADD(week, 12, '2020-06-15') AS Date_After -- 2020-09-07 00:00:00.000
FROM clean_weekly_sales;



WITH SalesComparison AS (
    SELECT 
        SUM(CASE 
                WHEN week_date >= '2020-03-23' AND week_date < '2020-06-15' 
                THEN CAST(sales AS BIGINT) 
            END) AS total_sales_before,
        SUM(CASE 
                WHEN week_date >= '2020-06-15' AND week_date <= '2020-09-07' 
                THEN CAST(sales AS BIGINT) 
            END) AS total_sales_after
    FROM clean_weekly_sales
)

SELECT 
    total_sales_before AS before_sales, 
    total_sales_after AS after_sales,  
    (total_sales_after - total_sales_before) AS sales_difference, 
    ROUND(CAST((total_sales_after - total_sales_before) * 100.0 / total_sales_before AS FLOAT), 2) AS percent_change
FROM SalesComparison;


------- Question 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?



select distinct week_number
from clean_weekly_sales
where week_date = '2020-06-15'  and calendar_year = '2020'

WITH SalesByYear AS (
    SELECT 
        calendar_year,
        SUM(CASE 
                WHEN week_date >= DATEADD(YEAR, DATEDIFF(YEAR, '2020-01-01', week_date), '2020-05-18') 
                     AND week_date < DATEADD(YEAR, DATEDIFF(YEAR, '2020-01-01', week_date), '2020-06-15') 
                THEN CAST(sales AS BIGINT) 
            END) AS before_sales,
        SUM(CASE 
                WHEN week_date >= DATEADD(YEAR, DATEDIFF(YEAR, '2020-01-01', week_date), '2020-06-15') 
                     AND week_date <= DATEADD(YEAR, DATEDIFF(YEAR, '2020-01-01', week_date), '2020-07-13') 
                THEN CAST(sales AS BIGINT) 
            END) AS after_sales
    FROM clean_weekly_sales
    WHERE calendar_year IN (2018, 2019, 2020)
    GROUP BY calendar_year
)

SELECT 
    calendar_year,
    before_sales, 
    after_sales,  
    (after_sales - before_sales) AS sales_difference, 
    ROUND(CAST((after_sales - before_sales) * 100.0 / before_sales AS FLOAT), 2) AS percent_change
FROM SalesByYear
ORDER BY calendar_year;
