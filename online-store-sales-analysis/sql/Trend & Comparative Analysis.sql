select 
order_year, 
order_month, 
count(order_id) as total_orders,
round(sum(net_revenue), 2) as monthly_revenue
from final_master_table
group by order_year, order_month
order by order_year desc, field(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

select 
category,
round(sum(net_revenue), 2) as category_revenue,
count(order_id) as order_count,
round(avg(net_revenue), 2) as avg_order_value
from final_master_table
group by category
order by category_revenue desc;

with monthly_sales as (
select 
order_year, 
order_month,
sum(net_revenue) as revenue
from final_master_table
group by order_year, order_month)

select 
order_year, 
order_month, 
round(revenue, 2) as current_revenue,
round(lag(revenue) over (order by order_year, field(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')), 2) as prev_month_revenue,
round(((revenue - lag(revenue) over (order by order_year, field(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'))) / lag(revenue) over (order by order_year, field(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'))) * 100, 2) as growth_rate_percentage
from monthly_sales;

select 
product_name, 
category, 
sum(quantity) as total_quantity,
round(sum(net_revenue), 2) as total_revenue
from final_master_table
group by product_name, category
order by total_revenue desc;