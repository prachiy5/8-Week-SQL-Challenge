-- 1. What day of the week is used for each week_date value?

with cte as(select*,
datename(weekday, week_date) as week_day
from clean_weekly_sales)

select distinct(week_day) as day_of_the_week from cte

--2. What range of week numbers are missing from the dataset?

WITH week_numbers AS (
    SELECT 1 AS week_number
    UNION ALL
    SELECT week_number + 1
    FROM week_numbers
    WHERE week_number < 53
),
missing_weeks AS (
    SELECT wn.week_number
    FROM week_numbers wn
    LEFT JOIN (SELECT DISTINCT week_number FROM clean_weekly_sales) cws
    ON wn.week_number = cws.week_number
    WHERE cws.week_number IS NULL
),
ranges AS (
    SELECT 
        week_number,
        week_number - ROW_NUMBER() OVER (ORDER BY week_number) AS grp
    FROM missing_weeks
)
SELECT 
    MIN(week_number) AS start_week,
    MAX(week_number) AS end_week
FROM ranges
GROUP BY grp
ORDER BY start_week;





-- 3. How many total transactions were there for each year in the dataset?
--transactions is the count of unique purchases
select year(week_date) as year , sum(transactions) as total_transactions
from clean_weekly_sales
group by year(week_date) 
order by 2 desc

--4. What is the total sales for each region for each month?


 SELECT 
    region,
    month_number,
    SUM(CAST(sales AS BIGINT)) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY 1,2;

--5. What is the total count of transactions for each platform


SELECT 
    platform, 
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;

--What is the percentage of sales for Retail vs Shopify for each month?

WITH cte AS (
    SELECT 
        platform, 
        calendar_year,
        month_number,
        SUM(CAST(sales AS BIGINT)) AS total_sales
    FROM clean_weekly_sales
    WHERE platform IN ('Retail', 'Shopify')
    GROUP BY platform, calendar_year, month_number
),
cte2 AS (
    SELECT 
        calendar_year,
        month_number,
        SUM(total_sales) AS total_sales_all_platforms
    FROM cte
    GROUP BY calendar_year, month_number
)
SELECT 
    c.calendar_year,
    c.month_number,
    ROUND(
        SUM(CASE WHEN c.platform = 'Retail' THEN CAST(c.total_sales AS FLOAT) ELSE 0 END) 
        / t.total_sales_all_platforms * 100, 2
    ) AS retail_percent,
    ROUND(
        SUM(CASE WHEN c.platform = 'Shopify' THEN CAST(c.total_sales AS FLOAT) ELSE 0 END) 
        / t.total_sales_all_platforms * 100, 2
    ) AS shopify_percent
FROM cte c
JOIN cte2 t
ON c.calendar_year = t.calendar_year AND c.month_number = t.month_number
GROUP BY c.calendar_year, c.month_number, t.total_sales_all_platforms
ORDER BY c.calendar_year, c.month_number;

--What is the percentage of sales by demographic for each year in the dataset?
-- Step 1: Calculate total sales for each demographic per year
WITH YearlyDemographicSales AS (
    SELECT 
        calendar_year, 
        demographic, 
        SUM(CAST(sales AS BIGINT)) AS demographic_sales
    FROM clean_weekly_sales
    GROUP BY calendar_year, demographic
),

-- Step 2: Calculate total sales for each year and append it to the demographic-level data
YearlySalesWithTotals AS (
    SELECT 
        calendar_year, 
        demographic, 
        demographic_sales,
        SUM(demographic_sales) OVER (PARTITION BY calendar_year) AS total_yearly_sales
    FROM YearlyDemographicSales
)

-- Step 3: Calculate the percentage of sales for each demographic per year
SELECT 
    calendar_year, 
    demographic, 
    CAST(ROUND(100.0 * demographic_sales / total_yearly_sales, 2) AS DECIMAL(5, 2)) AS percent_sales
FROM YearlySalesWithTotals;

--Which age_band and demographic values contribute the most to Retail sales?


WITH TotalRetailSales AS (
    SELECT 
        SUM(CAST(sales AS BIGINT)) AS total_retail_sales
    FROM clean_weekly_sales
    WHERE platform = 'Retail'
)
SELECT 
    age_band, 
    demographic, 
    SUM(CAST(sales AS BIGINT)) AS total_sales,
    CAST(ROUND(100.0 * SUM(CAST(sales AS BIGINT)) / (SELECT total_retail_sales FROM TotalRetailSales), 2) AS DECIMAL(5,2)) AS percent_contribution
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;


--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
    calendar_year,
    platform,
    ROUND(SUM(CAST(sales AS FLOAT)) / SUM(transactions), 2) AS avg_transaction_size
FROM clean_weekly_sales
WHERE platform IN ('Retail', 'Shopify') -- Include only Retail and Shopify
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
