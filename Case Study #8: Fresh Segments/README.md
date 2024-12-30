# 🔧 8 Week SQL Challenge: Case Study #8 - Fresh Segments

## 🔎 Introduction
Fresh Segments, a digital marketing agency founded by Danny Ma, helps businesses analyze trends in online ad click behavior specific to their customer base. Clients share their customer lists, which Fresh Segments aggregates to create datasets with detailed metrics. These metrics include composition and rankings for different interests, showcasing the proportion of customers interacting with online content related to each interest every month.



This case study involves analyzing aggregated metrics for a client and deriving insights about their customers and their interests.

## 📊 Available Data
This case study utilizes two datasets:

### **1. Interest Metrics**
This table contains metrics aggregated from the client’s customer base, detailing their interactions with various interests.

| Column              | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `_month`            | Month of the interaction                                                   |
| `_year`             | Year of the interaction                                                    |
| `month_year`        | Combined month and year in `YYYY-MM` format                                |
| `interest_id`       | Unique identifier for the interest                                         |
| `composition`       | Percentage of the customer list interacting with the interest              |
| `index_value`       | Multiplication factor relative to the average composition across all clients |
| `ranking`           | Rank of the interest based on `index_value`                               |
| `percentile_ranking`| Percentile ranking of the interest                                         |

### **2. Interest Map**
This table maps each `interest_id` to its corresponding interest name and summary.

| Column           | Description                                         |
|------------------|-----------------------------------------------------|
| `id`             | Unique identifier for the interest                 |
| `interest_name`  | Name of the interest                                |
| `interest_summary` | Description of the interest                        |
| `created_at`     | Timestamp of when the interest was created          |
| `last_modified`  | Timestamp of the last modification                  |

## 🎨 Case Study Questions
This case study explores key business questions through the datasets. Below is a summary of the questions addressed:

### **[Data Exploration and Cleansing](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238:%20Fresh%20Segments/Data%20Exploration%20and%20Cleaning)**

[View Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238:%20Fresh%20Segments/Data%20Exploration%20and%20Cleaning)**
1. Update the `month_year` column in `interest_metrics` to be a proper date type.
2. Count records in `interest_metrics` for each `month_year` value, sorted chronologically.
3. Handle and analyze null values in the dataset.
4. Identify `interest_id` values present in one table but not the other.
5. Summarize the total record count for each `id` in `interest_map`.
6. Perform and validate an appropriate table join for analysis.
7. Check for records where `month_year` precedes `created_at` in `interest_map` and evaluate their validity.

### **[Interest Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%3A%20Fresh%20Segments/Interest%20Analysis)**

[View Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%3A%20Fresh%20Segments/Interest%20Analysis)**
1. Identify interests present in all `month_year` values.
2. Calculate the cumulative percentage of records based on total months and identify the threshold passing 90%.
3. Determine the total data points removed and retained when filtering interests below this threshold.
4. Evaluate the business implications of removing these data points.
5. Calculate unique interests remaining for each month after filtering.

### **[Segment Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%3A%20Fresh%20Segments/Segment%20Analysis)**

[View Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%3A%20Fresh%20Segments/Segment%20Analysis)**
1. Identify the top 10 and bottom 10 interests by maximum composition value for each month.
2. Find the 5 interests with the lowest average ranking.
3. Identify the 5 interests with the largest standard deviation in their percentile rankings.
4. Analyze minimum and maximum `percentile_ranking` values for these interests.
5. Provide insights into the customer base and recommend products/services to target effectively.

### **[Index Analysis](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%3A%20Fresh%20Segments/Index%20Analysis)**

[View Solution](https://github.com/prachiy5/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%3A%20Fresh%20Segments/Index%20Analysis)**
1. Calculate the top 10 interests by average composition for each month.
2. Identify which interest appears most frequently in the top 10.
3. Determine the average of the average composition for the top 10 interests monthly.
4. Calculate the 3-month rolling average of the max average composition and analyze variations in results.

## 🌍 Acknowledgment
This challenge is part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-8/) created by Danny Ma. It offers a fantastic opportunity to practice and improve SQL skills while working on real-world datasets.

## 💡 Key Takeaways
This case study provides valuable insights into customer segmentation and trends analysis using SQL. By exploring composition metrics and rankings, we can derive actionable strategies for better targeting in digital marketing.

---

Feel free to explore my solutions for this case study in the repository! 🚀 Happy querying!
