COPY superstore.stg_orders_raw
FROM 'E:/Tugas Anthar/PROJECT/Sales Performance Dashboard for E-commerce Retail/data/Orders.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';',
    ENCODING 'WIN1252'
);

COPY superstore.stg_people
FROM 'E:/Tugas Anthar/PROJECT/Sales Performance Dashboard for E-commerce Retail/data/Person.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';',
    ENCODING 'WIN1252'
);

COPY superstore.stg_returns
FROM 'E:/Tugas Anthar/PROJECT/Sales Performance Dashboard for E-commerce Retail/data/Returns.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';',
    ENCODING 'WIN1252'
);


insert into superstore.regions (region_name)
select distinct trim(region)
	from (
		select region from superstore.stg_orders 
		union
		select region from superstore.stg_people 
	) x
where region is not null
	and trim(region) <>''
on conflict (region_name) do nothing ;

insert into superstore.customers (customer_id,customer_name,segment)
select distinct 
	trim(customer_id),
	trim(customer_name),
	trim(segment)
from superstore.stg_orders 
where customer_id is not null 
	and trim(customer_id)<>''
on conflict (customer_id) do nothing 

insert into superstore.people (person_name ,region_id)
select
	trim(p.person_name), 
	r.region_id 
from superstore.stg_people p
join superstore.regions r
	on r.region_name = trim(p.region)
ON CONFLICT (region_id) DO NOTHING;


INSERT INTO superstore.products (product_id, category, sub_category, product_name)
SELECT DISTINCT
    TRIM(product_id),
    TRIM(category),
    TRIM(sub_category),
    TRIM(product_name)
FROM superstore.stg_orders
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> ''
ON CONFLICT (product_id) DO NOTHING;


INSERT INTO superstore.orders (
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    country_region,
    city,
    state,
    postal_code,
    region_id
)
SELECT DISTINCT
    TRIM(s.order_id),
    TO_DATE(TRIM(s.order_date), 'DD/MM/YYYY'),
    TO_DATE(TRIM(s.ship_date), 'DD/MM/YYYY'),
    TRIM(s.ship_mode),
    TRIM(s.customer_id),
    TRIM(s.country_region),
    TRIM(s.city),
    TRIM(s.state),
    TRIM(s.postal_code),
    r.region_id
FROM superstore.stg_orders s
JOIN superstore.regions r
    ON r.region_name = TRIM(s.region)
WHERE s.order_id IS NOT NULL
  AND TRIM(s.order_id) <> ''
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO superstore.order_items (
    row_id,
    order_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
)
SELECT
    NULLIF(BTRIM(s.row_id), '')::INT,
    BTRIM(s.order_id),
    BTRIM(s.product_id),
    REPLACE(NULLIF(BTRIM(s.sales), ''), ',', '.')::NUMERIC(12,4),
    NULLIF(BTRIM(s.quantity), '')::INT,
    REPLACE(NULLIF(BTRIM(s.discount), ''), ',', '.')::NUMERIC(5,4),
    REPLACE(NULLIF(BTRIM(s.profit), ''), ',', '.')::NUMERIC(12,4)
FROM superstore.stg_orders s
WHERE NULLIF(BTRIM(s.row_id), '') IS NOT NULL
ON CONFLICT (row_id) DO NOTHING;

INSERT INTO superstore.returns (order_id, returned)
SELECT DISTINCT
    TRIM(order_id),
    TRUE
FROM superstore.stg_returns
WHERE order_id IS NOT NULL
  AND TRIM(order_id) <> ''
ON CONFLICT (order_id) DO NOTHING;
