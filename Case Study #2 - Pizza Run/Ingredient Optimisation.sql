
--normalizing pizza_recipes table
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

--What are the standard ingredients for each pizza?


WITH cte AS (
    SELECT 
        pizza_id,
        pr.topping_id,
        CAST(topping_name AS VARCHAR(MAX)) AS topping_name
    FROM #split_pizza_recipes pr 
    INNER JOIN pizza_toppings pt
        ON pr.topping_id = pt.topping_id
),

cte2 AS (SELECT 
    pizza_id, 
    STRING_AGG(topping_name, ', ') AS toppings
FROM cte 
GROUP BY pizza_id)

SELECT pizza_name,toppings FROM cte2 c
inner join pizza_names p
on c.pizza_id=p.pizza_id


--NORMALIZING customer_orders_temp for extras and excludes column

SELECT * FROM customer_orders_temp

CREATE TABLE Cleaned_Customer_Orders (
    order_id INT,
    customer_id INT,
    pizza_id INT,
    exclusion NVARCHAR(50),
    extra NVARCHAR(50),
    order_time DATETIME
);

-- Step 2: Normalize the exclusions column
WITH Exclusions AS (
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        LTRIM(RTRIM(value)) AS exclusion,
        NULL AS extra,
        order_time
    FROM customer_orders_temp
    CROSS APPLY STRING_SPLIT(exclusions, ',')
    WHERE exclusions IS NOT NULL AND exclusions != ''
    UNION ALL
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        NULL AS exclusion,
        NULL AS extra,
        order_time
    FROM customer_orders_temp
    WHERE exclusions IS NULL OR exclusions = ''
),

-- Step 3: Normalize the extras column
Extras AS (
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        NULL AS exclusion,
        LTRIM(RTRIM(value)) AS extra,
        order_time
    FROM customer_orders_temp
    CROSS APPLY STRING_SPLIT(extras, ',')
    WHERE extras IS NOT NULL AND extras != ''
    UNION ALL
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        NULL AS exclusion,
        NULL AS extra,
        order_time
    FROM customer_orders_temp
    WHERE extras IS NULL OR extras = ''
)

-- Step 4: Combine Exclusions and Extras
INSERT INTO Cleaned_Customer_Orders
SELECT
    e.order_id,
    e.customer_id,
    e.pizza_id,
    e.exclusion,
    ex.extra,
    e.order_time
FROM Exclusions e
LEFT JOIN Extras ex
ON e.order_id = ex.order_id AND e.customer_id = ex.customer_id AND e.pizza_id = ex.pizza_id;

select * from Cleaned_Customer_Orders
select * from pizza_toppings


--What was the most commonly added extra?

SELECT 
    CAST(pt.topping_name AS NVARCHAR(MAX)) AS extra_topping, -- Convert topping_name to NVARCHAR
    COUNT(co.extra) AS occurrence_count
FROM cleaned_customer_orders co
INNER JOIN pizza_toppings pt
    ON CAST(co.extra AS INT) = pt.topping_id -- Match the extra with the topping ID
GROUP BY CAST(pt.topping_name AS NVARCHAR(MAX)) -- Group by the converted topping_name
ORDER BY occurrence_count DESC;

--What was the most common exclusion?
SELECT 
    CAST(pt.topping_name AS NVARCHAR(MAX)) AS exclusion_topping, -- Convert topping_name to NVARCHAR
    COUNT(co.exclusion) AS occurrence_count
FROM cleaned_customer_orders co
INNER JOIN pizza_toppings pt
    ON CAST(co.exclusion AS INT) = pt.topping_id -- Match the extra with the topping ID
GROUP BY CAST(pt.topping_name AS NVARCHAR(MAX)) -- Group by the converted topping_name
ORDER BY occurrence_count DESC;

--CLEANING DATA

-- Check data types for Cleaned_Customer_Orders
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Cleaned_Customer_Orders';

-- Check data types for pizza_names
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_names';

-- Check data types for #split_pizza_recipes
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM tempdb.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE '#split_pizza_recipes%'; -- Use LIKE because temporary tables have unique identifiers

-- Check data types for pizza_toppings
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_toppings';

ALTER TABLE pizza_names
ALTER COLUMN pizza_name NVARCHAR(MAX);

----Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH cte AS (
    SELECT 
        c.order_id,
        c.customer_id,
        pn.pizza_id,
        pn.pizza_name,
        pt.topping_id,
        pt.topping_name,
        c.extra,
        c.exclusion
    FROM Cleaned_Customer_Orders c
    INNER JOIN pizza_names pn 
        ON c.pizza_id = pn.pizza_id
    INNER JOIN #split_pizza_recipes pr 
        ON c.pizza_id = pr.pizza_id
    INNER JOIN pizza_toppings pt 
        ON pt.topping_id = pr.topping_id
),
distinct_exclusions AS (
    SELECT DISTINCT
        order_id,
        topping_name
    FROM cte
    WHERE exclusion = topping_id -- Match normalized exclusion data
),
distinct_extras AS (
    SELECT DISTINCT
        order_id,
        topping_name
    FROM cte
    WHERE extra = topping_id -- Match normalized extra data
),
exclusion_items AS (
    SELECT 
        order_id,
        STRING_AGG(topping_name, ', ') AS excluded_toppings
    FROM distinct_exclusions
    GROUP BY order_id
),
extra_items AS (
    SELECT 
        order_id,
        STRING_AGG(topping_name, ', ') AS extra_toppings
    FROM distinct_extras
    GROUP BY order_id
),
final_output AS (
    SELECT 
        cte.order_id,
        cte.pizza_name,
        COALESCE(exclusion_items.excluded_toppings, '') AS excluded,
        COALESCE(extra_items.extra_toppings, '') AS extras,
        CASE 
            WHEN exclusion_items.excluded_toppings IS NOT NULL AND extra_items.extra_toppings IS NOT NULL THEN 
                CONCAT(cte.pizza_name, ' - Exclude ', exclusion_items.excluded_toppings, ' - Extra ', extra_items.extra_toppings)
            WHEN exclusion_items.excluded_toppings IS NOT NULL THEN 
                CONCAT(cte.pizza_name, ' - Exclude ', exclusion_items.excluded_toppings)
            WHEN extra_items.extra_toppings IS NOT NULL THEN 
                CONCAT(cte.pizza_name, ' - Extra ', extra_items.extra_toppings)
            ELSE cte.pizza_name
        END AS order_item
    FROM cte
    LEFT JOIN exclusion_items 
        ON cte.order_id = exclusion_items.order_id
    LEFT JOIN extra_items 
        ON cte.order_id = extra_items.order_id
)
SELECT DISTINCT order_id, order_item
FROM final_output
ORDER BY order_id;


---------------
--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
--and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

WITH cte_base AS (
    SELECT 
        c.order_id,
        pn.pizza_name,
        pt.topping_name,
        CASE 
            WHEN c.extra = pt.topping_id THEN 1 -- Mark as extra
            ELSE 0 -- Not an extra
        END AS is_extra,
        CASE 
            WHEN c.exclusion = pt.topping_id THEN 1 -- Mark as excluded
            ELSE 0 -- Not excluded
        END AS is_excluded
    FROM Cleaned_Customer_Orders c
    INNER JOIN pizza_names pn 
        ON c.pizza_id = pn.pizza_id
    INNER JOIN #split_pizza_recipes pr 
        ON c.pizza_id = pr.pizza_id
    INNER JOIN pizza_toppings pt 
        ON pr.topping_id = pt.topping_id
),
cte_filtered AS (
    SELECT 
        order_id,
        pizza_name,
        topping_name,
        is_extra
    FROM cte_base
    WHERE is_excluded = 0 -- Exclude items marked as excluded
),
cte_counted AS (
    SELECT 
        order_id,
        pizza_name,
        topping_name,
        COUNT(*) + SUM(is_extra) AS total_count -- Count base and extras
    FROM cte_filtered
    GROUP BY order_id, pizza_name, topping_name
),
cte_formatted AS (
    SELECT 
        order_id,
        pizza_name,
        CASE 
            WHEN total_count > 1 THEN CONCAT(total_count, 'x ', topping_name) -- Add "2x", "3x", etc.
            ELSE topping_name
        END AS formatted_topping
    FROM cte_counted
),
cte_aggregated AS (
    SELECT 
        order_id,
        pizza_name,
        STRING_AGG(formatted_topping, ', ') WITHIN GROUP (ORDER BY formatted_topping) AS ingredient_list
    FROM cte_formatted
    GROUP BY order_id, pizza_name
)
SELECT 
    order_id,
    CONCAT(pizza_name, ': ', ingredient_list) AS order_item
FROM cte_aggregated
ORDER BY order_id;


----What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?


WITH cte AS (
    SELECT 
        c.order_id,
        c.customer_id,
        pn.pizza_id,
        pn.pizza_name,
        pt.topping_id,
        pt.topping_name,
        c.extra,
        c.exclusion
    FROM Cleaned_Customer_Orders c
    INNER JOIN pizza_names pn 
        ON c.pizza_id = pn.pizza_id
    INNER JOIN #split_pizza_recipes pr 
        ON c.pizza_id = pr.pizza_id
    INNER JOIN pizza_toppings pt 
        ON pt.topping_id = pr.topping_id
    INNER JOIN runner_orders_temp r 
        ON c.order_id = r.order_id
    WHERE r.distance != 0 -- Only include delivered pizzas
),
Valid_Toppings AS (
    SELECT 
        cte.order_id,
        cte.topping_name
    FROM cte
    WHERE cte.topping_id NOT IN (
        SELECT exclusion
        FROM cte
        WHERE exclusion IS NOT NULL
    ) -- Exclude toppings explicitly excluded
),
Extra_Toppings AS (
    SELECT 
        pt.topping_name,
        COUNT(*) AS extra_quantity
    FROM Cleaned_Customer_Orders c
    INNER JOIN pizza_toppings pt 
        ON c.extra = pt.topping_id -- Direct join with normalized extra toppings
    WHERE c.extra IS NOT NULL
    GROUP BY pt.topping_name
),
Base_Toppings AS (
    SELECT 
        topping_name,
        COUNT(*) AS base_quantity
    FROM Valid_Toppings
    GROUP BY topping_name
),
Combined_Toppings AS (
    SELECT 
        topping_name,
        SUM(base_quantity) AS total_base_quantity,
        SUM(extra_quantity) AS total_extra_quantity
    FROM (
        SELECT topping_name, base_quantity, 0 AS extra_quantity FROM Base_Toppings
        UNION ALL
        SELECT topping_name, 0 AS base_quantity, extra_quantity FROM Extra_Toppings
    ) All_Toppings
    GROUP BY topping_name
)
SELECT 
    topping_name,
    SUM(total_base_quantity + total_extra_quantity) AS total_quantity
FROM Combined_Toppings
GROUP BY topping_name
ORDER BY total_quantity DESC;
