--data cleaning

-- Create a cleaned temporary table for customer_orders
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
      WHEN exclusions IS NULL OR exclusions = 'null' THEN ' '
      ELSE exclusions
  END AS exclusions,
  CASE
      WHEN extras IS NULL OR extras = 'null' THEN ' '
      ELSE extras
  END AS extras,
  order_time
INTO customer_orders_temp
FROM customer_orders;

-- Verify the cleaned table
SELECT * FROM customer_orders_temp;



-- Create a cleaned temporary table for runner_orders
SELECT 
  order_id, 
  runner_id,  
  CASE
      WHEN pickup_time IS NULL OR pickup_time = 'null' THEN ' '
      ELSE pickup_time
  END AS pickup_time,
  CASE
      WHEN distance IS NULL OR distance = 'null' THEN ' '
      WHEN distance LIKE '%km' THEN REPLACE(distance, 'km', '')
      ELSE distance
  END AS distance,
  CASE
      WHEN duration IS NULL OR duration = 'null' THEN ' '
      WHEN duration LIKE '%mins' THEN REPLACE(duration, 'mins', '')
      WHEN duration LIKE '%minute' THEN REPLACE(duration, 'minute', '')
      WHEN duration LIKE '%minutes' THEN REPLACE(duration, 'minutes', '')
      ELSE duration
  END AS duration,
  CASE
      WHEN cancellation IS NULL OR cancellation = 'null' THEN ' '
      ELSE cancellation
  END AS cancellation
INTO runner_orders_temp
FROM runner_orders;

-- Alter the data types for the cleaned table
ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time DATETIME;
ALTER TABLE runner_orders_temp
ALTER COLUMN distance FLOAT;
ALTER TABLE runner_orders_temp
ALTER COLUMN duration INT;

-- Verify the cleaned table
SELECT * FROM runner_orders_temp;



-- Create a temporary table to hold the split toppings
CREATE TABLE #split_pizza_recipes (
    pizza_id INT,
    topping_id INT
);

-- Insert split values into the temporary table
INSERT INTO #split_pizza_recipes (pizza_id, topping_id)
SELECT 
    pizza_id, 
    CAST(value AS INT) AS topping_id
FROM pizza_recipes
CROSS APPLY STRING_SPLIT(CAST(toppings AS VARCHAR(MAX)), ',');

-- Verify the temporary table
SELECT * FROM #split_pizza_recipes;


