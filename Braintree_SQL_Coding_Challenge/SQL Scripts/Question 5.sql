/*Find the sum of gpd_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where (i) the year is before 2012 and (ii) the country has a null gdp_per_capita in 2012. Your result should have the columns:
year
country_count
total

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Answer:
1. Pretty basic query structure, with a sub-query created first, named 'b', to extract all those records from per_capita table where year is 2012 and GDP per capita values are null.
2. Once the temporary table is established, it is connected with the main query thorugh RIGHT JOIN to extract the sum of GDP per capita of all of these countries in all years before 2012 and their count in each year. */

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    a.year, 
    COUNT(DISTINCT a.country_code) AS country_count, 
    CONCAT('$', ROUND(SUM(a.gdp_per_capita), 2)) AS total
FROM 
    per_capita AS a
RIGHT JOIN (
    SELECT * FROM per_capita
    WHERE year = 2012 AND gdp_per_capita IS NULL
) AS b ON a.country_code = b.country_code
WHERE 
    a.year < 2012 AND a.gdp_per_capita IS NOT NULL
GROUP BY 
    a.year;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Solution:

| year | country_count   | total               |
|------|-----------------|---------------------|
| 2004 | 15              | $491,203            |
| 2005 | 15              | $510,735            |
| 2006 | 14              | $553,690            |
| 2007 | 14              | $654,509            |
| 2008 | 10              | $574,016            |
| 2009 | 9               | $473,103            |
| 2010 | 4               | $179,751            |
| 2011 | 4               | $199,153            |

*/
