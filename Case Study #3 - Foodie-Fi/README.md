# 🍔 Case Study #3: Foodie-Fi

This repository contains my solutions for **Case Study #3: Foodie-Fi** from the **8 Week SQL Challenge** by [Danny Ma](https://www.datawithdanny.com/).

---

## 📖 Table of Contents
- [Introduction](#introduction)
- [Available Data](#available-data)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Tables](#tables)
- [Case Study Questions](#case-study-questions)
- [Progress and Sections](#progress-and-sections)
- [Data Cleaning Approach](#data-cleaning-approach)
- [Solutions](#solutions)
  - [Customer Journey Solutions](#customer-journey-solutions)
  - [Data Analysis Solutions](#data-analysis-solutions)
  - [Challenge Payment Solutions](#challenge-payment-solutions)
  - [Outside the Box Questions](#outside-the-box-questions)
- [Future Updates](#future-updates)
- [Acknowledgments](#acknowledgments)

---

## 🛠 Introduction

Danny created **Foodie-Fi**, a subscription-based streaming service with content centered around food! Think of it like Netflix, but exclusively for cooking shows.

This case study is all about analyzing subscription data to answer key business questions. Danny also challenges us to simulate payment data and come up with strategies for improving customer retention.

---

## 🗂 Available Data

### 📋 Entity Relationship Diagram

Here’s the ERD for the Foodie-Fi database:

![{A1B9120E-2639-41B3-A9B7-602C4CFE8269}](https://github.com/user-attachments/assets/01a13fd8-1534-43b0-9950-8c3ff82f7bf6)


### 🧾 Tables

1. **`plans`**: Details of the different subscription plans.
2. **`subscriptions`**: Records of customer subscriptions, including plan changes and churn details.

---

## ❓ Case Study Questions

This case study is divided into the following sections:

1. **Customer Journey**: Analyze onboarding journeys for 8 sample customers.
2. **Data Analysis**: Answer questions about customer counts, churn rates, and plan trends.
3. **Challenge Payment**: Create a payment simulation table for 2020 based on business rules.
4. **Outside the Box**: Open-ended questions about growth strategies, key metrics, and customer retention.

---

## 🚧 Progress and Sections

I’ve broken the case study into smaller parts and uploaded the solutions incrementally. Once all sections are complete, I’ll publish a comprehensive write-up to explain my approach.

### **Uploaded Sections**
1. **Customer Journey Solutions**
2. **Data Analysis Solutions**

---

## 📊 Solutions

### Customer Journey Solutions

I analyzed the onboarding journeys of the 8 sample customers using SQL. Each customer’s journey was mapped based on their subscription data.
```sql
select * from subscriptions s inner join plans p on s.plan_id=p.plan_id
where customer_id in (1,2,11,13,15,16,18,19)
```
| customer_id | plan_id | start_date  | plan_id | plan_name       | price  |
|-------------|---------|-------------|---------|-----------------|--------|
| 1           | 0       | 2020-08-01  | 0       | trial           | 0.00   |
| 1           | 1       | 2020-08-08  | 1       | basic monthly   | 9.90   |
| 2           | 0       | 2020-09-20  | 0       | trial           | 0.00   |
| 2           | 3       | 2020-09-27  | 3       | pro annual      | 199.00 |
| 11          | 0       | 2020-11-19  | 0       | trial           | 0.00   |
| 11          | 4       | 2020-11-26  | 4       | churn           | NULL   |
| 13          | 0       | 2020-12-15  | 0       | trial           | 0.00   |
| 13          | 1       | 2020-12-22  | 1       | basic monthly   | 9.90   |
| 13          | 2       | 2021-03-29  | 2       | pro monthly     | 19.90  |
| 15          | 0       | 2020-03-17  | 0       | trial           | 0.00   |
| 15          | 2       | 2020-03-24  | 2       | pro monthly     | 19.90  |
| 15          | 4       | 2020-04-29  | 4       | churn           | NULL   |
| 16          | 0       | 2020-05-31  | 0       | trial           | 0.00   |
| 16          | 1       | 2020-06-07  | 1       | basic monthly   | 9.90   |
| 16          | 3       | 2020-10-21  | 3       | pro annual      | 199.00 |
| 18          | 0       | 2020-07-06  | 0       | trial           | 0.00   |
| 18          | 2       | 2020-07-13  | 2       | pro monthly     | 19.90  |
| 19          | 0       | 2020-06-22  | 0       | trial           | 0.00   |
| 19          | 2       | 2020-06-29  | 2       | pro monthly     | 19.90  |
| 19          | 3       | 2020-08-29  | 3       | pro annual      | 199.00 |
---
Insight:
Here’s a summary of customer journeys based on their subscription data:

- **Customer 1**: Started with a 7-day free trial on **2020-08-01** and switched to the **Basic Monthly** plan for **$9.90** on **2020-08-08**. They seemed happy with the basic features.
  
- **Customer 2**: Tried the free trial on **2020-09-20** and quickly upgraded to the **Pro Annual** plan for **$199** on **2020-09-27**. They went all in for the best features!

- **Customer 11**: Signed up for the free trial on **2020-11-19** but didn’t stick around and canceled on **2020-11-26**.

- **Customer 13**: Started with the free trial on **2020-12-15**, moved to the **Basic Monthly** plan for **$9.90** on **2020-12-22**, and later upgraded to **Pro Monthly** for **$19.90** on **2021-03-29**. They seemed to enjoy the service more over time.

- **Customer 15**: Began with the free trial on **2020-03-17**, upgraded to **Pro Monthly** for **$19.90** on **2020-03-24**, but canceled on **2020-04-29**. They didn’t stick around long.

- **Customer 16**: Tried the free trial on **2020-05-31**, switched to **Basic Monthly** for **$9.90** on **2020-06-07**, and later committed to **Pro Annual** for **$199** on **2020-10-21**. They became a long-term fan.

- **Customer 18**: Started with the free trial on **2020-07-06** and upgraded quickly to **Pro Monthly** for **$19.90** on **2020-07-13**. They liked the premium features right away.

- **Customer 19**: Tried the free trial on **2020-06-22**, moved to **Pro Monthly** for **$19.90** on **2020-06-29**, and later went for **Pro Annual** at **$199** on **2020-08-29**. They really valued the full experience.

### Key Takeaways
- Many customers upgraded quickly from the free trial to premium plans, showing interest in higher-value features.
- Some customers canceled shortly after upgrading, indicating room for improvement in retaining these users.
- Pro Annual plans were a popular choice among loyal customers, highlighting the value of long-term commitments.

### Data Analysis Solutions

This section dives into subscription trends and customer behavior. Here are some key questions I answered:

## 📊 Insights and Answers

### 1. How many customers has Foodie-Fi ever had?
```sql
select count(distinct customer_id) as total_customers from subscriptions 
```

**Answer:**
| Total Customers |
|-----------------|
| 1000           |

---

### 2. What is the monthly distribution of trial plan `start_date` values for our dataset?  
```sql
select count(plan_name) num_of_plans,DateName(Month, start_date) as 'month' from subscriptions s inner join plans p on p.plan_id=s.plan_id
where s.plan_id=0
group by DateName(Month, start_date)
order by 1  
```
**Answer:**
| num_of_plans | month      |
|--------------|------------|
| 68           | February   |
| 75           | November   |
| 79           | October    |
| 79           | June       |
| 81           | April      |
| 84           | December   |
| 87           | September  |
| 88           | May        |
| 88           | August     |
| 88           | January    |
| 89           | July       |
| 94           | March      |

---

### 3. What `plan_start_date` values occur after the year 2020 for our dataset?  
```sql
with cte as(select s.plan_id, p.plan_name,start_date from subscriptions s inner join plans p on p.plan_id=s.plan_id
where DateName(Year, start_date) > 2020)

select plan_id,plan_name, count(start_date) count_of_events_after_2020 from cte
group by plan_name,plan_id
order by plan_id

```
**Answer:**
| plan_id | plan_name      | count_of_events_after_2020 |
|---------|----------------|----------------------------|
| 1       | basic monthly  | 8                          |
| 2       | pro monthly    | 60                         |
| 3       | pro annual     | 63                         |
| 4       | churn          | 71                         |

---

### 4. What is the customer count and percentage of customers who have churned (rounded to 1 decimal place)?  
```sql
with cte as(select count(distinct customer_id) as churned_customers from subscriptions s inner join plans p on p.plan_id=s.plan_id
where plan_name='churn')

select count(distinct customer_id) as total_customers, 
round(cast((select churned_customers from cte) as float)/ count(distinct customer_id)*100,1) as churn_percentage from subscriptions cross join cte

```
**Answer:**
| Total Customers | Churn Percentage |
|------------------|------------------|
| 1000            | 30.7             |

---

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?  
```sql
with cte as(select p.plan_id,plan_name,customer_id,start_date,
row_number() over(partition by customer_id order by start_date) rn from subscriptions s inner join plans p on s.plan_id=p.plan_id),

cte2 as(select count(distinct c1.customer_id) as number_of_churned_cust_after_trial from cte c1
inner join cte c2 on c1.customer_id=c2.customer_id
and c1.rn=c2.rn-1
where c1.plan_name='trial' and c2.plan_name='churn')


select cast((select number_of_churned_cust_after_trial from cte2 ) as float)*100/count(distinct customer_id) as churn_percentage_right_after_trial 
			from subscriptions
```
**Answer:**
| churn_percentage_right_after_trial |
|------------------------------------|
| 9.2                                |

---

### 6. What is the number and percentage of customer plans after their initial free trial? 
```sql
with cte as(select s.plan_id,plan_name,customer_id,start_date,
row_number() over(partition by customer_id order by start_date) as rn from subscriptions s
inner join plans p
on s.plan_id=p.plan_id),

cte2 as(select c2.plan_name,count(*) as count_of_customers from cte c1 inner join cte c2
on c1.customer_id=c2.customer_id and c2.rn=c1.rn+1
where c1.rn=1 and c1.plan_name='trial'
group by c2.plan_name),

cte3 as(select count(*) as total_customers
from cte c1 inner join cte c2
on c1.customer_id=c2.customer_id
and c2.rn=c1.rn+1
where c1.rn=1 and c1.plan_name='trial')

select plan_name, count_of_customers, cast(count_of_customers as float)*100/ cast ((select total_customers from cte3) as float) aspercentage_of_customer_plans
from cte2

```
**Answer:**
| plan_name       | count_of_customers | aspercentage_of_customer_plans |
|------------------|--------------------|---------------------------------|
| pro annual       | 37                 | 3.7%                           |
| pro monthly      | 325                | 32.5%                          |
| churn            | 92                 | 9.2%                           |
| basic monthly    | 546                | 54.6%                          |

---

### 7. What is the customer count and percentage breakdown of all 5 `plan_name` values as of 2020-12-31?  
```sql
with cte as(select customer_id,s.plan_id,start_date,plan_name,
lead(start_date,1) over(partition by customer_id order by start_date) as start_date_of_next_plan from subscriptions s inner join plans p 
on s.plan_id=p.plan_id
where start_date<= '2020-12-31'),

cte2 as(select plan_name,cast(count(distinct customer_id) as float) total, cast((select count(distinct customer_id) as total_customers from subscriptions) as float) as total_all from cte
where start_date_of_next_plan is null
group by plan_name)

select plan_name,total, total*100.0/total_all as percentage_breakdown from cte2
order by percentage_breakdown desc
```
**Answer:**
| plan_name       | total | percentage_breakdown |
|------------------|-------|----------------------|
| pro monthly      | 326   | 32.6%               |
| churn            | 236   | 23.6%               |
| basic monthly    | 224   | 22.4%               |
| pro annual       | 195   | 19.5%               |
| trial            | 19    | 1.9%                |

---

### 8. How many customers have upgraded to an annual plan in 2020?  
```sql
with cte as(select customer_id,s.plan_id,plan_name,start_date from subscriptions s inner join plans p 
on s.plan_id=p.plan_id
where datename(year,start_date)=2020),

cte2 as(select plan_name,customer_id from cte
where plan_name='trial')

select count(distinct customer_id) as pro_annual_customers from cte
where customer_id in (select customer_id from cte2) and plan_name like 'pro annual'
```
**Answer:**
| pro_annual_customers |
|-----------------------|
| 195                   |

---

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?  
```sql
with cte as(select customer_id,s.plan_id,plan_name,start_date from subscriptions s inner join plans p 
on s.plan_id=p.plan_id),


cte2 as(select customer_id,plan_name,start_date as first_start_date from cte where plan_name='trial'),

cte3 as(select customer_id,plan_name,start_date as annual_start_date from cte where plan_name='pro annual' ),

cte4 as(select c1.customer_id, first_start_date,annual_start_date from cte2 c1 inner join  cte3 c2 
on c1.customer_id=c2.customer_id)

select avg(datediff(day,first_start_date,annual_start_date)) as avg_number_of_days from cte4

```
**Answer:**
| avg_number_of_days |
|---------------------|
| 104                 |

---

### 10. Can you further break down this average value into 30-day periods (e.g., 0-30 days, 31-60 days, etc.)?  
```sql
with cte as(select customer_id,s.plan_id,plan_name,start_date from subscriptions s inner join plans p 
on s.plan_id=p.plan_id),


cte2 as(select customer_id,plan_name,start_date as first_start_date from cte where plan_name='trial'),

cte3 as(select customer_id,plan_name,start_date as annual_start_date from cte where plan_name='pro annual' ),

cte4 as(select c1.customer_id, first_start_date,annual_start_date from cte2 c1 inner join  cte3 c2 
on c1.customer_id=c2.customer_id),

cte5 as(select customer_id,datediff(day,first_start_date,annual_start_date) as number_of_days from cte4),

cte6 as(select customer_id, number_of_days, floor(number_of_days / 30) as group_day
from cte5)

select 
    concat((group_day * 30) + 1, '-', (group_day + 1) * 30, ' days') as days,
    count(group_day) AS number_days
from cte6
group by group_day
order by group_day;
```
**Answer:**
| days        | number_days |
|-------------|-------------|
| 1-30 days   | 48          |
| 31-60 days  | 25          |
| 61-90 days  | 33          |
| 91-120 days | 35          |
| 121-150 days| 43          |
| 151-180 days| 35          |
| 181-210 days| 27          |
| 211-240 days| 4           |
| 241-270 days| 5           |
| 271-300 days| 1           |
| 301-330 days| 1           |
| 331-360 days| 1           |

---

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
with cte as(select customer_id, p.plan_id, plan_name, start_date,
row_number() over(partition by customer_id order by start_date) as rn from subscriptions s inner join plans p 
on s.plan_id=p.plan_id),

cte2 as(select c1.customer_id, c1.plan_name as first_plan, c2.plan_name as second_plan,
c1.start_date as first_date, c2.start_date as later_date from cte c1 
inner join cte c2
on c1.customer_id=c2.customer_id
and c2.rn=c1.rn+1
where c1.plan_name='pro monthly')

select count(customer_id) as downgraded_customers from cte2 
where second_plan='basic monthly'
and year(later_date)=2020
```
**Answer:**
| downgraded_customers |
|-----------------------|
| 0                     |




---

## C. Challenge Payment Question

The Foodie-Fi team tasked us with creating a payments table for the year 2020. The table includes details of payments made by customers based on their subscription plans and adheres to the following requirements:

1. **Monthly Payments**: Payments occur on the same day of the month as the subscription's `start_date`.
2. **Upgrades**: 
   - From `basic monthly` to `pro plans`, payments for the current month are reduced by the amount already paid.
   - From `pro monthly` to `pro annual`, payments occur at the end of the billing period and start at the end of the month.
3. **Churn**: Once a customer churns, no further payments are recorded.

### Steps Taken to Create the Payments Table
1. **Create the `payments_2020` Table**: A new table was created with the required fields: `payment_id`, `customer_id`, `plan_id`, `plan_name`, `payment_date`, `amount`, and `payment_order`.

2. **Base Data Preparation**: 
   - A CTE was used to join `subscriptions` and `plans` to gather details like `start_date`, `next_date`, and `amount`.
   - `trial` and `churn` plans were filtered out.

3. **Recursive Payment Generation**:
   - A recursive CTE generated monthly payments, stopping one month before the `next_date` or at the end of 2020.

4. **Insert Payments into the Table**:
   - Payments were inserted into the `payments_2020` table with proper ranking for `payment_order`.

5. **Output Validation**:
   - A query verified the correctness of the data.

---
```sql

CREATE TABLE payments_2020 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    plan_id INT NOT NULL,
    plan_name NVARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_order INT NOT NULL
);


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


SELECT *
FROM payments_2020
ORDER BY customer_id, plan_id, payment_date;
```


## 📋 Sample Output

The table below shows a sample of the `payments_2020` table (15 records out of 1000):

| payment_id | customer_id | plan_id | plan_name       | payment_date | amount  | payment_order |
|------------|-------------|---------|-----------------|--------------|---------|---------------|
| 1          | 1           | 1       | basic monthly   | 2020-08-08   | 9.90    | 1             |
| 2          | 1           | 1       | basic monthly   | 2020-09-08   | 9.90    | 2             |
| 3          | 1           | 1       | basic monthly   | 2020-10-08   | 9.90    | 3             |
| 4          | 1           | 1       | basic monthly   | 2020-11-08   | 9.90    | 4             |
| 5          | 1           | 1       | basic monthly   | 2020-12-08   | 9.90    | 5             |
| 6          | 2           | 3       | pro annual      | 2020-09-27   | 199.00  | 1             |
| 7          | 3           | 1       | basic monthly   | 2020-01-20   | 9.90    | 1             |
| 8          | 3           | 1       | basic monthly   | 2020-02-20   | 9.90    | 2             |
| 9          | 3           | 1       | basic monthly   | 2020-03-20   | 9.90    | 3             |
| 10         | 3           | 1       | basic monthly   | 2020-04-20   | 9.90    | 4             |
| 11         | 3           | 1       | basic monthly   | 2020-05-20   | 9.90    | 5             |
| 12         | 3           | 1       | basic monthly   | 2020-06-20   | 9.90    | 6             |
| 13         | 3           | 1       | basic monthly   | 2020-07-20   | 9.90    | 7             |
| 14         | 3           | 1       | basic monthly   | 2020-08-20   | 9.90    | 8             |

---

### Key Takeaways
- **Monthly Payments**: Payments for monthly plans are made on the same day of the month as the `start_date`.
- **Upgrades**: Handled according to business rules, with adjustments for overlapping payments.
- **Churn**: Payments stop as soon as a customer churns.

## 🔜 Future Updates

I’ve uploaded solutions for the **Customer Journey**, **Data Analysis** and  **Challenge Payment** section. Next, I will be uploading solutions for Bonus sections and  I’ll also add:
- A detailed write-up of my approach to solving these problems.

Stay tuned for updates!

---

## 📣 Acknowledgments

This case study is part of the **8 Week SQL Challenge** by [Danny Ma](https://www.datawithdanny.com/). A big thanks to Danny for creating this amazing resource for SQL learners like me!

---

Thanks for stopping by! If you have feedback or questions, feel free to reach out. 😊

