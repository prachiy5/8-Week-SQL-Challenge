# Data Mart Case Study: Bonus Question Analysis

## Bonus Question
**Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 weeks before and after the sustainable packaging change?**

### Business Dimensions Analyzed
- **Region**
- **Platform**
- **Age Band**
- **Demographic**
- **Customer Type**

---

## SQL Query

```sql
WITH period_sales AS (
    SELECT
        CASE
            WHEN week_date < '2020-06-15' AND week_date >= '2020-03-23' THEN 'Before'
            WHEN week_date >= '2020-06-15' AND week_date < '2020-09-07' THEN 'After'
        END AS period,
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE week_date BETWEEN '2020-03-23' AND '2020-09-06'
    GROUP BY
        CASE
            WHEN week_date < '2020-06-15' AND week_date >= '2020-03-23' THEN 'Before'
            WHEN week_date >= '2020-06-15' AND week_date < '2020-09-07' THEN 'After'
        END,
        region,
        platform,
        age_band,
        demographic,
        customer_type
),
sales_comparison AS (
    SELECT
        region,
        platform,
        age_band,
        demographic,
        customer_type,
        MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END) AS sales_before,
        MAX(CASE WHEN period = 'After' THEN total_sales ELSE 0 END) AS sales_after,
        MAX(CASE WHEN period = 'After' THEN total_sales ELSE 0 END) - 
        MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END) AS sales_difference,
        ROUND(
            CASE
                WHEN MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END) = 0 THEN 0
                ELSE 
                    ((MAX(CASE WHEN period = 'After' THEN total_sales ELSE 0 END) - 
                      MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END)) * 100.0 /
                     MAX(CASE WHEN period = 'Before' THEN total_sales ELSE 0 END))
            END, 2
        ) AS percentage_change
    FROM period_sales
    GROUP BY region, platform, age_band, demographic, customer_type
)
SELECT
    region,
    platform,
    age_band,
    demographic,
    customer_type,
    sales_before,
    sales_after,
    sales_difference,
    percentage_change
FROM sales_comparison
ORDER BY percentage_change ASC;
```

---

## Output (Sample Rows)

| Region        | Platform | Age Band   | Demographic | Customer Type | Sales Before | Sales After | Sales Difference | Percentage Change |
|---------------|----------|------------|-------------|---------------|--------------|-------------|------------------|-------------------|
| SOUTH AMERICA | Shopify  | unknown    | unknown     | Existing      | 11785        | 6808        | -4977            | -42.23            |
| EUROPE        | Shopify  | Retirees   | Families    | New           | 7292         | 4834        | -2458            | -33.71            |
| EUROPE        | Shopify  | Young Adults | Families   | New           | 15863        | 11426       | -4437            | -27.97            |
| SOUTH AMERICA | Retail   | unknown    | unknown     | Existing      | 127781       | 98131       | -29650           | -23.20            |
| SOUTH AMERICA | Retail   | Retirees   | Families    | New           | 168495       | 132639      | -35856           | -21.28            |

---

## Insights

### Key Business Observations
1. **Regions with the Most Impact**:
   - South America on Shopify experienced the highest percentage decline (-42.23%).
   - Retail in South America and Europe also showed significant declines, particularly among "unknown" demographics and new customers.

2. **Customer Segments**:
   - "New" customer types and "unknown" demographics consistently showed high negative impacts, indicating potential gaps in onboarding or targeting strategies.

3. **Platforms**:
   - Shopify platforms faced greater declines compared to Retail, particularly in South America and Europe, hinting at potential platform-specific challenges.

4. **Positive Areas**:
   - Certain regions like Oceania and Asia showed positive performance, particularly among Middle-Aged Couples and Young Adults. These can serve as benchmarks for underperforming areas.

### Recommendations for Danny’s Team
1. **Target Problem Areas**:
   - Investigate South America and Europe on Shopify for specific challenges. Analyze factors like platform user experience, regional marketing efforts, and product availability.

2. **Improve Data Collection**:
   - Address the "unknown" demographics to enhance customer segmentation and enable personalized targeting.

3. **Engage New Customers**:
   - Develop a retention strategy for new customers, such as tailored offers, follow-up campaigns, and incentives for repeat purchases.

4. **Replicate Success**:
   - Study successful segments like Oceania Retail (Young Adults) or Asia Shopify (Middle-Aged Couples). Identify what worked and replicate strategies in struggling areas.

5. **Future Rollouts**:
   - Conduct smaller pilot tests for future sustainability initiatives to measure customer reactions and mitigate potential sales impacts.

---

This README file provides a detailed exploration of the bonus question, offering actionable insights based on real-world business scenarios to support strategic decision-making at Data Mart.

