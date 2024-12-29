# Product Funnel Analysis ☕🛍️

### Overview 🔍

In this analysis, we examine the entire purchase funnel for Clique Bait products: from page views to purchases. We also aggregate these metrics at both product and product category levels to identify performance trends and actionable insights.

---

## Questions Addressed 🖊️

### Using a single SQL query, create a new output table with the following details:

- **How many times was each product viewed?**
- **How many times was each product added to a cart?**
- **How many times was each product added to a cart but not purchased (abandoned)?**
- **How many times was each product purchased?**

### SQL Query:

```sql
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
```

### Output Table: `product_summary`

| product_id | page_name        | page_views | cart_adds | not_purchased_but_add | product_purchases |
|------------|------------------|------------|-----------|-----------------------|-------------------|
| 7          | Lobster          | 1547       | 968       | 214                   | 754               |
| 3          | Tuna             | 1515       | 931       | 234                   | 697               |
| 8          | Crab             | 1564       | 949       | 230                   | 719               |
| 6          | Abalone          | 1525       | 932       | 233                   | 699               |
| 9          | Oyster           | 1568       | 943       | 217                   | 726               |
| 1          | Salmon           | 1559       | 938       | 227                   | 711               |
| 5          | Black Truffle    | 1469       | 924       | 217                   | 707               |
| 4          | Russian Caviar   | 1563       | 946       | 249                   | 697               |
| 2          | Kingfish         | 1559       | 920       | 213                   | 707               |

### Insights:

- **Top Performing Products**:
  - Lobster has the most **purchases** (754), showing strong customer demand.
  - Oyster and Crab follow closely in popularity.
- **Cart Abandonment**:
  - Russian Caviar has the highest abandonment rate (249 times added to cart but not purchased).

---

### Aggregation by Product Category:

### SQL Query:

```sql
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
```

### Output Table: `product_category_summary`

| product_category | category_views | category_cart_adds | category_not_purchased_but_add | category_purchases |
|------------------|----------------|---------------------|--------------------------------|--------------------|
| Fish             | 4633          | 2789               | 674                            | 2115              |
| Shellfish        | 6204          | 3792               | 894                            | 2898              |
| Luxury           | 3032          | 1870               | 466                            | 1404              |

### Insights:

- **Shellfish Leads in Performance**:
  - Shellfish dominates with the highest views (6204), cart adds (3792), and purchases (2898).
- **Luxury Products Have High Abandonment**:
  - Luxury products face notable cart abandonment rates (466).

---

### Conversion Rates:

#### SQL Query:

```sql
SELECT
    ROUND(AVG(CAST(cart_adds AS FLOAT) / NULLIF(page_views, 0))*100.0,2) AS avg_view_to_cart_rate,
    ROUND(AVG(CAST(product_purchases AS FLOAT) / NULLIF(cart_adds, 0))*100.0,2) AS avg_cart_to_purchase_rate
FROM product_summary;
```

### Output:

| avg_view_to_cart_rate | avg_cart_to_purchase_rate |
|-----------------------|---------------------------|
| 60.95                | 75.93                    |

### Insights:

- **Conversion Success**:
  - On average, 60.95% of product views convert to cart additions.
  - 75.93% of cart additions result in purchases, indicating a strong conversion pipeline.

---

