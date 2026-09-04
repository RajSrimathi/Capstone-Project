 CREATE DATABASE retail_sales;
 USE retail_sales;
 


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    brand_id INT,
    category_id INT,
    list_price DECIMAL(10,2),
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
drop table products;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status VARCHAR(20),
    order_date DATE,
    shipped_date DATE,
    store_id INT,
    staff_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES staffs(staff_id)
);
drop table orders;

CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    product_id INT,
    quantity INT,
    list_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    total_price DECIMAL(10,2),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
drop table order_items;
-- inner join --
SELECT o.order_id, o.order_date, p.product_name, oi.quantity, oi.total_price
FROM orders as o
INNER JOIN order_items as oi ON o.order_id = oi.order_id
INNER JOIN products as p ON oi.product_id = p.product_id;
-- total price --
SELECT o.store_id, SUM(oi.total_price) AS total_sales
FROM orders as o
JOIN order_items as  oi ON o.order_id = oi.order_id
GROUP BY o.store_id;

select quantity from retail_sales.order_items;

-- top 5 products --
select product_name from retail_sales.order_items
order by quantity asc
limit 296,5;

-- each customer  purchase --
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity) AS total_items,
       SUM(oi.total_price) AS total_revenue
FROM customers as c
JOIN orders as o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;
-- spent  category --
SELECT customer_id, total_spend,
    CASE 
        WHEN total_spend >= 5000 THEN 'High'
        WHEN total_spend <= 5000 and total_spend >= 1000 THEN 'Medium'
        when total_spend <= 1000 THEN 'low'
        ELSE 'Cheap'
    END AS spend_category
FROM (
    SELECT o.customer_id, SUM(oi.total_price) AS total_spend
    FROM orders as o
    JOIN order_items as oi 
    ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) AS customer_totals;
-- Staff Performance Analysis --
SELECT s.staff_id, s.first_name, s.last_name,
       SUM(oi.total_price) AS total_revenue
FROM staffs as s
JOIN orders as o ON s.staff_id = o.staff_id
JOIN order_items as oi ON o.order_id = oi.order_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY total_revenue DESC;

-- Quantity < 10  --
SELECT store_id, product_id,quantity FROM stocks
WHERE quantity < 10
order by quantity asc;

-- Segmentation Table --
SELECT 
    s.staff_id, s.first_name, s.last_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.total_price), 2) AS total_sales
FROM staffs s
INNER JOIN orders o ON s.staff_id = o.staff_id
INNER JOIN order_items i ON o.order_id = i.order_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY total_sales DESC;



select * from retail_sales.customer_segment;





