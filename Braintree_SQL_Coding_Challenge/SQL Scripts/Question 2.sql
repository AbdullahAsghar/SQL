/*2. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:

(i) Asia, (ii) Europe, (iii) the Rest of the World. Your result should look something like

|  Asia  | Europe | Rest of World |
| ------ | ------ | ------------- |
| 25.0%  | 25.0%  | 50.0%         |

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Answer:
1. A CTE is first created, named 'x', which has two LEFT JOINS joining the per_capita table with continent_map and continents tables to extract the names of continents and countries.
2. Condition of year being 2012 is also applied.
3. The results from this CTE are then taken into the main query which has multiple CASE statements to classify each result based on the continent.The CASE statement calculates the percentage contribution of each continent from the total GDP and gets grouped by the continent name. 
*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH x AS (
    SELECT 
        a.country_code, 
        a.year, 
        ROUND(a.gdp_per_capita, 2) AS gdp_per_capita, 
        c.continent_name
    FROM 
        per_capita AS a
    LEFT JOIN 
        continent_map AS b ON a.country_code = b.country_code
    LEFT JOIN 
        continents AS c ON b.continent_code = c.continent_code
    WHERE 
        a.year IN (2012)
)
SELECT 
    CASE 
        WHEN x.continent_name = 'Asia' THEN CONCAT(ROUND(100 * SUM(x.gdp_per_capita) / (SELECT SUM(gdp_per_capita) FROM per_capita WHERE year IN (2012)), 2), '%')
    END AS Asia,
    CASE 
        WHEN x.continent_name = 'Europe' THEN CONCAT(ROUND(100 * SUM(x.gdp_per_capita) / (SELECT SUM(gdp_per_capita) FROM per_capita WHERE year IN (2012)), 2), '%')
    END AS Europe,
    CASE 
        WHEN x.continent_name NOT IN ('Asia', 'Europe') THEN CONCAT(ROUND(100 * SUM(x.gdp_per_capita) / (SELECT SUM(gdp_per_capita) FROM per_capita WHERE year IN (2012)), 2), '%')
    END AS 'Rest_of_World'
FROM 
    x
GROUP BY 
    x.continent_name;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Solution:

|  Asia  | Europe | Rest of World |
| ------ | ------ | ------------- |
| 24.52% | 36.55% | 38.93%        |

*/
