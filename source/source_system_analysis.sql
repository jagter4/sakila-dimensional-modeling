--  Getting a deeper understanding of the source data:
/*
How many movies do we have to rent?
How many customer do we have on the system?
Which country do they live in?
What language do the speak?
Where do our employees work?
Which years do our rentals cover?

*/








-- how many movies for we have?

select count(*)
from film;

select * from film;


-- many customers for we have on the system?

select count(*)
from customer;

-- where do they live?

select country, count(*)
from customer c 
join address a on c.address_id = a.address_id
join city ci on a.city_id = ci.city_id
join country co on ci.country_id = co.country_id
group by country;

-- what language do they speak?

-- this cannot be answered from the source data

-- what language movies do we have?

select l.name, count(*)
from film f 
join language l on f.language_id = l.language_id
group by l.name;

-- Where do our employees work?

select address.*, store.*, staff.*
from staff join store 
on staff.store_id = store.store_id
join address on store.address_id = address.address_id;

-- Which years do our rentals cover?

select year(rental_date), count(*)
from rental
group by year(rental_date);

