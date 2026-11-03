WITH CTE_best_selling as (
               SELECT top 2
                    p.product_id,
                    p.product_category_name,
                    COUNT(oi.order_id) as total_orders,
                    ROW_NUMBER() OVER(PARTITION BY p.product_category_name order by COUNT(oi.order_id) DESC)as 'rank'
               FROM products p
               join item_order oi
               on p.product_id = oi.product_id
               group by p.product_category_name, p.product_id
)
SELECT
    product_id,
    product_category_name,
    total_orders
FROM CTE_best_selling;

-- Find all orders whose status is delivered

SELECT
    order_id,
    order_status
FROM orders
where order_status = 'Delivered';

-- Display all unique order statuses available in the orders table
SELECT  DISTINCT
    order_status
FROM orders;

--Retrieve the 10 most recent orders.
SELECT top 10
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
FROM orders
order by order_id DESC;

--. Find all products whose weight is greater than 1,000 grams.
SELECT
     product_id,
     product_category_name,
     product_weight_g
FROM products
where product_weight_g > 1000;

-- Find all orders whose status is either canceled or unavailable.
SELECT
     order_id,
     customer_id,
     order_status
FROM orders
where order_status in ('canceld', 'unavailable');

--. Find all payments whose payment value is between 100 and 500
SELECT
    order_id,
    payment_type,
    payment_value
FROM payments
where payment_value BETWEEN 500 and 100;

--. Find all products whose category name is NULL.
SELECT
   product_id,
   product_category_name
FROM products
where product_category_name is null;

--Display customers sorted alphabetically by their city
SELECT
    customer_id,
    customer_city,
    customer_state,
    customer_unique_id
FROM customers
order by customer_city asc;

--Find all orders that were purchased in 2017.
SELECT
     order_id,
     customer_id,
     order_purchase_timestamp
FROM orders
where year(order_purchase_timestamp) = 2017;

--Calculate the total number of orders.
SELECT
     count(*) as total_order
FROM orders;

--Calculate the total number of unique customers.
SELECT
      COUNT(DISTINCT customer_unique_id) as unique_customer
FROM customers;

--Calculate the total revenue using the payment_value column.
SELECT
    sum(payment_value) as total_revanue
FROM payments;

--Calculate the average order payment value.
SELECT
     AVG(payment_value) as avg_value
from payments;

--Find the highest product item price.
SELECT TOP 1
     order_id,
     order_item_id,
     product_id,
     price
FROM item_order
order by price DESC;


--Count the number of orders for each order status.
SELECT
     COUNT(order_id) as total_order,
     order_status
FROM orders
group by order_status;

--Calculate the number of customers in each state
SELECT
     count(customer_id) as total_customer,
     customer_state
FROM customers
GROUP BY customer_state
order by total_customer DESC;

--Find all states that have more than 100 customers.
SELECT
    customer_state,
    COUNT(*) as total_customer
FROM customers
group by customer_state
HAVING COUNT(*) > 100
ORDER BY total_customer DESC;

--Calculate the average payment value for each payment type.
SELECT
    payment_type,
    AVG(payment_value) as avg_payment
FROM payments
group by payment_type
ORDER by avg_payment;

--Display product categories in descending order of total sales.
SELECT
    product_category_name,
    COUNT(o.order_id) total_sales
FROM item_order o
join products p
on o.product_id = p.product_id
group by product_category_name
ORDER BY total_sales DESC;

--.Display customer IDs along with their corresponding order IDs.
 SELECT
     c.customer_id,
     o.order_id
FROM customers c
inner join orders o
on c.customer_id = o.customer_id;

--Display each order along with its payment details.
SELECT
     o.order_id,
     o.customer_id,
     o.order_status,
     p.payment_installments,
     p.payment_type
FROM orders o
join payments p
on o.order_id = p.order_id;

--Calculate the total number of orders for each customer, including customers who have never placed an order.
SELECT
    c.customer_id,
    COUNT(o.order_id) as total_order
FROM customers c
left join orders o
on c.customer_id = o.customer_id
group by c.customer_id
order by total_order DESC;

--Calculate the total item price and total freight value for each order
SELECT
    order_id,
    sum(price) as item_total_price,
    sum(freight_value) as total_freight_value
FROM item_order
GROUP BY order_id;

--Calculate the total spending of each customer.
SELECT
    c.customer_id,
    sum(p.payment_value) as total_amount
FROM customers c
join orders o
on c.customer_id = o.customer_id
join payments p
on o.order_id = p.order_id
GROUP BY c.customer_id;

--Find customers whose total spending is greater than the average spending of all customer
SELECT
    c.customer_id,
    SUM(p.payment_value) as total_amount
FROM customers c
join orders o
on c.customer_id = o.customer_id
join payments p
on o.order_id = p.order_id
group by c.customer_id
HAVING sum(p.payment_value) >
              (SELECT
                   AVG(customer_total)
               FROM(
                  SELECT
                       SUM(p2.payment_value) as customer_total
                  FROM customers c2
                  join orders o2
                  on c2.customer_id = o2.customer_id
                  join payments p2
                  on o2.order_id = p2.order_id
                  GROUP BY c2.customer_id
            )as avg_amount
);

--Find customers who have placed more than one order.
SELECT
    customer_id,
    COUNT(order_id) as total_order
FROM orders
group by customer_id
having count(order_id) > 1;

--Find orders whose payment value is greater than their total item price.
SELECT
     oi.order_id,
     SUM(p.payment_value) as total_payment,
     SUM(oi.price) as total_price
FROM item_order oi
join payments p
on oi.order_id = p.order_id
group by oi.order_id
having SUM(p.payment_value) > SUM(oi.price);

--Find customers who have never placed an order.
SELECT
    c.customer_id,
    c.customer_city,
    o.order_id
FROM customers c
left join orders o
on c.customer_id = o.customer_id
where o.order_id is null;

--Retrieve the latest order placed by each customer
WITH CTE_latest_order as (
            SELECT
                order_id,
                customer_id,
                order_status,
                order_purchase_timestamp,
                ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_purchase_timestamp DESC) as latest_order
            FROM orders
)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
FROM CTE_latest_order
where latest_order = 1;

--Find products that have never been purchased in any orde
SELECT
    p.product_id,
    p.product_category_name
FROM products p
LEFT JOIN item_order oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

--Rank customers within each state based on their total number of orders.

WITH Count_order as (
                SELECT
                    c.customer_id,
                    c.customer_unique_id,
                    COUNT(o.order_id) as total_order
                FROM customers c
                join orders o
                on c.customer_id = o.customer_id
                GROUP BY c.customer_id, c.customer_unique_id
),
RankedCustomer as (
            SELECT
                customer_id,
                customer_unique_id,
                total_order,
                RANK() OVER(PARTITION BY customer_state ORDER by total_order) as rank_customer
            FROM Count_order
)
SELECT *
FROM RankedCustomer
ORDER BY total_order, rank_customer;

-- Find the most expensive product in each product category.
WITH expensive_product as (
                 SELECT
                      p.product_id,
                      p.product_category_name,
                      o.price,
                      ROW_NUMBER() OVER(PARTITION BY p.product_category_name ORDER BY o.price DESC) AS max_price
                FROM products p
                join item_order o
                on p.product_id = o.product_id
)
SELECT
     product_id,
     product_category_name,
     price
FROM expensive_product
where max_price = 1;

--Display monthly order counts along with the previous month's order count.
WITH Monthly_count as (
              SELECT
                   FORMAT(o.order_purchase_timestamp, 'yyyy-MM') as revenue_month,
                   SUM(p.payment_value) as monthly_revenue
              FROM orders o
              join payments p
              on o.order_id = p.order_id
              WHERE  o.order_purchase_timestamp IS NOT NULL
              GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER(order by revenue_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)AS cumulative_revenue

FROM Monthly_count
ORDER BY revenue_month;
