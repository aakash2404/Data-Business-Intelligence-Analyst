-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*)
FROM
    orders;

-- Calculate the total revenue generated from pizza sale  
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza 
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity), 2) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity), 0) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.time) AS hourOfDay,
    COUNT(order_details.order_details_id) AS orderByDay
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY hourOfDay
ORDER BY orderByDay DESC;

-- Join relevant tables to find the category-wise distribution of pizzas. 
SELECT 
    category, COUNT(category) AS countDistribution
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(sumOfQty) AS AvgOrdersPerDAY
FROM
    (SELECT 
        (orders.date) AS orderdate,
            ROUND(SUM((order_details.quantity)), 0) AS sumOfQty
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orderdate) AS salesData;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM((pizzas.price * order_details.quantity)) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    SUM(pizzas.price * order_details.quantity / (SELECT 
            SUM(pizzas.price * order_details.quantity) AS TOTALSALES
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100) AS revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time.

select  order_date, revenue ,
round(sum(revenue) over (order by order_date),2) as cummulative_revenue
from
(SELECT 
    orders.date as order_date,
    round(SUM((pizzas.price * order_details.quantity)),2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.date ) as  sales ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select 
CATEGORY , revenue ,NAME,rn
from
(	select CATEGORY , revenue ,NAME,
	RANK() OVER (partition by category ORDER BY revenue DESC) as rn
	from
		(SELECT 
			pizza_types.category as CATEGORY,
			pizza_types.name as NAME,
			SUM((pizzas.price * order_details.quantity)) AS revenue
		FROM
			order_details
				JOIN
			pizzas ON order_details.pizza_id = pizzas.pizza_id
				JOIN
			pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		GROUP BY CATEGORY , NAME
		ORDER BY revenue DESC
        ) as Total_Sales 		
)  as RankResults
where rn <= 3
;













