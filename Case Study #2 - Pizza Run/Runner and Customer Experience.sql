--B. Runner and Customer Experience

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)


SELECT 
    (DATEDIFF(DAY, '2021-01-01', registration_date) / 7) + 1 AS week_number, -- Calculate the week number
    DATEADD(DAY, -DATEDIFF(DAY, '2021-01-01', registration_date) % 7, registration_date) AS week_start_date, -- Calculate the start of the week
    COUNT(*) AS runners_signed_up
FROM runners
GROUP BY 
    (DATEDIFF(DAY, '2021-01-01', registration_date) / 7) + 1, -- Group by week number
    DATEADD(DAY, -DATEDIFF(DAY, '2021-01-01', registration_date) % 7, registration_date) -- Group by week start date
ORDER BY week_start_date;



--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?


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


--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?



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


--4. What was the average distance travelled for each customer?


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


--5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(duration) - MIN(duration) AS diff_between_shortest_and_longest_delivery
FROM runner_orders_temp
WHERE duration != 0;

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    order_id, 
    runner_id, 
    ROUND(AVG(distance * 60 / duration), 2) AS avg_speed_km_per_h
FROM runner_orders_temp
WHERE distance != 0
GROUP BY order_id, runner_id;

--What is the successful delivery percentage for each runner?

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
