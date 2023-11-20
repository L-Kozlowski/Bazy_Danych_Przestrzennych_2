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


-- Dzie� dobry,
 
--mam problem techniczny z najnowszym �wiczeniem. Problem polega na tym �e nie mog� wej�� do ustawie� edycji slowly changing dimension.
--Obstawiam, �e mo�e by� to zwi�zane z visual studio kt�ry na moim komputerze nie wiem czemu ci�gle crashuje przy robieniu �wicze�,
--natomiast do tej pory wszytsko da�o si� zrobi�. 
--Na filmiku pokazuje co si� dzieje. Pod koniec filmiku r�wnie� pod��czam bezpo�rednio bez sort ale jest taki sam efekt. 
--Na zdj�ciu jak wczytuje dane i wczytuj� si� poprawanie
--Czy jest Pan mi wstanie jako� z tym pom�c?
 
--Pozdrawiam

--dziwna sprawa
--zr�bmy tak, prosz� znale�� na yt film dotycz�cy konfiguracji SCD w SSIS, zapozna� si� z nim, a do repo zrobi� commit filmiku, kt�ry doda� Pan wy�ej i prosz� przeklei� t� dyskusj� do komentarza w pliku SQLQuery3.sql
--nie chodzi o to aby Pan walczy� z VS i traci� czas
--przepraszam te� za op�nienie z odpisaniem na Pana wiadomo��, choroba mnie zmog�a i by�em offline ca�y weekend