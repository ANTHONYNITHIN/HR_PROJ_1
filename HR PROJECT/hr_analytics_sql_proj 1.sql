SELECT * FROM pp2.`human resources`;
use pp2;
SELECT * FROM `human resources`;
-- change the column name ï»¿id

alter table `human resources` rename column ï»¿id to emp_id;
-- SELECT * FROM `human resources`;
-- details of the column (datatype)
describe `human resources`;
-- change from text to varchar for emp_id
alter table `human resources` modify column emp_id varchar(20);
SELECT * FROM `human resources`;

rename Table `human resources` to hr;
SELECT * FROM hr;
SELECT birthdate FROM hr;

-- make sure the records of birth date are of the same data type
update hr set birthdate = 
	case when birthdate like "%/%" then date_format(str_to_date(birthdate,"%m/%d/%Y"),'%Y-%m-%d') -- date_format -- str_to_date
		 when birthdate like "%-%" then date_format(str_to_date(birthdate,"%m-%d-%Y"),'%Y-%m-%d')
    else NOT NULL
	END 
-- To update
Set sql_safe_updates = 0;
-- change the data type of the birthdate column
alter table hr modify column birthdate date;
describe hr;
Select * from hr;
-- make sure the records of birth date are of the same data type
update hr set hire_date = 
	case when hire_date like "%/%" then date_format(str_to_date(hire_date,"%m/%d/%Y"),'%Y-%m-%d') -- date_format -- str_to_date
		 when hire_date like "%-%" then date_format(str_to_date(hire_date,"%m-%d-%Y"),'%Y-%m-%d')
    else NOT NULL
	END 
-- change the data type of the hire_date column
describe hr;
UPDATE hr
SET termdate = str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')
WHERE termdate IS NOT NULL AND termdate != '' AND termdate != ' ';


UPDATE hr
SET termdate = NULL
WHERE termdate = '';

ALTER TABLE hr MODIFY COLUMN termdate DATE;

describe hr;

-- age column from birthdate for classifying and reading purpose
ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE()); -- TIMESTAMPDIFF(unit, start_timestamp, end_timestamp)
-- to calculate the difference between two timestamps. 
-- curdate - (yyyy-mm-dd)
select birthdate,age from hr;

SELECT 
	min(age) AS youngest, /*-46 is the youngest age which is wrong */
    max(age) AS oldest
FROM hr;

SELECT count(*) FROM hr WHERE age < 18;

select termdate from hr;
SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();
 /*
SELECT COUNT(*)
FROM hr
WHERE termdate is null;
*/
SELECT location FROM hr;
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- Q1 - what is the gender break down of the emplyoees in the table ?
--  ans 1
select * from hr;
select gender,count(gender) from hr where age >=18 and termdate is null  group by gender;
/* 'Male', '8911'
'Female', '8090'
'Non-Conforming', '481'
*/
-- Q2 - what is the race/ethnicity break down of the emplyoees in the comapny ?
--  ans 2
select * from hr;
select race,count(race) as count_of_race from hr
where age >=18 and termdate is null  group by race order by count(race) desc;
/*
'White', '4987'
'Two or More Races', '2867'
'Black or African American', '2840'
'Asian', '2791'
'Hispanic or Latino', '1994'
'American Indian or Alaska Native', '1051'
'Native Hawaiian or Other Pacific Islander', '952'
*/

-- Q3 - What is the age distribution of employees in the company?
--  ans 3
select * from hr;
select min(age) YOUNGEST,MAX(age) OLDEST from hr where age >=18 and termdate is null ;
/* '20', '57' */
SELECT
    CASE
        WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE 'Above 65'
    END AS age_distribution,
    count(age) AS count,gender
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_distribution,gender
ORDER BY age_distribution,gender DESC;


-- Q4. How many employees work at headquarters versus remote locations?
-- ans4
select location,count(location) as location_dis from hr WHERE age >= 18 AND termdate IS NULL group by location ;
/*
'Headquarters', '13107'
'Remote', '4375'
*/
-- 5. What is the average length of employment for employees who have been terminated?
-- ans5
select termdate,hire_date from hr;
SELECT round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment FROM hr
WHERE termdate <= curdate() AND termdate is not null AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
-- ans6
select * from hr;
select gender,department,count(*) count from hr
WHERE age >= 18 AND termdate IS NULL group by department,gender order by department ;
-- 7. What is the distribution of job titles across the company?
-- ans7

select jobtitle,count(*) count from hr
WHERE age >= 18 AND termdate IS NULL group by jobtitle order by jobtitle desc ;

-- 8. Which department has the highest turnover rate?
-- ans8
select * from hr;
SELECT department,total_count,terminated_count,terminated_count/total_count AS termination_rate
FROM (SELECT department,count(*) AS total_count,
SUM(CASE WHEN termdate is not null AND termdate <= curdate() THEN 1 ELSE 0 END) as terminated_count
FROM hr
WHERE age >= 18 GROUP BY department) AS subquery ORDER BY termination_rate DESC;
-- 9. What is the distribution of employees across locations by city and state?
-- ans

select * from hr;

select count(*) as count,location_state from hr  
WHERE age >= 18 AND termdate IS NULL  
group by location_state 
order by count desc;

-- 10. How has the company's employee count changed over time based on hire and term dates?
-- ans10
SELECT year,hires,terminations,hires - terminations AS net_change,round((hires - terminations)/hires* 100, 2) AS net_change_percent
FROM(
SELECT YEAR(hire_date) AS year,count(*) AS hires,SUM(CASE WHEN termdate is not null AND termdate <= curdate() THEN 1 ELSE 0 END) 
as terminations
FROM hr
WHERE age >=18
GROUP BY YEAR(hire_date)) AS subquery
order by year asc;


-- 11. What is the tenure distribution for each department?
-- 11 ans
select * from hr;

SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr WHERE termdate <= curdate() AND termdate is not null AND age >= 18 GROUP BY department;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------