# Clique Bait - Case Study #6 🦞🐟🦐

### **Overview** 📊

This project is part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/) by Danny Ma. In this case study, we dive into the digital world of **Clique Bait**, an online seafood store, to analyze user behavior, product performance, and campaign success using SQL. Let’s explore the data and uncover actionable insights to optimize their operations! 🛒📈

---

### **Objectives** 🎯

The main goals of this case study are:

1. **Understand User Behavior**:
   - Analyze user interactions on the Clique Bait website, including page views, cart additions, and purchases.
2. **Funnel Analysis**:
   - Identify points where users drop off in the purchase funnel.
3. **Campaign Performance**:
   - Evaluate the effectiveness of marketing campaigns through impressions, clicks, and conversions.
4. **Product Metrics**:
   - Examine product performance: views, cart additions, and purchases.
5. **Generate Insights**:
   - Provide actionable recommendations to improve digital marketing and operational strategies.

---

### **Datasets** 📂

This case study includes five datasets:

1. **Users** 👤:
   - Information about website visitors identified by their `cookie_id`.
2. **Events** 🗓️:
   - Logs of user interactions, such as page views, cart additions, and purchases.
3. **Event Identifier** 🔖:
   - Mapping of event types to descriptive names.
4. **Campaign Identifier** 🎯:
   - Details of marketing campaigns, including product focus and timeframes.
5. **Page Hierarchy** 🗺️:
   - Metadata about website pages and their associated product categories and IDs.

---

### **Case Study Structure** 🧩

The solutions for this case study are organized into the following sections:

1. **Enterprise Relationship Diagram (ERD)**:
   - Visual representation of the relationships between datasets.
   - Provides the foundation for data joins and transformations.

2. **Digital Analysis** 📈:
   - Key questions about user behavior and website performance, such as:
     - How many users are there?
     - What is the percentage of visits with a purchase event?
     - What are the top 3 pages by views?

3. **Product Funnel Analysis** 🛍️:
   - Detailed metrics for each product:
     - Views
     - Cart Additions
     - Abandoned Cart Rate
     - Purchases
   - Aggregated data by product category.

4. **Campaigns Analysis** 📢:
   - Metrics for evaluating campaign performance:
     - Purchase rates with and without impressions.
     - Uplift in purchase rates based on clicks and impressions.
     - Success metrics for each campaign.

5. **Visit Summary** 🕵️‍♂️:
   - A single table summarizing each visit with details such as:
     - User ID
     - Visit start time
     - Total page views, cart additions, and purchases
     - Campaign mapping

---

### **File Structure** 📁

The project is divided into folders for each section, with solutions and explanations provided in individual `README.md` files.

```
Clique_Bait_Case_Study/
├── Digital_Analysis/
│   ├── README.md
│   └── solutions.sql
├── Product_Funnel_Analysis/
│   ├── README.md
│   └── solutions.sql
├── Campaign_Analysis/
│   ├── README.md
│   └── solutions.sql
├── Visit_Summary/
│   ├── README.md
│   └── solutions.sql
└── README.md  # Main overview file
```
### **Quick Links to Each Section** 🔗

- [Enterprise Relationship Diagram (ERD)](./ERD/README.md)
- [Digital Analysis](./Digital_Analysis/README.md)
- [Product Funnel Analysis](./Product_Funnel_Analysis/README.md)
- [Campaign Analysis](./Campaign_Analysis/README.md)


---


### **Insights and Recommendations** 💡

- **Ad Impressions Drive Conversions**:
  - Users exposed to ad impressions have significantly higher purchase rates compared to those who don’t receive impressions.

- **Clicks Lead to Higher Engagement**:
  - Users who click on ads exhibit the highest purchase rates, emphasizing the importance of engagement.

- **Campaign Optimization Opportunities**:
  - Campaigns like **"Half Off - Treat Your Shellf(ish)"** outperform others, serving as a model for future strategies.

- **User Funnel Analysis**:
  - Products with high abandonment rates should be prioritized for retargeting and optimization to improve conversions.

---

### **Acknowledgment** 🙏

This project is part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/) by Danny Ma. Special thanks to Danny for creating such engaging and insightful case studies that enhance real-world SQL skills. 🌟

