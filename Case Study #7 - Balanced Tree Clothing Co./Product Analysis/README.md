# Product Analysis 🍔✅

In this section, we explore product-level performance across various dimensions, including revenue, quantity, discounts, and customer preferences. These insights help identify top-performing products and segments, aiding strategic decision-making.

---

## 1. What are the top 3 products by total revenue before discount?
### Query:
```sql
WITH cte AS (
    SELECT product_id, qty, p.price, product_name
    FROM sales s
    INNER JOIN product_details p
    ON s.prod_id = p.product_id
),
cte2 AS (
    SELECT product_id, product_name, SUM(qty * price) AS revenue,
           DENSE_RANK() OVER (ORDER BY SUM(qty * price) DESC) AS rn
    FROM cte 
    GROUP BY product_id, product_name
)
SELECT product_id, product_name, revenue 
FROM cte2
WHERE rn <= 3;
```
### Answer:
| Product ID | Product Name                 | Revenue ($) |
|------------|------------------------------|-------------|
| 2a2353     | Blue Polo Shirt - Mens       | 217,683     |
| 9ec847     | Grey Fashion Jacket - Womens | 209,304     |
| 5d267b     | White Tee Shirt - Mens       | 152,000     |

### Insight:
The **Blue Polo Shirt - Mens** emerged as the top revenue generator, contributing over **$217K**. The **Grey Fashion Jacket - Womens** and **White Tee Shirt - Mens** also performed exceptionally well, highlighting their popularity.

---

## 2. What is the total quantity, revenue, and discount for each segment?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, s.discount, p.segment_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
)
SELECT segment_name, 
       SUM(qty) AS total_quantity, 
       SUM(qty * price) AS total_revenue,
       CAST(ROUND(SUM(qty * price * CAST(discount AS NUMERIC) / 100), 2) AS DECIMAL(10, 2)) AS total_discount
FROM cte
GROUP BY segment_name;
```
### Answer:
| Segment Name | Total Quantity | Total Revenue ($) | Total Discount ($) |
|--------------|----------------|--------------------|---------------------|
| Socks        | 11,217         | 307,977           | 37,013.44          |
| Jacket       | 11,385         | 366,983           | 44,277.46          |
| Shirt        | 11,265         | 406,143           | 49,594.27          |
| Jeans        | 11,349         | 208,350           | 25,343.97          |

### Insight:
The **Shirt segment** led in both revenue (**$406K**) and discounts (**$49K**), reflecting its significant contribution to overall sales. 

---

## 3. What is the top-selling product for each segment?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, s.discount, p.segment_name, product_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
),
cte2 AS (
    SELECT segment_name, product_name,
           SUM(qty) AS total_quantity,
           SUM(qty * price) AS total_revenue,
           DENSE_RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty) DESC) AS rn
    FROM cte
    GROUP BY segment_name, product_name
)
SELECT segment_name, product_name, total_revenue 
FROM cte2
WHERE rn = 1;
```
### Answer:
| Segment Name | Product Name                 | Total Revenue ($) |
|--------------|------------------------------|--------------------|
| Jacket       | Grey Fashion Jacket - Womens | 209,304           |
| Jeans        | Navy Oversized Jeans - Womens| 50,128            |
| Shirt        | Blue Polo Shirt - Mens       | 217,683           |
| Socks        | Navy Solid Socks - Mens      | 136,512           |

### Insight:
The **Grey Fashion Jacket - Womens** and **Blue Polo Shirt - Mens** dominate their respective segments, showcasing customer preferences for premium and popular designs.

---

## 4. What is the total quantity, revenue, and discount for each category?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, s.discount, p.segment_name, p.category_id, p.category_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
)
SELECT category_id, category_name, 
       SUM(qty) AS total_quantity, 
       SUM(qty * price) AS total_revenue,
       CAST(ROUND(SUM(qty * price * CAST(discount AS NUMERIC) / 100), 2) AS DECIMAL(10, 2)) AS total_discount
FROM cte
GROUP BY category_id, category_name;
```
### Answer:
| Category ID | Category Name | Total Quantity | Total Revenue ($) | Total Discount ($) |
|-------------|---------------|----------------|--------------------|---------------------|
| 2           | Mens          | 22,482         | 714,120           | 86,607.71          |
| 1           | Womens        | 22,734         | 575,333           | 69,621.43          |

### Insight:
**Mens category** leads in total revenue with **$714K**, while **Womens category** maintains competitive sales volume and discounts, reflecting its popularity.

---

## 5. What is the top-selling product for each category?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, s.discount, p.category_id, category_name, product_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
),
cte2 AS (
    SELECT category_name, product_name,
           SUM(qty) AS total_quantity,
           SUM(qty * price) AS total_revenue,
           DENSE_RANK() OVER (PARTITION BY category_name ORDER BY SUM(qty) DESC) AS rn
    FROM cte
    GROUP BY category_name, product_name
)
SELECT category_name, product_name, total_revenue 
FROM cte2
WHERE rn = 1;
```
### Answer:
| Category Name | Product Name                 | Total Revenue ($) |
|---------------|------------------------------|--------------------|
| Mens          | Blue Polo Shirt - Mens       | 217,683           |
| Womens        | Grey Fashion Jacket - Womens | 209,304           |

### Insight:
Top products in both categories highlight the company’s ability to cater to distinct customer preferences, with high revenues from **Blue Polo Shirt - Mens** and **Grey Fashion Jacket - Womens**.

---

## 6. What is the percentage split of revenue by product for each segment?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, s.discount, p.category_id, category_name, product_name, segment_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
),
cte2 AS (
    SELECT segment_name, product_name, SUM(price * qty) AS revenue
    FROM cte
    GROUP BY segment_name, product_name
),
cte3 AS (
    SELECT segment_name, SUM(qty * price) AS total_segment_revenue
    FROM cte
    GROUP BY segment_name
)
SELECT cte2.segment_name, cte2.product_name, cte2.revenue, 
       cte2.revenue * 100.0 / cte3.total_segment_revenue AS percentage_split
FROM cte2 
JOIN cte3
ON cte2.segment_name = cte3.segment_name
ORDER BY percentage_split DESC;
```
### Answer:
| Segment Name | Product Name                 | Revenue ($) | Percentage Split (%) |
|--------------|------------------------------|-------------|-----------------------|
| Jeans        | Black Straight Jeans - Womens| 121,152     | 58.15                |
| Jacket       | Grey Fashion Jacket - Womens | 209,304     | 57.03                |
| Shirt        | Blue Polo Shirt - Mens       | 217,683     | 53.60                |
| Socks        | Navy Solid Socks - Mens      | 136,512     | 44.33                |

### Insight:
The **Grey Fashion Jacket - Womens** continues to dominate its segment, capturing **57%** of revenue within the **Jacket** category.

---

## 7. What is the percentage split of revenue by segment for each category?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, s.discount, p.category_id, category_name, product_name, segment_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
),
cte2 AS (
    SELECT segment_name, category_name, SUM(price * qty) AS revenue
    FROM cte
    GROUP BY segment_name, category_name
),
cte3 AS (
    SELECT category_name, SUM(qty * price) AS total_category_revenue
    FROM cte
    GROUP BY category_name
)
SELECT cte2.category_name, cte2.segment_name, cte2.revenue, 
       CAST(ROUND(cte2.revenue * 100.0 / cte3.total_category_revenue, 2) AS DECIMAL(10, 2)) AS percentage_split
FROM cte2 
JOIN cte3
ON cte2.category_name = cte3.category_name
ORDER BY percentage_split DESC;
```
### Answer:
| Category Name | Segment Name | Revenue ($) | Percentage Split (%) |
|---------------|--------------|-------------|-----------------------|
| Womens        | Jacket       | 366,983     | 63.79                |
| Mens          | Shirt        | 406,143     | 56.87                |
| Mens          | Socks        | 307,977     | 43.13                |
| Womens        | Jeans        | 208,350     | 36.21                |

### Insight:
The **Jacket segment** in the **Womens category** captured the highest revenue share at **63.79%**, showing its dominance.

---

## 8. What is the percentage split of total revenue by category?
### Query:
```sql
WITH cte AS (
    SELECT p.price, s.qty, p.category_id, category_name
    FROM product_details p
    INNER JOIN sales s 
    ON p.product_id = s.prod_id
),
cte2 AS (
    SELECT category_id, category_name, SUM(price * qty) AS revenue
    FROM cte
    GROUP BY category_id, category_name
)
SELECT category_name, 
       CAST(100.0 * CAST(revenue AS FLOAT) / (SELECT SUM(price * qty) FROM cte) AS DECIMAL(10, 2)) AS percentage_split
FROM cte2;
```
### Answer:
| Category Name | Percentage Split (%) |
|---------------|-----------------------|
| Mens          | 55.38                |
| Womens        | 44.62                |

### Insight:
The **Mens category** contributed the majority share of revenue at **55.38%**, highlighting its significant role in overall sales.

---

## 9. What is the total transaction “penetration” for each product?
### Query:
```sql
WITH cte AS (
    SELECT product_id, txn_id, qty, product_name
    FROM product_details p
    INNER JOIN sales s
    ON p.product_id = s.prod_id
)
SELECT product_name, 
       CAST(ROUND(COUNT(txn_id), 2) AS DECIMAL(10, 2)) AS total_txns,
       CAST(100.0 * COUNT(DISTINCT txn_id) AS FLOAT) / (SELECT COUNT(DISTINCT txn_id) FROM sales) AS percentage_split
FROM cte
GROUP BY product_name
ORDER BY percentage_split DESC;
```
### Answer:
| Product Name                 | Total Transactions | Percentage Split (%) |
|------------------------------|--------------------|-----------------------|
| Navy Solid Socks - Mens      | 1,281.00          | 51.24                |
| Grey Fashion Jacket - Womens | 1,275.00          | 51.00                |
| Navy Oversized Jeans - Womens| 1,274.00          | 50.96                |
| White Tee Shirt - Mens       | 1,268.00          | 50.72                |

### Insight:
The **Navy Solid Socks - Mens** had the highest transaction penetration at **51.24%**, followed closely by the **Grey Fashion Jacket - Womens**.

---
## 10. What is the most common combination of at least 1 quantity of any 3 products in a single transaction? 📉

### Query:
```sql
WITH cte AS (
    SELECT txn_id, p1.product_name
    FROM sales s  
    INNER JOIN product_details p1 ON s.prod_id = p1.product_id
)
SELECT TOP 1 
       c1.product_name AS product_1,
       c2.product_name AS product_2,
       c3.product_name AS product_3,
       COUNT(*) AS time_trans
FROM cte c1
INNER JOIN cte c2 ON c1.txn_id = c2.txn_id AND c1.product_name < c2.product_name
INNER JOIN cte c3 ON c1.txn_id = c3.txn_id AND c2.product_name < c3.product_name
WHERE c1.product_name IS NOT NULL 
  AND c2.product_name IS NOT NULL 
  AND c3.product_name IS NOT NULL
GROUP BY c1.product_name, c2.product_name, c3.product_name
ORDER BY time_trans DESC;
```

### Answer:
| Product 1                  | Product 2                | Product 3                | Times Combined |
|----------------------------|--------------------------|--------------------------|----------------|
| Grey Fashion Jacket - Womens | Teal Button Up Shirt - Mens | White Tee Shirt - Mens  | 352            |

### Insight:
The combination of **Grey Fashion Jacket - Womens**, **Teal Button Up Shirt - Mens**, and **White Tee Shirt - Mens** appeared together in **352 transactions**, making it the most common combination of 3 products purchased together. This insight is valuable for creating bundled promotions or targeted marketing campaigns.

## Summary Insight for Product Analysis 🌟

- **Top Performers:** The **Blue Polo Shirt - Mens** and **Grey Fashion Jacket - Womens** dominate revenue across categories, reflecting customer preference for premium products.
- **Segment Success:** The **Shirt** segment leads in revenue, while the **Socks** segment demonstrates strong transaction penetration, highlighting a loyal customer base for smaller items.
- **Category Performance:** Menswear contributed the majority of revenue (**55.38%**), with significant support from the **Shirt** segment.
- **Product Bundling:** The most common product combination—**Grey Fashion Jacket - Womens**, **Teal Button Up Shirt - Mens**, and **White Tee Shirt - Mens**—provides an excellent opportunity for cross-selling and bundling promotions.
- **Discount Impact:** Discounts are effectively distributed across segments, ensuring value-driven promotions while maintaining profitability.


