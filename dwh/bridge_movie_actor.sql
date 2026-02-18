CREATE TABLE sakila_dw.brg_movie_actor(
  movie_key INT NOT NULL,
  actor_key INT NOT NULL,
  weighting DECIMAL(10,2),
  load_date DATETIME,
  PRIMARY KEY(actor_key, movie_key)
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;
  
insert into sakila_dw.brg_movie_actor
  select
	  movie_key,
	  actor_key,
	  1/count(fa.actor_id) OVER (PARTITION BY fa.film_id) as weight,
	  current_date()
  from sakila_stg.film_actor fa
  join sakila_dw.dim_movie m 	on fa.film_id = m.film_id
  join sakila_dw.dim_actor a	on fa.actor_id = a.actor_id
  order by fa.film_id;
  
select * from sakila_dw.brg_movie_actor;
  
select * from
  sakila_dw.dim_movie m
  join sakila_dw.brg_movie_actor b 	on m.movie_key = b.movie_key
  join sakila_dw.dim_actor a		on b.actor_key = a.actor_key;
  
  select a.actor_last_name, movie_category, count(1) from
  sakila_dw.dim_movie m
  join sakila_dw.brg_movie_actor b 	on m.movie_key = b.movie_key
  join sakila_dw.dim_actor a		on b.actor_key = a.actor_key
  group by a.actor_last_name, movie_category
  order by a.actor_last_name, count(1) desc;
  
select a.actor_last_name, count(distinct movie_category), count(1) from
  sakila_dw.dim_movie m
  join sakila_dw.brg_movie_actor b 	on m.movie_key = b.movie_key
  join sakila_dw.dim_actor a		on b.actor_key = a.actor_key
  group by a.actor_last_name;
