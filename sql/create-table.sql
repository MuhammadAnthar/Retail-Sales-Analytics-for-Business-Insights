CREATE TABLE superstore.regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE superstore.people (
    person_id SERIAL PRIMARY KEY,
    person_name VARCHAR(100) NOT NULL,
    region_id INT NOT NULL UNIQUE,
    CONSTRAINT fk_people_region
        FOREIGN KEY (region_id) REFERENCES superstore.regions(region_id)
);

CREATE TABLE superstore.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    segment VARCHAR(50)
);

CREATE TABLE superstore.products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name TEXT NOT NULL
);

CREATE TABLE superstore.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE NOT NULL,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50) NOT NULL,
    country_region VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region_id INT NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES superstore.customers(customer_id),
    CONSTRAINT fk_orders_region
        FOREIGN KEY (region_id) REFERENCES superstore.regions(region_id)
);

CREATE TABLE superstore.order_items (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    sales NUMERIC(12,2),
    quantity INT,
    discount NUMERIC(5,2),
    profit NUMERIC(12,2),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES superstore.orders(order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES superstore.products(product_id)
);


CREATE TABLE superstore.returns (
    order_id VARCHAR(50) PRIMARY KEY,
    returned BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_returns_order
        FOREIGN KEY (order_id) REFERENCES superstore.orders(order_id)
);


#KOLOM STAGGING#

CREATE TABLE superstore.stg_orders_raw (
    row_id text,
    order_id text,
    order_date text,
    ship_date text,
    ship_mode text,
    customer_id text,
    customer_name text,
    segment text,
    country_region text,
    city text,
    state text,
    postal_code text,
    region text,
    product_id text,
    category text,
    sub_category text,
    product_name text,
    sales text,
    quantity text,
    discount text,
    profit text
);

CREATE TABLE superstore.stg_people (
    person_name TEXT,
    region TEXT
);

CREATE TABLE superstore.stg_returns (
    returned text,
	order_id text
);