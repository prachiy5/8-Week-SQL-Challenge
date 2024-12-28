
DROP TABLE IF EXISTS clean_weekly_sales;


SELECT 
    week_date AS week_date,
    DATEPART(WEEK, week_date) AS week_number,
    MONTH(week_date) AS month_number,
    YEAR(week_date) AS calendar_year,
    ISNULL(segment, 'unknown') AS segment,
    CASE
        WHEN RIGHT(ISNULL(segment, '0'), 1) = '1' THEN 'Young Adults'
        WHEN RIGHT(ISNULL(segment, '0'), 1) = '2' THEN 'Middle Aged'
        WHEN RIGHT(ISNULL(segment, '0'), 1) IN ('3', '4') THEN 'Retirees'
        ELSE 'unknown'
    END AS age_band,
    CASE
        WHEN LEFT(ISNULL(segment, '0'), 1) = 'C' THEN 'Couples'
        WHEN LEFT(ISNULL(segment, '0'), 1) = 'F' THEN 'Families'
        ELSE 'unknown'
    END AS demographic,
    ROUND(CAST(sales AS FLOAT) / NULLIF(transactions, 0), 2) AS avg_transaction,
    region,
    platform,
    customer_type,
    sales,
    transactions
INTO clean_weekly_sales
FROM weekly_sales;


select * from clean_weekly_sales

