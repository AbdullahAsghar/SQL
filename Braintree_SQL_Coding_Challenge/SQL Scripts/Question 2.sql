/*2. List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012.
The percent of growth should be calculated as: ((2012 gdp - 2011 gdp) / 2011 gdp)
The list should include the columns:
- rank
- continent_name
- country_code
- country_name
- growth_percent

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Answer:
1. The CTE j is created to join data from multiple tables (per_capita, continent_map, continents, and countries) to gather information about GDP per capita growth for each country.
2. It selects fields such as continent name, country code, country name, year, GDP per capita, and calculates the GDP per capita growth percentage compared to the previous year using the LAG window function.
3. The LAG function is used to access data from the previous row within the same partition, allowing calculation of GDP growth percentage.
4. The main query selects the rank, continent name, country code, country name, and growth percentage for each country.
5. It uses a subquery to calculate the rank of each country within its continent based on GDP per capita growth percentage in descending order.
6. The DENSE_RANK() window function assigns a rank to each country within its continent, where countries with higher GDP growth percentages receive lower ranks.
7. The subquery filters the data to include only records for the year 2012.
8. Finally, the outer query further filters the results to include only countries with ranks 10, 11, or 12 within their respective continents.*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH j AS (
    SELECT 
        b.continent_name, 
        a.country_code, 
        c.country_name, 
        a.year, 
        a.gdp_per_capita, 
        LAG(a.gdp_per_capita) OVER (PARTITION BY a.country_code ORDER BY a.year ASC) AS last_year_gdp, 
        CONCAT(ROUND(100 * (a.gdp_per_capita - LAG(a.gdp_per_capita) OVER (PARTITION BY a.country_code ORDER BY a.year ASC)) / LAG(a.gdp_per_capita) OVER (PARTITION BY a.country_code ORDER BY a.year ASC),2),'%') AS growth_percent
    FROM 
        per_capita AS a
    LEFT JOIN (
        SELECT 
            x.country_code, 
            x.continent_code, 
            y.continent_name
        FROM 
            continent_map AS x
        LEFT JOIN continents AS y ON x.continent_code = y.continent_code
    ) AS b ON a.country_code = b.country_code
    LEFT JOIN countries AS c ON a.country_code = c.country_code
)
SELECT 
    rank, 
    continent_name, 
    country_code, 
    country_name, 
    growth_percent
FROM (
    SELECT 
        dense_rank() OVER (PARTITION BY j.continent_name ORDER BY j.growth_percent DESC) AS rank, 
        j.continent_name, 
        j.country_code, 
        j.country_name, 
        j.growth_percent
    FROM 
        j
    WHERE 
        j.year IN (2012)
) AS ranked_data
WHERE 
    rank IN (10, 11, 12);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Solution:

| Category | Region       | Country Code | Country Name                           | Growth Rate |
|----------|--------------|--------------|----------------------------------------|-------------|
| 10       | NULL         | LMY          | Low & middle income                    | 4.08%       |
| 11       | NULL         | HPC          | Heavily indebted poor countries (HIPC) | 3.87%       |
| 12       | NULL         | NAC          | North America                          | 3.54%       |
| 10       | Africa       | ETH          | Ethiopia                               | 35.88%      |
| 11       | Africa       | ZMB          | Zambia                                 | 3.86%       |
| 12       | Africa       | STP          | Sao Tome and Principe                  | 3.31%       |
| 10       | Asia         | JOR          | Jordan                                 | 5.21%       |
| 11       | Asia         | HKG          | Hong Kong SAR, China                   | 4.62%       |
| 12       | Asia         | SAU          | Saudi Arabia                           | 4.23%       |
| 10       | Europe       | HUN          | Hungary                                | -8.88%      |
| 11       | Europe       | MKD          | Macedonia, FYR                         | -7.99%      |
| 12       | Europe       | NLD          | Netherlands                            | -7.87%      |
| 10       | North America| ATG          | Antigua and Barbuda                    | 2.52%       |
| 11       | North America| SLV          | El Salvador                            | 2.46%       |
| 12       | North America| JAM          | Jamaica                                | 2.15%       |
| 10       | Oceania      | TON          | Tonga                                  | 11.06%      |
| 11       | Oceania      | TUV          | Tuvalu                                 | 1.27%       |
| 12       | Oceania      | KIR          | Kiribati                               | 0.04%       |
| 10       | South America| GUY          | Guyana                                 | 10%         |
| 11       | South America| BRA          | Brazil                                 | -9.83%      |
| 12       | South America| PRY          | Paraguay                               | -3.62%      |
