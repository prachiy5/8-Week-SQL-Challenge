-- How many users are there?

select count(distinct user_id) as count_users
from users

--How many cookies does each user have on average?
WITH cte AS (
  SELECT user_id, COUNT(cookie_id) AS num_cookies_per_user
  FROM users
  GROUP BY user_id
)
SELECT ROUND(AVG(num_cookies_per_user), 2) AS avg_cookies
FROM cte;

--What is the unique number of visits by all users per month?

select datepart(month,event_time) as month_number,
datename(month,event_time) as month,
count(distinct visit_id) as unique_visits
 from events
 group by datepart(month,event_time),datename(month,event_time)
 order by month_number


--What is the number of events for each event type?

select event_type, count(*) as event_count from events
group by event_type


--What is the percentage of visits which have a purchase event?



SELECT 
  CAST(ROUND(COUNT(DISTINCT CASE WHEN ei.event_name = 'Purchase' THEN e.visit_id END) * 1.0 /
  COUNT(DISTINCT e.visit_id) * 100,2) AS DECIMAL(5,2)) AS purchase_percentage
FROM events e
INNER JOIN event_identifier ei
  ON e.event_type = ei.event_type;


--What is the percentage of visits which view the checkout page but do not have a purchase event?

  
WITH abc AS (
    SELECT DISTINCT visit_id,
        MAX(CASE WHEN event_name != 'Purchase' AND page_id = 12 THEN 1 ELSE 0 END) AS checkouts,
        MAX(CASE WHEN event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchases
    FROM events e
    JOIN event_identifier ei ON e.event_type = ei.event_type
    GROUP BY visit_id
)
SELECT 
    SUM(checkouts - purchases) * 100.0 / SUM(checkouts) AS percentage_checkout_no_purchase
FROM abc;

--What are the top 3 pages by number of views?

with cte as (select e.visit_id, e.page_id,ph.page_name, ei.event_name  from events e
inner join event_identifier ei
on e.event_type=ei.event_type
inner join page_hierarchy ph
on ph.page_id=e.page_id
where event_name= 'Page View'),

cte2 as(select page_name, count(*) as number_views
from cte
group by page_name),

cte3 as(select page_name, number_views,
dense_rank() over(order by number_views desc) as rn
from cte2)

select page_name, number_views 
from cte3
where rn<=3

--What is the number of views and cart adds for each product category?
with cte as(select e.visit_id, e.page_id,ph.page_name, ei.event_name,product_category  from events e
inner join event_identifier ei
on e.event_type=ei.event_type
inner join page_hierarchy ph
on ph.page_id=e.page_id)

select product_category, 
sum(case when event_name='Page View' then 1 else 0 end) as page_views,
sum(case when event_name='Add to Cart' then 1 else 0 end) as cart_adds
from cte
where product_category is not null
group by product_category
order by page_views desc,cart_adds desc

--What are the top 3 products by purchases?

with cte as(select e.visit_id, e.page_id,ph.page_name, ei.event_name,product_category,product_id,e.event_type  from events e
inner join event_identifier ei
on e.event_type=ei.event_type
inner join page_hierarchy ph
on ph.page_id=e.page_id),


purchase_events as (select distinct visit_id from cte
where  event_name='Purchase'),

cart_add as (
select distinct visit_id,product_id,page_name from cte
where event_name='Add to Cart')

select  TOP 3 page_name,count(visit_id) as number_of_purchase  from  cart_add
where visit_id in (select visit_id from purchase_events)
group by page_name
order by number_of_purchase DESC


