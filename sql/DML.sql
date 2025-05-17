INSERT INTO dim_country (country_name)
SELECT DISTINCT customer_country FROM abd.mock_data
WHERE customer_country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_country (country_name)
SELECT DISTINCT seller_country FROM abd.mock_data
WHERE seller_country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_country (country_name)
SELECT DISTINCT store_country FROM abd.mock_data
WHERE store_country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_country (country_name)
SELECT DISTINCT supplier_country FROM abd.mock_data
WHERE supplier_country IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_city (city_name, state, country_id)
SELECT DISTINCT store_city, store_state,
    (SELECT country_id FROM dim_country WHERE country_name = store_country)
FROM abd.mock_data
WHERE store_city IS NOT NULL AND store_country IS NOT NULL;

INSERT INTO dim_city (city_name, state, country_id)
SELECT DISTINCT supplier_city, NULL,
    (SELECT country_id FROM dim_country WHERE country_name = supplier_country)
FROM abd.mock_data
WHERE supplier_city IS NOT NULL AND supplier_country IS NOT NULL;

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category FROM abd.mock_data
WHERE product_category IS NOT NULL
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO dim_pet_breed (breed_name)
SELECT DISTINCT customer_pet_breed FROM abd.mock_data
WHERE customer_pet_breed IS NOT NULL
ON CONFLICT (breed_name) DO NOTHING;

INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category FROM abd.mock_data
WHERE pet_category IS NOT NULL
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, postal_code, country_id)
SELECT DISTINCT
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_postal_code,
    (SELECT country_id FROM dim_country WHERE country_name = customer_country)
FROM abd.mock_data
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dim_seller (seller_id, first_name, last_name, email, postal_code, country_id)
SELECT DISTINCT
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_postal_code,
    (SELECT country_id FROM dim_country WHERE country_name = seller_country)
FROM abd.mock_data
ON CONFLICT (seller_id) DO NOTHING;


INSERT INTO dim_supplier (supplier_name, contact, email, phone, address, city_id, country_id)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    (SELECT city_id FROM dim_city WHERE city_name = supplier_city and country_id = (SELECT country_id FROM dim_country WHERE country_name = supplier_country)),
    (SELECT country_id FROM dim_country WHERE country_name = supplier_country)
FROM abd.mock_data;

INSERT INTO dim_store (store_name, location, city_id, phone, email)
SELECT DISTINCT
    store_name,
    store_location,
    (SELECT city_id FROM dim_city
                    join dim_country on dim_city.country_id = dim_country.country_id
                    WHERE city_name = store_city and dim_country.country_name = mock_data.store_country),
    store_phone,
    store_email
FROM abd.mock_data;

INSERT INTO dim_product (product_id, product_name, category_id, price, weight, color, size, brand, material, description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT
    sale_product_id,
    product_name,
    (SELECT category_id FROM dim_product_category WHERE category_name = product_category),
    product_price,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    -- преобразование даты из текста к типу DATE (формат нужно уточнить, здесь пример ISO)
    TO_DATE(product_release_date, 'MM/DD/YYYY'),
    TO_DATE(product_expiry_date, 'MM/DD/YYYY')
FROM abd.mock_data
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO dim_pet (pet_id, pet_type, pet_name, breed_id, category_id)
SELECT DISTINCT
    ROW_NUMBER() OVER () AS pet_id,
    customer_pet_type,
    customer_pet_name,
    (SELECT breed_id FROM dim_pet_breed WHERE breed_name = customer_pet_breed),
    (SELECT category_id FROM dim_pet_category WHERE category_name = pet_category)
FROM abd.mock_data
WHERE customer_pet_name IS NOT NULL
ON CONFLICT DO NOTHING;


INSERT INTO dim_date (full_date, year, quarter, month, day, weekday)
SELECT DISTINCT
    TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date,
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Day')
FROM abd.mock_data
ON CONFLICT (full_date) DO NOTHING;


INSERT INTO sales_fact (
    sale_date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    sale_quantity,
    sale_total_price
)
SELECT
    dd.date_id,
    md.sale_customer_id,
    md.sale_seller_id,
    md.sale_product_id,
    ds.store_id,
    dsu.supplier_id,
    md.sale_quantity,
    md.sale_total_price
FROM abd.mock_data md
JOIN dim_date dd ON dd.full_date = TO_DATE(md.sale_date, 'MM/DD/YYYY')
JOIN dim_store ds ON ds.store_name = md.store_name
JOIN dim_supplier dsu ON dsu.supplier_name = md.supplier_name;
