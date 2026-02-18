DROP TABLE IF EXISTS sakila_dw.fact_daily_rentals;

CREATE TABLE sakila_dw.fact_daily_rentals(
  date_key INT NOT NULL,
  time_key INT NOT NULL,
  customer_key INT NOT NULL,
  movie_key INT NOT NULL,
  store_key_inventory INT NOT NULL,
  store_key_staff INT NOT NULL,
  store_key_customer INT NOT NULL,
  staff_key INT NOT NULL,
  rental_id INT NOT NULL,
  rental_qty INT,
  rental_amnt DOUBLE(10,4),
  discount DOUBLE(10,4),
  tax DOUBLE(10,4),
  load_date DATETIME
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;

  CREATE INDEX fact_daily_rentals_ix_1 ON sakila_dw.fact_daily_rentals(date_key);
  CREATE INDEX fact_daily_rentals_ix_2 ON sakila_dw.fact_daily_rentals(time_key);
  CREATE INDEX fact_daily_rentals_ix_3 ON sakila_dw.fact_daily_rentals(movie_key);
  CREATE INDEX fact_daily_rentals_ix_4 ON sakila_dw.fact_daily_rentals(customer_key);
  CREATE INDEX fact_daily_rentals_ix_5 ON sakila_dw.fact_daily_rentals(store_key_inventory);
  CREATE INDEX fact_daily_rentals_ix_6 ON sakila_dw.fact_daily_rentals(store_key_staff);
  CREATE INDEX fact_daily_rentals_ix_7 ON sakila_dw.fact_daily_rentals(store_key_customer);
  CREATE INDEX fact_daily_rentals_ix_8 ON sakila_dw.fact_daily_rentals(staff_key);

truncate table sakila_dw.fact_daily_rentals;

insert into sakila_dw.fact_daily_rentals
	select 
	date(r.rental_date) + 0,
	t.time_key,
	ifnull(c.customer_key, -1),
	ifnull(m.movie_key, -1),
	ifnull(si.store_key, -1),
	ifnull(s.staff_main_store_key, -1),
    ifnull(sc.store_key, -1),
	ifnull(s.staff_key, -1),
    r.rental_id,
	1,
	p.amount,
	0,
	0,
	current_date()
 from 
	sakila_stg.rental r
	left join sakila_dw.dim_time t 			on hour(r.rental_date) = t.hour and minute(r.rental_date) = t.minute
	left join sakila_stg.inventory i		on r.inventory_id = i.inventory_id
	left join sakila_dw.dim_movie m			on i.film_id = m.film_id
	left join sakila_dw.dim_customer c  	on r.customer_id = c.customer_id and r.rental_date between c.effective_from and c.effective_to
	left join sakila_dw.dim_staff s			on r.staff_id = s.staff_id
	left join sakila_dw.dim_store si		on i.store_id = si.store_id
    left join sakila_stg.customer cu 		on r.customer_id = cu.customer_id
    left join sakila_dw.dim_store sc 			on cu.store_id = sc.store_id
	left join sakila.payment p				on r.rental_id = p.rental_id;

select * from sakila_dw.fact_daily_rentals r 
join sakila_dw.dim_customer c on r.customer_key = c.customer_key
where customer_id = 7;


select date_key_rental, movie_key, count(1)
from sakila_dw.fact_daily_rentals
group by date_key_rental, movie_key;
