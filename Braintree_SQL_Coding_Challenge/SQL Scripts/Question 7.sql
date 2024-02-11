/*7. Find the country with the highest average gdp_per_capita for each continent for all years. Now compare your list to the following data set. Please describe any and all mistakes that you can find with the data set below.

rank | continent_name | country_code | country_name | avg_gdp_per_capita 
---- | -------------- | ------------ | ------------ | -----------------
   1 | Africa         | SYC          | Seychelles   |         $11,348.66
   1 | Asia           | KWT          | Kuwait       |         $43,192.49
   1 | Europe         | MCO          | Monaco       |        $152,936.10
   1 | North America  | BMU          | Bermuda      |         $83,788.48
   1 | Oceania        | AUS          | Australia    |         $47,070.39
   1 | South America  | CHL          | Chile        |         $10,781.71

Answer: The query mentioned below was constructed in this way:
1. First, a sub-query named 'b' is created to join continent_map with continents table to get the names of all continents against each country.
2. This sub-query was used to further create a CTE named 'avg_cte' to get the names of all countries from countries table. Average GDP per capita for each country was also calculated in this CTE for the period of 2004-2012.
3. Another sub-query was created that is linked with the CTE, named 'k', having DENSE_RANK function to rank each country's GDP per capita in the window of its own continent. 
4. From there, a main query links that only selects the desired columns from the sub-query, along with the condition to only select the countries whose average GDP per capita was ranked 1st in their respective continents.*/

WITH avg_cte AS ( 
    SELECT 
        b.continent_name, 
        a.country_code, 
        c.country_name, 
        ROUND(AVG(a.gdp_per_capita), 2) AS avg_gdp
    FROM 
        per_capita AS a
    LEFT JOIN 
        countries AS c ON a.country_code = c.country_code
    LEFT JOIN 
        (
            SELECT 
                y.*, 
                x.continent_name
            FROM 
                continent_map AS y
            LEFT JOIN 
                continents AS x ON y.continent_code = x.continent_code
        ) AS b ON a.country_code = b.country_code  
    GROUP BY
        b.continent_name, 
        a.country_code, 
        c.country_name
)
SELECT 
    k.rank, 
    k.continent_name, 
    k.country_code, 
    k.country_name, 
    CONCAT('$', k.avg_gdp) AS avg_gdp 
FROM
    (
        SELECT 
            DENSE_RANK() OVER (PARTITION BY avg_cte.continent_name ORDER BY avg_cte.avg_gdp DESC) AS rank, 
            avg_cte.*
        FROM 
            avg_cte
    ) AS k
WHERE 
    k.rank = 1

/*Solution:*/

rank | continent_name | country_code |    country_name   |     avg_gdp
---- | -------------- | ------------ | ----------------- | -----------------
   1 | NULL           | CHI          | Channel Islands   |         $64494
   1 | Africa         | GNQ          | Equatorial Guinea |         $17955.7
   1 | Asia           | QAT          | Qatar             |         $70568
   1 | Europe         | MCO          | Monaco            |         $151422
   1 | North America  | BMU          | Bermuda           |         $84634.8
   1 | Oceania        | AUS          | Australia         |         $46147.4
   1 | South America  | CHL          | Chile             |         $10781

/*Errors and Differences:

1. No values for records having NULL province.
2. Different country and GDP per capita for Africa and Asia.
3. Same country for Europe but different GDP per capita values. Same for North America and Oceania.*/
