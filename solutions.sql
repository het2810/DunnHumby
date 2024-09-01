 --Question-1 :Find the number of orders that are small, medium or large order value(small:0-5$, 
-- medium:5-10$, large:10+)

WITH order_sizes AS (
  SELECT basket_id,
         CAST(sales_value AS FLOAT) AS sales_value,
         CASE WHEN CAST(sales_value AS FLOAT) < 5 THEN 'Small'
              WHEN CAST(sales_value AS FLOAT) BETWEEN 5 AND 10 THEN 'Medium'
              ELSE 'Large'
         END AS order_size
  FROM transaction_data
)
SELECT order_size, COUNT(*) AS order_count
FROM order_sizes
GROUP BY order_size;


-- Question-2:Find top 3 stores with highest foot traffic for each week (Foot traffic: number of customers 
-- transacting )


select count(store_id),store_id from transaction_data  group by store_id order by count(store_id) desc limit 3;

--Question 3. Create a basic customer profiling with first, last visit, number of visits, average money spent 
-- per visit and total money spent order by highest avg money

-- Doubt : Explain Day column in transaction_data 

select household_key , min(day) first_visit , max(day) last_visit , count(household_key) number_of_visits,
	round(avg(cast(sales_value as float))::numeric,2)::double precision avg_sales_per_visit ,
	round(sum(cast(sales_value as float))::numeric,2)::double precision sum_sales
	from transaction_data group by household_key order by avg(cast(sales_value as float));
	

-- Question 4. Do a single customer analysis selecting most spending customer for whom we have 
-- demographic information(because not all customers in transaction data are present in 
-- demographic table)(show the demographic as well as profiling data)

WITH top_spender AS (
  SELECT
    h.household_key,
    SUM(CAST(sales_value AS FLOAT)) AS total_spent
  FROM transaction_data t
  INNER JOIN hh_demographic h ON t.household_key = h.household_key  
  GROUP BY h.household_key
  ORDER BY total_spent DESC
  limit 1 
),
product_minmax AS (
  SELECT
    ts.household_key,
    MIN(product_id) AS min_product_id,
    MAX(product_id) AS max_product_id
  FROM top_spender ts
  INNER JOIN transaction_data t ON ts.household_key = t.household_key
  GROUP BY ts.household_key
),
store_visits AS (
  SELECT
    household_key,
    store_id,
    COUNT(*) AS visit_count
  FROM transaction_data
  GROUP BY household_key, store_id
)
SELECT
  ts.household_key,
  h.age_desc,  -- Demographic from hh_demographic
  h.income_desc,  -- Demographic from hh_demographic
  h.martial_status_code,  -- Demographic from hh_demographic

  tv.first_visit,
  tv.last_visit,
  tv.visit_count,
  round(avg(cast(tv.sales_value as float))::numeric, 2) :: double precision avg_sales_per_visit,
  round(sum(cast(tv.sales_value as float))::numeric, 2) :: double precision sum_sales
FROM top_spender ts
INNER JOIN hh_demographic h ON ts.household_key = h.household_key  -- Inner join for top spender with demographics
LEFT JOIN (
  SELECT
    household_key,
    MIN(day) AS first_visit,
    MAX(day) AS last_visit,
    COUNT(*) AS visit_count,
    sales_value
  FROM transaction_data
  GROUP BY household_key, sales_value
) tv ON ts.household_key = tv.household_key
GROUP BY ts.household_key, h.age_desc, h.income_desc, h.martial_status_code, tv.first_visit, tv.last_visit, tv.visit_count;



-- Qustion 5. Find products(product table :SUB_COMMODITY_DESC) which are most frequently bought 
-- together

--Harshils Query :

-- WITH CTE AS(
-- SELECT PRODUCT_ID,WEEK_NO,DENSE_RANK() OVER(PARTITION BY PRODUCT_ID ORDER BY WEEK_NO) FREQUENCY FROM PRODUCT  
-- JOIN CAUSAL_DATA USING(PRODUCT_ID)
-- ),
-- CTE2 AS(
-- 	SELECT PRODUCT_ID,FREQUENCY,COUNT(FREQUENCY) CF FROM CTE GROUP BY PRODUCT_ID,FREQUENCY
-- )SELECT DISTINCT PRODUCT_ID,SUB_COMMODITY_DESC FROM PRODUCT WHERE PRODUCT_ID IN (SELECT PRODUCT_ID FROM CTE2 GROUP BY PRODUCT_ID ORDER BY MAX(CF) DESC LIMIT 5);
with cte as(
	select t1.basket_id bid,t1.product_id p1,t2.product_id p2 from transaction_data t1 join transaction_data t2 on 
	t1.basket_id = t2.basket_id and t1.product_id<>t2.product_id
)select p1,p2,count(*) from cte group by p1,p2 having count(*)>1 order by count(*) desc;
				
-- Question 6. Find out on which weeks does each household shop and find their cumulative 
-- spending over time(sum of all previous) (uses sum over partition)
SELECT
  household_key,
  week_no,
  sum(cast(sales_value as float)) AS weekly_spend,
  sum(sum(cast(sales_value as float))) over (partition by household_key order by week_no) AS cumulative_spend
FROM transaction_data
GROUP BY household_key, week_no
ORDER BY household_key, week_no;


-- Question 7. Find the weekly change in Revenue Per Account (RPA) (spending by each customer 
-- compared to last week)(use lag function)
-- Doubt : TYPE casting issue !!
WITH total_weekly_spend AS (
	select week_no,sum(cast(sales_value as float)) as weekly_spend from transaction_data group by week_no 
)
select *,lag(weekly_spend,1,0) over(order by week_no) as previous_week_spend , 
		weekly_spend - lag(weekly_spend,1,0) over(order by week_no) as weekly_change 
		from total_weekly_spend ;
		
-- Question 8. Find number of returning customers and percent of returning customers for all week
with first_visit as(
	select household_key,min(week_no) as first_visit from transaction_data group by household_key
),
visitor_check as (
	select td.household_key,td.week_no , fv.first_visit ,
		case when td.week_no  = fv.first_visit then 1 else 0 end as first_visitor,
		case when td.week_no  != fv.first_visit then 1 else 0 end as repeat_visitor
		from transaction_data td
		inner join first_visit fv on td.household_key = fv.household_key
		order by household_key
)
,
total_visitor_counts as (
	select week_no , sum(first_visitor) as total_new_customer_weekly, sum(repeat_visitor) as total_repeat_customer_weekly
		from visitor_check 
		group by week_no 
		order by week_no
)
,
percent_calc as (
	select *, lag(total_repeat_customer_weekly,1,0) over (order by week_no) privious_weekly_repeated_customer,
		total_repeat_customer_weekly - lag(total_repeat_customer_weekly,1,0) over (order by week_no) as diff_percent
		from total_visitor_counts

)
select *,
case 
	when
		total_repeat_customer_weekly = 0 then 0
	else 
		round((total_repeat_customer_weekly / (total_repeat_customer_weekly + pc.privious_weekly_repeated_customer ))*100,2)
	end as percentage_of_weekly_new_customer
from percent_calc pc ;

-- Question 9. Quarterly analysis: sales comparison: total sale amount (create a new quarter 
-- column using case where,12 weeks(3 months)=1 quarter)
-- (Use cte tables)


WITH weekly_data AS (
  SELECT
    household_key,sales_value,week_no,
	case 
		when week_no % 13 =0 then week_no / 13
	else
		ceil(week_no/13)+1
	end as sub_quarter
	from transaction_data
	where week_no >52 
	order by week_no
	
),
quarterly_sales AS (
  SELECT
    household_key,
	sales_value,week_no,
	case 
		when sub_quarter :: int%4 = 0 then 4 
	else 
		sub_quarter :: int%4 
	end as quarter
  FROM weekly_data 
	
)
SELECT quarter , round(sum(sales_value)) total_sales_amount_quarterly 
	from quarterly_sales 
	group by quarter
	order by quarter;

