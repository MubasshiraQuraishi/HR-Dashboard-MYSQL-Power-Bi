CREATE DATABASE projects;

USE projects;
SELECT * FROM hr;

-- Data Cleaning

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;
DESCRIBE hr;

-- Cleaning birthdate column
SELECT birthdate FROM hr;
UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE "%/%" THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE "%-%" THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- Cleaning hire_date column
SELECT hire_date FROM hr;
UPDATE hr
SET hire_date = CASE
    WHEN hire_date LIKE "%/%" THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE "%-%" THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- Cleaning termdate column
SELECT termdate FROM hr;

UPDATE hr
SET termdate = '0000-00-00'
WHERE termdate IS NULL OR termdate = '';

UPDATE hr
SET termdate = 
    CASE 
        WHEN termdate IS NOT NULL AND termdate != '' AND termdate != '0000-00-00' THEN DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
        ELSE '0000-00-00'
    END
WHERE termdate IS NOT NULL OR termdate != '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- Adding age column
ALTER TABLE hr
ADD COLUMN age int;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) as Employeegendercount
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) as Employeereacecount
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY COUNT(*) DESC;
-- 3. What is the age distribution of employees in the company?
SELECT 
	min(age) as youngest,
    max(age) as oldest
FROM hr
WHERE age >= 18 and termdate = '0000-00-00';
SELECT
	CASE
		WHEN age >= 18 AND age <= 25 THEN '18-25'
        WHEN age >= 26 AND age <= 35 THEN '26-35'
        WHEN age >= 36 AND age <= 45 THEN '36-45'
        WHEN age >= 46 AND age <= 55 THEN '46-55'
        WHEN age >= 56 AND age <= 65 THEN '56-65'
        ELSE '65+'
	END AS 'age_group',
    COUNT(*) AS COUNT
    FROM hr
    WHERE age >= 18 and termdate = '0000-00-00'
    GROUP BY age_group
    ORDER BY age_group;
    ---
    SELECT 
	min(age) as youngest,
    max(age) as oldest
FROM hr
WHERE age >= 18 and termdate = '0000-00-00';
SELECT
	CASE
		WHEN age >= 18 AND age <= 25 THEN '18-25'
        WHEN age >= 26 AND age <= 35 THEN '26-35'
        WHEN age >= 36 AND age <= 45 THEN '36-45'
        WHEN age >= 46 AND age <= 55 THEN '46-55'
        WHEN age >= 56 AND age <= 65 THEN '56-65'
        ELSE '65+'
	END AS age_group, gender,
    COUNT(*) AS COUNT
    FROM hr
    WHERE age >= 18 and termdate = '0000-00-00'
    GROUP BY age_group, gender
    ORDER BY age_group, gender;
    
-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) as COUNT
FROM hr
WHERE age >=18 and termdate = '0000-00-00'
GROUP BY location;
-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS AverageLengthOfEmployment
FROM hr
WHERE termdate <> '0000-00-00' AND age>= 18 AND termdate <= CURDATE();

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS COUNT
FROM hr
WHERE age>=18 and termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS COUNT
FROM hr
WHERE age>=18 and termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS terminated_rate
FROM (
SELECT department,
COUNT(*) AS total_count,
SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
FROM hr
WHERE age >= 18
GROUP BY department
) AS subquery
ORDER BY terminated_rate DESC;
 
-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS COUNT
FROM hr
WHERE age>=18 and termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
year,
hires,
terminations,
hires - terminations AS net_change,
ROUND((hires - terminations) / hires * 100, 2) AS net_change_percent
FROM(
	SELECT 
    YEAR(hire_date) AS YEAR,
	COUNT(*) AS hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
	GROUP BY YEAR(hire_date)
    ) AS subquery
    ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT
department,
ROUND(AVG(DATEDIFF(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE() AND age >=18
GROUP BY department;