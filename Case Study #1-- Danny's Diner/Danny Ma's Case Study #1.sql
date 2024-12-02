SELECT * FROM members;
SELECT * FROM sales;
SELECT * FROM menu;




-- 1) What is the total amount each customer spent at the restaurant?
SELECT 
    customer_id, 
    SUM(price) AS total_price
FROM sales s
INNER JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_price DESC;



-- 2) How many days has each customer visited the restaurant?
SELECT 
    customer_id, 
    COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;


-- 3) What was the first item from the menu purchased by each customer?
WITH first_purchase_cte AS (
    SELECT 
        customer_id, 
        s.product_id, 
        m.product_name, 
        s.order_date,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS rank
    FROM sales s
    INNER JOIN menu m 
        ON s.product_id = m.product_id
)
SELECT DISTINCT 
    customer_id, 
    product_name, 
    order_date
FROM first_purchase_cte
WHERE rank = 1;


-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 
    m.product_name, 
    COUNT(*) AS purchase_times
FROM sales s
INNER JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_times DESC;


--5) Which item was the most popular for each customer?
WITH popular_item_cte AS (
    SELECT 
        customer_id, 
        product_name, 
        COUNT(s.product_id) AS num_of_prod_ordered,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(s.product_id) DESC) AS rank
    FROM sales s 
    INNER JOIN menu m 
        ON s.product_id = m.product_id
    GROUP BY customer_id, product_name
)
SELECT 
    customer_id, 
    product_name
FROM popular_item_cte
WHERE rank = 1;

-- 6) Which item was purchased first by the customer after they became a member?
WITH first_member_purchase_cte AS (
    SELECT 
        m.customer_id, 
        s.product_id, 
        m.join_date, 
        s.order_date,
        DENSE_RANK() OVER (PARTITION BY m.customer_id ORDER BY order_date ASC) AS rank
    FROM members m 
    INNER JOIN sales s 
        ON m.customer_id = s.customer_id
    WHERE order_date >= join_date
)
SELECT 
    customer_id, 
    product_name, 
    order_date
FROM first_member_purchase_cte c
INNER JOIN menu m 
    ON c.product_id = m.product_id
WHERE rank = 1;

-- 7) Which item was purchased just before the customer became a member?
WITH last_purchase_before_membership_cte AS (
    SELECT DISTINCT 
        m.customer_id, 
        m.join_date, 
        s.order_date, 
        s.product_id, 
        me.product_name,
        DENSE_RANK() OVER (PARTITION BY m.customer_id ORDER BY order_date DESC) AS rank
    FROM members m
    INNER JOIN sales s
        ON m.customer_id = s.customer_id
    INNER JOIN menu me
        ON s.product_id = me.product_id
    WHERE order_date < join_date
)
SELECT 
    customer_id, 
    product_name, 
    order_date
FROM last_purchase_before_membership_cte
WHERE rank = 1;

-- 8) What is the total items and amount spent for each member before they became a member?
WITH purchases_before_membership_cte AS (
    SELECT 
        s.customer_id, 
        join_date, 
        order_date, 
        s.product_id, 
        me.product_name, 
        price
    FROM members m 
    INNER JOIN sales s 
        ON m.customer_id = s.customer_id
    INNER JOIN menu me 
        ON me.product_id = s.product_id
    WHERE order_date < join_date OR join_date IS NULL
)
SELECT 
    customer_id, 
    SUM(price) AS amount_spent, 
    COUNT(product_id) AS total_items
FROM purchases_before_membership_cte
GROUP BY customer_id;

-- 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
    SELECT 
        customer_id,
        CASE 
            WHEN product_name = 'sushi' THEN price * 10 * 2 
            ELSE price * 10 
        END AS points
    FROM sales s 
    INNER JOIN menu m 
        ON s.product_id = m.product_id
)
SELECT 
    customer_id, 
    SUM(points) AS total_points
FROM points_cte
GROUP BY customer_id;

--10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH customer_purchases_cte AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        me.product_name, 
        me.price,
        CASE 
            WHEN s.order_date BETWEEN m.join_date AND DATEADD(DAY, 6, m.join_date) THEN 2 * 10 * price -- First week: 2x points on all items
            WHEN me.product_name = 'sushi' THEN 2 * 10 * price -- Sushi earns 2x points after the first week
            ELSE 1 * 10 * price -- All other items earn 1 point after the first week
        END AS points
    FROM members m
    INNER JOIN sales s
        ON m.customer_id = s.customer_id
    INNER JOIN menu me 
        ON s.product_id = me.product_id
    WHERE s.order_date <= '2021-01-31'
)
SELECT 
    customer_id, 
    SUM(points) AS total_points
FROM customer_purchases_cte
GROUP BY customer_id;

-- BONUS
WITH membership_status_cte AS (
    SELECT 
        s.customer_id,
        s.order_date,
        me.product_name,
        me.price,
        CASE 
            WHEN m.join_date > s.order_date THEN 'N'
            WHEN m.join_date <= s.order_date THEN 'Y'
            ELSE 'N' 
        END AS member_status
    FROM sales s 
    LEFT JOIN members m
        ON s.customer_id = m.customer_id
    INNER JOIN menu me
        ON me.product_id = s.product_id
)
SELECT *,
    CASE 
        WHEN member_status = 'N' THEN NULL
        ELSE RANK() OVER (PARTITION BY customer_id, member_status ORDER BY order_date ASC)
    END AS ranking
FROM membership_status_cte;
