
--Which customer used a discount but still spent more than average purchase amount?
USE Customer_Data
select customer_id, purchase_amount
from customer 
where discount_applied = 'Yes' and purchase_amount >= (select AVG (purchase_amount) from customer) 

--Which are top 5 products with highest average review rating?
select top 5 item_purchased,round(AVG(review_rating),2) as average
from customer
group by item_purchased
order by average desc 

--Compare the average purchase amounts between standard and express shipping
select shipping_type,avg(purchase_amount) as average 
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--Do subscribers spend more ? Compare average spend and total revenue between subscribers and non subscribers.
select subscription_status,avg(purchase_amount) as average, sum(purchase_amount) as total_revenue
from customer
group by subscription_status
order by total_revenue, average desc 

--Which 5 products have highest percentage of purchases with discounts applied?
select top 5 item_purchased,
100*sum(case when discount_applied='Yes' then 1 else 0 end )/count(*) as discount_percentage 
from customer
group by item_purchased
order by discount_percentage desc

--Segment customers into new ,returning and loyal based on their total number of previous purchases 
--and show the count of each segment 
with customer_type as(
select customer_id ,previous_purchases,
case when previous_purchases=1 then 'New'
when previous_purchases between 2 and 10 then 'returning'
else 'loyal'
end as customer_segment
from customer
)
select customer_segment,count(*) as number_of_customers
from customer_type
group by customer_segment 
order by number_of_customers desc

--What are top 3 most purchased products within each category?
with item_count as (
select category,
item_purchased,
count(customer_id) as total_orders,
row_number() over (partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased) 

select item_rank,category,item_purchased,total_orders 
from item_count
where item_rank<=3

--Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe ?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases >5
group by subscription_status

--What is the revenue by age group ?
select age_group,sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc