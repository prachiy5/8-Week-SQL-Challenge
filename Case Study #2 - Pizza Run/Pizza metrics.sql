-- PIZZA METRICS 

-- View data in temporary tables
SELECT * 
FROM customer_orders_temp;

SELECT * 
FROM runner_orders_temp;


-- How many pizzas were ordered?
SELECT COUNT(order_id) AS num_of_orders 
FROM customer_orders_temp;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS num_of_orders 
FROM customer_orders_temp;

-- How many successful orders were delivered by each runner?
SELECT 
    runner_id, 
    COUNT(order_id) AS num_of_successful_orders 
FROM runner_orders_temp
WHERE distance != 0
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
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

-- How many Vegetarian and Meatlovers pizzas were ordered by each customer?
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

-- What was the maximum number of pizzas delivered in a single order?
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

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

-- How many pizzas were delivered that had both exclusions and extras?
SELECT 
    COUNT(r.order_id) AS num_pizzas_delivered 
FROM customer_orders_temp c 
INNER JOIN runner_orders_temp r 
    ON c.order_id = r.order_id
WHERE exclusions <> '' AND extras <> '' AND distance != 0;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    DATEPART(HOUR, order_time) AS hour_of_the_day, 
    COUNT(order_id) AS num_of_orders 
FROM customer_orders_temp
GROUP BY DATEPART(HOUR, order_time)
ORDER BY 1;

-- What was the volume of orders for each day of the week?
SELECT 
    FORMAT(DATEADD(DAY, 2, order_time), 'dddd') AS day_of_week, 
    COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY FORMAT(DATEADD(DAY, 2, order_time), 'dddd') 
ORDER BY 
    MIN(DATEADD(DAY, 2, order_time));
