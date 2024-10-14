-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_details_id) AS total_orders
FROM
    pizza_sales.order_details;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    pizza_sales.order_details
        JOIN
    pizza_sales.pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    pizzas.pizza_type_id, pizzas.price
FROM
    pizza_sales.pizzas
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details.quantity) AS quantity
FROM
    pizza_sales.pizzas
        JOIN
    pizza_sales.order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY quantity DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, COUNT(order_details.quantity) AS quantity
FROM
    pizza_sales.pizza_types
        JOIN
    pizza_sales.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_sales.order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    COUNT(order_details.quantity) AS quantity
FROM
    pizza_sales.pizza_types
        JOIN
    pizza_sales.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_sales.order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders.order_time),
    COUNT(order_details.quantity) AS quantity
FROM
    pizza_sales.orders
        JOIN
    pizza_sales.order_details ON orders.order_id = order_details.order_id
GROUP BY HOUR(orders.order_time); 

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(category)
FROM
    pizza_sales.pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        pizza_sales.orders
    JOIN pizza_sales.order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_sales.pizza_types
        JOIN
    pizza_sales.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_sales.order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(pizzas.price * order_details.quantity) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_revenue
                FROM
                    pizza_sales.order_details
                        JOIN
                    pizza_sales.pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            0) AS revenue
FROM
    pizza_sales.pizza_types
        JOIN
    pizza_sales.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_sales.order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;


-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cumm_revenue from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from pizza_sales.orders join pizza_sales.order_details on orders.order_id = order_details.order_id
join pizza_sales.pizzas on order_details.pizza_id = pizzas.pizza_id
group by order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rnk from
(select pizza_types.category, pizza_types.name, sum(order_details.quantity * pizzas.price)  as revenue
from pizza_sales.pizza_types join pizza_sales.pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join pizza_sales.order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name) as pizza_revenue) as pizza_rank
where rnk <=3;