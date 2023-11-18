USE AdventureWorksDW2019

SELECT OrderDate
FROM dbo.FactInternetSales 
GROUP BY OrderDate
HAVING COUNT(OrderQuantity) > 100

WITH RankedProducts AS (
	SELECT OrderDate, UnitPrice, ProductKey, 
	ROW_NUMBER() OVER (PARTITION BY OrderDate ORDER BY UnitPrice DESC  ) AS rowNum
	FROM  dbo.FactInternetSales 
)

SELECT OrderDate, UnitPrice, ProductKey
FROM  RankedProducts
where rowNum <=3