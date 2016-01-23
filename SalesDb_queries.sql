-- 1. Show the total sales (quantity sold and dollar value) for each customer.
-- This is a strange query...why would I want to track the quantity and not track the product.
-- Quantity of what?
SELECT c.id, c.name, sum(quantity) as total_qty, sum(pricePaid) as total_paid
FROM Orders o JOIN customer c ON o.customerID = c.id
GROUP BY c.id, c.name

-- 2. Show the total sales for each state.
SELECT s.name, sum(quantity) as total_qty, sum(pricePaid) as total_paid
FROM Orders o JOIN Customer c ON o.customerID = c.id
	JOIN States s ON s.code = c.stateCode
GROUP BY s.name

-- 3. Show the total sales for each product, for a given customer. Only products 
-- that were actually bought by the given customer. Order by dollar value.
SELECT c.id, c.name, p.name, sum(pricePaid) as total_paid
FROM Orders o JOIN customer c ON o.customerID = c.id
	JOIN product p ON p.id = o.productID
WHERE c.id = 1 -- this needs to be the given customer
GROUP BY c.id, c.name, p.name
ORDER by total_paid DESC

-- 4. Show the total sales for each product and customer. Order by dollar value.
SELECT c.id, c.name, p.name, sum(pricePaid) as total_paid
FROM Orders o JOIN customer c ON o.customerID = c.id
	JOIN product p ON p.id = o.productID
GROUP BY c.id, c.name, p.name
ORDER by total_paid DESC

-- 5. Show the total sales for each product category and state.
SELECT s.name, cat.category, sum(pricePaid) as total_paid
FROM Orders o JOIN customer c ON o.customerID = c.id
	JOIN product p ON p.id = o.productID
GROUP BY c.id, c.name, p.name
ORDER by total_paid DESC

-- 6. For each one of the top 20 product categories and top 20 customers, it returns a tuple (top
product, top customer, quantity sold, dollar value)
