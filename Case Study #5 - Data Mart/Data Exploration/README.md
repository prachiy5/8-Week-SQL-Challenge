# Data Exploration for Case Study #5: Data Mart

This document details the data exploration performed as part of **Case Study #5: Data Mart**. The exploration answers various questions about the dataset and derives insights through SQL queries.

---

## 1. **What day of the week is used for each `week_date` value?**

### Query:
```sql
WITH cte AS (
    SELECT *,
           DATENAME(weekday, week_date) AS week_day
    FROM clean_weekly_sales
)
SELECT DISTINCT(week_day) AS day_of_the_week 
FROM cte;
```

### Output:
| day_of_the_week |
|------------------|
| Monday          |

The `week_date` values always start on a **Monday**.

---

## 2. **What range of week numbers are missing from the dataset?**

### Query:
```sql
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
```

### Output:
| start_week | end_week |
|------------|----------|
| 1          | 12       |
| 37         | 53       |

Missing weeks are from **1 to 12** and **37 to 53**.

---

## 3. **How many total transactions were there for each year in the dataset?**

### Query:
```sql
SELECT YEAR(week_date) AS year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY YEAR(week_date)
ORDER BY total_transactions DESC;
```

### Output:
| year | total_transactions |
|------|---------------------|
| 2020 | 375,813,651        |
| 2019 | 365,639,285        |
| 2018 | 346,406,460        |

---

## 4. **What is the total sales for each region for each month?**

### Query:
```sql
SELECT 
    region,
    month_number,
    SUM(CAST(sales AS BIGINT)) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
```

### Output:
(Partial sample shown below)

| region       | month_number | total_sales   |
|--------------|--------------|---------------|
| AFRICA       | 3            | 567,767,480   |
| AFRICA       | 4            | 1,911,783,504 |
| ASIA         | 3            | 529,770,793   |
| ASIA         | 4            | 1,804,628,707 |
| CANADA       | 3            | 144,634,329   |
| EUROPE       | 3            | 35,337,093    |
| OCEANIA      | 3            | 783,282,888   |
| SOUTH AMERICA| 3            | 71,023,109    |
| USA          | 3            | 225,353,043   |

---

## 5. **What is the total count of transactions for each platform?**

### Query:
```sql
SELECT 
    platform, 
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
```

### Output:
| platform | total_transactions |
|----------|---------------------|
| Retail   | 1,081,934,227      |
| Shopify  | 5,925,169          |

---

## 6. **What is the percentage of sales for Retail vs Shopify for each month?**

### Query:
```sql
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
```

### Output:
| calendar_year | month_number | retail_percent | shopify_percent |
|---------------|--------------|----------------|-----------------|
| 2018          | 3            | 97.92          | 2.08            |
| 2018          | 4            | 97.93          | 2.07            |
| 2019          | 3            | 97.71          | 2.29            |
| 2020          | 3            | 97.30          | 2.70            |

---

## 7. **What is the percentage of sales by demographic for each year in the dataset?**

### Query:
```sql
WITH YearlyDemographicSales AS (
    SELECT 
        calendar_year, 
        demographic, 
        SUM(CAST(sales AS BIGINT)) AS demographic_sales
    FROM clean_weekly_sales
    GROUP BY calendar_year, demographic
),
YearlySalesWithTotals AS (
    SELECT 
        calendar_year, 
        demographic, 
        demographic_sales,
        SUM(demographic_sales) OVER (PARTITION BY calendar_year) AS total_yearly_sales
    FROM YearlyDemographicSales
)
SELECT 
    calendar_year, 
    demographic, 
    CAST(ROUND(100.0 * demographic_sales / total_yearly_sales, 2) AS DECIMAL(5, 2)) AS percent_sales
FROM YearlySalesWithTotals;
```

### Output:
| calendar_year | demographic | percent_sales |
|---------------|-------------|---------------|
| 2018          | unknown     | 41.63         |
| 2018          | Families    | 31.99         |
| 2018          | Couples     | 26.38         |
| 2019          | Couples     | 27.28         |
| 2019          | unknown     | 40.25         |
| 2020          | Families    | 32.73         |

---

## 8. **Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify?**

### Query:
```sql
SELECT 
    calendar_year,
    platform,
    ROUND(SUM(CAST(sales AS FLOAT)) / SUM(transactions), 2) AS avg_transaction_size
FROM clean_weekly_sales
WHERE platform IN ('Retail', 'Shopify')
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```

### Output:
| calendar_year | platform | avg_transaction_size |
|---------------|----------|-----------------------|
| 2018          | Retail   | 36.56                |
| 2018          | Shopify  | 192.48               |
| 2019          | Retail   | 36.83                |
| 2019          | Shopify  | 183.36               |
| 2020          | Retail   | 36.56                |
| 2020          | Shopify  | 179.03               |

---

