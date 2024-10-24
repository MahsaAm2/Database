-- q4

-- a
SELECT id,name
from student
WHERE name LIKE 'M%a';

-- b
select title
from course,department,section
where course.dept_name = department.dept_name
and department.dept_name like '%Eng.'
and course.course_id=section.course_id
and section.semester='Fall'
and section.year=2009;

-- c
select student.name, course.title
from student,course,takes
where student.id=takes.id
and takes.course_id = course.course_id
group by (student.id,course.course_id)
having count(*) >= 3;


-- d
select prereq.prereq_id, sum(course.credits)
from course,prereq
where course.course_id = prereq.course_id
group by prereq.prereq_id
having sum(course.credits) > 4
order by sum DESC;



-- e
select classroom.room_number
from classroom,section,time_slot
where section.year=2008
and section.semester='Spring'
and section.room_number = classroom.room_number
and section.time_slot_id = time_slot.time_slot_id
group by classroom.room_number
having sum(time_slot.end_hr - time_slot.start_hr) >=2;


-- f
with avg_count(value) as 
(
select  avg(t1.t_count)
from (
select instructor.id , count(*) as t_count
from instructor,teaches
where instructor.id = teaches.id
and year=2003
GROUP by instructor.id
) as t1	
)
select t1.t_name , t1.t_count
from (
select instructor.name as t_name , count(*) as t_count
from instructor,teaches
where instructor.id = teaches.id
and year=2003
GROUP by instructor.id
) as t1, avg_count
where t1.t_count < avg_count.value;



-- g
select distinct section.* from 
section,time_slot
where section.building='Taylor'
and section.year=2007
and section.time_slot_id = time_slot.time_slot_id
and time_slot.start_hr BETWEEN 8 and 12;

-- h
select student.name, sum (course.credits) 
from student,takes,course
where student.id = takes.id
and course.course_id = takes.course_id
and takes.grade in ('A+','A-','A ','B+','B-','B ')
group by student.id;



--------------------------------------------------
-- q5 a
select dept_name
from(
select dept_name, sum(salary) as s
from instructor
group by dept_name
) as t1
where t1.s > 
(
select avg (s)
from (
select dept_name, sum(salary) as s
from instructor
group by dept_name	
) as t2
)


-- q5 b
with avg_ins_count(value) as 
( 
SELECT AVG(t.TeachCount)
FROM (SELECT instructor.id,COUNT(*) AS TeachCount
FROM teaches,instructor
WHERE teaches.id=instructor.id AND year=2003
GROUP BY instructor.id	) as t
) 
,
ins_count (name,value) as
( 
SELECT instructor.name,COUNT(*),COUNT(*)
FROM teaches,instructor
WHERE teaches.id=instructor.id AND year=2003
GROUP BY instructor.id
)
SELECT name,sum(ins_count.value)
from ins_count,avg_ins_count
where ins_count.value > avg_ins_count.value
group by name

-----------------------------------------
-- q6
-- a
create table uni_data
	(stu_id			    varchar(5), 
	 stu_name			varchar(20) not null, 
	 stu_dept_name		varchar(20),
	 year               numeric(4,0),
	 semester           varchar(6), 
	 course_name        varchar(50),
	 score              float,
	 is_rank            int
	);
	
-- b
INSERT INTO uni_data (stu_id,stu_name,stu_dept_name,year,semester,course_name,score)
SELECT student.id, student.name, student.dept_name,takes.year,takes.semester,course.title,
CASE
    WHEN takes.grade = 'A+' THEN 100
	WHEN takes.grade = 'A ' THEN 95
	WHEN takes.grade = 'A-' THEN 90
	WHEN takes.grade = 'B+' THEN 85
	WHEN takes.grade = 'B ' THEN 80
	WHEN takes.grade = 'B-' THEN 75
	WHEN takes.grade = 'C+' THEN 70
	WHEN takes.grade = 'C ' THEN 65
	WHEN takes.grade = 'C-' THEN 60
    ELSE 0
END AS score
FROM student,takes,course
where student.id=takes.id
and course.course_id = takes.course_id;

update uni_data
	set is_rank = case
	when score > 70
	then 1
	else 0
	end;
	
	
	
-- c
select * from uni_data;
update uni_data
set score= score+10
where score > 75 and stu_dept_name='Physics';

update uni_data
set score= score+15
where score <= 75 and stu_dept_name='Physics';

-- d
delete from uni_data
where stu_name like 'T%' and score < (select avg (score) from uni_data);














