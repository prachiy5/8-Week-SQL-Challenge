# Digital Analysis 📊

In this section, we analyze the **Clique Bait** dataset to extract insights about user behavior, event trends, and product performance.
---

## How many users are there? 👤

```sql
SELECT COUNT(DISTINCT user_id) AS count_users
FROM users;
```

**Output:**

| count_users |
|-------------|
| 500         |

**Insight:**
Clique Bait has a total of 500 unique users, forming the core of its customer base.

---

## How many cookies does each user have on average? 🍪

```sql
WITH cte AS (
  SELECT user_id, COUNT(cookie_id) AS num_cookies_per_user
  FROM users
  GROUP BY user_id
)
SELECT ROUND(AVG(num_cookies_per_user), 2) AS avg_cookies
FROM cte;
```

**Output:**

| avg_cookies |
|-------------|
| 3           |

**Insight:**
On average, each user has 3 cookies, indicating repeat visits or multiple devices being used.

---

## What is the unique number of visits by all users per month? 📅

```sql
SELECT DATEPART(month, event_time) AS month_number,
       DATENAME(month, event_time) AS month,
       COUNT(DISTINCT visit_id) AS unique_visits
FROM events
GROUP BY DATEPART(month, event_time), DATENAME(month, event_time)
ORDER BY month_number;
```

**Output:**

| month_number | month      | unique_visits |
|--------------|------------|---------------|
| 1            | January    | 876           |
| 2            | February   | 1488          |
| 3            | March      | 916           |
| 4            | April      | 248           |
| 5            | May        | 36            |

**Insight:**
February sees the highest user activity, likely due to successful campaigns during that period.

---

## What is the number of events for each event type? 🔖

```sql
SELECT event_type, COUNT(*) AS event_count
FROM events
GROUP BY event_type;
```

**Output:**

| event_type | event_count |
|------------|-------------|
| 3          | 1777        |
| 1          | 20928       |
| 4          | 876         |
| 5          | 702         |
| 2          | 8451        |

**Insight:**
"Page View" events dominate the data, while "Purchase" events are less frequent, indicating a potential drop-off in the user funnel.

---

## What is the percentage of visits which have a purchase event? 🛒

```sql
SELECT 
  CAST(ROUND(COUNT(DISTINCT CASE WHEN ei.event_name = 'Purchase' THEN e.visit_id END) * 1.0 /
  COUNT(DISTINCT e.visit_id) * 100, 2) AS DECIMAL(5, 2)) AS purchase_percentage
FROM events e
INNER JOIN event_identifier ei
  ON e.event_type = ei.event_type;
```

**Output:**

| purchase_percentage |
|----------------------|
| 49.86               |

**Insight:**
Approximately half of all visits result in a purchase, showing strong conversion rates.

---

## What is the percentage of visits which view the checkout page but do not have a purchase event? 💳

```sql
WITH abc AS (
    SELECT DISTINCT visit_id,
        MAX(CASE WHEN event_name != 'Purchase' AND page_id = 12 THEN 1 ELSE 0 END) AS checkouts,
        MAX(CASE WHEN event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchases
    FROM events e
    JOIN event_identifier ei ON e.event_type = ei.event_type
    GROUP BY visit_id
)
SELECT 
    CAST(ROUND(SUM(checkouts - purchases) * 100.0 / SUM(checkouts), 2) AS DECIMAL(5, 2)) AS percentage_checkout_no_purchase
FROM abc;
```

**Output:**

| percentage_checkout_no_purchase |
|---------------------------------|
| 15.50                           |

**Insight:**
15.5% of visits that reach the checkout page do not result in a purchase, indicating room for improvement in the final stages of the funnel.

---

## What are the top 3 pages by number of views? 📄

```sql
WITH cte AS (
    SELECT e.visit_id, e.page_id, ph.page_name, ei.event_name
    FROM events e
    INNER JOIN event_identifier ei ON e.event_type = ei.event_type
    INNER JOIN page_hierarchy ph ON ph.page_id = e.page_id
    WHERE event_name = 'Page View'
),
cte2 AS (
    SELECT page_name, COUNT(*) AS number_views
    FROM cte
    GROUP BY page_name
),
cte3 AS (
    SELECT page_name, number_views,
           DENSE_RANK() OVER (ORDER BY number_views DESC) AS rn
    FROM cte2
)
SELECT page_name, number_views 
FROM cte3
WHERE rn <= 3;
```

**Output:**

| page_name     | number_views |
|---------------|--------------|
| All Products  | 3174         |
| Checkout      | 2103         |
| Home Page     | 1782         |

**Insight:**
The "All Products" page is the most viewed, suggesting it plays a critical role in user browsing behavior.

---

## What is the number of views and cart adds for each product category? 📦

```sql
WITH cte AS (
    SELECT e.visit_id, e.page_id, ph.page_name, ei.event_name, product_category
    FROM events e
    INNER JOIN event_identifier ei ON e.event_type = ei.event_type
    INNER JOIN page_hierarchy ph ON ph.page_id = e.page_id
)
SELECT product_category, 
       SUM(CASE WHEN event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
       SUM(CASE WHEN event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds
FROM cte
WHERE product_category IS NOT NULL
GROUP BY product_category
ORDER BY page_views DESC, cart_adds DESC;
```

**Output:**

| product_category | page_views | cart_adds |
|------------------|------------|-----------|
| Shellfish        | 6204       | 3792      |
| Fish             | 4633       | 2789      |
| Luxury           | 3032       | 1870      |

**Insight:**
Shellfish dominates in both views and cart additions, indicating its popularity among users.

---

## What are the top 3 products by purchases? 🛍️

```sql
WITH cte AS (
    SELECT e.visit_id, e.page_id, ph.page_name, ei.event_name, product_category, product_id, e.event_type
    FROM events e
    INNER JOIN event_identifier ei ON e.event_type = ei.event_type
    INNER JOIN page_hierarchy ph ON ph.page_id = e.page_id
),
purchase_events AS (
    SELECT DISTINCT visit_id FROM cte
    WHERE event_name = 'Purchase'
),
cart_add AS (
    SELECT DISTINCT visit_id, product_id, page_name FROM cte
    WHERE event_name = 'Add to Cart'
)
SELECT TOP 3 page_name, COUNT(visit_id) AS number_of_purchase
FROM cart_add
WHERE visit_id IN (SELECT visit_id FROM purchase_events)
GROUP BY page_name
ORDER BY number_of_purchase DESC;
```

**Output:**

| page_name | number_of_purchase |
|-----------|---------------------|
| Lobster   | 754                 |
| Oyster    | 726                 |
| Crab      | 719                 |

**Insight:**
Lobster is the best-selling product, followed by Oyster and Crab, making Shellfish the most popular product category.

---

