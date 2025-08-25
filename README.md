
# E-commerce Database Analysis using SQL

## Project Overview
This project involves analyzing an e-commerce platform's database to extract actionable business insights. The database includes tables such as **Customers**, **Orders**, **Products**, and **Payments**.

## Features
- Analyze customer behavior and purchasing patterns  
- Identify **top-selling products** and **frequent customers**  
- Explore **seasonal sales trends** and revenue contributions  
- Optimize queries for **efficient data retrieval** on large datasets (100k+ records)  

## SQL Concepts Used
- Data Definition & Manipulation (**DDL & DML**)  
- Joins, Subqueries, and Aggregations  
- `GROUP BY`, `HAVING`, and Window Functions  

## Sample Queries

```sql
-- Top 5 best-selling products
SELECT product_id, SUM(quantity) AS total_sold
FROM Orders
GROUP BY product_id
ORDER BY total_sold DESC
LIMIT 5;

-- Customers with highest order frequency
SELECT customer_id, COUNT(*) AS orders_count
FROM Orders
GROUP BY customer_id
ORDER BY orders_count DESC;
