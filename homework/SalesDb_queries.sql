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
SELECT cat1.category_id, c.customer_id
FROM category cat1, customer c
WHERE cat1.category_id IN (SELECT cat.category_id
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

-- And the semi-final query and resulting tuple, although this one doesn't quite get ALL top customer and ALL top products
-- even if the sum of the total paid is 0
SELECT cat.category_name, c.customer_name, sum(quantity) as total_qty, sum(price) as total_paid
FROM sale s JOIN product p ON s.product_id = p.product_id
	    JOIN customer c ON s.customer_id = c.customer_id
	    RIGHT JOIN (SELECT cat1.category_id, c.customer_id
			FROM category cat1, customer c
			WHERE cat1.category_id IN (SELECT cat.category_id
						FROM sale s 
						JOIN product p ON s.product_id = p.product_id
						JOIN category cat ON cat.category_id = p.category_id
						GROUP BY cat.category_id
						ORDER BY sum(s.price) DESC
						LIMIT 20)
			AND c.customer_id IN (SELECT c.customer_id
						FROM sale s JOIN customer c ON s.customer_id = c.customer_id
						GROUP BY c.customer_id
						ORDER BY sum(s.price) DESC
						LIMIT 20)) a 
			ON p.category_id = a.category_id
			AND c.customer_id = a.customer_id
	     JOIN category cat ON cat.category_id = a.category_id
GROUP BY category_name, c.customer_name
ORDER BY c.customer_name


-- This query shows the top 20 customers and the top 20 product categories along side their total sales and total qty
-- and includes ALL 20 customers in ALL 20 product categories regardless if their total sales in one of the top
-- categories is 0.
SELECT cat.category_name, top.category_id, c.customer_name, top.customer_id, COALESCE(price,0) total_price, COALESCE(quantity,0) total_qty
FROM (SELECT category_id, customer_id 
		FROM (SELECT cat.category_id
			FROM category cat, product p, sale s
			WHERE s.product_id = p.product_id
			AND cat.category_id = p.category_id
			GROUP BY cat.category_id
			ORDER BY sum(s.price) DESC
			LIMIT 20) cat1, 
			(SELECT customer_id
			FROM sale s
			GROUP BY customer_id
			ORDER BY sum(s.price) DESC
			LIMIT 20
			) c1
	) top LEFT OUTER JOIN 
	(SELECT sum(s.price) price, sum(s.quantity) quantity, p.category_id, s.customer_id
		FROM sale s, product p
		WHERE s.product_id = p.product_id
		GROUP BY p.category_id, s.customer_id
	) merge
	ON  top.customer_id = merge.customer_id
	AND top.category_id = merge.category_id 
JOIN customer c ON top.customer_id = c.customer_id
JOIN category cat ON top.category_id = cat.category_id 
JOIN product p ON p.category_id = cat.category_id
GROUP BY cat.category_name, top.category_id, c.customer_name, top.customer_id, price, quantity
ORDER BY cat.category_name, c.customer_name
