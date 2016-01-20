CREATE TABLE States(
	id		SERIAL PRIMARY KEY,
	name		TEXT UNIQUE,
	code		TEXT UNIQUE
);

CREATE TABLE Customer(
	id		SERIAL PRIMARY KEY,
	name		TEXT,
	stateCode	TEXT REFERENCES States (code) 
);

CREATE TABLE Category(
	id		SERIAL PRIMARY KEY,
	name		TEXT,
	description	TEXT
);

CREATE TABLE Product(
	id		SERIAL PRIMARY KEY,
	name		TEXT,
	listPrice	DECIMAL,
	categoryID	INTEGER REFERENCES Category (id) NOT NULL
);


CREATE TABLE Sales(
	quantity	INTEGER,
	pricePaid	DECIMAL,
	customerID	INTEGER REFERENCES Customer (id) NOT NULL,
	productID	INTEGER REFERENCES Product (id) NOT NULL
);


