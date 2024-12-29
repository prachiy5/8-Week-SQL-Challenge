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


select * from visit_summary

-------------------------
--Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event

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


-------------------------
--Does clicking on an impression lead to higher purchase rates?

SELECT 
    COUNT(CASE WHEN click > 0 AND purchase = 1 THEN 1 ELSE NULL END) AS purchases_with_click,
    COUNT(CASE WHEN click = 0 AND purchase = 1 THEN 1 ELSE NULL END) AS purchases_without_click,
    ROUND(100.0 * SUM(CASE WHEN click > 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN click > 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_click,
    ROUND(100.0 * SUM(CASE WHEN click = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN click = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_without_click
FROM visit_summary;

-----------------------

--What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression?
--What if we compare them with users who just an impression but do not click?

SELECT 
    ROUND(100.0 * SUM(CASE WHEN click > 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN click > 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_click,
    ROUND(100.0 * SUM(CASE WHEN impression > 0 AND click = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN impression > 0 AND click = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_with_impression_no_click,
    ROUND(100.0 * SUM(CASE WHEN impression = 0 AND purchase = 1 THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN impression = 0 THEN 1 ELSE 0 END), 0), 2) AS purchase_rate_without_impression
FROM visit_summary;


---------------------------

--What metrics can you use to quantify the success or failure of each campaign compared to eachother?

SELECT 
    campaign_name,
    ROUND(100.0 * SUM(purchase) / COUNT(visit_id), 2) AS purchase_rate,
    AVG(cart_adds) AS avg_cart_adds,
    AVG(page_views) AS avg_page_views,
    AVG(impression) AS avg_impressions,
    AVG(click) AS avg_clicks
FROM visit_summary
GROUP BY campaign_name;
