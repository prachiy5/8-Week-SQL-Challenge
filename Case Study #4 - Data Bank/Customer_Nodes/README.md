
## Customer Node Analysis

### Introduction
The **Customer Node Analysis** explores how customers and their data are distributed across Data Bank's global network of nodes. These nodes function as secure repositories for both customer funds and data storage. By analyzing this distribution, we aim to provide insights that help Data Bank optimize its resource allocation, enhance security, and ensure operational efficiency.

---

### Objective
The objective of this analysis is to answer key questions about customer nodes:
1.  How many unique nodes are there on the Data Bank system?
  ```sql
select count(distinct node_id) nodes from customer_nodes
```
- **Output**: `5`

2. What is the number of nodes per region??
  ```sql
select region_name, count(node_id) as num_of_nodes 
from customer_nodes c
inner join regions r
on c.region_id=r.region_id
group by region_name

```
| Region Name | Number of Nodes |
|-------------|-----------------|
| Africa      | 714             |
| America     | 735             |
| Asia        | 665             |
| Australia   | 770             |
| Europe      | 616             |
---

3. How many customers are allocated to each region?
```sql
select region_name, count(distinct customer_id) as num_of_nodes 
from customer_nodes c
inner join regions r
on c.region_id=r.region_id
group by region_name
   ```

| Region Name | Number of Customers |
|-------------|---------------------|
| Africa      | 102                 |
| America     | 105                 |
| Asia        | 95                  |
| Australia   | 110                 |
| Europe      | 88                  |
---

4. How many days on average are customers reallocated to a different node?

```sql
  --
select * from customer_nodes

select distinct start_date from customer_nodes

select distinct end_date from customer_nodes

select avg(datediff(Day, start_date,end_date)) as avg_number_of_days
from customer_nodes
where end_date != '9999-12-31';
   ```
- **Output**: `14`
 ---  
5.  What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
```sql
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
```
| Region ID | Region Name | Median | 80th Percentile | 95th Percentile |
|-----------|-------------|--------|-----------------|-----------------|
| 3         | Africa      | 15     | 24              | 28              |
| 2         | America     | 15     | 23              | 28              |
| 4         | Asia        | 15     | 23              | 28              |
| 1         | Australia   | 15     | 23              | 28              |
| 5         | Europe      | 15     | 24              | 28              |
---
### Insights
1. The system operates with **5 unique nodes**, ensuring a distributed and secure setup.
2. The **Australia** region has the highest number of nodes (770), while **Europe** has the least (616).
3. **Australia** also has the most customers (110), indicating a high concentration of activity.
4. On average, customers are reallocated every **14 days**, ensuring frequent redistribution for security.
5. The reallocation days are consistent across regions, with a **median of 15 days** and 80th and 95th percentiles reaching up to 28 days.


