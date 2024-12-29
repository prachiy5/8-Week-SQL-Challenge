# Reporting Challenge 📊

This section consolidates all the queries from **High-Level Sales Analysis** and **Transaction Analysis** into a single SQL script. The goal is to generate a scheduled report for the previous month’s data, allowing the Balanced Tree team to review key metrics effectively.

---

## High-Level Sales Analysis 🔢

### SQL Script:
```sql
-- Declare variables for the reporting period
DECLARE @start_date DATE = '2021-01-01'; -- Adjust for the first day of the month
DECLARE @end_date DATE = '2021-01-31';   -- Adjust for the last day of the month

-- 1. What was the total quantity sold for all products?
SELECT SUM(qty) AS total_quantity
FROM sales
WHERE start_txn_time BETWEEN @start_date AND @end_date;

-- 2. What is the total generated revenue for all products before discounts?
SELECT SUM(qty * price) AS total_revenue
FROM sales
WHERE start_txn_time BETWEEN @start_date AND @end_date
  AND qty IS NOT NULL 
  AND price IS NOT NULL;

-- 3. What was the total discount amount for all products?
SELECT CAST(ROUND(SUM(qty * price * discount / 100.0), 2) AS DECIMAL(10,2)) AS total_discount_amount
FROM sales
WHERE start_txn_time BETWEEN @start_date AND @end_date;
```

### Insights:
- **Total Quantity Sold:** Aggregates all product quantities sold within the reporting period.
- **Total Revenue:** Reflects the revenue generated before applying any discounts.
- **Total Discount Amount:** Summarizes the value of all discounts applied during the reporting period.

---

## Transaction Analysis 📊

### SQL Script:
```sql
-- 1. How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales
WHERE start_txn_time BETWEEN @start_date AND @end_date;

-- 2. What is the average unique products purchased in each transaction?
WITH cte AS (
    SELECT txn_id, COUNT(DISTINCT prod_id) AS products_per_txn
    FROM sales
    WHERE start_txn_time BETWEEN @start_date AND @end_date
    GROUP BY txn_id
)
SELECT AVG(products_per_txn) AS avg_unique_products
FROM cte;

-- 3. What are the 25th, 50th, and 75th percentile values for the revenue per transaction?
WITH cte AS (
    SELECT txn_id, SUM(price * qty) AS revenue
    FROM sales
    WHERE start_txn_time BETWEEN @start_date AND @end_date
    GROUP BY txn_id
)
SELECT DISTINCT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) OVER () AS percentile_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue) OVER () AS percentile_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) OVER () AS percentile_75
FROM cte;

-- 4. What is the average discount value per transaction?
WITH cte AS (
    SELECT txn_id, SUM(qty * price * CAST(discount AS NUMERIC) / 100) AS discount_per_transaction
    FROM sales
    WHERE start_txn_time BETWEEN @start_date AND @end_date
    GROUP BY txn_id
)
SELECT CAST(ROUND(AVG(discount_per_transaction), 2) AS DECIMAL(10,2)) AS avg_discount_value
FROM cte;

-- 5. What is the percentage split of all transactions for members vs non-members?
WITH cte AS (
    SELECT member, COUNT(DISTINCT txn_id) AS txns
    FROM sales
    WHERE start_txn_time BETWEEN @start_date AND @end_date
    GROUP BY member
)
SELECT 
    CASE 
        WHEN member = 0 THEN 'Not a Member' 
        WHEN member = 1 THEN 'Is a Member'
    END AS member_status,
    100.0 * CAST(txns AS FLOAT) / 
    (SELECT COUNT(DISTINCT txn_id) FROM sales WHERE start_txn_time BETWEEN @start_date AND @end_date) AS percentage_split
FROM cte;

-- 6. What is the average revenue for member transactions and non-member transactions?
WITH cte AS (
    SELECT txn_id, member, SUM(qty * price) AS revenue
    FROM sales
    WHERE start_txn_time BETWEEN @start_date AND @end_date
    GROUP BY txn_id, member
)
SELECT 
    CASE 
        WHEN member = 0 THEN 'Not a Member' 
        WHEN member = 1 THEN 'Is a Member'
    END AS member_status,
    AVG(revenue) AS avg_revenue
FROM cte
GROUP BY member;
```

### Insights:
- **Unique Transactions:** Tracks the count of distinct transactions in the reporting period.
- **Average Unique Products:** Evaluates the diversity of purchases per transaction.
- **Revenue Percentiles:** Highlights key revenue distribution metrics (25th, 50th, and 75th percentiles).
- **Average Discount Value:** Summarizes the discount value per transaction.
- **Member vs Non-Member:** Analyzes transaction contributions and revenue patterns for both groups.

---
## Product Analysis 🍔✅
### SQL Script:

```sql
---1. Top 3 Products by Total Revenue Before Discount

WITH cte AS (
    SELECT 
        p.product_id, 
        s.qty, 
        p.price, 
        p.product_name
    FROM sales s
    INNER JOIN product_details p ON s.prod_id = p.product_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
),
cte2 AS (
    SELECT 
        product_id, 
        product_name, 
        SUM(qty * price) AS revenue,
        DENSE_RANK() OVER (ORDER BY SUM(qty * price) DESC) AS rn
    FROM cte 
    GROUP BY product_id, product_name
)
SELECT 
    product_id, 
    product_name, 
    revenue
FROM cte2
WHERE rn <= 3;

--- 2. Total Quantity, Revenue, and Discount for Each Segment

WITH cte AS (
    SELECT 
        p.segment_name, 
        s.qty, 
        s.price, 
        s.discount
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
)
SELECT 
    segment_name, 
    SUM(qty) AS total_quantity, 
    SUM(qty * price) AS total_revenue,
    CAST(ROUND(SUM(qty * price * discount / 100.0), 2) AS DECIMAL(10,2)) AS total_discount
FROM cte
GROUP BY segment_name;

--- 3. Top Selling Product for Each Segment

WITH cte AS (
    SELECT 
        p.segment_name, 
        p.product_name, 
        s.qty, 
        s.price
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
),
cte2 AS (
    SELECT 
        segment_name, 
        product_name,
        SUM(qty) AS total_quantity,
        SUM(qty * price) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty) DESC) AS rn
    FROM cte
    GROUP BY segment_name, product_name
)
SELECT 
    segment_name, 
    product_name, 
    total_revenue
FROM cte2
WHERE rn = 1;


--- 4. Total Quantity, Revenue, and Discount for Each Category

WITH cte AS (
    SELECT 
        p.category_name, 
        s.qty, 
        s.price, 
        s.discount
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
)
SELECT 
    category_name, 
    SUM(qty) AS total_quantity, 
    SUM(qty * price) AS total_revenue,
    CAST(ROUND(SUM(qty * price * discount / 100.0), 2) AS DECIMAL(10,2)) AS total_discount
FROM cte
GROUP BY category_name;

--- 5. Top Selling Product for Each Category

WITH cte AS (
    SELECT 
        p.category_name, 
        p.product_name, 
        s.qty, 
        s.price
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
),
cte2 AS (
    SELECT 
        category_name, 
        product_name,
        SUM(qty) AS total_quantity,
        SUM(qty * price) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY category_name ORDER BY SUM(qty) DESC) AS rn
    FROM cte
    GROUP BY category_name, product_name
)
SELECT 
    category_name, 
    product_name, 
    total_revenue
FROM cte2
WHERE rn = 1;

--- 6. Percentage Split of Revenue by Product for Each Segment

WITH cte AS (
    SELECT 
        p.segment_name, 
        p.product_name, 
        s.qty, 
        s.price
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
),
cte2 AS (
    SELECT 
        segment_name, 
        product_name, 
        SUM(qty * price) AS revenue
    FROM cte
    GROUP BY segment_name, product_name
),
cte3 AS (
    SELECT 
        segment_name, 
        SUM(qty * price) AS total_segment_revenue
    FROM cte
    GROUP BY segment_name
)
SELECT 
    cte2.segment_name, 
    cte2.product_name, 
    cte2.revenue,
    CAST(ROUND(cte2.revenue * 100.0 / cte3.total_segment_revenue, 2) AS DECIMAL(10,2)) AS percentage_split
FROM cte2
INNER JOIN cte3 ON cte2.segment_name = cte3.segment_name
ORDER BY percentage_split DESC;


--- 7. Percentage Split of Revenue by Segment for Each Category

WITH cte AS (
    SELECT 
        p.category_name, 
        p.segment_name, 
        s.qty, 
        s.price
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
),
cte2 AS (
    SELECT 
        category_name, 
        segment_name, 
        SUM(qty * price) AS revenue
    FROM cte
    GROUP BY category_name, segment_name
),
cte3 AS (
    SELECT 
        category_name, 
        SUM(qty * price) AS total_category_revenue
    FROM cte
    GROUP BY category_name
)
SELECT 
    cte2.category_name, 
    cte2.segment_name, 
    cte2.revenue,
    CAST(ROUND(cte2.revenue * 100.0 / cte3.total_category_revenue, 2) AS DECIMAL(10,2)) AS percentage_split
FROM cte2
INNER JOIN cte3 ON cte2.category_name = cte3.category_name
ORDER BY percentage_split DESC;


--- 8. Percentage Split of Total Revenue by Category
WITH cte AS (
    SELECT 
        p.category_name, 
        s.qty, 
        s.price
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
)
SELECT 
    category_name,
    CAST(ROUND(SUM(qty * price) * 100.0 / (SELECT SUM(qty * price) FROM cte), 2) AS DECIMAL(10,2)) AS percentage_split
FROM cte
GROUP BY category_name;

--- 9. Total Transaction Penetration for Each Product

WITH cte AS (
    SELECT 
        p.product_name, 
        s.txn_id
    FROM product_details p
    INNER JOIN sales s ON p.product_id = s.prod_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
)
SELECT 
    product_name, 
    COUNT(DISTINCT txn_id) AS total_txns,
    CAST(ROUND(COUNT(DISTINCT txn_id) * 100.0 / (SELECT COUNT(DISTINCT txn_id) FROM sales WHERE start_txn_time BETWEEN @start_date AND @end_date), 2) AS DECIMAL(10,2)) AS penetration_percentage
FROM cte
GROUP BY product_name
ORDER BY penetration_percentage DESC;

--- 10. Most Common Combination of 3 Products in a Single Transaction
WITH cte AS (
    SELECT 
        s.txn_id, 
        p.product_name
    FROM sales s
    INNER JOIN product_details p ON s.prod_id = p.product_id
    WHERE s.start_txn_time BETWEEN @start_date AND @end_date
)
SELECT TOP 1 
    c1.product_name AS product_1,
    c2.product_name AS product_2,
    c3.product_name AS product_3,
    COUNT(*) AS occurrence_count
FROM cte c1
INNER JOIN cte c2 ON c1.txn_id = c2.txn_id AND c1.product_name < c2.product_name
INNER JOIN cte c3 ON c1.txn_id = c3.txn_id AND c2.product_name < c3.product_name
GROUP BY c1.product_name, c2.product_name, c3.product_name
ORDER BY occurrence_count DESC;
```

### 📊 Instructions for Running and Automating the Report

- 🗓️ Use `@start_date` and `@end_date` variables to set the reporting period for the desired month. Update these dates before running the script.

- 📁 The script is divided into sections like **High-Level Sales Analysis**, **Transaction Analysis**, and **Product Analysis**. Each section calculates specific metrics.

- 🤖 To automate the script, schedule it using SQL Job Scheduler or similar tools. Set the job to run at the start of each month for the previous month’s data.

- ✅ Validate the results for a few months manually before scheduling the script. This ensures accuracy in outputs like percentiles and aggregations.

- 📝 Store the output of each section in separate tables for record-keeping and future reference. Create a summary table for quick executive review.

- 🔁 The script is designed to be reusable. To analyze a different month, just update the date variables.

- 💬 Before finalizing the report, get feedback from stakeholders (e.g., the CFO or merchandising team) to ensure the metrics meet their expectations.

- ⚙️ Check the database for proper indexing on key tables like `sales` and `product_details` to optimize script performance.

- 📈 Use the outputs to track trends over time and identify areas for business improvements.

- 🔄 Run the script periodically to keep the metrics up-to-date and relevant.

