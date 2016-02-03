-- 1. Show the total sales (quantity sold and dollar value) for each customer.
-- This is a strange query...why would I want to track the quantity and not track the product.
-- Quantity of what?  Let's see highest sales..
SELECT c.customer_id, c.customer_name, sum(quantity) as total_qty, sum(price) as total_paid
FROM sale s JOIN customer c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_paid DESC

-- 2. Show the total sales for each state.
SELECT st.state_name, sum(quantity) as total_qty, sum(price) as total_paid
FROM sale s JOIN Customer c ON s.customer_id = c.customer_id
	JOIN state st ON st.state_id = c.state_id
GROUP BY st.state_name
ORDER BY st.state_name

-- 3. Show the total sales for each product, for a given customer. Only products 
-- that were actually bought by the given customer. Order by dollar value.
SELECT c.customer_id, c.customer_name, p.product_name, sum(price) as total_paid
FROM sale s JOIN customer c ON s.customer_id = c.customer_id
	JOIN product p ON p.product_id = s.product_id
WHERE c.customer_id = 1 -- this needs to be the given customer
GROUP BY c.customer_id, c.customer_name, p.product_name
ORDER by total_paid DESC

-- 4. Show the total sales for each product and customer. Order by dollar value.
SELECT c.customer_id, c.customer_name, p.product_name, sum(price) as total_paid
FROM sale s JOIN customer c ON s.customer_id = c.customer_id
	JOIN product p ON p.product_id = s.product_id
GROUP BY c.customer_id, c.customer_name, p.product_name
ORDER by total_paid DESC

-- 5. Show the total sales for each product category and state.
SELECT st.state_name, cat.category_name, sum(price) as total_paid
FROM sale s JOIN customer c ON s.customer_id = c.customer_id
	JOIN product p ON p.product_id = s.product_id
	JOIN state st ON st.state_id = c.state_id
	JOIN category cat ON cat.category_id = p.category_id
GROUP BY cat.category_name, st.state_name
ORDER by cat.category_name, st.state_name, total_paid DESC

-- 6. For each one of the top 20 product categories and top 20 customers, it returns a tuple (top
-- product, top customer, quantity sold, dollar value)

-- Get the top product categories
SELECT cat.category_id, sum(s.price) as total_paid
FROM sale s JOIN product p ON s.product_id = p.product_id
	JOIN category cat ON cat.category_id = p.category_id
GROUP BY cat.category_id
ORDER BY total_paid DESC
LIMIT 20

-- Get the top customers.
SELECT c.customer_id, sum(s.price) as total_paid
FROM sale s JOIN customer c ON s.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_paid DESC
LIMIT 20

-- Each combination of top 20 categories and top 20 customers
SELECT p.product_name, c.customer_name 
FROM product p, customer c
WHERE p.product_id IN (SELECT cat.category_id
			FROM sale s JOIN product p ON s.product_id = p.product_id
				JOIN category cat ON cat.category_id = p.category_id
			GROUP BY cat.category_id
			ORDER BY sum(s.price) DESC
			LIMIT 20)
AND c.customer_id IN (SELECT c.customer_id
			FROM sale s JOIN customer c ON s.customer_id = c.customer_id
			GROUP BY c.customer_id
			ORDER BY sum(s.price) DESC
			LIMIT 20)

-- And the final query and resulting tuple:
SELECT p.product_name, c.customer_name, COALESCE(sum(quantity),0) as total_qty, COALESCE(sum(price),0) as total_paid
FROM sale s RIGHT JOIN (SELECT p.product_id, c.customer_id 
			FROM product p, customer c
			WHERE p.product_id IN (SELECT cat.category_id
						FROM sale s JOIN product p ON s.product_id = p.product_id
							JOIN category cat ON cat.category_id = p.category_id
						GROUP BY cat.category_id
						ORDER BY sum(s.price) DESC
						LIMIT 20)
			AND c.customer_id IN (SELECT c.customer_id
						FROM sale s JOIN customer c ON s.customer_id = c.customer_id
						GROUP BY c.customer_id
						ORDER BY sum(s.price) DESC
						LIMIT 20)) a 
			ON s.product_id = a.product_id AND s.customer_id = a.customer_id
	JOIN customer c ON c.customer_id = a.customer_id
	JOIN product p ON p.product_id = a.product_id
GROUP BY p.product_name, c.customer_name
ORDER BY p.product_name, c.customer_name