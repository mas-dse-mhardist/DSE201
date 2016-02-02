CREATE TABLE States(
	id		SERIAL PRIMARY KEY,
	name		TEXT UNIQUE, —- NOT NULL?
	code		TEXT UNIQUE
);

-- I could put NOT NULL constraints on fields in this table, but this 
-- table is so skeleton of customer info that there are many other ways
-- customers can be named - email, an id from salesforce, etc.
-- without actually having a customer name like "Joe-Bob" per se.  
-- So, I'm leaving out the constraints assuming that there's more to
-- the customer table in a real-world example and that the table is
-- incomplete.
CREATE TABLE Customer(
	id		SERIAL PRIMARY KEY,
	name		TEXT,
	stateCode	TEXT REFERENCES States (code) 
);

-- No NOT NULL constraints because there are reasons for having 
-- a category id without a name or description, if we were generating 
-- a multi-level product hierarchy.
CREATE TABLE Category(
	id		SERIAL PRIMARY KEY,
	name		TEXT,
	description	TEXT
);

-- Same here, I didn't add constraints yet, because I'm not sure of the 
-- how this product table will be used.
CREATE TABLE Product(
	id		SERIAL PRIMARY KEY,
	name		TEXT,
	listPrice	DECIMAL,
	categoryID	INTEGER REFERENCES Category (id) NOT NULL
);

-- Named this table Orders because a list of items isn't truly a sale
-- until the payment is made.
CREATE TABLE Orders(
	quantity	INTEGER,
	pricePaid	DECIMAL,
	customerID	INTEGER REFERENCES Customer (id) NOT NULL,
	productID	INTEGER REFERENCES Product (id) NOT NULL
);


