# High-Level Sales Analysis 📊

In this section, we dive into the overall performance metrics for Balanced Tree Clothing Co., focusing on quantity sold, revenue, and discounts. These insights provide a high-level view of the company's sales performance.

---

## Total Quantity Sold
### Query:
```sql
SELECT SUM(qty) AS total_quantity FROM sales;
```
### Result:
- **Total Quantity Sold:** `45,216`

### Insight:
With an impressive **45,216 units sold**, Balanced Tree Clothing Co. demonstrates strong sales volume. This indicates that the product range is resonating well with customers, and the company is successfully capturing market demand.

---

## Total Revenue Before Discounts
### Query:
```sql
SELECT SUM(qty * price) AS total_revenue FROM sales
WHERE qty IS NOT NULL AND price IS NOT NULL;
```
### Result:
- **Total Revenue (Before Discounts):** `$1,289,453`

### Insight:
The company generated a total revenue of **$1.29M** before applying any discounts. This reflects the effectiveness of the pricing strategy and highlights the potential revenue if no discounts were provided.

---

## Total Discount Amount
### Query:
```sql
SELECT CAST(ROUND(SUM(qty * price * discount / 100.0), 2) AS DECIMAL(10, 2)) AS total_discount_amount
FROM sales;
```
### Result:
- **Total Discount Amount:** `$156,229.14`

### Insight:
Discounts accounted for approximately **$156K**, which represents a significant investment in promotional efforts to drive sales. This figure underscores the company’s strategy to attract price-sensitive customers while balancing profitability.

---

## Summary of Insights
- The company achieved **high sales volume** with over **45,000 units sold**, reflecting a strong market presence.
- The **total revenue before discounts** was **$1.29M**, indicating healthy pricing strategies and product demand.
- A **$156K discount investment** demonstrates the company’s focus on customer acquisition and competitive positioning in the market.

These metrics provide a solid foundation for deeper transactional and product-level analysis to uncover further growth opportunities!

