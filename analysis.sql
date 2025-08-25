-- analysis.sql
USE ecommerce_sql;

-- 1) KPI: Total revenue, total orders, AOV (completed orders only)
SELECT 
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
  ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed';

-- 2) Monthly revenue trend
SELECT 
  DATE_FORMAT(o.order_date, '%Y-%m') AS month,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY month
ORDER BY month;

-- 3) Top 10 products by revenue
SELECT 
  p.product_name,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
  SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o   ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 4) Category revenue split
SELECT 
  p.category,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o   ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- 5) Customer LTV (total spend) - top customers
SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent,
  COUNT(DISTINCT o.order_id) AS orders_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 15;

-- 6) New vs Returning customers by month
WITH first_order AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM orders
  WHERE status = 'completed'
  GROUP BY customer_id
)
SELECT 
  DATE_FORMAT(o.order_date, '%Y-%m') AS month,
  SUM(CASE WHEN DATE(first_order_date) = DATE(o.order_date) THEN 1 ELSE 0 END) AS new_orders,
  SUM(CASE WHEN DATE(first_order_date) < DATE(o.order_date) THEN 1 ELSE 0 END) AS returning_orders
FROM orders o
JOIN first_order f ON o.customer_id = f.customer_id
WHERE o.status = 'completed'
GROUP BY month
ORDER BY month;

-- 7) Repeat purchase rate (customers with >= 2 completed orders)
SELECT 
  ROUND(100.0 * SUM(CASE WHEN cnt >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_purchase_rate_pct
FROM (
  SELECT customer_id, COUNT(*) AS cnt
  FROM orders
  WHERE status = 'completed'
  GROUP BY customer_id
) t;

-- 8) Basket analysis: average items per order
SELECT 
  ROUND(AVG(items_per_order), 2) AS avg_items_per_order
FROM (
  SELECT o.order_id, SUM(oi.quantity) AS items_per_order
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.status = 'completed'
  GROUP BY o.order_id
) x;

-- 9) Monthly AOV
SELECT 
  DATE_FORMAT(o.order_date, '%Y-%m') AS month,
  ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY month
ORDER BY month;

-- 10) City-wise revenue (customer geography)
SELECT 
  c.city,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.city
ORDER BY revenue DESC;
