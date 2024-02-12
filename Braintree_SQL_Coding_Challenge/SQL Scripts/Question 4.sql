/*4a. What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Answer:
1. First, a CTE is created, named 'k', with a LEFT JOIN to select the name of every country from the countries table. Condition to extract results for 2007 only has been applied.
2. The CTE is now linked to the main query to extract the count of only those countries that have the string 'an' in their names. LIKE operator used to obtain the result.*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH k AS (
    SELECT 
        a.country_code, 
        b.country_name, 
        a.year, 
        a.gdp_per_capita
    FROM 
        per_capita AS a
    LEFT JOIN 
        countries AS b ON a.country_code = b.country_code
    WHERE 
        a.year = 2007
)
SELECT 
    COUNT(DISTINCT k.country_name) AS countries_count,
    CONCAT('$', ROUND(SUM(k.gdp_per_capita), 2)) AS total_gdp
FROM 
    k
WHERE 
    k.country_name LIKE '%an%';

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Solution:

| countries_count | total_gdp     |
|-----------------|---------------|
| 68              | $1,022,936.33 |

*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*4b. Repeat question 4a, but this time make the query case sensitive.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Answer:
1. Query structure for this question is same as for 4a, except for the difference in LIKE operator, which uses the COLLATE function. ChatGPT's assistance taken. Function explained below:
  - COLLATE: Specifies the collation for the comparison operation.
  - Latin1_General_CS_AS: This is the specific collation being used. In this case, it's Latin1_General_CS_AS, which stands for Latin1 General Case-Sensitive, Accent-Sensitive.
  - CS indicates that the comparison will be case-sensitive, meaning it will differentiate between uppercase and lowercase letters.
  - AS indicates that the comparison will be accent-sensitive, meaning it will differentiate between accented and unaccented characters.*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH k AS (
    SELECT 
        a.country_code, 
        b.country_name, 
        a.year, 
        a.gdp_per_capita
    FROM 
        per_capita AS a
    LEFT JOIN 
        countries AS b ON a.country_code = b.country_code
    WHERE 
        a.year = 2007
)
SELECT 
    COUNT(DISTINCT k.country_name) AS countries_count,
    CONCAT('$', ROUND(SUM(k.gdp_per_capita), 2)) AS total_gdp
FROM 
    k
WHERE 
    k.country_name LIKE '%an%' COLLATE Latin1_General_CS_AS;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Solution: 

| countries_count | total_gdp     |
|-----------------|---------------|
| 66              | $979,601      |

*/
