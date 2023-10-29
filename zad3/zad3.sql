
USE AdventureWorksDW2019
DECLARE @YearsAgo INT
SET @YearsAgo = -10

SELECT *
FROM dbo.FactCurrencyRate as dfcr
FULL OUTER JOIN dbo.DimCurrency as dc
ON dfcr.CurrencyKey = dc.CurrencyKey
WHERE (CurrencyAlternateKey = 'GBP' or CurrencyAlternateKey = 'EUR') and DATEADD("year", @YearsAgo,GETDATE()) > Date;


Różnicą pomiędzy procesem ETL a kwerendą sql jest to, że w kwerendzie operujemy tylko na komendach sql, natomisat w procesie ETL na róznych komponetach. 
Zaletą etl jest wyraźny podział na etapy przetwarzania, jak po kolei w komponentach jest są przetwarzane dane, natomiast wadą jest pisanie komend sql w komponentach, 
które nie daję informacji gdzie jest błąd w zapytaniu.