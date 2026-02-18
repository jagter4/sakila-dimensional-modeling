DROP TABLE IF EXISTS sakila_dw.dim_actor;

CREATE TABLE sakila_dw.dim_actor(
  actor_key INT NOT NULL AUTO_INCREMENT,
  actor_id INT NOT NULL,
  actor_first_name VARCHAR(100),
  actor_last_name VARCHAR(100),
  load_date DATETIME,
  PRIMARY KEY(actor_key)
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;

  CREATE UNIQUE INDEX dim_actor_ix_1 ON sakila_dw.dim_actor(actor_id);
  
  insert into sakila_dw.dim_actor
	  select
		  null,
		  actor_id,
		  first_name,
		  last_name,
		  current_date()
	  from sakila_stg.actor;
  
  select * from sakila_dw.dim_actor;
  
  --  Bridge Table between movie and actor
  
  DROP TABLE IF EXISTS sakila_dw.brg_movie_actor;
  
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