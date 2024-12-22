# 💰 Case Study #4: Data Bank 💰
![{0C6BD14A-2392-4559-8DDF-E924BEEB89BA}](https://github.com/user-attachments/assets/f2ed9008-4db0-4dc1-a571-59db692f4cc0)


## Introduction
The financial industry is witnessing a revolutionary shift with the rise of **Neo-Banks**—digital-only banks with no physical branches. Combining the innovations of modern banking, cryptocurrency, and the data world, **Data Bank** has emerged as a secure, distributed banking platform. 

Data Bank not only provides traditional banking services but also offers the world's most secure distributed data storage platform. Customers are allocated cloud data storage limits that are directly tied to their account balances. 

This case study focuses on:
1. Calculating key metrics for understanding customer and system performance.
2. Forecasting future storage needs to optimize Data Bank's operations.
3. Helping the management team make informed decisions to grow their customer base.

---

## Available Data
The Data Bank system is designed with three key tables that facilitate the analysis:

### **1. Regions**
- Stores region information where Data Bank's nodes are located.
- **Columns**:
  - `region_id`: Unique identifier for each region.
  - `region_name`: Name of the region (e.g., Africa, America).

### **2. Customer Nodes**
- Tracks customer allocations to specific nodes within regions.
- **Columns**:
  - `customer_id`: Unique identifier for each customer.
  - `region_id`: The region where the node is located.
  - `node_id`: Unique identifier for the node.
  - `start_date`: The date the customer was assigned to the node.
  - `end_date`: The date the customer left the node.

### **3. Customer Transactions**
- Records all customer transactions.
- **Columns**:
  - `customer_id`: Unique identifier for each customer.
  - `txn_date`: Date of the transaction.
  - `txn_type`: Type of transaction (`deposit`, `withdrawal`, `purchase`).
  - `txn_amount`: Amount involved in the transaction.

---

## Case Study Objectives
This case study is divided into three main sections, with each focusing on different aspects of Data Bank’s operations:

### **A. Customer Node Exploration**
Analyze the distribution and mobility of customers across nodes and regions:
1. How many unique nodes are there in the Data Bank system?
2. How many nodes exist in each region?
3. How many customers are allocated to each region?
4. On average, how often are customers reallocated to different nodes?
5. What are the median, 80th, and 95th percentiles for the duration of customer allocations to nodes in each region?

**[View the Customer Node Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Customer_Nodes/README.md)**
---

### **B. Customer Transactions**
Analyze customer transactions to uncover patterns and trends:
1. What is the unique count and total amount for each transaction type?
2. What are the average historical deposit counts and amounts for all customers?
3. For each month, how many customers make more than one deposit and either one purchase or one withdrawal?
4. What is the **closing balance** for each customer at the end of the month?
5. What percentage of customers increase their closing balance by more than 5%?

**[View the Customer Transactions Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Customer%20Transactions/README.md)**


---

### **C. Data Allocation Challenge**
Estimate how much data needs to be provisioned under different allocation models:
1. **Option 1**: Data is allocated based on the **balance at the end of the previous month**.
2. **Option 2**: Data is allocated based on the **average balance over the past 30 days**.
3. **Option 3**: Data is updated in **real-time** based on each transaction.

**[View the Data Allocation Challenge Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Data%20Allocation/README.md)**


---

## Insights and Observations
The analysis will uncover:
1. Customer mobility patterns across nodes and regions.
2. Transactional trends and how they impact storage requirements.
3. The efficiency of different data allocation models to meet customer needs.
4. Strategic recommendations to optimize operations and attract new customers.

---

---

## Conclusion
This case study offers a hands-on opportunity to explore real-world banking data scenarios, blending traditional financial operations with modern data-driven strategies. It showcases how advanced analytics can optimize business processes, improve customer satisfaction, and prepare organizations for future growth.

**Ready to dive deeper? Let’s analyze the data and uncover actionable insights!**

