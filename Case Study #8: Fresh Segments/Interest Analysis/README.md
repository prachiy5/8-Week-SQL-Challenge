# 📊 Interest Analysis

## 1. Which interests have been present in all `month_year` dates in our dataset?

**Query:**
```sql
SELECT  
    CAST(i2.interest_name AS NVARCHAR(MAX)) AS interest_name, 
    COUNT(i1.month_year) AS TIME 
FROM interest_metrics i1
LEFT JOIN interest_map i2 
ON i1.interest_id = i2.id 
WHERE i1.month_year IS NOT NULL
GROUP BY CAST(i2.interest_name AS NVARCHAR(MAX))
HAVING COUNT(i1.month_year) >= (SELECT COUNT(DISTINCT month_year) FROM interest_metrics)
ORDER BY TIME DESC;
```

**Sample Output:**
| interest_name               | TIME |
|-----------------------------|------|
| Pizza Lovers                | 18   |
| Plus Size Women             | 14   |
| Pool and Spa Researchers    | 14   |
| Portugal Trip Planners      | 14   |
| Powerboat Purchasers        | 14   |
| Pre-Measured Grocery Shoppers | 14   |
| Premier League Fans         | 14   |
| Preppy Clothing Shoppers    | 14   |
| Price Conscious Home Shoppers | 14   |
| Professional Chefs          | 14   |

**Insight:**
- Interests like "Pizza Lovers" and "Premier League Fans" are consistently present in all months, indicating steady engagement throughout the dataset.

---

## 2.  Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

**Query:**
```sql
WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
),
interest_count AS (
  SELECT
    total_months,
    COUNT(interest_id) AS interests
  FROM interest_months
  GROUP BY total_months
)
SELECT TOP 1 total_months, cumulative_pct
FROM (
  SELECT *,
      CAST(100.0 * SUM(interests) OVER(ORDER BY total_months DESC)
           / SUM(interests) OVER() AS decimal(10, 2)) AS cumulative_pct
  FROM interest_count
) cumulative
WHERE cumulative_pct >= 90
ORDER BY total_months DESC;
```

**Output:**
| total_months | cumulative_pct |
|--------------|----------------|
| 6            | 90.85          |

**Insight:**
- 90% of the cumulative data points come from interests spanning at least 6 months, making this a critical threshold for analysis.
---

## 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

**Query:**
```sql
WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
)
SELECT COUNT(*) as num_interests_to_remove
FROM interest_metrics im
WHERE im.interest_id IN (
    SELECT interest_id
    FROM interest_months
    WHERE total_months < 6
);
```

**Output:**
| num_interests_to_remove |
|--------------------------|
| 400                     |

**Insight:**
- Removing interests with less than 6 months of data would eliminate 400 data points, focusing the analysis on more stable and consistent trends.
---

## 4.  Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

**Query:**
```sql
WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
)
SELECT 
    im.interest_id, 
    imap.interest_name, 
    imap.interest_summary, 
    im.total_months
FROM interest_months im
JOIN interest_map imap
ON im.interest_id = imap.id
WHERE im.total_months =14;
```

**Sample Output:**
| interest_id | interest_name             | interest_summary                                             | total_months |
|-------------|---------------------------|-------------------------------------------------------------|--------------|
| 4           | Luxury Retail Researchers | Consumers researching luxury product reviews and gift ideas. | 14           |
| 5           | Brides & Wedding Planners | People researching wedding ideas and vendors.               | 14           |
| 6           | Vacation Planners         | Consumers reading reviews of vacation destinations.         | 14           |
| 12          | Thrift Store Shoppers     | Consumers shopping online for clothing at thrift stores.    | 14           |
| 15          | NBA Fans                  | People reading articles about basketball and the NBA.       | 14           |
| 16          | NCAA Fans                 | People reading articles about college sports and the NCAA.  | 14           |
| 17          | MLB Fans                  | People reading articles about baseball and the MLB.         | 14           |

**Answer:**
Removing interest_id values with fewer than 6 months of data makes sense in certain scenarios but requires careful consideration. Interests with data spanning fewer months may indicate incomplete or inconsistent trends, making them less reliable for analysis. For example:

- **"Luxury Retail Researchers"** (14 months): Provides stable, year-round insights valuable for long-term strategies.
- **"Star Wars Fans"** (4 months): Offers niche or seasonal insights but lacks continuity.

**Conclusion:**
- Removing shorter trends helps reduce noise and focus on consistent data.
- However, this could result in losing insights into emerging or seasonal trends like "Comedy Fans," which may represent newer segments.

---

## 5.  After removing these interests - how many unique interests are there for each month?

**Query:**
```sql
WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
),
filtered_data AS (
  SELECT *
  FROM interest_metrics
  WHERE interest_id NOT IN (
    SELECT interest_id
    FROM interest_months
    WHERE total_months <6
  )
)
SELECT 
    COUNT(DISTINCT interest_id) AS unique_interests,
    COUNT(interest_id) AS all_interests
FROM filtered_data;
```

**Output:**
| unique_interests | all_interests |
|------------------|---------------|
| 1092             | 12679         |

**Insight:**
- After filtering, the dataset contains 1092 unique interests out of a total of 12,679 data points.

---

