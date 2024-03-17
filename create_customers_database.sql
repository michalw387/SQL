DROP SCHEMA IF EXISTS customers_db CASCADE;
DROP TYPE IF EXISTS customers_db.review CASCADE;

CREATE SCHEMA IF NOT EXISTS customers_db;

CREATE TABLE IF NOT EXISTS customers_db.customers (
    customer_id int8 PRIMARY KEY,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    email varchar(50) NOT NULL,
    phone int DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS customers_db.categories (
    category_id int8 PRIMARY KEY,
    category_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS customers_db.products (
    product_id int8 PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price decimal(
        10,
        2
    ) NOT NULL,
    category_id int8,
    FOREIGN KEY (category_id) REFERENCES
    customers_db.categories(category_id)
);

CREATE TABLE IF NOT EXISTS customers_db.orders (
    order_id int8 PRIMARY KEY,
    customer_id int NOT NULL,
    order_date date NOT NULL,
    shipping_address varchar(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES
    customers_db.customers(customer_id)
);

CREATE TABLE IF NOT EXISTS customers_db.order_product (
    order_id int8 NOT NULL,
    product_id int8 NOT NULL,
    quantity int NOT NULL DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES
    customers_db.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES
    customers_db.products(product_id),
    PRIMARY KEY (
        order_id,
        product_id
    )
);

CREATE TABLE IF NOT EXISTS customers_db.payments (
    payment_id int8 PRIMARY KEY,
    order_id int8 NOT NULL,
    payment_date date NOT NULL,
    payment_amount decimal(
        10,
        2
    ) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES
    customers_db.orders(order_id)
);


CREATE TYPE customers_db.review AS ENUM (
    'Positive',
    'Neutral',
    'Negative'
);

CREATE TABLE IF NOT EXISTS customers_db.reviews (
    review_id int8 PRIMARY KEY,
    customer_id int8 NOT NULL,
    product_id int8 NOT NULL,
    review_date date NOT NULL,
    review_type customers_db.review NOT NULL,
    description varchar(500) DEFAULT '',
    FOREIGN KEY (customer_id) REFERENCES
    customers_db.customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES
    customers_db.products(product_id)
);
