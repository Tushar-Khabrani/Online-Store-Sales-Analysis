select 
'Raw Orders Total' as metric, 
round(sum(total_amount), 2) as value from cleaned_orders
union all
select 
'Order Items Net (Price * Qty - Discount)' as metric, 
round(sum((quantity * price) - discount), 2) from cleaned_order_items
union all
select 
'Actual Received (Payments)' as metric, 
round(sum(amount), 2) from cleaned_payments where payment_status = 'Completed';
select
round(sum(net_revenue), 2) as total_revenue,
round(sum(net_revenue) / count(distinct order_id), 2) as average_order_value,
(select round((count(distinct case when order_count > 1 then customer_id end) / count(distinct customer_id)) * 100, 2)
from (select customer_id, count(order_id) as order_count from cleaned_orders group by customer_id) as sub) as retention_rate_percentage
from final_master_table;
 
select 
round((count(distinct case when order_count > 1 then customer_id end) / count(distinct customer_id)) * 100, 2) as retention_rate_percentage
from (
select customer_id, count(order_id) as order_count
from cleaned_orders
group by customer_id
) as customer_stats;

with monthly_rev as (
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
round(((revenue - lag(revenue) over (order by order_year, FIELD(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'))) 
/ lag(revenue) over (order by order_year, FIELD(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'))) * 100, 2) as growth_rate
from monthly_rev;