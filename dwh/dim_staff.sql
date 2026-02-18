DROP TABLE IF EXISTS sakila_dw.dim_staff;

CREATE TABLE sakila_dw.dim_staff(
  staff_key INT NOT NULL AUTO_INCREMENT,
  staff_id INT,
  staff_first_name VARCHAR(100),
  staff_last_name VARCHAR(100),
  staff_main_store_key INT,
  last_updated DATE,
  PRIMARY KEY(staff_key)
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;
CREATE UNIQUE INDEX dim_staff_ix_1 ON sakila_dw.dim_staff(staff_id);

insert into sakila_dw.dim_staff
  select
  null,
  staff_id,
  first_name,
  last_name,
  st.store_key,
  current_date()
  from sakila.staff s
  join sakila_dw.dim_store st on s.store_id = st.store_id;
  
  select * from sakila_dw.dim_staff;
  
  