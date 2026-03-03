--- create a view as impdata ---
create or replace view impdata as
select
    c.customer_id,
    o.order_id,
    d.sales,
    d.quantity,
    d.profit,
    d.discount,
    o.order_date,
    o.ship_date,
    o.months,
    
    p.product_id,
    p.category,
    p.sub_category

from customers c 
left join orders o on c.customer_id=o.customer_id
left join order_details d on d.order_id=o.order_id
join products p on p.product_id=d.product_id;

------section 1: overall business performance-----

---q1. what are the total sales, total profit, and profit margin?
select total_sale,
       total_profit,
	   round((total_profit / total_sale) * 100,2) as margin
	   from (
	         select sum(sales) as total_sale,
             sum(profit) as total_profit
              from order_details) as t;


---q2. what is the total loss amount across all orders?
select
    sum(abs(profit)) as total_loss_amount
from impdata
where profit < 0;


---q3. how much profit was lost specifically due to discounts?
select
    sum(abs(profit)) as total_profit_lost_due_to_discount
from impdata
where discount > 0
  and profit < 0;


---q4. what is the overall average order value?
select
    round(avg(order_total),2) as avg_order_value
from (
    select order_id,
           sum(sales) as order_total
    from impdata
    group by order_id) as t;


------section 2: sales & profit by geography-----

---q5. what are the total sales and profit by region and city?
select  c.region,c.city,
    sum(i.sales) as total_sales,
    sum(i.profit) as total_profit
from impdata i join customers c
on c.customer_id=i.customer_id
group by c.region,c.city
order by total_profit desc;


---q6. which region has the highest number of orders?
select c.region,count(o.order_id) as total_orders from customers c
join orders o on c.customer_id=o.customer_id
join order_details d on o.order_id=d.order_id
group by c.region
order by total_orders desc;


---q7. what is the sales and profit performance by state?
select c.state,
    sum(i.sales) as total_sales,
    sum(i.profit) as total_profit,
    round(sum(i.profit) / sum(i.sales) * 100,2) as margin
from impdata i join customers c
on c.customer_id=i.customer_id
group by c.state
order by total_profit desc;


------section 3: category & product analysis-----

---q8. what is the profit vs loss by category and sub-category?
select
    category,
    sub_category,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    case
        when sum(profit) < 0 then 'loss'
        else 'profit'
    end as performance
from impdata
group by category,sub_category
order by total_profit desc;


---q9. which products have wrong pricing that leads to loss?
select i.order_id,p.product_name,
    sum(i.sales) as total_sales,
    sum(i.profit) as total_profit,
    round(avg(i.discount),2) as avg_discount
from impdata i join products p on i.product_id=p.product_id
where i.discount > 0
group by i.order_id,p.product_name
having sum(i.profit) < 0
order by total_profit;


---q10. which category has the highest number of loss-making products?
select category,
    count(*) as loss_product_count,
    sum(profit) as total_loss
from impdata
where profit < 0
group by category
order by loss_product_count desc;


---q11. what are the top 5 best-selling products by sales?
select p.product_name,
    sum(i.sales) as total_sales,
    sum(i.profit) as total_profit
from impdata i join products p on i.product_id=p.product_id
group by p.product_name
order by total_sales desc
limit 5;


------section 4: discount analysis-----

---q12. how does discount level affect profit? (bucket analysis)
select case
        when discount = 0 then 'no discount'
        when discount between 0.01 and 0.10 then '1-10%'
        when discount between 0.11 and 0.20 then '11-20%'
        when discount between 0.21 and 0.30 then '21-30%'
        when discount > 0.30 then '30%+'
end as discount_bucket,
sum(sales) as total_sales,
sum(profit) as total_profit,
count(*) as order_count
from impdata
group by discount_bucket
order by total_profit desc;


---q13. which category is most negatively impacted by discounts?
select category,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    round(avg(discount),2) as avg_discount
from impdata
where discount > 0
group by category
order by total_profit;


---q14. are high discounts affecting profit for specific orders?
select d.order_id,sum(d.sales) as total_sale,
sum(d.profit) as total_profit,
round(avg(d.discount),2) as avg_discount,
case
    when avg(d.discount) > 0.20 and sum(d.profit)<=0
    then 'high discount - loss making'
	when avg(d.discount) >0.20 and sum(d.profit) <= 0.10 * sum(d.sales)
	then 'high discount - low profit'
	else 'normal'
end as status
from order_details d join orders o
on d.order_id=o.order_id
group by d.order_id
order by total_profit asc;


---q15. which customers have low sales but are getting high discounts?
select c.customer_id,c.name,
sum(d.sales) as total_sales,
round(avg(d.discount),2) as avg_discount,
'low sales - high discount' as customer_flag
from customers c
join orders o on c.customer_id=o.customer_id
join order_details d on o.order_id=d.order_id
group by c.customer_id,c.name
having
    sum(d.sales) < 1000
    and avg(d.discount) > 0.15
order by total_sales asc;


------section 5: customer analysis-----

---q16. which customer segment contributes the most to total sales and profit?
select c.segment,
    sum(i.sales) as total_sales,
    sum(i.profit) as total_profit,
    round(sum(i.profit) / sum(i.sales) * 100,2) as margin
from impdata i join customers c on i.customer_id=c.customer_id
group by c.segment
order by total_profit desc;


---q17. who are the top 10 customers by total profit?
select c.name,sum(d.sales) as total_sales,
sum(d.profit) as total_profit from customers c
join orders o on c.customer_id=o.customer_id
join order_details d on o.order_id=d.order_id
group by c.name
order by total_profit desc
limit 10;


---q18. which customers have high revenue but low or negative profit?
select
    customer_id,
    sum(sales) as total_sales,
    sum(profit) as total_profit
from impdata
group by customer_id
having sum(sales) > (
        select avg(total_sales)
        from (
            select customer_id,sum(sales) as total_sales
            from impdata
            group by customer_id
        ) t
     )
   and sum(profit) <= 0
order by total_sales desc;


---q19. top 20% customers contributing 80% of sales (pareto analysis)
with customer_sales as (
    select
        customer_id,
        sum(sales) as total_sales
    from impdata
    group by customer_id
),
ranked_customers as (
    select
        customer_id,
        total_sales,
        sum(total_sales) over (order by total_sales desc) as cum_sales,
        sum(total_sales) over () as overall_sales
    from customer_sales
)
select
    customer_id,
    total_sales,
    round(cum_sales / overall_sales * 100,2) as cumulative_sales_pct
from ranked_customers
where cum_sales / overall_sales <= 0.8
order by total_sales desc;


---q20. what is each customer's lifetime value?
select
    customer_id,
    count(distinct order_id) as total_orders,
    sum(sales) as lifetime_sales,
    sum(profit) as lifetime_profit,
    round(sum(profit) / sum(sales) * 100,2) as lifetime_margin
from impdata
group by customer_id
order by lifetime_profit desc;


---q21. classify customers by order behavior (frequent small vs few large orders)
with customer_orders as (
    select
        customer_id,
        count(distinct order_id) as order_count,
        sum(sales) as total_sales
    from impdata
    group by customer_id
)
select
    customer_id,
    order_count,
    total_sales,
    round(total_sales / order_count,2) as avg_order_value,
    case
        when order_count >= 10 and total_sales / order_count < 500
            then 'frequent small orders'
        when order_count < 10 and total_sales / order_count >= 500
            then 'few large orders'
        else 'mixed behavior'
    end as customer_type
from customer_orders
order by total_sales desc;


---q22. which customers have never placed a repeat order?
select c.customer_id,c.name,
count(distinct o.order_id) as total_orders from customers c
join orders o on c.customer_id=o.customer_id
group by c.customer_id,c.name
having count(distinct o.order_id) = 1
order by c.name;


------section 6: shipping & delivery analysis-----

---q23. which shipping mode delivers the most profit?
select o.ship_mode,count(o.order_id) as total_orders,
sum(d.sales) as total_sales,
sum(d.profit) as total_profit from orders o
join order_details d on o.order_id=d.order_id
group by o.ship_mode
order by total_profit desc;


---q24. what is the average delivery time per shipping mode?
select ship_mode,round(avg(ship_date - order_date),2) as avg_delivery_days,
min(ship_date - order_date) as min_days,
max(ship_date - order_date) as max_days
from orders
group by ship_mode
order by avg_delivery_days asc;


---q25. how many total orders were delivered late (more than 4 days)?
select count(*) as late_orders
from orders
where ship_date > order_date + interval '4 days';


---q26. classify each order as late or on time
select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.ship_date,
	case
	   when o.ship_date > o.order_date + interval '4 days'
	   then 'late'
	   else 'on time'
	end as delivery_status
from orders o;


---q27. which customers are most affected by late deliveries?
select c.customer_id,c.name,count(o.order_id) as late_deliveries,
dense_rank() over(order by count(o.order_id) desc) as ranking
from customers c join orders o
on c.customer_id=o.customer_id
where o.ship_date > o.order_date + interval '4 days'
group by c.customer_id,c.name
order by late_deliveries desc
limit 10;


---q28. what percentage of orders per shipping mode are late?
select ship_mode,
    count(*) as total_orders,
    sum(case when ship_date > order_date + interval '4 days' then 1 else 0 end) as late_orders,
    round(
        sum(case when ship_date > order_date + interval '4 days' then 1 else 0 end) * 100.0 / count(*),2
    ) as late_pct
from orders
group by ship_mode
order by late_pct desc;


------end of file-----
