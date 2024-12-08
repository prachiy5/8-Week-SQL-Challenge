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
- [Ingredient Optimization Solutions](#ingredient-optimization-solutions)
- [Pricing and Rating Solutions](#pricing-and-rating-solutions)
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

## 🍕 Ingredient Optimization Solutions

### Overview

The Ingredient Optimization section was one of the most complex and rewarding parts of this case study. It required thorough data cleaning, normalization, and advanced SQL techniques such as Common Table Expressions (CTEs) and dynamic string aggregation. This section focuses on optimizing pizza ingredients by handling extras and exclusions, normalizing data, and generating dynamic insights.

### Key Challenges Solved

#### 1. Data Normalization
- Initially, the `extras` and `exclusions` columns contained comma-separated values.
- These columns were normalized into separate rows in the `Cleaned_Customer_Orders` table for better usability and query efficiency.

#### 2. Dynamic Ingredient Descriptions
- Created order items dynamically, such as:
  - Meat Lovers
  - Meat Lovers - Exclude Cheese
  - Meat Lovers - Extra Bacon
  - Vegetarian: 2x Bacon, Cheese

#### 3. Ingredient Frequencies
- Calculated the total usage of each ingredient across all delivered pizzas, accounting for extras and excluding ingredients listed in exclusions.

#### 4. Dynamic String Formatting
- Generated ingredient lists dynamically, prefixing repeated ingredients with quantities like `2x Bacon`.

### Data Cleaning Highlights
Proper normalization was crucial for these queries. Initially, the data in `extras` and `exclusions` was not clean or normalized. The normalized tables (`Cleaned_Customer_Orders` and `#split_pizza_recipes`) were essential for simplifying complex queries. If you’re working on similar challenges, ensure you’ve cleaned and normalized your data upfront.

### Concepts Applied
- **CTEs (Common Table Expressions):** Modularized the queries for better readability and reusability.
- **STRING_AGG:** Used to generate dynamic, comma-separated ingredient lists.
- **CASE Statements:** Handled conditional logic for marking extras and excluding ingredients dynamically.

### 📝 Notes for Solvers

#### Understand CTEs:
- This section heavily uses **CTEs (Common Table Expressions)** for clarity and modularity. If you’re unfamiliar with them, take the time to learn as they simplify complex query logic significantly.

#### Normalize Your Data First:
- **Normalized tables** make querying much easier. For example:
  - The `extras` and `exclusions` columns were transformed from `1,2,3` into individual rows for better usability.

#### Dynamic Querying:
- The queries here rely on **string functions** like `STRING_AGG` to dynamically generate outputs such as:
  - `Meat Lovers - Exclude Cheese - Extra Bacon, Mushrooms`.

#### Complex Aggregations:
- Combining base quantities with extras while excluding specific ingredients requires careful **query structuring**.

  
## 📂 Solution File
The solutions for Ingredient Optimization have been added to the existing file that contains answers to other sections of the challenge. Since the queries for this section are lengthy, I’ve chosen not to repeat them here. You can find the full solutions in the uploaded file.

### 📈 Pricing and Ratings

This section dives into questions related to **pricing**, **extras**, and a **new ratings system** for Pizza Runner. These queries involved advanced SQL techniques, including the use of `CASE` statements, data normalization, and aggregations.

---

#### 1. How much money has Pizza Runner made so far if there are no delivery fees?

**Scenario**:  
If a Meat Lovers pizza costs $12 and Vegetarian costs $10 with no extra charges or delivery fees, calculate the total revenue Pizza Runner has generated.

**Key Challenges**:
- Accounting for the fixed prices of different pizzas.
- Excluding orders with no delivery (`distance = 0`).

**Solution**:
The solution uses a `CASE` statement to dynamically assign prices based on `pizza_id` and filters only successful deliveries.
```sql
WITH cte AS(SELECT pizza_id,
case when pizza_id=1 THEN 12  ELSE 10 END
AS price
FROM customer_orders_temp c 
INNER JOIN runner_orders_temp r
ON r.order_id=c.order_id
WHERE r.distance!=0)

SELECT SUM(price) AS TOTAL_EARNED
FROM cte
```
---

#### 2. What if there was an additional $1 charge for any pizza extras?

**Scenario**:  
In addition to the base price, customers are charged $1 for each extra topping (e.g., adding Cheese or Bacon). Calculate the total revenue, including the additional charges for extras.

**Key Challenges**:
- Normalized `extras` column: Extras like "1, 4" need to be split and processed individually.
- Adding dynamic pricing for extras to the base pizza price.

**Solution**:
The query uses:
- `STRING_SPLIT()` to handle the normalized `extras` column.
- A `CASE` statement to calculate charges dynamically based on the number of extras.
- Aggregation to compute the total revenue per order, including extras.

```sql
WITH cte_base AS (
    SELECT 
        r.order_id,
        c.pizza_id,
        c.extras,
        CASE 
            WHEN c.pizza_id = 1 THEN 12 -- Meat Lovers price
            ELSE 10 -- Vegetarian price
        END AS base_price
    FROM customer_orders_temp c
    INNER JOIN runner_orders_temp r
        ON c.order_id = r.order_id
    WHERE r.distance != 0 -- Only include delivered pizzas
),
cte_extras AS (
    SELECT 
        order_id,
        pizza_id,
        base_price,
        extras,
        CASE 
            WHEN extras IS NOT NULL AND extras != '' THEN 
                (SELECT COUNT(value) -- Count the number of extras
                 FROM STRING_SPLIT(extras, ','))
            ELSE 0 -- No extras
        END AS extra_count
    FROM cte_base
),
cte_total AS (
    SELECT 
        order_id,
        pizza_id,
        base_price,
        extras,
        extra_count,
        base_price + extra_count AS total_price -- Add extra charges only if extras exist
    FROM cte_extras
)
SELECT 
    sum(total_price) as total_price
FROM cte_total
```

---

#### 3. How would you design an additional table for a ratings system?

**Scenario**:  
Pizza Runner wants to introduce a ratings system where customers can rate their runners (1 to 5) for each successful delivery. Design a schema for the ratings table and populate it with sample data.

**Schema Design**:
The new table `runner_ratings` includes:
- `rating_id`: A unique identifier for each rating.
- `order_id`: A foreign key referencing the successful orders.
- `runner_id`: A foreign key referencing the runner who completed the delivery.
- `rating`: A numeric column for ratings between 1 to 5.
- `created_at`: A timestamp for when the rating was added.

**Challenges Addressed**:
- Ensuring `order_id` and `runner_id` exist in their respective tables.
- Avoiding duplicate ratings for the same order.

```sql
CREATE TABLE runner_ratings (
    rating_id INT IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for each rating
    order_id INT NOT NULL, -- Reference to the order
    runner_id INT NOT NULL, -- Reference to the runner
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- Rating between 1 and 5
    feedback NVARCHAR(MAX), -- Optional customer feedback
    rating_date DATETIME DEFAULT GETDATE(), -- Timestamp of the rating
    FOREIGN KEY (order_id, runner_id) REFERENCES runner_orders_temp(order_id, runner_id) -- Ensure the order and runner exist
);

SELECT * FROM runner_orders_temp
WHERE order_id IS NULL OR runner_id IS NULL;

-- Insert sample ratings for each successful order
INSERT INTO runner_ratings (order_id, runner_id, rating, feedback)
VALUES 
    (1, 1, 5, 'Great service!'),
    (2, 1, 4, 'On time but could be friendlier.'),
    (3, 1, 5, 'Perfect delivery!'),
    (4, 2, 3, 'Late by a few minutes.'),
    (5, 3, 5, 'Very professional and quick!'),
    (7, 2, 4, 'Good service overall.'),
    (8, 2, 5, 'Highly satisfied!'),
    (10, 1, 4, 'Quick delivery but forgot napkins.');
```
---

#### 4. Join all the information together for successful deliveries

**Scenario**:  
Combine data to create a table with the following information for successful deliveries:
- `customer_id`
- `order_id`
- `runner_id`
- `rating`
- `order_time`
- `pickup_time`
- `Time between order and pickup`
- `Delivery duration`
- `Average speed`
- `Total number of pizzas`

**Key Challenges**:
- Calculating time differences (`DATEDIFF`) and average speed (`distance / duration`).
- Ensuring data integrity with proper joins across multiple tables.
- Aggregating total pizzas for each order.

**Solution**:
The final query joins:
- `runner_orders_temp` for runner details.
- `customer_orders_temp` for customer and order details.
- `runner_ratings` for ratings data.
Calculations are performed for time intervals, total pizzas, and average speed.

```sql
WITH successful_deliveries AS (
    SELECT 
        cco.customer_id,
        r.order_id,
        r.runner_id,
        r.pickup_time,
        r.distance,
        r.duration,
        cco.order_time,
        DATEDIFF(MINUTE, cco.order_time, r.pickup_time) AS time_between_order_and_pickup,
        ROUND((r.distance / NULLIF(r.duration, 0)) * 60, 2) AS average_speed -- Average speed in km/h
    FROM customer_orders_temp cco
    INNER JOIN runner_orders_temp r 
        ON cco.order_id = r.order_id
    WHERE r.distance !=0  -- Include only successful deliveries
),
pizza_count AS (
    SELECT 
        order_id,
        COUNT(pizza_id) AS total_pizzas
    FROM customer_orders_temp
    GROUP BY order_id
)
SELECT 
    sd.customer_id,
    sd.order_id,
    sd.runner_id,
    rr.rating,
    sd.order_time,
    sd.pickup_time,
    sd.time_between_order_and_pickup,
    sd.duration AS delivery_duration,
    sd.average_speed,
    pc.total_pizzas
FROM successful_deliveries sd
LEFT JOIN runner_ratings rr 
    ON sd.order_id = rr.order_id AND sd.runner_id = rr.runner_id
LEFT JOIN pizza_count pc 
    ON sd.order_id = pc.order_id
ORDER BY sd.order_id;
```
---

#### 5. How much money does Pizza Runner have left after paying the runners?

**Scenario**:  
Each runner is paid $0.30 per kilometer traveled. Calculate how much money Pizza Runner has left after paying runners.

**Key Challenges**:
- Accounting for multiple pizzas in a single order while ensuring the runner’s travel distance is counted only once.
- Deduplicating distance calculations to avoid overpaying for the same order.

**Solution**:
The query ensures:
- Runner costs are calculated based on unique `order_id` and `distance`.
- Revenue is calculated for all pizzas, excluding unsuccessful deliveries.
- The difference between revenue and runner costs gives the final amount left for Pizza Runner.
```sql

WITH cte AS (
    SELECT 
        r.order_id,
        r.runner_id,
        r.distance,
        r.distance * 0.30 AS runner_earned -- Runner earnings per order
    FROM runner_orders_temp r
    WHERE r.distance != 0 -- Only successful deliveries
),
pizza_cte AS (
    SELECT 
        c.order_id,
        c.pizza_id,
        CASE 
            WHEN c.pizza_id = 1 THEN 12
            ELSE 10
        END AS pizza_price
    FROM customer_orders_temp c
),
aggregated_cte AS (
    SELECT 
        cte.order_id,
        SUM(pizza_cte.pizza_price) AS total_pizza_price, 
        cte.runner_earned
    FROM cte
    INNER JOIN pizza_cte
        ON cte.order_id = pizza_cte.order_id
    GROUP BY cte.order_id, cte.runner_earned -- Group by order_id to ensure distances are counted only once
)
SELECT 
    SUM(total_pizza_price) AS total_revenue,
    SUM(runner_earned) AS total_runner_costs,
    (SUM(total_pizza_price) - SUM(runner_earned)) AS amount_left
FROM aggregated_cte;


```
---

#### Insights Gained:
-These questions heavily relied on `CASE` statements for dynamic calculations, especially for pricing and extras.
-  Joining multiple tables and handling normalized data ensured accurate results.
-  Challenges like calculating costs and revenues, deduplicating distances, and introducing a ratings system reflect real-world SQL problems.

The **Pricing and Ratings** section has been uploaded with the solutions for all questions. Check the SQL files for the complete queries and outputs.


---
## 🔜 Future Updates
- I have uploaded solutions for **Pizza Metrics**, **Runner and Customer Experience**, **Ingredient Optimization** and **Pricing and Ratings** sections.
-  I will share a comprehensive write-up on Medium soon, explaining my approach and findings.

Stay tuned for updates!

---

## 📣 Acknowledgments
This case study is part of the **8 Week SQL Challenge** by [Danny Ma](https://www.datawithdanny.com/). Special thanks to Danny for creating these enriching SQL challenges.

