# 🛒 **8 Week SQL Challenge - Case Study #5: Data Mart**

Welcome to **Case Study #5: Data Mart**, part of the **8 Week SQL Challenge** by **Danny Ma**. This case study focuses on analyzing sales performance for an international supermarket that recently transitioned to sustainable packaging methods.
![{00AAB74A-C862-4446-BD5C-6E833C4DDC56}](https://github.com/user-attachments/assets/c8870d18-17c8-4cf8-8b54-5583145dd1f2)

---

## 📖 **Case Study Overview**

In June 2020, **Data Mart** implemented large-scale changes to adopt sustainable packaging methods for all its products. This case study explores the **impact of these changes** on sales performance across various dimensions such as platforms, regions, customer types, and more.

### **Key Objectives:**
1. Quantify the impact of sustainable packaging changes introduced in June 2020.
2. Identify the platforms, regions, segments, and customer types most affected.
3. Develop insights and recommendations to minimize potential sales impacts for future sustainability initiatives.

---

## 📊 **Available Data**

The dataset for this case study contains a single table: `data_mart.weekly_sales`.

### **Column Dictionary:**
| Column Name     | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `week_date`      | The start date of the sales week                                           |
| `region`         | Region of operation (e.g., Oceania, Europe)                               |
| `platform`       | Platform used for sales (e.g., Retail, Shopify)                           |
| `segment`        | Customer demographic segment                                              |
| `customer_type`  | Type of customer (New, Existing, Guest)                                    |
| `transactions`   | Count of unique purchases made                                            |
| `sales`          | Total dollar amount of purchases                                          |

---

## 🔍 **Case Study Questions**

### **1. Data Cleansing Steps**
Create a cleaned version of the `weekly_sales` table, adding new calculated columns:
- Convert `week_date` to a `DATE` format.
- Add `week_number`, `month_number`, and `calendar_year` columns.
- Create new columns: `age_band`, `demographic`, and `avg_transaction`.

### **2. Data Exploration**
Answer exploratory questions such as:
- What day of the week is used for `week_date`?
- Identify missing `week_number` ranges.
- Calculate total sales, transactions, and percentage breakdowns by various dimensions.

### **3. Before & After Analysis**
Analyze the impact of sustainable packaging changes:
- Compare total sales for the **4 weeks** and **12 weeks** before and after the baseline date (`2020-06-15`).
- Compare these sales metrics with the corresponding periods in 2018 and 2019.

### **4. Bonus Question**
Identify areas of the business most negatively impacted during the **12-week period** after the change, broken down by:
- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

---

## 🛠️ **Repository Structure**

The repository is structured to include separate solution files for each part of the case study.


---

## 🛠️ **Tools & Techniques Used**
- **SQL**: Data cleansing, exploratory analysis, and comparative metrics calculations.
- **Window Functions**: For cumulative totals and percentages.
- **Common Table Expressions (CTEs)**: For organizing intermediate queries.
- **CASE Statements**: For dynamic classifications (e.g., `before/after`, `age_band`).

---

## 🚀 **Next Steps**
Ready to dive in? Check out the solution files for each part:

- [Part 1: Data Cleansing Steps](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Data%20Cleaning)
- [Part 2: Data Exploration](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Data%20Exploration)
- [Part 3: Before & After Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Before%20%26%20After%20Analysis)



---

Feel free to reach out or contribute your solutions to the community! Let’s tackle this case study together. 😊

## 🤝 **Acknowledgment**

This case study is part of the **8 Week SQL Challenge** created by **Danny Ma**. The challenge is an excellent resource for SQL enthusiasts to enhance their skills by solving real-world business problems using SQL.

Visit the [8 Week SQL Challenge Website](https://8weeksqlchallenge.com/) to explore this and other case studies, or follow Danny Ma on [LinkedIn](https://www.linkedin.com/in/datawithdanny/) for more insights into data analytics and SQL.

---

--- 

This **README** provides a clear and structured overview of the case study while guiding users to detailed solution files. Let me know if you’d like to refine this further! 😊

