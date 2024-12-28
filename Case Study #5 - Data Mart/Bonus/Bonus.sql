WITH period_sales AS (
    SELECT
        CASE
            WHEN week_date < '2020-06-15' AND week_date >= '2020-03-23' THEN 'Before'
            WHEN week_date >= '2020-06-15' AND week_date < '2020-09-07' THEN 'After'
        END AS period,
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE week_date BETWEEN '2020-03-23' AND '2020-09-06'
    GROUP BY
        CASE
            WHEN week_date < '2020-06-15' AND week_date >= '2020-03-23' THEN 'Before'
            WHEN week_date >= '2020-06-15' AND week_date < '2020-09-07' THEN 'After'
        END,
        region,
        platform,
        age_band,
        demographic,
        customer_type
),
sales_comparison AS (
    SELECT
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END) AS sales_before,
        MAX(CASE WHEN period = 'After' THEN total_sales ELSE 0 END) AS sales_after,
        MAX(CASE WHEN period = 'After' THEN total_sales ELSE 0 END) - 
        MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END) AS sales_difference,
        ROUND(
            CASE
                WHEN MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END) = 0 THEN 0
                ELSE 
                    ((MAX(CASE WHEN period = 'After' THEN total_sales ELSE 0 END) - 
                      MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END)) * 100.0 /
                     MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END))
            END, 2
        ) AS percentage_change
    FROM period_sales
    GROUP BY region, platform, age_band, demographic, customer_type
)
SELECT
    region,
    platform,
    age_band,
    demographic,
    customer_type,
    sales_before,
    sales_after,
    sales_difference,
    percentage_change
FROM sales_comparison
ORDER BY percentage_change ASC;
