# Data Cleansing Steps for Case Study #5: Data Mart

This document outlines the data cleansing steps performed to create a clean and structured dataset named **clean_weekly_sales**.

---

## Task:

Perform the following operations to clean the data and generate a new table `data_mart.clean_weekly_sales`:

1. Convert `week_date` to a `DATE` format.
2. Add a `week_number` column representing the week of the year for each `week_date`.
3. Add a `month_number` column for the calendar month of each `week_date`.
4. Add a `calendar_year` column for the year (2018, 2019, or 2020).
5. Add an `age_band` column based on the segment value using the mapping:
    - `1`: Young Adults
    - `2`: Middle Aged
    - `3` or `4`: Retirees
6. Add a `demographic` column using the first letter in the segment value:
    - `C`: Couples
    - `F`: Families
7. Replace all `NULL` string values in the original `segment`, `age_band`, and `demographic` columns with `"unknown"`.
8. Add an `avg_transaction` column calculated as `sales / transactions`, rounded to 2 decimal places.

---

## Query:

```sql
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

SELECT * FROM clean_weekly_sales;
```

---

## Sample Output:

| week_date   | week_number | month_number | calendar_year | segment | age_band   | demographic | avg_transaction | region       | platform | customer_type | sales   | transactions |
|-------------|-------------|--------------|---------------|---------|------------|-------------|------------------|--------------|----------|---------------|---------|--------------|
| 2020-08-03  | 32          | 8            | 2020          | null    | unknown    | unknown     | 29.96           | SOUTH AMERICA| Retail   | Existing      | 9258    | 309          |
| 2020-08-03  | 32          | 8            | 2020          | F3      | Retirees   | Families    | 209.46          | OCEANIA      | Shopify  | Existing      | 773324  | 3692         |
| 2020-08-03  | 32          | 8            | 2020          | null    | unknown    | unknown     | 41.47           | OCEANIA      | Retail   | Existing      | 1916895 | 46226        |
| 2020-08-03  | 32          | 8            | 2020          | C4      | Retirees   | Couples     | 49.38           | CANADA       | Retail   | Existing      | 1401391 | 28378        |
| 2020-08-03  | 32          | 8            | 2020          | F3      | Retirees   | Families    | 35.13           | CANADA       | Retail   | New           | 627747  | 17871        |
| 2020-08-03  | 32          | 8            | 2020          | F3      | Retirees   | Families    | 208.16          | USA          | Shopify  | Existing      | 193590  | 930          |
| 2020-08-03  | 32          | 8            | 2020          | null    | unknown    | unknown     | 35.09           | OCEANIA      | Retail   | New           | 2864778 | 81643        |
| 2020-08-03  | 32          | 8            | 2020          | C4      | Retirees   | Couples     | 33.61           | AFRICA       | Retail   | New           | 1532557 | 45605        |
| 2020-08-03  | 32          | 8            | 2020          | C3      | Retirees   | Couples     | 195.29          | ASIA         | Shopify  | Existing      | 384914  | 1971         |

---

