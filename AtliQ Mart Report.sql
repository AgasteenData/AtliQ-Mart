-- Creating Database
create database retail_events_db

use retail_events_db

--Changing the datatype smallint to biging 

ALTER TABLE fact_events
ALTER COLUMN  quantity_sold_after_promo bigint

--Reading all Tables 

select * from dim_campaigns

select * from dim_stores

select * from dim_products

select * from fact_events





-- Store Performance Analysis:


--- Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?.

select top 5 store_id ,SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) as IR 

from fact_events  

group by store_id

order by SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc

======================================================================================================================================

-- Which are the bottom 10 stores when it comes to Incremental Sold Units (ISU)during the promotional period?.

select top 5 store_id, SUM(quantity_sold_after_promo - quantity_sold_before_promo) as ISU 

from fact_events  

group by store_id

order by SUM(quantity_sold_after_promo - quantity_sold_before_promo) asc

========================================================================================================================================

--  How does the performance of stores vary by city?
with cte as (
			select t2.city,t2.store_id , promo_type,SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) as IR,

			SUM(quantity_sold_after_promo - quantity_sold_before_promo) as ISU, 
			
			DENSE_RANK() over(partition by city order by SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc) as [Rank]

			from fact_events t1 

			inner join dim_stores t2 on t1.store_id = t2.store_id

			group by t2.city, t2.store_id ,promo_type
			)

select city, store_id,IR,ISU,promo_type 

from cte

where [Rank] = 1

order  by IR desc, ISU desc

==========================================================================================================================================
--Each store in all cities by IR and ISU

select t2.city,t2.store_id,SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) as IR,

SUM(quantity_sold_after_promo - quantity_sold_before_promo) as ISU,--sum(t1.quantity_sold_before_promo) B, sum(t1.quantity_sold_after_promo) F

t1.promo_type

from fact_events t1 

inner join dim_stores t2 on t1.store_id = t2.store_id

group by t2.city,t2.store_id,t1.promo_type

order by SUM(quantity_sold_after_promo - quantity_sold_before_promo) desc,

SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc

================================================================================================================================================


--Are there any common characteristics among the top-performing stores that could be leveraged across other stores?
with rank_store as (
					select t2.store_id,promo_type,SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) as IR,

					
					SUM(quantity_sold_after_promo - quantity_sold_before_promo) as ISU,
					
					DENSE_RANK() over(partition by t2.store_id,promo_type order by SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc) as [Rank]
					
					from fact_events t1 
					
					inner join dim_stores t2 on t1.store_id = t2.store_id
					
					group by t2.store_id,promo_type
					)

select  top 10 * from rank_store

order by IR desc,ISU desc

-- Promotion Type Analysis:

--•1. What are the top 2 promotion types that resulted in the highest Incremental Revenue?. 

select top 2  promo_type, sum((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo))  as IR

from fact_events 

group by  promo_type

order by sum((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc

=======================================================================================================================================
--•2. What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?. 

select top 2 promo_type ,sum(quantity_sold_after_promo - quantity_sold_before_promo) as IUS

from fact_events

group by promo_type

order by sum(quantity_sold_after_promo - quantity_sold_before_promo) asc

========================================================================================================================================

--•3. Is there a significant difference in the performance of discount-based promotions versus BOGOF (Buy One 
---Get One Free) or cashback promotions?.

select promo_type,store_id,sum((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo))  as IR ,

	sum(quantity_sold_after_promo - quantity_sold_before_promo) as IUS, AVG(base_price) as [Avg price] ,
	
	COUNT(quantity_sold_after_promo) [No.of_Tran]

from 
	fact_events

--where promo_type in ('500 Cashback', 'BOGOF')

group by promo_type,store_id

order by [No.of_Tran] desc,sum((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc

========================================================================================================================================

--Top performance promotion by IR and ISU
SELECT 

    
	promo_type,
    
	SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo))  as IR ,
    
	sum(quantity_sold_after_promo - quantity_sold_before_promo) as ISU
FROM 
    fact_events
GROUP BY 
    promo_type
ORDER BY 
    IR DESC, ISU DESC;

===================================================================================================================================

--4.• Which promotions strike the best balance between Incremental Sold Units and maintaining healthy margins?
with cte as (
select *,  CASE 
                WHEN promo_type = '50% OFF' THEN base_price * 0.5
                WHEN promo_type = '25% OFF' THEN base_price * 0.75
                WHEN promo_type = 'BOGOF' THEN base_price * 0.5
                WHEN promo_type LIKE '%Cashback%' THEN base_price - CAST(SUBSTRING(promo_type, 1, CHARINDEX(' ', promo_type)) AS FLOAT)
                ELSE base_price 
            END as Margin
from fact_events
)

select promo_type, sum(Margin) as Margin, sum(quantity_sold_after_promo - quantity_sold_before_promo) as IUS 

from cte

group by promo_type

order by Margin desc, IUS desc
 
===================================================================================================================================


---Product and category Analysis

---1.Which product categories saw the most significant lift in sales from the promotions?.

select category

	,sum(quantity_sold_after_promo- quantity_sold_before_promo) as IUS 
from
	dim_products t1 
	
	join fact_events t2 on t1.product_code = t2.product_code
group by 
		category
order by
		sum(quantity_sold_after_promo- quantity_sold_before_promo) desc

======================================================================================================================================

--Category sold percetage before and after promotion
SELECT 
    t1.category, 
    SUM(t2.quantity_sold_before_promo) AS total_quantity_before_promo, 
    SUM(t2.quantity_sold_after_promo) AS total_quantity_after_promo,
    (SUM(t2.quantity_sold_after_promo) * 100.0 / 
        (SELECT SUM(quantity_sold_after_promo) FROM fact_events)) AS percentage_after_promo,
    (SUM(t2.quantity_sold_before_promo) * 100.0 / 
        (SELECT SUM(quantity_sold_after_promo) FROM fact_events)) AS percentage_before_promo
FROM 
    dim_products t1
JOIN 
    fact_events t2 
ON 
    t1.product_code = t2.product_code
GROUP BY 
    t1.category
ORDER BY 
    SUM(t2.quantity_sold_after_promo) DESC, 
    SUM(t2.quantity_sold_before_promo) DESC;

============================================================================================================================================ 

--Top 3 products by highest Incremental Units Sold
SELECT  
    category,
    SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price)) AS IR
FROM dim_products t1
JOIN fact_events t2 ON t1.product_code = t2.product_code
GROUP BY category
ORDER BY SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price))  DESC


=======================================================================================================================================

-- Top 3 products by highest Incremental Units Sold
SELECT 

    product_name,promo_type ,SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price)) AS IR,

    SUM(quantity_sold_after_promo - quantity_sold_before_promo) AS IUS, AVG(base_price) av

FROM 
	dim_products t1
JOIN 
	fact_events t2 ON t1.product_code = t2.product_code
GROUP BY 
		product_name,promo_type
having 
		SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price)) < 0
ORDER BY 
		SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price))  asc

=========================================================================================================================================

-- Top 3 products by lowest Incremental Units Sold
SELECT top 3
		product_name,promo_type,--SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price)) AS IR
		SUM(quantity_sold_after_promo - quantity_sold_before_promo) AS IUS
FROM 
	dim_products t1
JOIN 
	fact_events t2 ON t1.product_code = t2.product_code
GROUP BY 
		product_name,promo_type
--having SUM(quantity_sold_after_promo - quantity_sold_before_promo)<0
ORDER BY  
		SUM(quantity_sold_after_promo - quantity_sold_before_promo) desc;--SUM((quantity_sold_after_promo* base_price) - (quantity_sold_before_promo*base_price))desc

=======================================================================================================================================

--3. What is the correlation between product category and promotion type effectiveness?
with cte as (

			select category,promo_type,SUM(quantity_sold_after_promo - quantity_sold_before_promo) as IUS,
			DENSE_RANK() over(partition by promo_type order by SUM(quantity_sold_after_promo - quantity_sold_before_promo) desc) as [RANK]
from 
	fact_events t1  
inner join	
		dim_products as t2 on t1.product_code = t2.product_code
group by 
		category,promo_type


)
select * from cte
where [RANK] = 1
order by IUS desc

==================================================================================================================================

--4. How does the performance of products vary by city?

select  top 10 
		city,promo_type, product_name ,SUM(quantity_sold_after_promo - quantity_sold_before_promo) as IUS
		,SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) as IR
		,AVG(base_price) [Avg_Base_Price], MAX(base_price) [Max_Base_Price], MIN(base_price)[Min_Base_Price]
from 
	fact_events t1 
inner join 
		dim_products t2 on t1.product_code = t2.product_code
inner join 
		dim_stores t3 on t1.store_id = t3.store_id
group by 
		city,promo_type,product_name
order by 
		SUM(quantity_sold_after_promo - quantity_sold_before_promo) desc,
		SUM((base_price * quantity_sold_after_promo)-(base_price * quantity_sold_before_promo)) desc

========================================================================================================================================


---Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy 
--One Get One Free).
SELECT 
    product_name,  
    base_price, 
    promo_type
FROM 
    fact_events t1
INNER JOIN 
    dim_products t2 
    ON t1.product_code = t2.product_code
WHERE 
    base_price > 500 
    AND promo_type = 'BOGOF'

========================================================================================================================================

--Generate a report that provides an overview of the number of stores in each city.

select city, COUNT(store_id) as [Count_of_stores] 
from 
	dim_stores
group by 
		city
order by 
		COUNT(store_id) desc
=========================================================================================================================================

--Generate a report that displays each campaign along with the total revenue generated before and after the 
--campaign?

select 
		campaign_name, sum((quantity_sold_before_promo*base_price)) as [Total_Rev_Before]
		,sum((quantity_sold_after_promo*base_price)) as [Total_Rev_After]

from 
	fact_events t1
inner join 
		dim_campaigns t2 on t1.campaign_id = t2.campaign_id
group by 
		campaign_name 
