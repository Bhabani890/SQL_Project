-- Introduction:

-- The HR Analysis project revolves around the careful examination and interpretation of data related to an 
-- organization's human resources. The project is grounded in the belief that data-driven insights shedding light 
-- on various aspects of the workforce. The project employs SQL queries to clean, preprocess, and analyze data from
-- an HR database.

-- Objective of the Project:

-- The primary goal of this HR Analysis project is to extract meaningful insights from the organization's HR data, 
-- can help organizations make informed decisions about their workforce, leading to improved efficiency, employee 
-- satisfaction, and overall success. 

--  The specific objectives are as follows:

-- 1) Data Cleaning and Preprocessing:  
--            The project begins by cleaning and preprocessing the data to ensure its accuracy and consistency. 
--     This involves handling data format issues and converting text-based dates into the proper date format.

-- 2) Demographic Analysis:
--            The project aims to understand the composition of the workforce by examining gender and race 
--     distributions among current employees.

-- 3) Age Distribution:
--           Analyzing the age distribution of employees provides insights into the generational makeup of the 
--      workforce.

-- 4) Location Analysis: 
--           Understanding where employees are located, including headquarters and remote offices, assists 
--     in managing and optimizing the company's physical presence.

-- 5) Gender Distribution by Department and Job Title: 
--           Examining gender distribution across departments and job titles.

-- 6) Job Title Distribution: 
--           Analyzing the distribution of job titles among terminated employees provides a snapshot of the 
--      company's organizational structure and the roles most affected by turnover.

-- 7) Department Turnover Rates: 
--            Identifying departments with higher turnover rates can help HR and management address issues specific 
--      to those areas and develop retention strategies.

-- 8) Historical Workforce Trends: 
--            Tracking the changes in the employee count over time based on hire and termination dates helps in 
--      understanding historical trends and anticipating future staffing needs.

-- 9) Tenure Distribution by Department: 
--           Analyzing the average tenure of employees within each department helps HR and management understand 
--      how long employees tend to stay in different parts of the organization.

create database hr_analysis

use hr_analysis

select * from hr

-- data cleaning and preprocessing--

alter table hr
CHANGE COLUMN id emp_id VARCHAR(20) NULL;

DESCRIBE hr

set sql_safe_updates=0

update hr
SET birthdate = CASE
    when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
    else null
    end;
    
select * from hr

DESCRIBE hr

-- the data type of birthdate is still in text format. so we have to change it into date format--
alter table hr
modify column birthdate date

-- change the data format and datatype of hire_date column

update hr
SET hire_date = CASE
    when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
    else null
    end;
    
-- the data type of hire_date is still in text format. so we have to change it into date format--
alter table hr
modify column hire_date date

DESCRIBE hr

select * from hr

-- change the date format and datatpye of termdate column

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

alter table hr
modify column termdate date

-- create age column
alter table hr
add column age int

update hr
set age= timestampdiff(year, birthdate, curdate())

select * from hr

SELECT min(age), max(age) FROM hr




-- 1. What is the gender breakdown of employees in the company ?

-- steps -- first retrieves all the data from the "hr" table. 
         -- second counts the number of employees for each gender in the company. 
         -- third specifically counts the number of current employees for each gender, excluding those who 
				-- have left the company. 
		 -- This helps understand the gender distribution among the current workforce.
         
         
select * from hr
select gender, count(*) as count from hr
group by gender

select gender, COUNT(*) as count from hr
where termdate is null
group by gender;



   
-- 2. What is the race breakdown of employees in the company

-- This SQL query helps us understand the distribution of different races among employees. 
-- It counts how many employees belong to each race category
-- This helps us see the racial diversity within the company's workforce.


select race, COUNT(*) as count from hr
where termdate is null                    -- 'termdate IS NULL' means it gives information of the current employees.
group by race;




-- 3. What is the age distribution of employees in the company

-- This SQL query groups employees into different age groups and counts how many employees fall into each group.
-- The query summarizes the age distribution of employees to understand the workforce's age composition.
select
	case
        when age>=18 and age <=24 then '18-24'
		when age>=25 and age <=34 then '25-34'
		when age>=35 and age <=44 then '35-44'
		when age>=45 and age <=54 then '45-54'
		when age>=55 and age <=64 then '55-64'
        else '65+'
    end as age_group, 
    COUNT(*) as count from hr
    where termdate is null               
    group by age_group
    
    
    
    
    
-- 4. How many employees work at HQ vs remote?

-- This SQL query counts the number of employees working at headquarters (HQ) and remote locations. 
 
    select location , COUNT(*) as count from hr
    where termdate is null               
    group by location
    
    
    
    
    
-- 5. What is the average length of employement who have been teminated.

-- This SQL query calculates the average number of years an employee worked before being terminated. 
-- It looks at the difference between the termination year and the hire year for each terminated employee.
    
select * from hr

select round(avg(year(termdate) - year(hire_date)),0) as length_of_emp from hr
where termdate is not null and termdate <= curdate()






-- 6. How does the gender distribution vary acorss dept. and job titles ?

-- This SQL query checks how gender is spread across different departments and job titles. 
-- It counts how many employees of each gender work in each department and job title. 
-- This helps understand gender distribution patterns within the company's organizational structure.

select * from hr

select department, jobtitle, gender, count(*) as count from hr
where termdate is not null
group by department, jobtitle, gender
order by department, jobtitle, gender


select department, gender, count(*) as count from hr
where termdate is not null
group by department, gender
order by department, gender






-- 7. What is the distribution of jobtitles acorss the company ?

-- This SQL query calculates the number of employees who have held each job title in the company,
-- focusing only on those who are no longer employed. 
-- It groups the data by job title and counts how many employees had each title. 
-- The result gives an overview of how job titles are distributed across the company after considering terminations.

select jobtitle, count(*) as count from hr
where termdate is not null
group by jobtitle








-- 8. Which dept has the higher turnover/termination rate?

-- It counts the total number of employees and those who have been terminated. 
-- Then, it calculates the termination rate as a percentage of terminations over the total count. 
-- The results are grouped by department and presented in descending order of termination rate.

select * from hr

select department, 
         count(*) as total_count,
		 count(case
				 when termdate is not null and termdate <= curdate() then 1 end) as terminated_count,
		 round((count(case  
					   when termdate is not null and termdate <= curdate() then 1 end)/count(*))*100,2)
					   as termination_rate
		 from hr
		 group by department
		 order by termination_rate desc
         
         
         
         
         
                   

-- 9. What is the distribution of employees across location_state?

-- These SQL queries count and show the number of active employees in different states and cities. 
-- The first query counts employees by their state of work, while the second query counts them by their 
-- specific city.


select location_state, COUNT(*) as count from hr
where termdate is null
group by location_state

select location_city, COUNT(*) as count from hr
where termdate is null
group by location_city








-- 10. How has the companys employee count changed over time based on hire and termination date.

-- It calculates the hires and terminations for each year, finds the net change, and calculates 
-- the percentage change. The final result displays these changes for each year, giving an overview 
-- of the company's employee count trend.


select * from hr

select year, hires, terminations, hires-terminations as net_change, (terminations/hires)*100 as change_percent
	from(select year(hire_date) as year, count(*) as hires,
            SUM(case 
					when termdate is not null and termdate <= curdate() then 1 end) as terminations from hr
            group by year(hire_date)) as subquery
group by year
order by year;









-- 11. What is the tenure distribution for each dept.

-- This query calculates the average time employees stay in each department. 
--  It considers only employees who have left and limits it to current dates. 
-- Giving insights into how long employees typically stay in different parts of the company.


select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure from hr
where termdate is not null and termdate<= curdate()
group by  department





-- Conclusion:
--    In conclusion, the HR Analysis project aims to transform raw HR data into actionable insights. 
--    By cleansing and processing the data, we ensure its quality and reliability for analysis. 
--    The project addresses various aspects of the workforce, including demographics, age distribution, 
--        location, tenure, and turnover rates. 
--    The insights gained from this analysis can guide strategic HR decisions, improve employee engagement, and 
--        ultimately contribute to the organization's success by fostering a productive and inclusive work 
--        environment. 
