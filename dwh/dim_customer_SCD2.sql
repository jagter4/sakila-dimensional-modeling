drop table sakila_dw.dim_customer;

CREATE TABLE sakila_dw.dim_customer(
    customer_key INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    district VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(10),
    create_date DATE,
    first_rental_date DATE,
    effective_from DATE,
    effective_to DATE,
    current_flag INT,
    load_date DATETIME,
    PRIMARY KEY(customer_key)
) DEFAULT CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_0900_ai_ci';

CREATE UNIQUE INDEX dim_customer_ix_2 ON sakila_dw.dim_customer (customer_id, effective_from);

--------

insert into sakila_dw.dim_customer
select
    null,
    cu.customer_id,
    cu.first_name,
    cu.last_name,
    ad.district,
    ci.city,
    co.country,
    ad.postal_code,
    cu.create_date,
    date('1900-01-01'),
    date('2005-01-01'),
    date('2050-12-31'),
    1,
    current_date()
from sakila_stg.customer cu
left join sakila_stg.address ad on cu.address_id = ad.address_id
left join sakila_stg.city ci on ad.city_id = ci.city_id
left join sakila_stg.country co on ci.country_id = co.country_id;

select * from sakila_dw.dim_customer; 