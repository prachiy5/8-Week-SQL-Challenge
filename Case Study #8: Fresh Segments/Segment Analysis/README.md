# 🌍 Segment Analysis

## 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year

**Query:**
```sql
WITH interest_months AS (
  -- Calculate total months for each interest_id
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
),
filtered_data AS (
  -- Keep only interest_id values with total_months >= 6
  SELECT *
  FROM interest_metrics
  WHERE interest_id IN (
    SELECT interest_id
    FROM interest_months
    WHERE total_months >= 6
  )
),
max_composition AS (
  -- Get the maximum composition value and corresponding month_year for each interest_id
  SELECT 
    interest_id,
    MAX(composition) AS max_composition,
    MAX(month_year) AS month_year
  FROM filtered_data
  GROUP BY interest_id
),
ranked_data AS (
  -- Rank interests by their max_composition values in descending order
  SELECT 
    mc.interest_id,
    mc.max_composition,
    mc.month_year,
    im.interest_name,
    ROW_NUMBER() OVER (ORDER BY mc.max_composition DESC) AS rank_desc,
    ROW_NUMBER() OVER (ORDER BY mc.max_composition ASC) AS rank_asc
  FROM max_composition mc
  LEFT JOIN interest_map im
  ON mc.interest_id = im.id
)
-- Get top 10 and bottom 10 interests
SELECT *
FROM ranked_data
WHERE rank_desc <= 10 OR rank_asc <= 10
ORDER BY rank_desc, rank_asc;
```

**Output:**

| interest_id | max_composition | month_year  | interest_name                    | rank_desc | rank_asc |
|-------------|-----------------|-------------|----------------------------------|-----------|----------|
| 21057       | 21.2            | 2019-02-01  | Work Comes First Travelers       | 1         | 1092     |
| 6284        | 18.82           | 2019-08-01  | Gym Equipment Owners             | 2         | 1091     |
| 39          | 17.44           | 2019-08-01  | Furniture Shoppers               | 3         | 1090     |
| 77          | 17.19           | 2019-08-01  | Luxury Retail Shoppers           | 4         | 1089     |
| 12133       | 15.15           | 2019-08-01  | Luxury Boutique Hotel Researchers | 5         | 1088     |
| ...         | ...             | ...         | ...                              | ...       | ...      |

**Insight:**
- "Work Comes First Travelers" has the highest maximum composition value of 21.2 in February 2019.
- Bottom interests like "Astrology Enthusiasts" have much smaller maximum composition values, indicating niche engagement.

---

## 2. Which 5 interests had the lowest average ranking value?

**Query:**
```sql
WITH interest_avg_ranking AS (
  -- Calculate the average ranking for each interest_id
  SELECT 
    im.interest_id,
    CAST(imap.interest_name AS NVARCHAR(MAX)) AS interest_name,
    AVG(im.ranking) AS avg_ranking
  FROM interest_metrics im
  LEFT JOIN interest_map imap
  ON im.interest_id = imap.id
  GROUP BY im.interest_id, CAST(imap.interest_name AS NVARCHAR(MAX))
)
-- Select the 5 interests with the lowest average ranking
SELECT TOP 5 
    interest_id,
    interest_name,
    avg_ranking
FROM interest_avg_ranking
ORDER BY avg_ranking ASC;
```

**Output:**

| interest_id | interest_name                  | avg_ranking |
|-------------|--------------------------------|-------------|
| 41548       | Winter Apparel Shoppers       | 1           |
| 42203       | Fitness Activity Tracker Users | 4           |
| 115         | Mens Shoe Shoppers            | 5           |
| 48154       | Elite Cycling Gear Shoppers   | 7           |
| 171         | Shoe Shoppers                 | 9           |

**Insight:**
- "Winter Apparel Shoppers" consistently ranks the highest, with the lowest average ranking value of 1.

---

## 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

**Query:**
```sql
WITH interest_stddev AS (
  SELECT 
    im.interest_id,
    CAST(imap.interest_name AS NVARCHAR(MAX)) AS interest_name,
    STDEV(im.percentile_ranking) AS stddev_percentile_ranking
  FROM interest_metrics im
  INNER JOIN interest_map imap
  ON im.interest_id = imap.id
  WHERE im.percentile_ranking IS NOT NULL
  GROUP BY im.interest_id, CAST(imap.interest_name AS NVARCHAR(MAX))
)
SELECT TOP 5 
    interest_id,
    interest_name,
    stddev_percentile_ranking
FROM interest_stddev
ORDER BY stddev_percentile_ranking DESC;
```

**Output:**

| interest_id | interest_name                        | stddev_percentile_ranking |
|-------------|--------------------------------------|----------------------------|
| 6260        | Blockbuster Movie Fans              | 41.27                      |
| 131         | Android Fans                        | 30.72                      |
| 150         | TV Junkies                          | 30.36                      |
| 23          | Techies                             | 30.18                      |
| 20764       | Entertainment Industry Decision Makers | 28.97                    |

**Insight:**
- "Blockbuster Movie Fans" exhibits the largest variability in their engagement with a standard deviation of 41.27.

---

## 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value?

**Query:**
```sql
WITH interest_stddev AS (
  SELECT 
    im.interest_id,
    CAST(imap.interest_name AS NVARCHAR(MAX)) AS interest_name,
    STDEV(im.percentile_ranking) AS stddev_percentile_ranking
  FROM interest_metrics im
  INNER JOIN interest_map imap
  ON im.interest_id = imap.id
  WHERE im.percentile_ranking IS NOT NULL
  GROUP BY im.interest_id, CAST(imap.interest_name AS NVARCHAR(MAX))
),
top_5_interests AS (
  SELECT TOP 5 
    interest_id,
    interest_name
  FROM interest_stddev
  ORDER BY stddev_percentile_ranking DESC
),
min_max_values AS (
  SELECT 
    im.interest_id,
    CAST(imap.interest_name AS NVARCHAR(MAX)) AS interest_name,
    MIN(im.percentile_ranking) AS min_percentile_ranking,
    MAX(im.percentile_ranking) AS max_percentile_ranking,
    MIN(im.month_year) AS min_month_year,
    MAX(im.month_year) AS max_month_year
  FROM interest_metrics im
  INNER JOIN top_5_interests ti
  ON im.interest_id = ti.interest_id
  INNER JOIN interest_map imap
  ON im.interest_id = imap.id
  GROUP BY im.interest_id, CAST(imap.interest_name AS NVARCHAR(MAX))
)
SELECT *
FROM min_max_values;
```

**Output:**

| interest_id | interest_name                        | min_percentile_ranking | max_percentile_ranking | min_month_year | max_month_year |
|-------------|--------------------------------------|-------------------------|-------------------------|----------------|----------------|
| 6260        | Blockbuster Movie Fans              | 12.5                    | 99.9                    | 2018-07-01     | 2019-08-01     |
| 131         | Android Fans                        | 15.3                    | 95.6                    | 2018-08-01     | 2019-08-01     |
| 150         | TV Junkies                          | 14.0                    | 98.2                    | 2018-09-01     | 2019-07-01     |
| 23          | Techies                             | 10.5                    | 96.8                    | 2018-07-01     | 2019-08-01     |
| 20764       | Entertainment Industry Decision Makers | 16.7                 | 92.3                    | 2018-08-01     | 2019-08-01     |

**Insight:**
- "Blockbuster Movie Fans" showed the most variability, with percentile rankings ranging from 12.5 to 99.9 over the year.

---

## 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

**Answer:**
- Customers in these segments show varied engagement levels, influenced by trends, seasons, and new releases.
- For example:
  - **Blockbuster Movie Fans** are highly engaged during major movie releases.
  - **Android Fans** prefer Android-related products and services.
  - **Entertainment Industry Decision Makers** likely value professional tools and insights.

### Recommendations:
- Promote:
  - Streaming subscriptions.
  - New tech devices.
  - Exclusive entertainment offers.
- Avoid:
  - Generic or unrelated products.

