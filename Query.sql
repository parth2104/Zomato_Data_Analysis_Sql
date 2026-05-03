

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- These are the four tables 

select * from customers   
select * from restaurant
select * from orders   
select * from riders 
select * from deliveries  



--Q1) Write the query to find the top 5 most frequently ordered dishis  by the, 
-- customer name is aksah in the last 1 year
 select * from
  (select
    c.customer_id,
    c.customer_name, 
    COUNT(o.order_id) AS total_order,
    DENSE_RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS [Numbers]
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= DATEADD(YEAR, -1, GETDATE())
  AND c.customer_name = 'akash'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_order DESC) as t1 where Numbers <= 5


-- Q2)Identify the time slots during which  the most orders are placed based on 2 hours intervals
WITH time_data AS (
    SELECT 
        CASE 
            WHEN DATEPART(HOUR, order_time) BETWEEN 0 AND 1 THEN '12 – 2 AM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 2 AND 3 THEN '2–4 AM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 4 AND 5 THEN '4–6 AM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 6 AND 7 THEN '6–8 AM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 8 AND 9 THEN '8–10 AM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 10 AND 11 THEN '10–12 PM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 12 AND 13 THEN '12–2 PM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 14 AND 15 THEN '2–4 PM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 16 AND 17 THEN '4–6 PM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 18 AND 19 THEN '6–8 PM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 20 AND 21 THEN '8–10 PM'
            WHEN DATEPART(HOUR, order_time) BETWEEN 22 AND 23 THEN '10–12 AM'
        END AS time_slot
    FROM orders
)

SELECT TOP 5 
    time_slot,
    COUNT(*) AS order_counts
FROM time_data
GROUP BY time_slot
ORDER BY order_counts DESC

--Q3) find the average order value per customer who has placed  more than 750 orders
-- Returns customers_name and aov(Average orderr value)

SELECT 
    c.customer_id,
    c.customer_name,
    AVG(o.order_amount) AS aov
FROM orders o 
JOIN customers c 
    ON o.customer_id = c.customer_id 
GROUP BY 
    c.customer_id, 
    c.customer_name
HAVING 
    COUNT(c.customer_id) >= 750;

--Q4) List the customers who have spent more then 100k in total on food orders
-- return customer name and customer id

select c.customer_id,
       c.customer_name,
       sum(o.order_amount) as Total
from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_id,c.customer_name having sum(o.order_amount) >= 10000


--Q5) orders without deliveery
-- write the query to find order that were placed but not  delivered 
SELECT 
    r.restaurant_name,
    COUNT(o.order_id) AS total_order_not_delivered
FROM restaurant r
LEFT JOIN orders o 
    ON r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries d 
    ON o.order_id = d.order_id
WHERE d.order_id IS NULL
GROUP BY r.restaurant_name

--Q6) Restaurant total revenue ranking
--  rank restaurant by their total revenue from the last year ,including their name 
--  total revenue and rank  with their city 
with restaurant_rank as 
(
SELECT 
    r.restaurant_name,
    r.city,
    SUM(o.total_amount) AS total_revenue,
    RANK() OVER (
        PARTITION BY r.city 
        ORDER BY SUM(o.total_amount) DESC
    ) AS rank FROM restaurant r JOIN orders o 
    ON r.restaurant_id = o.restaurant_id
GROUP BY 
    r.restaurant_name,
    r.city) select * from restaurant_rank where  rank=1

--Q7) Most popular dish by city :
-- Identify most popular dish by each city based on the number of orders  from the last year 

with restaurant_rank as 
(
SELECT 
    o.order_item,
    r.city,
    count(o.order_id) AS total_order,
    RANK() OVER (
        PARTITION BY r.city 
        ORDER BY count(o.order_id) DESC
    ) AS rank
FROM restaurant r
JOIN orders o 
    ON r.restaurant_id = o.restaurant_id
    where o.order_date >= DATEADD(YEAR,-1,GETDATE())
GROUP BY 
    r.order_item,
    r.city)
select * from restaurant_rank where  rank=1

--Q8) Customers churns 
-- Find customers who haven't placed orderd in 2024 but did in 2023

SELECT DISTINCT 
    c.customer_id,
    c.customer_name
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = 2023
AND NOT EXISTS (
    SELECT 1
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
      AND YEAR(o2.order_date) = 2024
)

--Q9) monthly restaurant  growth ratio
--Calculate  each restaurent's growth ratiobase on the total number of delivered since its joining
WITH monthly_orders AS (
    SELECT o.restaurant_id,
        YEAR(o.order_date) AS year_,
        MONTH(o.order_date) AS month_,
        COUNT(o.order_id) AS current_month_orders
    FROM orders o
    JOIN deliveries d 
        ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY 
        o.restaurant_id,
        YEAR(o.order_date),
        MONTH(o.order_date)),
growth_ratio AS (
    SELECT 
        restaurant_id, year_,month_,
        current_month_orders,
        LAG(current_month_orders, 1) OVER (
            PARTITION BY restaurant_id 
            ORDER BY year_, month_
        ) AS previous_month_orders
    FROM monthly_orders
)
SELECT restaurant_id,year_,month_,current_month_orders,previous_month_orders,
    ROUND(
        (current_month_orders - previous_month_orders) * 100.0 
        / previous_month_orders, 2
    ) AS growth_percentage
FROM growth_ratio


























