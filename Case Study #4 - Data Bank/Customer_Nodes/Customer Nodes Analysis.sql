--Customer Nodes Exploration

--How many unique nodes are there on the Data Bank system?

select count(distinct node_id) nodes from customer_nodes

--What is the number of nodes per region?



select region_name, count(node_id) as num_of_nodes 
from customer_nodes c
inner join regions r
on c.region_id=r.region_id
group by region_name



--How many customers are allocated to each region?

select region_name, count(distinct customer_id) as num_of_nodes 
from customer_nodes c
inner join regions r
on c.region_id=r.region_id
group by region_name

--How many days on average are customers reallocated to a different node?

select * from customer_nodes

select distinct start_date from customer_nodes

select distinct end_date from customer_nodes

select avg(datediff(Day, start_date,end_date)) as avg_number_of_days
from customer_nodes
where end_date != '9999-12-31';

--What is the median, 80th and 95th percentile for this same reallocation days metric for each region


with cte as(select customer_id, cn.region_id,region_name, datediff(day,start_date,end_date) as reallocation_days
from customer_nodes cn
inner join regions r
on cn.region_id= r.region_id
where end_date!='9999-12-31')

select distinct region_id,region_name,
PERCENTILE_CONT(0.5) within group(order by reallocation_days) over(partition by region_name) as median,
percentile_cont(0.8) within group(order by reallocation_days) over(partition by region_name) as percentile_80,
PERCENTILE_CONT(0.95) within group(order by reallocation_days) over(partition by region_name) as percentile_95
from cte
order by region_name




SELECT DISTINCT region_id,
	   region_name,
	   PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY reallocation_days) OVER(PARTITION BY region_name) AS median,
	   PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY reallocation_days) OVER(PARTITION BY region_name) AS percentile_80,
	   PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY reallocation_days) OVER(PARTITION BY region_name) AS percentile_95
FROM date_diff
ORDER BY region_name;