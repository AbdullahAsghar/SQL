/*5. All in a single query, execute all of the steps below and provide the results as your final answer:

a. create a single list of all per_capita records for year 2009 that includes columns:
- continent_name
- country_code
- country_name
- gdp_per_capita

b. order this list by:
- continent_name ascending
- characters 2 through 4 (inclusive) of the country_name descending

c. create a running total of gdp_per_capita by continent_name

d. return only the first record from the ordered list for which each continent's running total of gdp_per_capita meets or exceeds $70,000.00 with the following columns:
- continent_name
- country_code
- country_name
- gdp_per_capita
- running_total

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Answer: The query is constructed in this manner:
1. First, a sub-query named 'b' is created to join continent_map with continents table to get the names of all continents against each country.
2. This sub_query was further used to create a CTE named 'p' to get the names of countries through LEFT JOIN. The CTE also has the aggregate window function of SUM to calculate running total of each continent in the year 2009 only.
3. Another sub-query is now created, named 'q' to rank running total of each continent, provided that the ranking meets or exceeds running total of $70,000.
4. This sub-query is further used to select all desired columns in the final output, where only those records are extracted having the rank of 1 for each continent.
5. This query also has an ORDER BY clause to order records by characters 2 through 4 (inclusive) of the name of the country in descending order.*/ 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH p AS (
    SELECT 
        b.continent_name, 
        a.country_code, 
        c.country_name, 
        a.gdp_per_capita, 
        SUM(a.gdp_per_capita) OVER (PARTITION BY b.continent_name ORDER BY a.gdp_per_capita) AS running_total
    FROM 
        per_capita AS a
    LEFT JOIN 
        countries AS c ON a.country_code = c.country_code
    LEFT JOIN 
        (SELECT y.*, x.continent_name
         FROM continent_map AS y
         LEFT JOIN continents AS x ON y.continent_code = x.continent_code) AS b ON a.country_code = b.country_code
    WHERE 
        a.year = 2009
)
SELECT 
    q.continent_name, 
    q.country_code, 
    q.country_name, 
    CONCAT('$', ROUND(q.gdp_per_capita, 2)) AS gdp_per_capita, 
    CONCAT('$', ROUND(q.running_total, 2)) AS running_total 
FROM 
    (
        SELECT 
            dense_rank() OVER (PARTITION BY p.continent_name ORDER BY p.running_total ASC) AS rank, 
            p.*
        FROM 
            p
        WHERE 
            p.running_total >= 70000
    ) AS q
WHERE 
    q.rank = 1
ORDER BY 
    q.continent_name ASC, 
    SUBSTRING(q.country_name, 2, 3) DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Solution:

| continent_name | country_code | country_name                                       | gdp_per_capita | running_total |
|----------------|--------------|----------------------------------------------------|----------------|---------------|
| NULL           | LCN          | Latin America & Caribbean (all income levels)      | $7,196.18      | $75,935.8     |
| Africa         | MUS          | Mauritius                                          | $6,928.97      | $74,586.9     |
| Asia           | MYS          | Malaysia                                           | $7,277.76      | $73,326.5     |
| Europe         | LTU          | Lithuania                                          | $11,649.4      | $71,714.4     |
| North America  | MEX          | Mexico                                             | $7,690.55      | $77,057.1     |
| Oceania        | AUS          | Australia                                          | $42,721.9      | $103,765      |
| South America  | VEN          | Venezuela, RB                                      | $11,525        | $74,829.4     |

*/


