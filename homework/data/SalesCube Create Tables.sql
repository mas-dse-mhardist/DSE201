CREATE TABLE state
(
  state_id serial primary key NOT NULL,
  state_name character varying(50) NOT NULL
);

CREATE TABLE category
(
  category_id serial primary key NOT NULL,
  category_name character varying(50) NOT NULL,
  category_desc text
);

CREATE TABLE product
(
  product_id serial primary key NOT NULL,
  product_name character varying(50) NOT NULL,
  category_id integer references category(category_id) NOT NULL,
  list_price numeric NOT NULL
);

CREATE TABLE customer
(
  customer_id serial primary key NOT NULL,
  customer_name character varying(50) NOT NULL,
  state_id integer references state(state_id) NOT NULL
);

CREATE TABLE sale
(
  sale_id serial primary key NOT NULL,
  customer_id integer references customer(customer_id) NOT NULL,
  product_id integer references product(product_id) NOT NULL,
  quantity integer NOT NULL,
  price numeric NOT NULL
);