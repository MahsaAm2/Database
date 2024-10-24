-- 3
-- a
create VIEW information_student_instructor AS
select instructor.id,instructor.name,'INS' as type,
case
	when instructor.dept_name like '%Eng.' then 'Engineer'
	ELSE 'Scientist'
	end job

from instructor
UNION
select student.id,student.name, 'STU' as type,
case
	when student.dept_name like '%Eng.' then 'Engineer'
	ELSE 'Scientist'
	end job
from student;

-- b
select * from information_student_instructor;

select information_student_instructor.name,
information_student_instructor.type,
(instructor.salary/department.budget)*100
from information_student_instructor,instructor,department
where information_student_instructor.id = instructor.id
and instructor.dept_name = department.dept_name
and information_student_instructor.type ='INS'

union

select information_student_instructor.name,
information_student_instructor.type,
(department.budget)/(SELECT count(*) from student where department.dept_name=student.dept_name)
from information_student_instructor,student,department
where information_student_instructor.id = student.id
and student.dept_name = department.dept_name
and information_student_instructor.type ='STU';
-----------------------------
-- 4
-- a

CREATE OR REPLACE FUNCTION check_length()
  RETURNS TRIGGER AS $$
DECLARE
  new_length     BIGINT;
BEGIN

  SELECT INTO new_length film.length
  FROM film
  WHERE film_id = NEW.film_id;
 
  IF new_length < 50
  THEN
    RAISE EXCEPTION 'error';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_length_trigger
AFTER INSERT OR UPDATE ON film
FOR EACH ROW EXECUTE PROCEDURE check_length();

insert into film(film_id,title,length,language_id)
values (100001,'X',5,1);

--
--b
ALTER TABLE payment
add column PAY_TYPE varchar(50)
CHECK (PAY_TYPE in ('credit_cart','cash','online'))

------------------------------
-- 5
--a

BEGIN;
INSERT INTO department(dept_name,building,budget)
VALUES('medical','Pasteur',700000);
INSERT INTO department(dept_name,building,budget)
VALUES('dental','Pasteur',800000);
COMMIT;

--b
BEGIN; 
DO $$ 
DECLARE s INTEGER ;
BEGIN
select budget into s
from department
where department.dept_name='medical';
UPDATE department SET budget = budget + (s*0.1)
    WHERE dept_name = 'dental';

UPDATE department SET budget = budget - (s*0.1)
    WHERE dept_name = 'medical';
END 
$$; 
COMMIT;

SELECT * from department
where building ='Pasteur';



-- 6
CREATE FUNCTION func_1 (input_actor_id integer)
	returns table(title varchar(255),
				count_f bigint)
AS $$
BEGIN
	return QUERY
		select film.title,count(*)
		from actor,film_actor,inventory,rental,film
		where actor.actor_id=film_actor.actor_id
		and film_actor.film_id = film.film_id
		and film.film_id = inventory.film_id
		and inventory.inventory_id = rental.inventory_id
		and actor.actor_id=input_actor_id
		group by film.title;
	
END;
$$
LANGUAGE 'plpgsql';
select * from func_1(10);



-----------------------------------------------

-- 7
CREATE PROCEDURE proc_6(film_a varchar(255), film_b varchar(255))
LANGUAGE plpgsql AS
$$
DECLARE _r_cost NUMERIC(5,2);
begin
SELECT replacement_cost INTO _r_cost
from film
where title = film_a;
update film
	set replacement_cost = replacement_cost + (0.05*_r_cost)
	where title = film_b;
update film	
	set replacement_cost = replacement_cost - (0.05*_r_cost)
	where title = film_a;
end;
$$;

call proc_6 ('Airport Pollock','Bright Encounters');


----- 
-- 8
-- a
CREATE OR REPLACE FUNCTION func_r()
	returns trigger
	LANGUAGE  PLPGSQL
	as $$
	DECLARE temp INT;
	begin
	select check_count into temp
	from customer
	where customer_id = new.customer_id;
	if temp < 2 THEN
	update customer
	set check_count = check_count+1
	where customer_id = new.customer_id;
	elseif temp=2 THEN
	
	update rental
	set rental_data = rental_date + interval'7 day'
	where rental_id = new.rental_id;
	update customer
	set check_count = 0
	where customer_id = new.customer_id;
	end if;
	return new;
	end;
	$$


create TRIGGER tri_r
after INSERT
on rental
for each row
when (pg_trigger_depth()<1)
execute procedure func_r();

	
	
insert into rental(rental_date,inventory_id,customer_id,return_date,staff_id) 
VALUES (now(),5,1,now()+interval'10 day',1)

insert into rental(rental_date,inventory_id,customer_id,return_date,staff_id) 
VALUES (now(),6,1,now()+interval'10 day',1)

insert into rental(rental_date,inventory_id,customer_id,return_date,staff_id) 
VALUES (now(),7,1,now()+interval'10 day',1)






-----------------------------
-- 9

select film.title,film.rating, rank () over (ORDER BY sum(payment.amount) DESC) as rank_in_all,
rank () over (PARTITION BY film.rating ORDER BY sum(payment.amount) DESC) as rank_in_rating,
sum(payment.amount) as sum_amount,
(CASE
 	WHEN(ntile(4) over (order by sum(amount) DESC))=1 THEN 'YES'
    else 'NO'
	end
) as is_in_first_quartile
from film,inventory,payment,rental
where film.film_id = inventory.film_id
and inventory.inventory_id = rental.inventory_id
and rental.rental_id = payment.rental_id
group by film.film_id
order by film.title;

----------------------------
--10
select EXTRACT (month from payment.payment_date) as m , film.rating,
sum(payment.amount) as sum, 
lead(sum(payment.amount),-1) OVER (PARTITION by film.rating ORDER by 
EXTRACT (month from payment.payment_date)) p_m,	
lead(sum(payment.amount),1) OVER (PARTITION by film.rating ORDER by 
EXTRACT (month from payment.payment_date)) n_m
from film,inventory,payment,rental
where film.film_id = inventory.film_id
and inventory.inventory_id = rental.inventory_id
and rental.rental_id = payment.rental_id
group by m,film.rating
order by m;

















