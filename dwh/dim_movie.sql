DROP table IF exists sakila_dw.dim_movie;

CREATE TABLE sakila_dw.dim_movie(
  movie_key INT NOT NULL AUTO_INCREMENT,
  film_id INT NOT NULL,
  movie_title VARCHAR(100),
  movie_descr VARCHAR(255),
  movie_category VARCHAR(100),
  release_year INT,
  rating VARCHAR(10),
  rental_days INT,
  rental_rate DECIMAL(18,2),
  replacement_cost DECIMAL(18,2),
  load_date DATETIME,
  PRIMARY KEY(movie_key)
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;

  CREATE UNIQUE INDEX dim_movie_ix_1 ON sakila_dw.dim_movie(film_id);
  
insert into sakila_dw.dim_movie
	select 
		null, 
		fi.film_id,
		fi.title,
		fi.description,
		ca.name,
		fi.release_year,
		fi.rating,
		fi.rental_duration,
		fi.rental_rate,
		fi.replacement_cost,
		current_date()
	from sakila_stg.film fi
	join sakila_stg.film_category fc  	on fi.film_id = fc.film_id
	join sakila_stg.category ca 		on fc.category_id = ca.category_id;

select * from sakila_dw.dim_movie;