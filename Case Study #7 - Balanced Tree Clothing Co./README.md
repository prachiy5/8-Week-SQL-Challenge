# Case Study #7 - Balanced Tree Clothing Co. 🌳💳

## Introduction
Balanced Tree Clothing Company prides itself on providing an optimized range of clothing and lifestyle wear for the modern adventurer! 🏃‍♂️✨

Danny, the CEO of this trendy fashion company, has asked you to assist the team’s merchandising teams analyze their sales performance and generate a basic financial report to share with the wider business. 📊

---

## Available Data 📂
For this case study, there are 4 datasets provided, out of which only 2 main tables are required to solve the regular questions, and the remaining 2 are used for the bonus challenge question. 🔄

### Main Datasets:
1. **Product Details** - `balanced_tree.product_details`
    - Information about the entire range that Balanced Tree sells.

    | product_id | price | product_name                 | category_id | segment_id | style_id | category_name | segment_name | style_name      |
    |------------|-------|-----------------------------|-------------|------------|----------|---------------|--------------|----------------|
    | c4a632     | 13    | Navy Oversized Jeans - Womens | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized |

2. **Product Sales** - `balanced_tree.sales`
    - Transaction details for all products sold.

    | prod_id | qty | price | discount | member | txn_id | start_txn_time          |
    |---------|-----|-------|----------|--------|--------|-------------------------|
    | c4a632  | 4   | 13    | 17       | t      | 54f307 | 2021-02-13 01:59:43.296 |


---

## Case Study Questions 🔍
The following questions form the core of the analysis. Each question is linked to its solution for easy navigation:

### [High-Level Sales Analysis 📊](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./High%20Level%20Sales%20Analysis)
1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?

### [Transaction Analysis 📈](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Transaction%20Analysis)
4. How many unique transactions were there?
5. What is the average unique products purchased in each transaction?
6. What are the 25th, 50th, and 75th percentile values for the revenue per transaction?
7. What is the average discount value per transaction?
8. What is the percentage split of all transactions for members vs non-members?
9. What is the average revenue for member and non-member transactions?

### [Product Analysis 🍔✅](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Product%20Analysis)
10. What are the top 3 products by total revenue before discount?
11. What is the total quantity, revenue, and discount for each segment?
12. What is the top selling product for each segment?
13. What is the total quantity, revenue, and discount for each category?
14. What is the top selling product for each category?
15. What is the percentage split of revenue by product for each segment?
16. What is the percentage split of revenue by segment for each category?
17. What is the percentage split of total revenue by category?
18. What is the total transaction penetration for each product?
19. What is the most common combination of at least 1 quantity of any 3 products in a single transaction?

### Reporting Challenge 🔢
20. Generate a monthly financial report for January and February.




## Links to Solutions ✨
- [High-Level Sales Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./High%20Level%20Sales%20Analysis)
- [Transaction Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Transaction%20Analysis)
- [Product Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Product%20Analysis)
- [Reporting Challenge](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Reporting%20Challenge)



---

## Conclusion 🏆
This case study provides a hands-on approach to solving real-world business problems using SQL. By navigating through product hierarchies, calculating transaction metrics, and generating detailed financial reports, you gain valuable experience applicable to roles in data analytics and business intelligence.


##Acknowledgment 🙌
This case study is part of the **8 Week SQL Challenge** created by **Danny Ma**. The Balanced Tree Clothing Co. case study was an excellent opportunity to develop SQL skills and analyze real-world data scenarios. You can learn more about the challenge and join the community [here](https://www.datawithdanny.com/).

