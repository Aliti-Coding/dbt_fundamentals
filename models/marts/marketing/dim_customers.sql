with customers as (

     select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as ( 

    select * from {{ ref('stg_jaffle_shop__orders') }}

),
payment as (
    select 
    customer_id,
    sum(iff(status = 'success', amount, 0)) as total_amount
    from {{ ref('fct_orders') }}
    group by 1
),
customer_orders as (

    select
        orders.customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(payment.total_amount) as lifetime_value
    from orders
        left join payment on orders.customer_id = payment.customer_id
    group by 1
    order by 1 asc

),
final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce (customer_orders.number_of_orders, 0) as number_of_orders,
        lifetime_value

    from customers
    left join customer_orders using (customer_id)

)

select * from final