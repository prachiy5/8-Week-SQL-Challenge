
--Using a single SQL query - create a new output table which has the following details:

--How many times was each product viewed?
--How many times was each product added to cart?
--How many times was each product added to a cart but not purchased (abandoned)?
--How many times was each product purchased?

WITH cte AS (
    SELECT 
        e.visit_id, 
        e.page_id,
        ph.page_name, 
        ei.event_name,
        ph.product_category,
        ph.product_id,
        e.event_type
    FROM events e
    INNER JOIN event_identifier ei
        ON e.event_type = ei.event_type
    INNER JOIN page_hierarchy ph
        ON ph.page_id = e.page_id
),
purchase_visits AS (
    SELECT DISTINCT visit_id
    FROM cte
    WHERE event_name = 'Purchase'
),
product_views AS (
    SELECT 
        product_id,
        page_name,
        COUNT(*) AS page_views
    FROM cte
    WHERE product_id IS NOT NULL AND event_name = 'Page View'
    GROUP BY product_id, page_name
),
cart_adds AS (
    SELECT 
        product_id,
        page_name,
        COUNT(*) AS cart_adds
    FROM cte
    WHERE event_name = 'Add to Cart'
    GROUP BY product_id, page_name
),
not_purchased_but_add AS (
    SELECT 
        cte.product_id,
        cte.page_name,
        COUNT(*) AS not_purchased_count
    FROM cte
    LEFT JOIN purchase_visits pv
        ON cte.visit_id = pv.visit_id
    WHERE cte.event_name = 'Add to Cart' AND pv.visit_id IS NULL
    GROUP BY cte.product_id, cte.page_name
),
product_purchases AS (
    SELECT 
        cte.product_id,
        cte.page_name,
        COUNT(*) AS product_purchases
    FROM cte
    INNER JOIN purchase_visits pv
        ON cte.visit_id = pv.visit_id
    WHERE cte.event_name = 'Add to Cart'
    GROUP BY cte.product_id, cte.page_name
)
SELECT 
    pv.product_id,
    pv.page_name,
    pv.page_views,
    ca.cart_adds,
    npa.not_purchased_count AS not_purchased_but_add,
    pp.product_purchases
INTO product_summary -- Create and populate the new table
FROM product_views pv
LEFT JOIN cart_adds ca
    ON pv.product_id = ca.product_id
LEFT JOIN not_purchased_but_add npa
    ON pv.product_id = npa.product_id
LEFT JOIN product_purchases pp
    ON pv.product_id = pp.product_id
ORDER BY pv.product_id;

select * from product_summary

--Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

--Use your 2 new output tables - answer the following questions:

--Which product had the most views, cart adds and purchases?
--Which product was most likely to be abandoned?
--Which product had the highest view to purchase percentage?
--What is the average conversion rate from view to cart add?
--What is the average conversion rate from cart add to purchase?


WITH cte AS (
    SELECT 
        e.visit_id, 
        e.page_id,
        ph.page_name, 
        ei.event_name,
        ph.product_category,
        ph.product_id,
        e.event_type
    FROM events e
    INNER JOIN event_identifier ei
        ON e.event_type = ei.event_type
    INNER JOIN page_hierarchy ph
        ON ph.page_id = e.page_id
),
purchase_visits AS (
    SELECT DISTINCT visit_id
    FROM cte
    WHERE event_name = 'Purchase'
),
product_views AS (
    SELECT 
        product_category,
        COUNT(*) AS category_views
    FROM cte
    WHERE product_id IS NOT NULL AND event_name = 'Page View'
    GROUP BY product_category
),
cart_adds AS (
    SELECT 
        product_category,
        COUNT(*) AS category_cart_adds
    FROM cte
    WHERE event_name = 'Add to Cart'
    GROUP BY product_category
),
not_purchased_but_add AS (
    SELECT 
        cte.product_category,
        COUNT(*) AS category_not_purchased_count
    FROM cte
    LEFT JOIN purchase_visits pv
        ON cte.visit_id = pv.visit_id
    WHERE cte.event_name = 'Add to Cart' AND pv.visit_id IS NULL
    GROUP BY cte.product_category
),
product_purchases AS (
    SELECT 
        cte.product_category,
        COUNT(*) AS category_purchases
    FROM cte
    INNER JOIN purchase_visits pv
        ON cte.visit_id = pv.visit_id
    WHERE cte.event_name = 'Add to Cart'
    GROUP BY cte.product_category
)
SELECT 
    pv.product_category,
    pv.category_views,
    ca.category_cart_adds,
    npa.category_not_purchased_count AS category_not_purchased_but_add,
    pp.category_purchases
INTO product_category_summary -- Create a new table
FROM product_views pv
LEFT JOIN cart_adds ca
    ON pv.product_category = ca.product_category
LEFT JOIN not_purchased_but_add npa
    ON pv.product_category = npa.product_category
LEFT JOIN product_purchases pp
    ON pv.product_category = pp.product_category
ORDER BY pv.product_category;


select * from product_category_summary


-------------------------------------------------------


-- Which product had the most views, cart adds, and purchases?
WITH most_views AS (
    SELECT TOP 1 product_id, page_name, page_views
    FROM product_summary
    ORDER BY page_views DESC
),
most_cart_adds AS (
    SELECT TOP 1 product_id, page_name, cart_adds
    FROM product_summary
    ORDER BY cart_adds DESC
),
most_purchases AS (
    SELECT TOP 1 product_id, page_name, product_purchases
    FROM product_summary
    ORDER BY product_purchases DESC
),
most_abandoned AS (
    SELECT TOP 1 product_id, page_name, not_purchased_but_add
    FROM product_summary
    ORDER BY not_purchased_but_add DESC
),
highest_view_to_purchase AS (
    SELECT TOP 1 
        product_id, 
        page_name, 
        CAST(product_purchases AS FLOAT) / NULLIF(page_views, 0) AS view_to_purchase_rate
    FROM product_summary
    ORDER BY view_to_purchase_rate DESC
)
-- Combine all results into one output
SELECT
    'Most Views' AS metric, mv.product_id, mv.page_name, mv.page_views AS value
FROM most_views mv
UNION ALL
SELECT
    'Most Cart Adds', mca.product_id, mca.page_name, mca.cart_adds
FROM most_cart_adds mca
UNION ALL
SELECT
    'Most Purchases', mp.product_id, mp.page_name, mp.product_purchases
FROM most_purchases mp
UNION ALL
SELECT
    'Most Abandoned', ma.product_id, ma.page_name, ma.not_purchased_but_add
FROM most_abandoned ma
UNION ALL
SELECT
    'Highest View to Purchase', hvp.product_id, hvp.page_name, hvp.view_to_purchase_rate
FROM highest_view_to_purchase hvp;

-- What is the average conversion rate from view to cart add and cart add to purchase?
SELECT
    ROUND(AVG(CAST(cart_adds AS FLOAT) / NULLIF(page_views, 0))*100.0,2) AS avg_view_to_cart_rate,
    ROUND(AVG(CAST(product_purchases AS FLOAT) / NULLIF(cart_adds, 0))*100.0,2) AS avg_cart_to_purchase_rate
FROM product_summary;
