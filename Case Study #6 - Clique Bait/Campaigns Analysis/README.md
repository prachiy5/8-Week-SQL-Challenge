# Campaign Analysis 📢

In this section, we analyze campaign performance and user behavior by generating a summary table for each visit and deriving insights from the data. The goal is to understand how campaigns influenced user engagement and purchases.

---

## Campaign Summary Table Creation 🛒

### SQL Code:
```sql
WITH visit_data AS (
    SELECT 
        e.visit_id,
        u.user_id,
        MIN(e.event_time) AS visit_start_time,
        COUNT(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE NULL END) AS page_views,
        COUNT(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE NULL END) AS cart_adds,
        MAX(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
        COUNT(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE NULL END) AS impression,
        COUNT(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE NULL END) AS click,
        STRING_AGG(CASE WHEN ei.event_name = 'Add to Cart' THEN ph.page_name ELSE NULL END, ', ') WITHIN GROUP (ORDER BY e.sequence_number) AS cart_products
    FROM events e
    LEFT JOIN event_identifier ei ON e.event_type = ei.event_type
    LEFT JOIN page_hierarchy ph ON e.page_id = ph.page_id
    LEFT JOIN users u ON e.cookie_id = u.cookie_id
    GROUP BY e.visit_id, u.user_id
),
campaign_mapping AS (
    SELECT 
        vd.visit_id,
        vd.user_id,
        vd.visit_start_time,
        vd.page_views,
        vd.cart_adds,
        vd.purchase,
        vd.impression,
        vd.click,
        vd.cart_products,
        ci.campaign_name
    FROM visit_data vd
    LEFT JOIN campaign_identifier ci 
        ON vd.visit_start_time BETWEEN ci.start_date AND ci.end_date
)
SELECT *
INTO visit_summary 
FROM campaign_mapping;
```

### Sample Output:
| visit_id | user_id | visit_start_time            | page_views | cart_adds | purchase | impression | click | cart_products                                  | campaign_name                        |
|----------|---------|-----------------------------|------------|-----------|----------|------------|-------|------------------------------------------------|---------------------------------------|
| 30b94d   | 1       | 2020-03-15 13:12:54.0239360 | 9          | 7         | 1        | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab | Half Off - Treat Your Shellf(ish)   |
| 76ee84   | 3       | 2020-05-28 20:11:54.9974060 | 7          | 3         | 1        | 0          | 0     | Salmon, Lobster, Crab                          | NULL                                  |
| 9a2f24   | 3       | 2020-02-21 03:19:10.0324550 | 6          | 2         | 1        | 0          | 0     | Kingfish, Black Truffle                        | Half Off - Treat Your Shellf(ish)    |
| 07a950   | 4       | 2020-03-19 17:56:24.6104450 | 6          | 0         | 0        | 0          | 0     | NULL                                           | Half Off - Treat Your Shellf(ish)    |
| 4bffe1   | 5       | 2020-02-26 16:03:10.3778810 | 8          | 1         | 0        | 0          | 0     | Russian Caviar                                | Half Off - Treat Your Shellf(ish)    |
| 8dd946   | 7       | 2020-02-25 05:51:07.8852980 | 1          | 0         | 0        | 0          | 0     | NULL                                           | Half Off - Treat Your Shellf(ish)    |
| 6fc659   | 9       | 2020-03-01 21:25:25.8472490 | 10         | 5         | 1        | 1          | 1     | Salmon, Tuna, Black Truffle, Lobster, Oyster  | Half Off - Treat Your Shellf(ish)    |
| d69e73   | 12      | 2020-02-06 09:09:05.9088780 | 5          | 1         | 0        | 0          | 0     | Lobster                                       | Half Off - Treat Your Shellf(ish)    |
| 430980   | 14      | 2020-03-11 21:10:15.7009220 | 1          | 0         | 0        | 0          | 0     | NULL                                           | Half Off - Treat Your Shellf(ish)    |
| 48810d   | 18      | 2020-02-29 15:26:40.9470950 | 4          | 0         | 0        | 0          | 0     | NULL                                           | Half Off - Treat Your Shellf(ish)    |

---

## Insights & Analysis 

### 1. **Ad Impressions Drive Higher Conversions**

**Query**:
```sql
SELECT 
    campaign_name,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT CASE WHEN impression > 0 THEN user_id ELSE NULL END) AS users_with_impressions,
    COUNT(DISTINCT CASE WHEN impression = 0 THEN user_id ELSE NULL END) AS users_without_impressions,
    ROUND(100.0 * SUM(CASE WHEN impression > 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN impression > 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_impressions,
    ROUND(100.0 * SUM(CASE WHEN impression = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN impression = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_without_impressions
FROM visit_summary
GROUP BY campaign_name;
```

**Output**:
| campaign_name                    | total_users | users_with_impressions | users_without_impressions | purchase_rate_with_impressions | purchase_rate_without_impressions |
|----------------------------------|-------------|-------------------------|---------------------------|----------------------------------|-----------------------------------|
| BOGOF - Fishing For Compliments | 103         | 59                      | 103                       | 84.62                           | 36.92                            |
| NULL                             | 183         | 101                     | 183                       | 79.07                           | 43.34                            |
| Half Off - Treat Your Shellf(ish)| 449         | 352                     | 449                       | 85.29                           | 37.96                            |
| 25% Off - Living The Lux Life    | 160         | 91                      | 160                       | 83.65                           | 38.33                            |

**Key Insight**:
- Ad impressions significantly boost purchase rates across all campaigns.
- Example: "Half Off - Treat Your Shellf(ish)" saw an **85.29% purchase rate** for users with impressions, compared to **37.96%** without.

---

### 2. **Does Clicking on Impressions Lead to Higher Purchase Rates?**

**Query**:
```sql
SELECT 
    COUNT(CASE WHEN click > 0 AND purchase = 1 THEN 1 ELSE NULL END) AS purchases_with_click,
    COUNT(CASE WHEN click = 0 AND purchase = 1 THEN 1 ELSE NULL END) AS purchases_without_click,
    ROUND(100.0 * SUM(CASE WHEN click > 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN click > 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_click,
    ROUND(100.0 * SUM(CASE WHEN click = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN click = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_without_click
FROM visit_summary;
```

**Output**:
| purchases_with_click | purchases_without_click | purchase_rate_with_click | purchase_rate_without_click |
|-----------------------|-------------------------|--------------------------|-----------------------------|
| 624                   | 1153                   | 88.89                    | 40.29                      |

**Key Insight**:
- Users who clicked on ads had an **88.89% purchase rate**, significantly higher than the **40.29%** for those who didn’t click.

---

### 3. **Uplift in Purchase Rates: Clicks vs. Impressions**

**Query**:
```sql
SELECT 
    ROUND(100.0 * SUM(CASE WHEN click > 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN click > 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_click,
    ROUND(100.0 * SUM(CASE WHEN impression > 0 AND click = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN impression > 0 AND click = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_impression_no_click,
    ROUND(100.0 * SUM(CASE WHEN impression = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN impression = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_without_impression
FROM visit_summary;
```

**Output**:
| purchase_rate_with_click | purchase_rate_with_impression_no_click | purchase_rate_without_impression |
|--------------------------|-----------------------------------------|----------------------------------|
| 88.89                   | 64.94                                  | 38.69                           |

**Key Insight**:
- Clicking on ads leads to the highest purchase rate (**88.89%**).
- Impressions without clicks still improve purchase rates (**64.94%**) compared to no impressions (**38.69%**).

---

### 4. **Metrics to Compare Campaign Success**

**Query**:
```sql
SELECT 
    campaign_name,
    ROUND(100.0 * SUM(purchase) / COUNT(visit_id), 2) AS purchase_rate,
    AVG(cart_adds) AS avg_cart_adds,
    AVG(page_views) AS avg_page_views,
    AVG(impression) AS avg_impressions,
    AVG(click) AS avg_clicks
FROM visit_summary
GROUP BY campaign_name;
```

**Output**:
| campaign_name                    | purchase_rate | avg_cart_adds | avg_page_views | avg_impressions | avg_clicks |
|----------------------------------|---------------|---------------|----------------|-----------------|------------|
| BOGOF - Fishing For Compliments | 48.85         | 2             | 5              | 0               | 0          |
| NULL                             | 52.34         | 2             | 5              | 0               | 0          |
| Half Off - Treat Your Shellf(ish)| 49.41         | 2             | 5              | 0               | 0          |
| 25% Off - Living The Lux Life    | 50.00         | 2             | 6              | 0               | 0          |

**Key Insight**:
- "25% Off - Living The Lux Life" had the highest purchase rate (**50%**) and the most page views (**6 average views per visit**).

---

### Summary
- Ad impressions and clicks significantly improve purchase rates.
- Campaigns like "25% Off - Living The Lux Life" show strong engagement and conversion metrics, providing a blueprint for future strategies.
- Retargeting non-impression users could further optimize campaign performance.
