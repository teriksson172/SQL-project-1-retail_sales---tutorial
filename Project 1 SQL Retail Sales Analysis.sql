-- SQL Retail Sales Analysis - P1

--CREATE DATABASE sql_project_p2;


SELECT current_database(), current_schema();

-- Create Table

DROP TABLE IF EXISTS retail_sales;
Create Table retail_sales
	(
		transactions_id INT Primary Key,
		sale_date DATE,
		sale_time TIME,
		customer_id	INT,
		gender VARCHAR(25),
		age INT,
		category VARCHAR(25),
		quantity INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
	);

--SELECT current_database();
--SELECT 1;
SELECT COUNT(*) FROM retail_sales;


SELECT * FROM retail_sales
LIMIT 10;

-- Data Cleaning

Select * From retail_sales
Where transactions_id Is Null;

Select * From retail_sales
Where sale_date Is Null;

Select * From retail_sales
Where sale_time Is Null;

Select * From retail_sales
Where customer_id Is Null;

Select * From retail_sales
Where gender Is Null;

Select * From retail_sales
Where age Is Null;

Select * From retail_sales
Where category Is Null;

Select * From retail_sales
Where quantity Is Null;

Select * From retail_sales
Where price_per_unit Is Null;

Select * From retail_sales
Where cogs Is Null;

Select * From retail_sales
Where total_sale Is Null;

-- All Together
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

 -- Delete rows with nulls
Delete From retail_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

 -- Data Exploration

 -- Nr of sales
 Select count(*)as total_sale from retail_sales

-- nr of customers
 Select count(Distinct customer_id)as total_sale from retail_sales

-- categories
 Select Distinct category as total_sale from retail_sales

-- data Analysis & Business Key Problems

--Q1 Write a SQL queery to retrieve all colum ns for sales made on '2022-11-05'
select *
from retail_sales
where sale_date = '2022-11-05';

-- Q2 Write a SQL queery to retrieve all transactions where the category is "clothing" and the quantity sold is more than 10 in the month of nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';

-- Alt

select *
from retail_sales
where category = 'Clothing'
	and
	to_char(sale_date, 'YYYY-MM') = '2022-11'
	and
	quantity >= 4
Group By 1

-- Q3 Write a SQL queery to calculate the total sales (total_sale) for each category

select
	category,
	sum(total_sale) as net_sale,
	count(*) as total_orders
from retail_sales
group by 1

-- Q4 fin the avg age of customers who purchase items from the "Beauty" category

select
	avg(age) as avg_age
	from retail_sales
where category = 'Beauty'

-- Q5 find all transactions where the total_sale is greater than 1000

select *
from retail_sales
where total_sale > 1000

-- Q6 find the total nr of transactions (transaction_id) made by each gender in each category

-- group by category
select
	category,
	gender,
	COUNT(*) as total_trans
from retail_sales
group
by
	category,
	gender

order by 1

-- Q7 calculate the avg sale for each month and find the best selling month in each year

select 
	year,
	month,
	avg_sale
from
(
	select
		extract(year from sale_date) as year,
		extract(month from sale_date) as month,
		rank() over(partition by extract(year from sale_date) order by avg(total_sale) desc) as rank,
		avg(total_sale) as avg_sale
	from retail_sales
	group by 1, 2
	--order by 1, 3 desc
) as t1
where rank  = 1

-- Q8 find the top 5 customer based on the highest total sale

select * from retail_sales
select
	customer_id,
	sum_sales,
	rank
from
(
	select
		customer_id,
		sum(total_sale) as sum_sales,
		rank() over(order by sum(total_sale) desc) as rank
	from retail_sales
	group by 1
) as t1
where rank <= 5

-- alt
select
	customer_id,
	sum(total_sale) as total_sales
from retail_sales
group by 1
order by 2
limit 5

-- Q9 find the number of unique customer who purchased items from each category

select
	count(distinct customer_id),
	category
from retail_sales
group by 2

-- Q10 create each shift and number of orders (ex: morning <= 12, 12 < afternoon <= 17, afternoon > 17)
select* from retail_sales

select
	sale_date,
	--sale_time as sale_time,
	sale_time <= '12:00:00' as morning,
	sale_time > '12:00:00' and sale_time <= '17:00:00' as afternoon,
	sale_time > '17:00:00' as evening,
	count(*) as total_orders
	--sum(total_sale)
	--customer_id
from retail_sales
group by 1, 2, 3, 4
order by 1, 2, 3, 4

with hourly_sale -- create a table with the shift column added to the data
as
(
select *,
	case -- Adding shift column
		when extract(hour from sale_time) < 12 then 'Morning'
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		else ' Evening'
	end as shift
from retail_sales
)
select
	shift,
	count(*) as total_orders
from hourly_sale
group by shift
