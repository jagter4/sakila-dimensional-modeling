--  

DROP TABLE IF EXISTS sakila_dw.dim_store;

CREATE TABLE sakila_dw.dim_store(
  store_key INT NOT NULL AUTO_INCREMENT,
  store_id INT NOT NULL,
  store_name VARCHAR(100),
  store_city VARCHAR(100),
  store_country VARCHAR(100),
  load_date DATETIME,
  PRIMARY KEY(store_key)
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;
CREATE UNIQUE INDEX dim_store_ix_1 ON sakila_dw.dim_store(store_id);
  
insert into sakila_dw.dim_store
select 
null,
store_id,
a.address,
c.city,
co.country,
current_date()
 from 
sakila.store s
left join sakila.address a on s.address_id = a.address_id
left join sakila.city c on a.city_id = c.city_id
left join sakila.country co on c.country_id = co.country_id;

select * from sakila_dw.dim_store;

--

  

