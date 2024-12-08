--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes -
--how much money has Pizza Runner made so far if there are no delivery fees?


WITH cte AS(SELECT pizza_id,
case when pizza_id=1 THEN 12  ELSE 10 END
AS price
FROM customer_orders_temp c 
INNER JOIN runner_orders_temp r
ON r.order_id=c.order_id
WHERE r.distance!=0)

SELECT SUM(price) AS TOTAL_EARNED
FROM cte


--What if there was an additional 1 charge for any pizza extras? (Add cheese is 1 extra)
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


--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
--how would you design an additional table for this new dataset
--generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.


SELECT COLUMN_NAME, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'runner_orders_temp' AND COLUMN_NAME IN ('order_id', 'runner_id');

ALTER TABLE runner_orders_temp
ALTER COLUMN order_id INT NOT NULL;

ALTER TABLE runner_orders_temp
ALTER COLUMN runner_id INT NOT NULL;

ALTER TABLE runner_orders_temp
ADD CONSTRAINT PK_runner_orders_temp PRIMARY KEY (order_id, runner_id);



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

select * from runner_ratings

-----

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


--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and 
--each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
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
