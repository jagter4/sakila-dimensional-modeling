-- the Time Dimension is separate from Date and useful when time of day is an interesting analysis
-- Gill Staniland January 2026 

drop table if exists sakila_dw.dim_time;

CREATE TABLE sakila_dw.dim_time(
  time_key INT NOT NULL AUTO_INCREMENT,
  `hour` INT NOT NULL,
  `minute` INT NOT NULL,
  `HH_MM` CHAR(5),
  shift VARCHAR(20),
  load_date DATETIME,
  PRIMARY KEY(time_key)
) DEFAULT CHARACTER SET = `utf8mb4` COLLATE = `utf8mb4_0900_ai_ci`;

  CREATE UNIQUE INDEX dim_time_ix_1 ON sakila_dw.dim_time(`hour`, `minute`);
  
delimiter //

DROP PROCEDURE IF EXISTS sakila_dw.timedimbuild;

CREATE PROCEDURE sakila_dw.timedimbuild()
begin
	
    DECLARE start_hour int;
    DECLARE start_minute int;

    DELETE FROM dim_time;

    SET start_hour = 0;
    SET start_minute = 0;
    
    select 0 as start_hour;
    select 0 as start_minute;
    
    WHILE start_hour < 25 DO
		WHILE start_minute < 61 DO
			INSERT INTO sakila_dw.dim_time (
					time_key,
					`hour` ,
					`minute` ,
					HH_MM,
					shift ,
					load_date
				) VALUES (
					null,
					start_hour,
					start_minute,
					concat(LPAD(start_hour, 2, '0'), ':', LPAD(start_minute,2,'0')),
					case
						when start_hour between 0 and 5 then 'Early'
						when start_hour between 6 and 11 then 'Morning'
						when start_hour between 12 and 17 then 'Afternoon'
						when start_hour between 18 and 20 then 'Evening'
						when start_hour between 21 and 24 then 'Late'
					end,
					current_date()
				);

			SET start_minute = start_minute + 1;
		END WHILE;
        
		set start_hour = start_hour + 1;
		set start_minute = 0;
    END WHILE;
END;
//
DELIMITER ;

call sakila_dw.timedimbuild();

select * from sakila_dw.dim_time 
where hour = 20;
