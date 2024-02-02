-- Sales Performance Ranking.
-- Rank the brands based on their total sales dollars, considering a rolling window of the last two months. Identify brands with consistent high rankings.

with cte1 as
	(
	select brand, description, format (salesdate, 'MMMM') as month, sum(salesdollars) as totalsales
	from salesfinal
	group by brand, description, format (salesdate, 'MMMM')
	)
select rank () over (partition by brand order by totalsales desc) as rank, *
from cte1;	

--Inventory Turnover Rate:
--Calculate the inventory turnover rate for each brand over time, considering a cumulative window. Identify brands with the most dynamic inventory turnover.

with x as
	(
	select a.brand, a.description, a.salesquantity, a.salesdollars, (a.salesquantity * b.purchaseprice) as COGS, (a.salesquantity * b.purchaseprice)/a.salesdollars as invturnover
	from salesfinal as a
	join purchaseprice as b
	on a.brand = b.brand
	)
select brand, description, sum(salesquantity) as qtysold, round(sum(salesdollars),2) as totalsales, round(sum (COGS),2) as totalcogs,  round(sum (invturnover),2) as totalinvturnover
from x
group by brand, description
order by totalinvturnover desc;

--Price Elasticity:
--Determine the price elasticity of demand for each brand by analyzing the percentage change in sales quantity in response to a percentage change in price within a specific time window.

select * from salesfinal

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
    ROUND(NULLIF(((B.qtysold - A.qtysold) * 100) / A.qtysold, 0), 1) AS qtysoldchange,
    ROUND(NULLIF(((B.Price - A.Price) * 100) / A.Price, 0), 1) AS pricechange
FROM 
    A
JOIN 
    B ON A.brand = B.brand;
	
--Vendor Contribution Over Time:
--Calculate the contribution of each vendor to total sales. Identify vendors with sustained high contributions.

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

--Calculate the cumulative contribution of each vendor to total sales over a moving window of two months. Identify vendors with sustained high contributions.

select * from salesfinal

SELECT
	VendorNo,
	VendorName,
	FORMAT (SalesDate, 'MMMM') AS Month,
	ROUND (SUM (SalesDollars), 0) AS TotalVendorSales
FROM
	salesfinal
GROUP BY
	VendorNo, VendorName, FORMAT (SalesDate, 'MMMM')

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

--Profit Margin Trends:
--Analyze the trend in profit margins for each brand over the last two months using a rolling window. Identify brands with improving or declining profit margins.

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

--Geographical Sales Patterns:
--Calculate the average of sales for each city, considering a window of the last two months. Identify cities with the most consistent sales growth.

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
	   	  
--Correlation between Pricing and Sales:
--Calculate the correlation coefficient between average sales prices and sales quantities over a rolling window of two months for each brand.

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

--Store-Level Performance Comparison:
--Rank stores based on their sales performance compared to the average sales. Identify stores that consistently outperform or underperform.

WITH a AS
(
	SELECT
		Store,
		SUM (SalesDollars) AS TotalSales
	FROM
		salesfinal
	GROUP BY
		Store
)
SELECT
	a.Store,
	a.TotalSales,
	RANK () OVER (ORDER BY a.TotalSales DESC) AS Rank,
	CASE
		WHEN a.TotalSales > AVG (a.TotalSales) THEN 'OutPerformed'
		WHEN a.TotalSales < AVG (a.TotalSales) THEN 'UnderPerformed'
	ELSE NULL
	END AS Status
FROM
	a

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

