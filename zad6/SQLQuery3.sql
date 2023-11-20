USE AdventureWorksDW2019


IF OBJECT_ID('dbo.stg_dimemp', 'U') IS NOT NULL 
  DROP TABLE  dbo.stg_dimemp;

SELECT EmployeeKey, FirstName, LastName, Title
INTO dbo.stg_dimemp
FROM dbo.DimEmployee
WHERE EmployeeKey >= 270 AND EmployeeKey <= 275

IF OBJECT_ID('dbo.scd_dimemp', 'U') IS NOT NULL 
  DROP TABLE  dbo.scd_dimemp;

CREATE TABLE AdventureWorksDW2019.dbo.scd_dimemp (
EmployeeKey int ,
FirstName nvarchar(50) not null,
LastName nvarchar(50) not null,
Title nvarchar(50),
StartDate datetime,
EndDate datetime,
PRIMARY KEY(EmployeeKey)
);

INSERT INTO AdventureWorksDW2019.dbo.scd_dimemp (EmployeeKey, FirstName, LastName, Title, StartDate, EndDate)
SELECT EmployeeKey, FirstName, LastName, Title, StartDate, EndDate
FROM dbo.DimEmployee
WHERE EmployeeKey >= 270 AND EmployeeKey <= 275


SELECT * FROM dbo.stg_dimemp


-- Dzieñ dobry,
 
--mam problem techniczny z najnowszym æwiczeniem. Problem polega na tym ¿e nie mogê wejœæ do ustawieñ edycji slowly changing dimension.
--Obstawiam, ¿e mo¿e byæ to zwi¹zane z visual studio który na moim komputerze nie wiem czemu ci¹gle crashuje przy robieniu æwiczeñ,
--natomiast do tej pory wszytsko da³o siê zrobiæ. 
--Na filmiku pokazuje co siê dzieje. Pod koniec filmiku równie¿ pod³¹czam bezpoœrednio bez sort ale jest taki sam efekt. 
--Na zdjêciu jak wczytuje dane i wczytuj¹ siê poprawanie
--Czy jest Pan mi wstanie jakoœ z tym pomóc?
 
--Pozdrawiam

--dziwna sprawa
--zróbmy tak, proszê znaleŸæ na yt film dotycz¹cy konfiguracji SCD w SSIS, zapoznaæ siê z nim, a do repo zrobiæ commit filmiku, który doda³ Pan wy¿ej i proszê przekleiæ tê dyskusjê do komentarza w pliku SQLQuery3.sql
--nie chodzi o to aby Pan walczy³ z VS i traci³ czas
--przepraszam te¿ za opóŸnienie z odpisaniem na Pana wiadomoœæ, choroba mnie zmog³a i by³em offline ca³y weekend