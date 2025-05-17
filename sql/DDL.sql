
create table abd.dim_date
(
    date_id   integer generated always as identity
        primary key,
    full_date date
        unique,
    year      integer,
    quarter   integer,
    month     integer,
    day       integer,
    weekday   text
);

alter table abd.dim_date
    owner to museum;

create table abd.dim_pet_category
(
    category_id   integer generated always as identity
        primary key,
    category_name text
        unique
);

alter table abd.dim_pet_category
    owner to museum;

create table abd.dim_pet_breed
(
    breed_id   integer generated always as identity
        primary key,
    breed_name text
        unique
);

alter table abd.dim_pet_breed
    owner to museum;

create table abd.dim_pet
(
    pet_id      integer not null
        primary key,
    pet_type    text,
    pet_name    text,
    breed_id    integer not null
        constraint fk_pet_breed
            references abd.dim_pet_breed,
    category_id integer not null
        constraint fk_pet_category
            references abd.dim_pet_category
);

alter table abd.dim_pet
    owner to museum;

create table abd.dim_product_category
(
    category_id   integer generated always as identity
        primary key,
    category_name text
        unique
);

alter table abd.dim_product_category
    owner to museum;

create table abd.dim_product
(
    product_id   integer not null
        primary key,
    product_name text,
    category_id  integer not null
        constraint fk_product_category
            references abd.dim_product_category,
    price        double precision,
    weight       double precision,
    color        text,
    size         text,
    brand        text,
    material     text,
    description  text,
    rating       double precision,
    reviews      integer,
    release_date date,
    expiry_date  date
);

alter table abd.dim_product
    owner to museum;

create table abd.dim_country
(
    country_id   integer generated always as identity
        primary key,
    country_name text
        unique
);

alter table abd.dim_country
    owner to museum;

create table abd.dim_customer
(
    customer_id integer not null
        primary key,
    first_name  text,
    last_name   text,
    age         integer,
    email       text,
    postal_code text,
    country_id  integer not null
        constraint fk_customer_country
            references abd.dim_country
);

alter table abd.dim_customer
    owner to museum;

create table abd.dim_seller
(
    seller_id   integer not null
        primary key,
    first_name  text,
    last_name   text,
    email       text,
    postal_code text,
    country_id  integer not null
        constraint fk_seller_country
            references abd.dim_country
);

alter table abd.dim_seller
    owner to museum;

create table abd.dim_city
(
    city_id    integer generated always as identity
        primary key,
    city_name  text,
    state      text,
    country_id integer not null
        constraint fk_city_country
            references abd.dim_country
);

alter table abd.dim_city
    owner to museum;

create table abd.dim_store
(
    store_id   integer generated always as identity
        primary key,
    store_name text,
    location   text,
    city_id    integer not null
        constraint fk_store_city
            references abd.dim_city,
    phone      text,
    email      text
);

alter table abd.dim_store
    owner to museum;

create table abd.dim_supplier
(
    supplier_id   integer generated always as identity
        primary key,
    supplier_name text,
    contact       text,
    email         text,
    phone         text,
    address       text,
    city_id       integer not null
        constraint fk_supplier_city
            references abd.dim_city,
    country_id    integer not null
        constraint fk_supplier_country
            references abd.dim_country
);

alter table abd.dim_supplier
    owner to museum;

create table abd.sales_fact
(
    sale_id          integer generated always as identity
        primary key,
    sale_date_id     integer not null
        constraint fk_sale_date
            references abd.dim_date,
    customer_id      integer not null
        constraint fk_sale_customer
            references abd.dim_customer,
    seller_id        integer not null
        constraint fk_sale_seller
            references abd.dim_seller,
    product_id       integer not null
        constraint fk_sale_product
            references abd.dim_product,
    store_id         integer not null
        constraint fk_sale_store
            references abd.dim_store,
    supplier_id      integer not null
        constraint fk_sale_supplier
            references abd.dim_supplier,
    sale_quantity    integer,
    sale_total_price double precision
);

alter table abd.sales_fact
    owner to museum;

