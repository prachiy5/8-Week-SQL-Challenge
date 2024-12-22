# Case Study #4: Data Bank

## **C. Data Allocation Challenge**

### **Introduction**
The **Data Allocation Challenge** addresses the critical task of estimating how much data storage needs to be provisioned for Data Bank customers. The challenge is based on three different allocation models:
1. **Option 1**: Data is allocated based on the **balance at the end of the previous month**.
2. **Option 2**: Data is allocated based on the **average balance over the past 30 days**.
3. **Option 3**: Data is updated in **real-time** based on each transaction.

Each model provides a unique perspective on how customer balances influence data requirements, allowing us to evaluate and recommend the most efficient and scalable allocation strategy.

---

### **Objective**
The primary goal of this challenge is to:
1. Analyze the impact of each data allocation model on storage requirements.
2. Compare the results to understand which allocation strategy best balances cost and efficiency.
3. Generate insights into customer behavior and transaction patterns to help optimize resource allocation.

---

### **Approach**
To solve this challenge, we break the task into the following steps:

#### **Step 1: Calculate Running Customer Balances**
For each transaction, we calculate the **running balance** of each customer. This balance is updated in real-time to reflect deposits (+) and withdrawals/purchases (-).

**Query:**
```sql
SELECT 
    customer_id,
    txn_date,
    txn_type,
    txn_amount,
    SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
            ELSE 0
        END) OVER (
            PARTITION BY customer_id 
            ORDER BY txn_date
        ) AS running_balance
FROM customer_transactions
ORDER BY customer_id, txn_date;
```
### **Sample Output: Running Customer Balances**
*Note: The overall dataset is too large to display; here is a sample for illustration.*

| Customer ID | Transaction Date | Transaction Type | Transaction Amount | Running Balance |
|-------------|------------------|------------------|--------------------|-----------------|
| 1           | 2020-01-02       | Deposit          | 312                | 312             |
| 1           | 2020-03-05       | Purchase         | 612                | -300            |
| 2           | 2020-01-03       | Deposit          | 549                | 549             |
| 3           | 2020-01-27       | Deposit          | 144                | 144             |
---

### **Step 2: Calculate Closing Balances for Each Month**
Using the running balances, calculate the closing balance for each customer at the end of every month. These balances represent the customer’s financial standing at the end of the month.
```sql
WITH running_balance AS (
    SELECT 
        customer_id,
        txn_date,
        SUM(CASE 
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
                ELSE 0
            END) OVER (
                PARTITION BY customer_id 
                ORDER BY txn_date
            ) AS running_balance
    FROM customer_transactions
)
SELECT 
    customer_id,
    MONTH(txn_date) AS month,
    DATENAME(MONTH, txn_date) AS month_name,
    MAX(running_balance) AS closing_balance
FROM running_balance
GROUP BY customer_id, MONTH(txn_date), DATENAME(MONTH, txn_date)
ORDER BY customer_id, month;
```
*Note: The overall dataset is too large to display; here is a sample for illustration.*

**Sample Output:**
| Customer ID | Month | Month Name | Closing Balance |
|-------------|-------|------------|-----------------|
| 1           | 1     | January    | 312             |
| 1           | 3     | March      | 24              |
| 2           | 1     | January    | 549             |
| 3           | 2     | February   | -821            |

---

### **Step 3: Minimum, Average, and Maximum Running Balances**
Calculate the **minimum**, **average**, and **maximum** running balances for each customer to analyze trends in their financial activity.
```sql
WITH running_balance AS
(
	SELECT customer_id,
	       txn_date,
	       txn_type,
	       txn_amount,
	       SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
			WHEN txn_type = 'withdrawal' THEN -txn_amount
			WHEN txn_type = 'purchase' THEN -txn_amount
			ELSE 0
		    END) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
	FROM customer_transactions
)

SELECT customer_id,
       AVG(running_balance) AS avg_running_balance,
       MIN(running_balance) AS min_running_balance,
       MAX(running_balance) AS max_running_balance
FROM running_balance
GROUP BY customer_id;

```
*Note: The overall dataset is too large to display; here is a sample for illustration.*

**Sample Output:**
| Customer ID | Avg Running Balance | Min Running Balance | Max Running Balance |
|-------------|----------------------|---------------------|---------------------|
| 1           | -151                | -640                | 312                 |
| 2           | 579                 | 549                 | 610                 |
| 3           | -732                | -1222               | 144                 |
| 4           | 653                 | 458                 | 848                 |

---

### **Step 4: Data Allocation by Model**

#### **Option 1: Based on End of Previous Month**
Allocate data based on the closing balance at the end of each month.
```sql
WITH running_balance AS (
    SELECT 
        customer_id,
        txn_date,
        SUM(CASE 
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
                ELSE 0
            END) OVER (
                PARTITION BY customer_id 
                ORDER BY txn_date
            ) AS running_balance
    FROM customer_transactions
),
monthly_closing_balance AS (
    SELECT 
        customer_id,
        MONTH(txn_date) AS month,
        DATENAME(MONTH, txn_date) AS month_name,
        MAX(running_balance) AS closing_balance
    FROM running_balance
    GROUP BY customer_id, MONTH(txn_date), DATENAME(MONTH, txn_date)
)
SELECT 
    month,
    month_name,
    SUM(closing_balance) AS data_required_per_month
FROM monthly_closing_balance
GROUP BY month, month_name
ORDER BY month;
```
**Sample Output:**
| Month | Month Name | Data Required Per Month |
|-------|------------|--------------------------|
| 1     | January    | 351,521                 |
| 2     | February   | 230,473                 |
| 3     | March      | 109,155                 |

---

#### **Option 2: Based on 30-Day Average Balance**
Allocate data based on the average running balance over the past 30 days.
```sql
WITH transaction_amt_cte AS (
    SELECT 
        customer_id,
        txn_date,
        MONTH(txn_date) AS txn_month,
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE -txn_amount 
        END AS net_transaction_amt
    FROM customer_transactions
),
running_balance_cte AS (
    SELECT 
        customer_id,
        txn_date,
        txn_month,
        SUM(net_transaction_amt) OVER (
            PARTITION BY customer_id 
            ORDER BY txn_date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_balance
    FROM transaction_amt_cte
),
rolling_30_day_avg_cte AS (
    SELECT 
        customer_id,
        txn_month,
        txn_date,
        AVG(running_balance) OVER (
            PARTITION BY customer_id 
            ORDER BY txn_date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS avg_30_days_balance
    FROM running_balance_cte
)
SELECT 
    txn_month,
    ROUND(SUM(avg_30_days_balance), 0) AS data_required_per_month
FROM rolling_30_day_avg_cte
GROUP BY txn_month
ORDER BY txn_month;

```
**Sample Output:**
| Month | Data Required Per Month |
|-------|--------------------------|
| 1     | 554,474                 |
| 2     | 431,203                 |

---

#### **Option 3: Real-Time Updates**
Allocate data dynamically based on the running balance after every transaction.
```sql
WITH transaction_amt_cte AS (
    SELECT 
        customer_id,
        txn_date,
        MONTH(txn_date) AS month,
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE -txn_amount 
        END AS net_transaction_amt
    FROM customer_transactions
),
running_balance_cte AS (
    SELECT 
        customer_id,
        month,
        SUM(net_transaction_amt) OVER (
            PARTITION BY customer_id 
            ORDER BY txn_date
        ) AS running_balance
    FROM transaction_amt_cte
)
SELECT 
    month,
    SUM(running_balance) AS data_required_per_month
FROM running_balance_cte
GROUP BY month
ORDER BY month;
```
**Sample Output:**
| Month | Data Required Per Month |
|-------|--------------------------|
| 1     | 390,315                 |
| 3     | -904,668                |

---

### **Overall Insights**
1. **Option 1**: Simple, predictable, and works well for stable customers with consistent balances.
2. **Option 2**: Captures long-term trends and is ideal for smoothing out variability in customer transactions.
3. **Option 3**: Provides real-time precision but is computationally expensive and reflects highly variable requirements.

---

### **Conclusion**
Each model offers unique advantages:
- **Option 1** is straightforward and cost-effective for planning.
- **Option 2** balances short-term and long-term trends, making it suitable for dynamic but predictable customer behavior.
- **Option 3** is ideal for environments that demand real-time precision but requires robust infrastructure.

Each option provides a unique perspective, allowing Data Bank to choose a model based on the balance between cost efficiency and operational complexity.


