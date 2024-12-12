-- Step 1: Create the payments_2020 table
CREATE TABLE payments_2020 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    plan_id INT NOT NULL,
    plan_name NVARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_order INT NOT NULL
);

-- Step 2: Insert data into payments_2020 using recursive CTEs
WITH join_table AS
(
    -- Create a base table with start and next dates for subscriptions
    SELECT 
        s.customer_id,
        s.plan_id,
        p.plan_name,
        s.start_date AS payment_date,
        s.start_date,
        LEAD(s.start_date, 1) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_date,
        p.price AS amount
    FROM subscriptions s
    LEFT JOIN plans p 
        ON p.plan_id = s.plan_id
),

new_join AS
(
    -- Filter out trial and churn plans
    SELECT 
        customer_id,
        plan_id,
        plan_name,
        payment_date,
        start_date,
        CASE WHEN next_date IS NULL OR next_date > '2020-12-31' THEN '2020-12-31' ELSE next_date END AS next_date,
        amount
    FROM join_table
    WHERE plan_name NOT IN ('trial', 'churn')
),

new_join1 AS
(
    -- Add a column for the month before the next payment date
    SELECT 
        customer_id,
        plan_id,
        plan_name,
        payment_date,
        start_date,
        next_date,
        DATEADD(MONTH, -1, next_date) AS next_date1,
        amount
    FROM new_join
),

Date_CTE AS
(
    -- Recursive CTE to generate payment dates for each customer-plan combination
    SELECT 
        customer_id,
        plan_id,
        plan_name,
        start_date,
        payment_date = (SELECT TOP 1 start_date FROM new_join1 WHERE customer_id = a.customer_id AND plan_id = a.plan_id),
        next_date, 
        next_date1,
        amount
    FROM new_join1 a

    UNION ALL 

    SELECT 
        customer_id,
        plan_id,
        plan_name,
        start_date, 
        DATEADD(MONTH, 1, payment_date) AS payment_date,
        next_date, 
        next_date1,
        amount
    FROM Date_CTE b
    WHERE payment_date < next_date1 AND plan_id != 3
)

-- Insert generated payment data into the payments_2020 table
INSERT INTO payments_2020 (customer_id, plan_id, plan_name, payment_date, amount, payment_order)
SELECT 
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount,
    RANK() OVER (PARTITION BY customer_id, plan_id ORDER BY customer_id, payment_date) AS payment_order
FROM Date_CTE
WHERE YEAR(payment_date) = 2020
ORDER BY customer_id, plan_id, payment_date;

-- Verify the results
SELECT *
FROM payments_2020
ORDER BY customer_id, plan_id, payment_date;
