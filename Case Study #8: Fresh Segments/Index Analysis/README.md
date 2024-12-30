# Index Analysis

## **The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.**

**Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.**

### **1. What is the top 10 interests by the average composition for each month?**

```sql
WITH avg_composition AS (
  SELECT 
      month_year,
      interest_id,
      ROUND(composition / index_value, 2) AS avg_composition
  FROM interest_metrics
  WHERE index_value > 0 -- Exclude invalid rows
),
ranked_composition AS (
  SELECT 
      month_year,
      interest_id,
      avg_composition,
      ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY avg_composition DESC) AS rank
  FROM avg_composition
)
SELECT 
    rc.month_year,
    rc.interest_id,
    CAST(im.interest_name AS NVARCHAR(MAX)) AS interest_name,
    rc.avg_composition
FROM ranked_composition rc
LEFT JOIN interest_map im
ON rc.interest_id = im.id
WHERE rc.rank <= 10
ORDER BY rc.month_year, rc.rank;
```

**Sample Output:**
| month_year   | interest_id | interest_name                   | avg_composition |
|--------------|-------------|---------------------------------|-----------------|
| 2018-07-01   | 6324        | Las Vegas Trip Planners        | 7.36            |
| 2018-07-01   | 6284        | Gym Equipment Owners           | 6.94            |
| 2018-07-01   | 4898        | Cosmetics and Beauty Shoppers  | 6.78            |
| 2018-07-01   | 77          | Luxury Retail Shoppers         | 6.61            |
| 2018-07-01   | 39          | Furniture Shoppers             | 6.51            |

**Insight:**
- Interests like "Las Vegas Trip Planners" and "Gym Equipment Owners" consistently rank high in composition across months, indicating strong engagement.

---

### **2. For all of these top 10 interests - which interest appears the most often?**

```sql
WITH avg_composition AS (
  SELECT 
      month_year,
      interest_id,
      ROUND(composition / index_value, 2) AS avg_composition
  FROM interest_metrics
  WHERE index_value > 0 -- Exclude invalid rows
),
ranked_composition AS (
  SELECT 
      month_year,
      interest_id,
      avg_composition,
      ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY avg_composition DESC) AS rank
  FROM avg_composition
),
top_10_interests AS (
  SELECT 
      rc.month_year,
      rc.interest_id,
      CAST(im.interest_name AS NVARCHAR(MAX)) AS interest_name,
      rc.avg_composition
  FROM ranked_composition rc
  LEFT JOIN interest_map im
  ON rc.interest_id = im.id
  WHERE rc.rank <= 10
)
SELECT 
    interest_name,
    COUNT(*) AS appearance_count
FROM top_10_interests
GROUP BY interest_name
ORDER BY appearance_count DESC;
```

**Sample Output:**
| interest_name                   | appearance_count |
|---------------------------------|------------------|
| Alabama Trip Planners           | 10               |
| Luxury Bedding Shoppers         | 10               |
| Solar Energy Researchers        | 10               |
| Readers of Honduran Content     | 9                |
| New Years Eve Party Ticket Purchasers | 9        |

**Insight:**
- "Alabama Trip Planners" and "Luxury Bedding Shoppers" appear the most often, suggesting they are highly relevant for the audience.

---

### **3. What is the average of the average composition for the top 10 interests for each month?**

```sql
WITH avg_composition AS (
  SELECT 
      month_year,
      interest_id,
      ROUND(composition / index_value, 2) AS avg_composition
  FROM interest_metrics
  WHERE index_value > 0 -- Exclude invalid rows
),
ranked_composition AS (
  SELECT 
      month_year,
      interest_id,
      avg_composition,
      ROW_NUMBER() OVER (PARTITION BY month_year ORDER BY avg_composition DESC) AS rank
  FROM avg_composition
),
top_10_interests AS (
  SELECT 
      month_year,
      avg_composition
  FROM ranked_composition
  WHERE rank <= 10
)
SELECT 
    month_year,
    ROUND(AVG(avg_composition), 2) AS avg_of_top_10
FROM top_10_interests
GROUP BY month_year
ORDER BY month_year;
```

**Sample Output:**
| month_year   | avg_of_top_10 |
|--------------|---------------|
| 2018-07-01   | 6.04          |
| 2018-08-01   | 5.94          |
| 2018-09-01   | 6.89          |
| 2018-10-01   | 7.07          |

**Insight:**
- The average composition varies over time, with peaks in October 2018, likely influenced by seasonal trends.

---

### **4. What is the 3-month rolling average of the max average composition value from September 2018 to August 2019, and include the previous top-ranking interests?**

```sql
WITH avg_compositions AS (
  SELECT 
    month_year,
    interest_id,
    ROUND(composition / index_value, 2) AS avg_comp,
    ROUND(MAX(composition / index_value) OVER (PARTITION BY month_year), 2) AS max_avg_comp
  FROM interest_metrics
  WHERE month_year IS NOT NULL AND index_value > 0
),
max_avg_compositions AS (
  SELECT *
  FROM avg_compositions
  WHERE avg_comp = max_avg_comp
),
moving_avg_compositions AS (
  SELECT 
    mac.month_year,
    CAST(im.interest_name AS NVARCHAR(MAX)) AS interest_name,
    mac.max_avg_comp AS max_index_composition,
    ROUND(AVG(mac.max_avg_comp) 
          OVER (ORDER BY mac.month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS [3_month_moving_avg],
    CAST(LAG(CAST(im.interest_name AS NVARCHAR(MAX))) OVER (ORDER BY mac.month_year) AS NVARCHAR(MAX)) + ': ' +
    CAST(LAG(mac.max_avg_comp) OVER (ORDER BY mac.month_year) AS NVARCHAR(10)) AS [1_month_ago],
    CAST(LAG(CAST(im.interest_name AS NVARCHAR(MAX)), 2) OVER (ORDER BY mac.month_year) AS NVARCHAR(MAX)) + ': ' +
    CAST(LAG(mac.max_avg_comp, 2) OVER (ORDER BY mac.month_year) AS NVARCHAR(10)) AS [2_months_ago]
  FROM max_avg_compositions mac 
  JOIN interest_map im 
    ON mac.interest_id = im.id
)
SELECT *
FROM moving_avg_compositions
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01';
```

**Sample Output:**
| month_year   | interest_name                | max_index_composition | 3_month_moving_avg | 1_month_ago                   | 2_months_ago               |
|--------------|------------------------------|------------------------|--------------------|-------------------------------|---------------------------|
| 2018-09-01   | Work Comes First Travelers  | 8.26                  | 7.61              | Las Vegas Trip Planners: 7.21 | Las Vegas Trip Planners: 7.36 |
| 2018-10-01   | Work Comes First Travelers  | 9.14                  | 8.20              | Work Comes First Travelers: 8.26 | Las Vegas Trip Planners: 7.21 |

**Insight:**
- "Work Comes First Travelers" consistently ranks high, reflecting strong engagement during these months.

---

### **5. Provide a possible reason why the max average composition might change from month to month?**

**Reasons:**
- Seasonal trends, such as vacations or holidays, influence customer interests.
- Targeted marketing campaigns may temporarily boost specific interest engagement.
- Customer behavior varies due to trends, new products, or external factors.
- Data collection or processing inconsistencies can cause fluctuations.
- Saturation of certain interests might naturally lead to declining engagement.

**Potential Issues:**
- Overreliance on a few interests may indicate a lack of diversification.
- Large fluctuations could point to inconsistencies in data quality or methodology.
- Repeated dominance of the same interests without growth suggests stagnation.
- Limited adaptability to market trends may result in declining engagement.
- Ineffective strategies might prevent Fresh Segments from reaching new audiences.


**Conclusion:**
The changes in max average composition are normal but should be watched carefully. Consistently high engagement in certain segments shows effective targeting, but big fluctuations or relying too much on a few interests could mean there are issues with the business model. Fresh Segments should focus on keeping data accurate, reaching a wider range of audiences, and making sure campaigns adjust to customer needs over time.


---

