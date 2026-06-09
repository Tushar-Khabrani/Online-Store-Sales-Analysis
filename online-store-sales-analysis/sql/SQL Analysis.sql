select 
c.customer_id, 
c.name as customer_name, 
round(sum(oi.quantity * oi.price - oi.discount), 2) as total_spent
from cleaned_orders o
join cleaned_customers c on o.customer_id = c.customer_id
join cleaned_order_items oi on o.order_id = oi.order_id
group by c.customer_id, c.name
order by total_spent desc;

select 
order_year, 
order_month, 
round(sum(net_revenue), 2) as monthly_revenue
from final_master_table
group by order_year, order_month
order by order_year desc, field(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
select 
product_name, 
category, 
sum(quantity) as total_units_sold,
round(sum(net_revenue), 2) as total_revenue
from final_master_table
group by product_name, category
order by total_units_sold desc;

select 
c.city, 
round(sum(oi.quantity * oi.price - oi.discount), 2) as region_revenue
from cleaned_orders o
join cleaned_customers c on o.customer_id = c.customer_id
join cleaned_order_items oi on o.order_id = oi.order_id
group by c.city
order by region_revenue desc;
with customer_orders as (
select customer_id, count(order_id) as order_count
from cleaned_orders
group by customer_id)
select 
case when order_count > 1 then 'Repeat' else 'New' end as customer_type,
count(customer_id) as total_customers
from customer_orders
group by customer_type;
