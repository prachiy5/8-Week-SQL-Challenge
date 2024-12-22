# Customer Transactions Analysis

### Introduction
The **Customer Transactions Analysis** focuses on understanding transactional patterns and trends across Data Bank customers. By analyzing transaction types, monthly activity, and closing balances, we gain insights into customer behavior and its impact on data storage needs. This section answers key questions related to transaction counts, amounts, and customer activity.

---

### Objectives
The analysis answers the following questions:

1. What is the unique count and total amount for each transaction type?
```sql
select txn_type, count(*) as unique_count, sum(txn_amount) as total_amount from customer_transactions
group by txn_type
```

| Transaction Type | Unique Count | Total Amount |
|------------------|--------------|--------------|
| Withdrawal       | 1,580        | 793,003      |
| Deposit          | 2,671        | 1,359,168    |
| Purchase         | 1,617        | 806,537      |
---
2. What is the average total historical deposit counts and amounts for all customers?
```sql
WITH depo_sum AS (
  SELECT customer_id,
    txn_type, 
    COUNT(*) AS deposit_count, 
    SUM(txn_amount) AS deposit_amount
FROM customer_transactions
WHERE txn_type='deposit'
GROUP BY customer_id, txn_type)

SELECT 'deposit' AS txn_type, 
  ROUND(AVG(deposit_count),2) AS count, 
  ROUND(AVG(deposit_amount),2) AS amount 
FROM depo_sum;

```
| Transaction Type | Average Count | Average Amount |
|------------------|---------------|----------------|
| Deposit          | 5             | 2,718          |
---

3. For each month, how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```sql
with cte as(select *, datename(month, txn_date) as month from customer_transactions),

cte2 as(select customer_id, month,
count(case when txn_type='deposit' then 1 end) as deposit,
count(case when txn_type='purchase' then 1 end) as purchase,
count(case when txn_type='withdrawal' then 1 end) as withdrawal
from cte
group by customer_id,month)

select month, count(distinct customer_id) as num_of_customers
from cte2
where deposit>1 and (purchase>0 or withdrawal>0)
group by month
order by 2 desc
```

| Month      | Number of Customers |
|------------|---------------------|
| March      | 192                 |
| February   | 181                 |
| January    | 168                 |
| April      | 70                  |
---
4. What is the closing balance for each customer at the end of the month?
```sql
WITH cte AS (
    SELECT 
        customer_id,
        MONTH(txn_date) AS month_number,
        DATENAME(MONTH, txn_date) AS month,
        SUM(CASE 
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
                ELSE 0 
            END) AS total
    FROM 
        customer_transactions
    GROUP BY 
        customer_id, MONTH(txn_date), DATENAME(MONTH, txn_date)
)

SELECT customer_id,month_number,month,
       SUM(total) OVER (
           PARTITION BY customer_id 
           ORDER BY month_number
       ) AS closing_balance
FROM cte
ORDER BY 
    customer_id, month_number;
```

*Sample Output* (Data too large to display in full):
| Customer ID | Month Number | Month   | Closing Balance |
|-------------|--------------|---------|-----------------|
| 1           | 1            | January | 312             |
| 1           | 3            | March   | -640            |
| 2           | 1            | January | 549             |
| 3           | 1            | January | 144             |
| 3           | 4            | April   | -729            |
---
5. What is the percentage of customers who increase their closing balance by more than 5%?
```sql
WITH monthly_transactions AS (
    SELECT 
        customer_id,
        EOMONTH(txn_date) AS end_date,
        SUM(CASE 
                WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
                ELSE txn_amount 
            END) AS transactions
    FROM 
        customer_transactions
    GROUP BY 
        customer_id, EOMONTH(txn_date)
),

closing_balances AS (
    SELECT 
        customer_id,
        end_date,
        COALESCE(SUM(transactions) OVER (
            PARTITION BY customer_id 
            ORDER BY end_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 0) AS closing_balance
    FROM 
        monthly_transactions
),

spct_increase AS (
    SELECT 
        customer_id,
        end_date,
        closing_balance,
        LAG(closing_balance) OVER (
            PARTITION BY customer_id 
            ORDER BY end_date
        ) AS prev_closing_balance,
        CASE 
            WHEN LAG(closing_balance) OVER (
                PARTITION BY customer_id 
                ORDER BY end_date
            ) IS NOT NULL AND LAG(closing_balance) OVER (
                PARTITION BY customer_id 
                ORDER BY end_date
            ) != 0 THEN
                100.0 * (closing_balance - LAG(closing_balance) OVER (
                    PARTITION BY customer_id 
                    ORDER BY end_date
                )) / NULLIF(LAG(closing_balance) OVER (
                    PARTITION BY customer_id 
                    ORDER BY end_date
                ), 0)
            ELSE NULL
        END AS pct_increase
    FROM 
        closing_balances
)

SELECT 
    CAST(
        100.0 * COUNT(DISTINCT customer_id) / 
        (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions)
    AS FLOAT) AS pct_customers
FROM 
    spct_increase
WHERE 
    pct_increase > 5;

```
- **Percentage**: `75.8%`
---

### Insights
1. **Transaction Analysis**:
   - Deposits account for the highest volume (2,671) and total amount (1.36 million).
   - Purchases and withdrawals follow with similar unique counts and amounts.

2. **Customer Activity**:
   - March has the highest number of active customers making more than 1 deposit and a purchase or withdrawal (192 customers).
   - Activity decreases significantly in April, indicating seasonal or operational factors affecting transactions.

3. **Closing Balances**:
   - Negative closing balances for some customers indicate withdrawals and purchases exceeding deposits.

4. **Customer Growth**:
   - 75.8% of customers increased their closing balance by more than 5%, indicating strong financial activity and potential for increased data storage allocation.

---



