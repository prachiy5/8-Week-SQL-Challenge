# 🍕 Case Study #2: Pizza Runner

This repository contains my solutions and analysis for **Case Study #2: Pizza Runner** from the **8 Week SQL Challenge** by [Danny Ma](https://www.datawithdanny.com/).

---

## 📖 Table of Contents
- [Introduction](#introduction)
- [Available Data](#available-data)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Tables](#tables)
- [Case Study Questions](#case-study-questions)
- [Progress and Sections](#progress-and-sections)
- [Data Cleaning Approach](#data-cleaning-approach)
- [Pizza Metrics Solutions](#pizza-metrics-solutions)
- [Runner and Customer Experience Solutions](#runner-and-customer-experience-solutions)
- [Future Updates](#future-updates)


---

## 🛠 Introduction

Danny launched **Pizza Runner**, a retro-styled pizza delivery service, combining Uber-like delivery with delicious pizza options. To optimize operations and direct his runners efficiently, Danny collected extensive data but needs help with data cleaning, analysis, and insights.

This case study includes many SQL challenges to solve and analyze Pizza Runner’s data.

---

## 🗂 Available Data

### 📋 Entity Relationship Diagram

Below is the ERD for the Pizza Runner database:

![{F43533B7-A117-434F-AA7F-15593A4D514D}](https://github.com/user-attachments/assets/b5ad6c78-467e-4e70-bd32-908175db6dea)


### 🧾 Tables

1. **`runners`**: Registration date of each runner.
2. **`customer_orders`**: Details of customer orders, including exclusions and extras.
3. **`runner_orders`**: Information on runner-assigned orders, including cancellations.
4. **`pizza_names`**: List of pizza types.
5. **`pizza_recipes`**: Standard toppings for each pizza.
6. **`pizza_toppings`**: Details of toppings by ID and name.

---

## ❓ Case Study Questions

This case study has **LOTS of questions**, grouped into the following focus areas:

1. **Pizza Metrics**: Questions on pizza orders, deliveries, and types.
2. **Runner and Customer Experience**: Questions on runner performance and delivery times.
3. **Ingredient Optimization**: Questions on toppings, exclusions, and extras.
4. **Pricing and Ratings**: Questions on revenue and customer satisfaction.
5. **Bonus DML Challenges**: Advanced challenges to test SQL skills.

---

## 🚧 Progress and Sections

Since this case study contains many questions, I am breaking it down into sections and uploading the solutions incrementally. Once all sections are completed, I will publish a comprehensive analysis on Medium, explaining the questions and solutions.

### **Uploaded Sections**
1. **Data Cleaning**
   - Explanation of the cleaning approach and why certain steps were taken.
2. **Pizza Metrics**
   - Solutions to the Pizza Metrics questions.

---

## 🧹 Data Cleaning Approach

### Why Clean the Data?
The raw data contains issues such as:
- `NULL` or invalid values in critical columns (`exclusions`, `extras`, `distance`, etc.).
- Inconsistent formatting (`km`, `minutes`, etc.).
- Duplicate or repeated records.

### How Was the Data Cleaned?

#### 1. **`customer_orders` Table**
- **Cleaned Columns**:
  - `exclusions` and `extras`: Replaced `NULL` and invalid strings (`'null'`) with blank space (`' '`).
- **Removed Duplicates**:
  - Ensured no duplicate `order_id` rows exist.

#### 2. **`runner_orders` Table**
- **Cleaned Columns**:
  - `pickup_time`: Replaced `NULL` and invalid strings (`'null'`) with blank space (`' '`).
  - `distance`: Removed the `"km"` suffix and replaced `NULL` with blank space.
  - `duration`: Removed inconsistent time suffixes (`"mins"`, `"minutes"`) and replaced `NULL` with blank space.
  - `cancellation`: Replaced `NULL` with blank space.
- **Altered Data Types**:
  - Converted `pickup_time` to `DATETIME`, `distance` to `FLOAT`, and `duration` to `INT`.

These cleaning steps were essential to ensure accurate and consistent data for analysis.

## 📊 Pizza Metrics Solutions

### Example Questions Answered

#### 1. **How many pizzas were ordered?**
```sql
SELECT COUNT(order_id) AS num_of_orders 
FROM customer_orders_temp;
```
**Explanation:** This query counts all the rows in the `customer_orders_temp` table. Each row represents one pizza, so the result gives the total number of pizzas ordered.

#### 2. **How many unique customer orders were made?**
```sql
SELECT COUNT(DISTINCT order_id) AS num_of_orders 
FROM customer_orders_temp;
```
**Explanation:** This query counts only the unique `order_id` values using `COUNT(DISTINCT order_id)`. It gives the number of separate customer orders, even if some orders included multiple pizzas.

#### 3. **How many successful orders were delivered by each runner?**
```sql
SELECT 
    runner_id, 
    COUNT(order_id) AS num_of_successful_orders 
FROM runner_orders_temp
WHERE distance != 0
GROUP BY runner_id;
```
**Explanation:** This query counts how many orders were successfully delivered by each runner. The `WHERE distance != 0` condition ensures only delivered orders are counted. Results are grouped by each `runner_id` to show the count per runner.

#### 4. **How many of each type of pizza was delivered?**
```sql
WITH cte AS (
    SELECT 
        c.order_id, 
        pizza_id, 
        distance 
    FROM customer_orders_temp c
    INNER JOIN runner_orders_temp r
        ON c.order_id = r.order_id
),
cte2 AS (
    SELECT 
        pizza_id, 
        COUNT(order_id) AS num_of_pizzas 
    FROM cte
    WHERE distance != 0
    GROUP BY pizza_id
)
SELECT 
    pizza_name, 
    num_of_pizzas 
FROM pizza_names
INNER JOIN cte2 
    ON cte2.pizza_id = pizza_names.pizza_id;
```
**Explanation:**
- First, the query filters for delivered orders by joining `customer_orders_temp` and `runner_orders_temp` and ensuring `distance != 0`.
- Then, it groups the data by `pizza_id` to count how many of each type were delivered.
- Finally, the `pizza_names` table is joined to replace `pizza_id` with the actual pizza names (e.g., Meat Lovers, Vegetarian).


#### 5. **How many Vegetarian and Meatlovers were ordered by each customer?**
```sql
WITH cte AS (
    SELECT 
        pizza_id, 
        customer_id, 
        COUNT(order_id) AS num_pizza_orders 
    FROM customer_orders_temp
    GROUP BY pizza_id, customer_id
)
SELECT 
    customer_id, 
    pizza_name, 
    num_pizza_orders 
FROM cte c
INNER JOIN pizza_names pn 
    ON c.pizza_id = pn.pizza_id
ORDER BY customer_id;
```
**Explanation:**
- The query groups data by `pizza_id` and `customer_id` to count how many pizzas of each type were ordered by each customer.
- The `pizza_names` table is joined to display pizza names instead of IDs.
- Results are ordered by `customer_id` for clarity.

#### 6. **What was the maximum number of pizzas delivered in a single order?**
```sql
WITH cte AS (
    SELECT 
        r.order_id, 
        COUNT(pizza_id) AS num_pizzas_delivered_per_order 
    FROM runner_orders_temp r
    INNER JOIN customer_orders_temp c
        ON r.order_id = c.order_id
    WHERE distance != 0
    GROUP BY r.order_id
)
SELECT MAX(num_pizzas_delivered_per_order) AS max_pizzas_delivered 
FROM cte;
```
**Explanation:**
This query calculates the maximum number of pizzas delivered in a single order.  
- It first counts the number of pizzas per `order_id` where `distance != 0`.
- Then, it uses the `MAX()` function to find the largest count from all the orders.
  
#### 7. **For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```sql
SELECT 
    customer_id,
    SUM(CASE 
        WHEN exclusions = '' AND extras = '' THEN 1 
        ELSE 0 
    END) AS no_change,
    SUM(CASE 
        WHEN exclusions <> '' OR extras <> '' THEN 1 
        ELSE 0 
    END) AS at_least_1_change
FROM customer_orders_temp c
INNER JOIN runner_orders_temp r 
    ON c.order_id = r.order_id
WHERE distance != 0
GROUP BY customer_id;
```
**Explanation:** 
This query shows how many delivered pizzas had changes and how many didn’t:  
- **No changes**: Rows where both `exclusions` and `extras` are empty.
- **At least one change**: Rows where either `exclusions` or `extras` has a value.
- Results are grouped by `customer_id` to show counts for each customer.


#### 8. **How many pizzas were delivered that had both exclusions and extras?**
```sql
SELECT 
    COUNT(r.order_id) AS num_pizzas_delivered 
FROM customer_orders_temp c 
INNER JOIN runner_orders_temp r 
    ON c.order_id = r.order_id
WHERE exclusions <> '' AND extras <> '' AND distance != 0;
```
**Explanation:** This query counts how many pizzas were delivered where customers requested both `exclusions` (ingredients removed) and `extras` (ingredients added). The `distance != 0` condition ensures only delivered orders are counted.


#### 9. **What was the total volume of pizzas ordered for each hour of the day?**
```sql
SELECT 
    DATEPART(HOUR, order_time) AS hour_of_the_day, 
    COUNT(order_id) AS num_of_orders 
FROM customer_orders_temp
GROUP BY DATEPART(HOUR, order_time)
ORDER BY 1;
```
**Explanation:** The query extracts the hour from `order_time` using `DATEPART(HOUR, order_time)` and counts the number of pizzas ordered during each hour. Results are grouped by hour and sorted in ascending order.

#### 10. **What was the volume of orders for each day of the week?**
```sql
SELECT 
    FORMAT(DATEADD(DAY, 2, order_time), 'dddd') AS day_of_week, 
    COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY FORMAT(DATEADD(DAY, 2, order_time), 'dddd') 
ORDER BY 
    MIN(DATEADD(DAY, 2, order_time));
```
**Explanation:**
This query calculates the number of pizzas ordered for each day of the week:  
- `DATEADD(DAY, 2, order_time)` adjusts the week to start from Monday.
- `FORMAT(..., 'dddd')` converts the date into a day name (e.g., Monday, Tuesday).
- Orders are grouped by day and sorted in chronological order.


## 🏃‍♂️ Runner and Customer Experience Solutions  

#### 1. **How many runners signed up for each 1-week period?**
```sql
SELECT 
    (DATEDIFF(DAY, '2021-01-01', registration_date) / 7) + 1 AS week_number, -- Calculate the week number
    DATEADD(DAY, -DATEDIFF(DAY, '2021-01-01', registration_date) % 7, registration_date) AS week_start_date, -- Calculate the start of the week
    COUNT(*) AS runners_signed_up
FROM runners
GROUP BY 
    (DATEDIFF(DAY, '2021-01-01', registration_date) / 7) + 1, -- Group by week number
    DATEADD(DAY, -DATEDIFF(DAY, '2021-01-01', registration_date) % 7, registration_date) -- Group by week start date
ORDER BY week_start_date;
```
#### 2. **What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
WITH cte AS (
    SELECT DISTINCT 
        orders.order_id,
        runners.runner_id,
        orders.order_time,
        runners.pickup_time
    FROM customer_orders_temp AS orders
    JOIN runner_orders_temp AS runners
        ON orders.order_id = runners.order_id
    WHERE runners.cancellation = ''
)
SELECT 
    runner_id,
    CEILING(CAST(AVG(DATEDIFF(SECOND, order_time, pickup_time)) AS FLOAT) / 60) AS avg_min_to_pickup
FROM cte
GROUP BY runner_id;

```
#### 3. **Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
WITH cte AS (
    SELECT 
        c.order_id, 
        COUNT(c.pizza_id) AS num_of_pizzas, 
        CEILING(CAST(AVG(DATEDIFF(SECOND, c.order_time, r.pickup_time)) AS FLOAT) / 60) AS avg_time
    FROM customer_orders_temp c
    INNER JOIN runner_orders_temp r 
        ON c.order_id = r.order_id
    WHERE r.pickup_time != 0 
    GROUP BY c.order_id
)
SELECT 
    num_of_pizzas, 
    AVG(avg_time) AS avg_preparation_time
FROM cte
GROUP BY num_of_pizzas
ORDER BY num_of_pizzas;
```
#### 4. **What was the average distance travelled for each customer?**
```sql
WITH cte AS (
    SELECT 
        c.order_id, 
        customer_id, 
        distance 
    FROM customer_orders_temp c
    INNER JOIN runner_orders_temp r
        ON c.order_id = r.order_id
)
SELECT 
    customer_id, 
    ROUND(AVG(distance), 2) AS avg_distance_travelled
FROM cte 
WHERE distance != 0
GROUP BY customer_id;
```

#### 5. **What was the difference between the longest and shortest delivery times for all orders?**
```sql
SELECT 
    MAX(duration) - MIN(duration) AS diff_between_shortest_and_longest_delivery
FROM runner_orders_temp
WHERE duration != 0;
```
#### 6. **What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```sql
SELECT 
    order_id, 
    runner_id, 
    ROUND(AVG(distance * 60 / duration), 2) AS avg_speed_km_per_h
FROM runner_orders_temp
WHERE distance != 0
GROUP BY order_id, runner_id;
```
#### 7. **What is the successful delivery percentage for each runner?**
```sql
WITH cte AS (
    SELECT 
        runner_id,
        COUNT(CASE WHEN distance != 0 THEN 1 END) AS num_successful_orders,
        COUNT(*) AS num_orders
    FROM runner_orders_temp
    GROUP BY runner_id
)
SELECT 
    runner_id,
    ROUND((CAST(num_successful_orders AS FLOAT) * 100) / num_orders, 2) AS percentage_successful_orders
FROM cte;
```


---
## 🔜 Future Updates
- I have uploaded solutions for **Pizza Metrics** and **Runner and Customer Experience** sections, and I will be uploading solutions for **Ingredient Optimization**, **Pricing and Ratings** and bonus sections in the coming weeks.
- Once all solutions are completed, I will share a comprehensive write-up on Medium, explaining my approach and findings.

Stay tuned for updates!

---

## 📣 Acknowledgments
This case study is part of the **8 Week SQL Challenge** by [Danny Ma](https://www.datawithdanny.com/). Special thanks to Danny for creating these enriching SQL challenges.

