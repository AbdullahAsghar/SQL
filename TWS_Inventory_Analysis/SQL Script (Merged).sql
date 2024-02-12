--Case Study Questions:

--Sales Performance Ranking.
--Rank the brands based on their total sales dollars, considering a rolling window of the last two months. Identify brands with consistent high rankings.
--Solution: I created a CTE calculating the total sales of each brand, and ranked each brand's sales using RANK function.

WITH cte1 AS (
    SELECT
        brand,
        description,
        FORMAT(salesdate, 'MMMM') AS month,
        SUM(salesdollars) AS totalsales
    FROM
        salesfinal
    GROUP BY
        brand, description, FORMAT(salesdate, 'MMMM')
)

SELECT
    RANK() OVER (PARTITION BY brand ORDER BY totalsales DESC) AS rank,
    *
FROM
    cte1;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Inventory Turnover Rate:
--Calculate the inventory turnover rate for each brand over time, considering a cumulative window. Identify brands with the most dynamic inventory turnover.
--Solution: I calculated the total sales, COGS, and Inventory Turnover rate for each brand by joining another table which had purchase prices of each brand. This became my CTE to extract only the necessary columns and get the Inventory Tunrover for each brand.

WITH x AS (
    SELECT
        a.brand,
        a.description,
        a.salesquantity,
        a.salesdollars,
        (a.salesquantity * b.purchaseprice) AS COGS,
        (a.salesquantity * b.purchaseprice) / a.salesdollars AS invturnover
    FROM
        salesfinal AS a
    JOIN
        purchaseprice AS b ON a.brand = b.brand
)

SELECT
    brand,
    description,
    SUM(salesquantity) AS qtysold,
    ROUND(SUM(salesdollars), 2) AS totalsales,
    ROUND(SUM(COGS), 2) AS totalcogs,
    ROUND(SUM(invturnover), 2) AS totalinvturnover
FROM
    x
GROUP BY
    brand, description
ORDER BY
    totalinvturnover DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Price Elasticity:
--Determine the price elasticity of demand for each brand by analyzing the percentage change in sales quantity in response to a percentage change in price within a specific time window.
--Solution: I first created a CTE which gave the monthly sold quantity and selling price of each brand. From this CTE, I created two branched CTEs having same columns, but for January and February each. From these two branched CTEs, I joined them both to get the price elasticity within a span of two months.

WITH cte AS (
    SELECT 
        brand, 
        description, 
        size, 
        FORMAT(salesdate, 'MMMM') AS Month, 
        SUM(salesquantity) AS qtysold,
        ROUND(salesprice, 2) AS Price
    FROM 
        salesfinal
    GROUP BY 
        brand, FORMAT(salesdate, 'MMMM'), description, size, salesprice
),
A AS (
    SELECT 
        brand, 
        description, 
        size, 
        qtysold, 
        Month,
        Price
    FROM 
        cte
    WHERE 
        Month = 'January'
),
B AS (
    SELECT 
        brand, 
        description, 
        size, 
        qtysold, 
        Month,
        Price
    FROM 
        cte
    WHERE 
        Month = 'February'
)

SELECT 
    A.brand, 
    A.description, 
    A.size, 
    A.qtysold AS qtysold_january,
    B.qtysold AS qtysold_february,
    A.Price AS price_january,
    B.Price AS price_february,
    ROUND(NULLIF(((B.qtysold - A.qtysold) * 100) / NULLIF(A.qtysold, 0), 0), 1) AS qtysoldchange,
    ROUND(NULLIF(((B.Price - A.Price) * 100) / NULLIF(A.Price, 0), 0), 1) AS pricechange
FROM 
    A
JOIN 
    B ON A.brand = B.brand;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Vendor Contribution Over Time:
--Calculate the contribution of each vendor to total sales. Identify vendors with sustained high contributions.
--Solution: Basic query structure, with a subquery added to calculate total sales, which was used to calculate %age contribution of each vendor in the main query.

SELECT
	VendorNo,
	VendorName,
	ROUND (SUM (salesdollars), 2) AS TotalVendorSales,
	ROUND (SUM (salesdollars) * 100 / 
		(
		SELECT
		SUM(salesdollars) AS TotalSales
		FROM
		salesfinal
		), 2) AS SalesContribution
FROM
	salesfinal
GROUP BY
	VendorNo, VendorName
ORDER BY
	SalesContribution DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Calculate the cumulative contribution of each vendor to total sales over two months. Identify vendors with sustained high contributions.
--Solution: Basic query structure, with each vendor's sale cotribution calculated through a subquery over two months.

SELECT
    VendorNo,
    VendorName,
    FORMAT(SalesDate, 'MMMM') AS Month,
    ROUND(SUM(SalesDollars), 0) AS TotalVendorSales,
    SUM(SalesDollars) * 100 / 
	(
	SELECT
		SUM(SalesDollars) AS TotalSales
	FROM
		salesfinal
	) AS Contribution
FROM
    salesfinal
GROUP BY
    VendorNo, VendorName, FORMAT(SalesDate, 'MMMM')

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Profit Margin Trends:
--Analyze the trend in profit margins for each brand over the last two months using a rolling window. Identify brands with improving or declining profit margins.
--Solution: I first created a CTE calculating the total sales and sold quantity against each brand. From this CTE, I created a main query having purchase prices of each brand by joining the table of purchase prices, and further calculated the margin and %age margin of each brand during two months.

WITH cte AS
(
SELECT
	FORMAT (SalesDate, 'MMMM') AS Month,
	Store,
	Brand,
	Description,
	SUM (SalesQuantity) AS QtySold,
	ROUND (SalesPrice, 2) AS SalesPrice
FROM
	salesfinal
GROUP BY 
	FORMAT (SalesDate, 'MMMM'), Store, Brand, Description, SalesPrice
)
SELECT
	a.*,
	ROUND (b.PurchasePrice, 2) AS PurchasePrice,
	ROUND ((a.SalesPrice - b.PurchasePrice), 2) AS Margin,
	ROUND (((a.SalesPrice - b.PurchasePrice) * 100 / a.SalesPrice), 2) AS MarginPercentage
FROM
	cte AS a
JOIN
	purchaseprice AS b
ON
	a.brand = b.brand;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Geographical Sales Patterns:
--Calculate the average of sales for each city, considering a window of the last two months. Identify cities with the most consistent sales growth.
--Solution: I first created a CTE with a join obtaining total sales against each city. From there, I created a main query having average sales of each city.

WITH SalesCTE AS (
    SELECT 
        a.salesdate,
        a.salesdollars,
        b.city,
        FORMAT(a.salesdate, 'MMMM') AS month
    FROM 
        salesfinal AS a
    JOIN 
        beginvfinal AS b ON a.store = b.store
)
SELECT 
    city, 
    month,	
    AVG(salesdollars) OVER (PARTITION BY month) AS avgsales
FROM 
    SalesCTE;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	   	  
--Correlation between Pricing and Sales:
--Calculate the correlation coefficient between average sales prices and sales quantities over a rolling window of two months for each brand.
--Solution: Created a CTE first that calculated the covariance of each brand. From there, I created a main query that calculated the standard deviations, and standard deviations and covariance were used to calculate the Pearson corelation coefficient of each brand.

WITH c AS (
  SELECT
    Brand,
    AVG(SalesQuantity) AS x,
    AVG(SalesPrice) AS y,
    (SalesQuantity * SalesPrice) AS xy,
    POWER(SalesQuantity, 2) AS x2,
    POWER(SalesPrice, 2) AS y2
  FROM
    salesfinal
  WHERE
    SalesQuantity IS NOT NULL AND SalesPrice IS NOT NULL
  GROUP BY
    Brand, SalesQuantity, SalesPrice
)
SELECT
  c.Brand,
  CASE
    WHEN COUNT(c.Brand) <= 1 THEN 0
  ELSE
      (
        (COUNT(c.Brand) * SUM(c.xy) - SUM(c.x) * SUM(c.y)) /
        SQRT(NULLIF((COUNT(c.Brand) * SUM(c.x2) - POWER(SUM(c.x), 2)) * (COUNT(c.Brand) * SUM(c.y2) - POWER(SUM(c.y), 2)), 0))
      )
  END AS r
FROM
  c
GROUP BY
  c.Brand;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Store-Level Performance Comparison:
--Rank stores based on their sales performance compared to the average sales. Identify stores that consistently outperform or underperform.
--Solution: With a CTE created first calculating total sales against each store, I ranked each store's sales against the average sales using RANK function and CASE. 

WITH a AS
(
    SELECT
        Store,
        ROUND (SUM(SalesDollars), 2) AS TotalSales
    FROM
        salesfinal
    GROUP BY
        Store
)
SELECT
    a.Store,
    a.TotalSales,
    RANK() OVER (ORDER BY a.TotalSales DESC) AS Rank,
    CASE
        WHEN a.TotalSales > AVG(a.TotalSales) OVER () THEN 'OutPerformed'
        WHEN a.TotalSales < AVG(a.TotalSales) OVER () THEN 'UnderPerformed'
        ELSE NULL
    END AS Status
FROM
    a;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
