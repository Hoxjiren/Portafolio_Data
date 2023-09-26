-- DimDate Limpia
SELECT 
  [DateKey] AS [ID Fecha], 
  [FullDateAlternateKey] AS Date, 
  --,[DayNumberOfWeek] --comentamos sobre las columnas para elegir solo las que utilizaremos
  [EnglishDayNameOfWeek] AS Day, 
  [SpanishDayNameOfWeek] AS Dia, 
  LEFT([SpanishDayNameOfWeek], 3) AS DiaCorto, 
  -- ,[FrenchDayNameOfWeek]
  --,[DayNumberOfMonth] 
  --,[DayNumberOfYear]
  [WeekNumberOfYear] AS SemanaNr, 
  [EnglishMonthName] AS Month, 
  [SpanishMonthName] AS Mes, 
  LEFT([SpanishMonthName], 3) AS MesCorto, 
  --,[FrenchMonthName]
  [MonthNumberOfYear] AS MesNr, 
  [CalendarQuarter] AS Cuatrimestre, 
  [CalendarYear] AS Año --,[CalendarSemester]
  --,[FiscalQuarter]
  --,[FiscalYear]
  --,[FiscalSemester]
FROM 
  [AdventureWorksDW2022].[dbo].[DimDate]
  WHERE 
  CalendarYear >= 2019
