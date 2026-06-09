create table data_validation_report (
table_name varchar(50),
column_name varchar(50),
null_count int, duplicate_count int );

insert into data_validation_report
select 'customers', 'customer_id',  sum(case when customer_id is null then 1 else 0 end), (count(*) - count(distinct customer_id)) from customers;
insert into data_validation_report
select 'customers', 'email',  sum(case when email is null or email = '' then 1 else 0 end), (count(*) - count(distinct email)) from customers;
insert into data_validation_report
select 'customers', 'city',  sum(case when city is null or city = '' then 1 else 0 end), 0 from customers;
insert into data_validation_report
select 'products', 'product_id',  sum(case when product_id is null then 1 else 0 end), (count(*) - count(distinct product_id)) from products;
insert into data_validation_report
select 'products', 'selling_price',  sum(case when selling_price is null or selling_price <= 0 then 1 else 0 end), 0 from products;
insert into data_validation_report
select 'orders', 'order_id',  sum(case when order_id is null then 1 else 0 end), (count(*) - count(distinct order_id)) from orders;
insert into data_validation_report
select 'orders', 'total_amount',  sum(case when total_amount is null or total_amount <= 0 then 1 else 0 end), 0 from orders;
insert into data_validation_report
select 'order_items', 'order_item_id',  sum(case when order_item_id is null then 1 else 0 end), (count(*) - count(distinct order_item_id)) from order_items;
insert into data_validation_report
select 'order_items', 'quantity',  sum(case when quantity is null or quantity <= 0 then 1 else 0 end), 0 from order_items;
insert into data_validation_report
select 'payments', 'payment_id',  sum(case when payment_id is null then 1 else 0 end), (count(*) - count(distinct payment_id)) from payments;
insert into data_validation_report
select 'payments', 'amount',  sum(case when amount is null or amount <= 0 then 1 else 0 end), 0 from payments;
insert into data_validation_report
select 'shipping', 'shipping_id',  sum(case when shipping_id is null then 1 else 0 end), (count(*) - count(distinct shipping_id)) from shipping;
insert into data_validation_report
select 'shipping', 'shipping_status',  sum(case when shipping_status is null or shipping_status = '' then 1 else 0 end), 0 from shipping;
insert into data_validation_report
select 'returns', 'return_id',  sum(case when return_id is null then 1 else 0 end), (count(*) - count(distinct return_id)) from returns;
insert into data_validation_report
select 'returns', 'refund_amount',  sum(case when refund_amount is null or refund_amount < 0 then 1 else 0 end), 0 from returns;
insert into data_validation_report
select 'reviews', 'review_id',  sum(case when review_id is null then 1 else 0 end), (count(*) - count(distinct review_id)) from reviews;
insert into data_validation_report
select 'reviews', 'rating',  sum(case when rating is null or rating < 1 or rating > 5 then 1 else 0 end), 0 from reviews;

select * from data_validation_report where null_count > 0 or duplicate_count > 0;

create table cleaned_customers as
with unique_customers as (
select * from (
select *, 
row_number() over(partition by email order by signup_date desc, customer_id desc) as rn
from customers) t where rn = 1 )
select 
customer_id,
trim(concat(upper(left(name, 1)), lower(substring(name, 2)))) as name,
case       
when email LIKE '%@%.%' and email NOT LIKE '%@@%' then lower(trim(email))    
else 'invalid_email' 
end as email,
case 
when lower(city) LIKE 'ban%al%' or lower(city) LIKE 'ben%al%' then 'Bengaluru'
when lower(city) LIKE 'mum%ai' or lower(city) = 'bombay' then 'Mumbai'
when lower(city) LIKE 'del%i' or lower(city) = 'new delhi' then 'Delhi'
when lower(city) LIKE 'kol%ata' or lower(city) = 'calcutta' then 'Kolkata'
when city is null or city = '' or city = 'Unknown' then 'Not Specified'
else trim(concat(upper(left(city, 1)), lower(substring(city, 2))))
end as city,
case        
when signup_date > '2025-12-31' then '2025-01-01' 
else signup_date 
end as signup_date,
case        
when lower(segment) LIKE 'prem%' then 'Premium'
when lower(segment) LIKE 'reg%' then 'Regular'
when lower(segment) LIKE 'vip%' then 'VIP'
when lower(segment) LIKE 'new%' then 'New'
else 'Other'
end as segment
from unique_customers;
select * from cleaned_customers;

create table cleaned_products as
with unique_products as (
select distinct
product_id,
trim(REPLACE(product_name, '(New)', '')) as clean_name,
category as original_category,
cost_price,
selling_price
from products )
select 
product_id,
clean_name as product_name,
case        
when clean_name LIKE '%OnePlus%' or clean_name LIKE '%Samsung%' or clean_name LIKE '%iPhone%' 
or clean_name LIKE '%Redmi%' or clean_name LIKE '%Realme%' or clean_name LIKE '%Lenovo%' 
or clean_name LIKE '%Logitech%' or clean_name LIKE '%Sony%' or clean_name LIKE '%AirPods%' 
or clean_name LIKE '%boAt%' or clean_name LIKE '%Fire-Boltt%' or clean_name LIKE '%Apple%' then 'Electronics'
when clean_name LIKE '%Shirt%' or clean_name LIKE '%Jeans%' or clean_name LIKE '%Kurta%' 
or clean_name LIKE '%T-Shirt%' or clean_name LIKE '%H&M%' or clean_name LIKE '%Levis%' 
or clean_name LIKE '%Allen Solly%' then 'Clothing'
when clean_name LIKE '%Mamaearth%' or clean_name LIKE '%Lakme%' or clean_name LIKE '%Hair Oil%' 
or clean_name LIKE '%Face Wash%' or clean_name LIKE '%Lipstick%' or clean_name LIKE '%WOW%' then 'Beauty'
when clean_name LIKE '%Habits%' or clean_name LIKE '%Wings of Fire%' or clean_name LIKE '%Psychology of Money%' 
or clean_name LIKE '%Atomic%' then 'Books'
when clean_name LIKE '%LEGO%' or clean_name LIKE '%Monopoly%' or clean_name LIKE '%Funskool%' then 'Toys'
when clean_name LIKE '%Yoga Mat%' or clean_name LIKE '%Basketball%' or clean_name LIKE '%Nike%' 
or clean_name LIKE '%Cosco%' or clean_name LIKE '%Boldfit%' then 'Sports'
when clean_name LIKE '%Flask%' or clean_name LIKE '%Milton%' or clean_name LIKE '%Induction%' 
or clean_name LIKE '%Air Fryer%' or clean_name LIKE '%Prestige%' or clean_name LIKE '%Philips%' then 'Home & Kitchen'
when clean_name LIKE '%Tea%' or clean_name LIKE '%Tata Tea%' then 'Grocery'
else 'Others'
end as category,

case        
when selling_price <= 0 or selling_price is null or selling_price > 500000 then 10000
else selling_price 
end as selling_price,

case        
when cost_price <= 0 or cost_price is null or cost_price > selling_price then 
(case when selling_price <= 0 or selling_price is null then 10000 else selling_price end)
else cost_price 
end as cost_price

from unique_products
where clean_name is not null and clean_name != '' and clean_name != 'N/A';
select * from cleaned_products;

create table orders_v1 as 
select * from orders 
where order_date regexp '^[0-9]' and order_date not like '%not-a-date%';
  
create table cleaned_orders as 
select 
order_id, 
customer_id, 
payment_method,
abs(total_amount) as total_amount,
case        
 when order_date regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then cast(order_date as date)
else str_to_date(order_date, '%d-%m-%Y') 
end as order_date
from orders_v1;

create table cleaned_order_items as 
select 
order_item_id, order_id, product_id, discount,
case when abs(quantity) = 0 then 1 else abs(quantity) end as quantity,
case when price <= 0 or price is null then 10000 else price end as price
from order_items;

create table cleaned_shipping as
select distinct
shipping_id,
order_id,
shipping_date,
delivery_date,
coalesce(shipping_status, 'Shipped') as shipping_status,
coalesce(courier_name, 'Standard Courier') as courier_name
from shipping
where shipping_id is not null;
select*from cleaned_shipping;

create table cleaned_payments as 
select 
payment_id, order_id, payment_method, payment_status, payment_date,
abs(amount) as amount 
from payments;

create table cleaned_returns as 
select 
return_id, order_id, product_id, return_reason, return_date,
case        
when refund_amount > 100000 or refund_amount is null then 10000 
else abs(refund_amount) 
end as refund_amount
from returns;

create table cleaned_reviews as
select distinct
review_id,
product_id,
customer_id,
case        
when rating BETWEEN 1 and 5 then rating 
when rating > 5 then 5 
else 3 
end as rating,
case        
when review_text is null or review_text = '' or review_text = 'N/A' then 'No feedback provided'
else trim(review_text)
end as review_text,
coalesce(review_date, '2025-01-01') as review_date
from reviews;
select*from cleaned_orders;
select*from cleaned_order_items;
select*from cleaned_returns;
select*from cleaned_payments;
select*from cleaned_reviews;

create table validation_after_cleaning as
select 'Cleaned_Customers' as table_name, 
sum(case when email = 'invalid_email' or email is null then 1 else 0 end) as null_or_invalid_values,
(select count(*) - count(distinct email) from cleaned_customers) as duplicate_records
from cleaned_customers
union all
select 'Cleaned_Products' as table_name, 
sum(case when selling_price <= 0 or product_name is null then 1 else 0 end) as null_or_invalid_values,
(select count(*) - count(distinct product_id) from cleaned_products) as duplicate_records
from cleaned_products
union all
select 'Cleaned_orders',  sum(case when order_date is null then 1 else 0 end), 0 from cleaned_orders
union all
select 'Cleaned_order_Items' as table_name, 
sum(case when quantity <= 0 or price <= 0 then 1 else 0 end) as null_or_invalid_values,
0 as duplicate_records 
from cleaned_order_items
union all
select 'Cleaned_Payments' as table_name, 
sum(case when amount <= 0 or payment_status = 'Failed' then 1 else 0 end) as null_or_invalid_values,
0 as duplicate_records
from cleaned_payments
union all
select 'Cleaned_Returns' as table_name, 
sum(case when refund_amount > 100000 then 1 else 0 end) as null_or_invalid_values,
0 as duplicate_records
from cleaned_returns
union all
select 'Cleaned_Reviews' as table_name, 
sum(case when rating < 1 or rating > 5 then 1 else 0 end) as null_or_invalid_values,
0 as duplicate_records
from cleaned_reviews;

select * from validation_after_cleaning;

create table final_master_table as
select  
o.order_id, 
o.order_date,
monthname(o.order_date) as order_month, 
cast(year(o.order_date) as signed) as order_year, 
c.name as customer_name, 
p.product_name, 
p.category, 
oi.quantity, 
oi.price, 
oi.discount,
round((oi.quantity * oi.price) - oi.discount, 2) as net_revenue,
round(((oi.quantity * oi.price) - oi.discount) - (oi.quantity * p.cost_price), 2) as profit 
from cleaned_orders o
join cleaned_customers c on o.customer_id = c.customer_id
join cleaned_order_items oi on o.order_id = oi.order_id
join cleaned_products p on oi.product_id = p.product_id;

select * from final_master_table ;