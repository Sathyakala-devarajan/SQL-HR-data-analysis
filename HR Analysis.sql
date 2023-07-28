-- Data uploading:
create database HR_dataset;
use HR_dataset;

-- Create Table
create table hris_1(
Employee_id int,
Positions varchar(255),
DOB date,
Gender varchar(255),
Marital_station varchar(255),
Date_of_Hiring date,
Date_of_termination date null,
Termination_reason varchar(255),
Employment_status varchar(255));

create table hris_2 (
Employee_id int,
Dept varchar(255),
Manager_name varchar(255),
Perf_score varchar(255),
Emp_satisfaction int,
Date_of_review date,
Last_days int,
Absences int);

create table hris_3(
Employee_id int,
salary float);

select * from hris_1;
select * from hris_2;
select * from hris_3;

-- Date processing
alter table hris_1 
add review_date date default '2020-12-31',
add column age int,
add column age_band varchar(50);

-- Data analysing:
/* How many employees are currently employed by each department? */
select t2.dept, count(t1.Employee_id) as Total_employee 
from hris_1 t1 
join hris_2 t2
on t1.Employee_id=t2.Employee_id
where t1.Employment_status = 'Active'
group by t2.Dept
order by Total_employee desc;


/* What are the demographics of our current employees Age */
select age_band, count(Employee_id) as Total_employee 
from hris_1
where Employment_status = 'Active'
group by age_band
order by age_band asc;
 
/* What are the demographics of our current employees by Gender */
select gender, count(Employee_id) as Total_employee 
from hris_1
where Employment_status = 'Active'
group by gender;

/* What are the demographics of our current employees by Marital Status */
select marital_station, count(Employee_id) as Total_employee 
from hris_1
where Employment_status = 'Active'
group by marital_station
order by Total_employee desc;

/* What was the current total salary expense for each department? */
select t2.dept, round(sum(t3.salary)) as Total_salary, round(avg(t3.salary)) as Avg_salary
from hris_2 as t2
join hris_3 as t3
on t2.Employee_id=t3.employee_id
join hris_1 as t1
on t1.Employee_id=t3.employee_id
where t1.Employment_status = 'Active'
group by t2.dept
order by Total_salary desc;

/* What is the salary structure for each demography of our current employees by Age */
select t1.age_band, round(sum(t3.salary)) as Total_salary, round(avg(t3.salary)) as Avg_salary
from hris_1 as t1
join hris_3 as t3
on t1.Employee_id=t3.employee_id
where t1.Employment_status = 'Active'
group by t1.age_band
order by t1.age_band;

/* What is the salary structure for each demography of our current employees by Gender */
select t1.gender, round(sum(t3.salary)) as Total_salary, round(avg(t3.salary)) as Avg_salary
from hris_1 as t1
join hris_3 as t3
on t1.Employee_id=t3.employee_id
where t1.Employment_status = 'Active'
group by t1.gender;

/* What is the salary structure for each demography of our current employees by Marital Status */
select t1.marital_station, round(sum(t3.salary)) as Total_salary, round(avg(t3.salary)) as Avg_salary
from hris_1 as t1
join hris_3 as t3
on t1.Employee_id=t3.employee_id
where t1.Employment_status = 'Active'
group by t1.marital_station
order by Total_salary desc, Avg_salary;

/* What was the distribution of employees in terms of their performance? */
select t2.perf_score, count(t1.employee_id) as Total_count
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by t2.perf_score
order by total_count desc;

/* Could we do a deep dive per group by Department */
select t2.dept, t2.perf_score, count(t1.employee_id) as total_count
from hris_2 t2 
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by t2.dept, t2.perf_score
order by t2.perf_score desc, total_count desc;


WITH PerformanceStats AS (
  SELECT
    t2.dept,
    t2.perf_score,
    COUNT(t1.employee_id) AS total_count,
    SUM(COUNT(t1.employee_id)) OVER (PARTITION BY t2.dept) AS department_total_count
  FROM hris_2 t2
  JOIN hris_1 t1 ON t2.employee_id = t1.employee_id
  WHERE t1.Employment_status = 'Active'
  GROUP BY t2.dept, t2.perf_score
)
SELECT
  dept,
  perf_score,
  total_count,
  ROUND((total_count / department_total_count) * 100, 2) AS percentage_of_total
FROM PerformanceStats
ORDER BY perf_score DESC, total_count DESC;

/* Could we do a deep dive per group by Age */
with age_performance as (
	select t1.age_band, t2.perf_score, count(t1.employee_id) as total_count,
	sum(count(t1.employee_id)) over (partition by t1.age_band) as age_total_count
	from hris_2 t2 
	join hris_1 t1
	on t2.employee_id=t1.employee_id
	where t1.Employment_status = 'Active'
	group by t1.age_band, t2.perf_score
)
select age_band, perf_score, total_count, 
round((total_count / age_total_count) * 100, 2) as percentage_of_total
from age_performance
order by age_band asc, perf_score desc, total_count desc;

/* Could we do a deep dive per group by Gender */
with gender_performance as (
	select t1.gender, t2.perf_score, count(t1.employee_id) as total_count,
	sum(count(t1.employee_id)) over (partition by t1.gender) as gender_total_count
	from hris_1 t1 
	join hris_2 t2
	on t2.employee_id=t1.employee_id
	where t1.Employment_status = 'Active'
	group by t1.gender, t2.perf_score
)
select gender, perf_score, total_count, 
round((total_count / gender_total_count) * 100, 2) as percentage_of_total
from gender_performance
order by gender asc, perf_score desc, total_count desc;

/* Could we do a deep dive per group by Marital Status */
with marital_performance as (
	select t1.marital_station, t2.perf_score, count(t1.employee_id) as total_count,
	sum(count(t1.employee_id)) over (partition by t1.marital_station) as marital_total_count
	from hris_1 t1 
	join hris_2 t2
	on t2.employee_id=t1.employee_id
	where t1.Employment_status = 'Active'
	group by t1.marital_station, t2.perf_score
)
select marital_station, perf_score, total_count, 
round((total_count / marital_total_count) * 100, 2) as percentage_of_total
from marital_performance
order by marital_station asc, perf_score desc, total_count desc;

/* How satisfied our employees are? */
select t2.emp_satisfaction, count(t2.emp_satisfaction) as Total_satisfaction
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active' 
group by emp_satisfaction
order by emp_satisfaction;

/* Could we do a deep dive per group for emp satisfaction by Department */
select t2.dept, count(t2.emp_satisfaction) as Total, round(avg(t2.emp_satisfaction),2) as Average
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by dept
order by Average desc;

/* Could we do a deep dive per group for emp satisfaction by Position */
select t1.positions, count(t2.emp_satisfaction) as Total, round(avg(t2.emp_satisfaction),2) as Average
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by t1.positions
order by Average desc;

/* Could we do a deep dive per group for emp satisfaction by Age */
select t1.positions, count(t2.emp_satisfaction) as Total, round(avg(t2.emp_satisfaction),2) as Average
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by t1.positions
order by Average desc limit 5;  

/* Could we do a deep dive per group for emp satisfaction by Gender */
select t1.gender, count(t2.emp_satisfaction) as Total, round(avg(t2.emp_satisfaction),2) as Average
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by t1.gender
order by Average desc; 

/* Could we do a deep dive per group for emp satisfaction by Marital Status */
select t1.marital_station, count(t2.emp_satisfaction) as Total, round(avg(t2.emp_satisfaction),2) as Average
from hris_2 t2
join hris_1 t1
on t2.employee_id=t1.employee_id
where t1.Employment_status = 'Active'
group by t1.marital_station
order by Average desc; 

/* How many employees have left the company in total */
select employment_status, count(employee_id) as total_count 
from hris_1
where employment_status in ('Voluntarily Terminated', 'Terminated for Cause')
group by employment_status;

/* What were the main reasons for them to leave? */
select termination_reason, count(employee_id) as total_count 
from hris_1
where employment_status in ('Voluntarily Terminated', 'Terminated for Cause')
group by termination_reason
order by total_count desc;

/* How many of those reasons are voluntary and non-voluntary? */
select Employment_status, termination_reason, count(employee_id) as total_count,
sum(count(employee_id)) over (partition by termination_reason) as grand_total_count
from hris_1
where Employment_status not like 'Active'
group by Employment_status, termination_reason
order by total_count desc;

/* Attrition by Department */
select t2.dept, t1.Employment_status, count(t1.Employee_id) as Total_count
from hris_1 t1
join hris_2 t2
on t1.Employee_id=t2.Employee_id
where Employment_status not like 'Active'
group by t2.dept, t1.employment_status;

/* Attrition by Age */
select age_band, Employment_status, count(Employee_id) as Total_count
from hris_1 t1
where Employment_status not like 'Active'
group by age_band, employment_status
order by age_band;

/* Attrition by Gender */
select gender, Employment_status, count(Employee_id) as Total_count
from hris_1 t1
where Employment_status not like 'Active'
group by gender, employment_status
order by gender;

/* Attrition by Marital Status */
select marital_station, Employment_status, count(Employee_id) as Total_count
from hris_1 t1
where Employment_status not like 'Active'
group by marital_station, employment_status
order by marital_station;