--Limpieza de DimCustomer
SELECT 
  [CustomerKey] AS [ID Cliente]
  --,[GeographyKey] Será útil para el join y si quisiéramos saber las zonas con más compras
  , 
  [FirstName] AS Nombre
  , 
  [LastName] AS Apellido, 
  [FirstName] + ' ' + [LastName] AS [Nombre Completo] --Combinación de dos columnas
  , 
  CASE [Gender] WHEN 'M' THEN 'Hombre' WHEN 'F' THEN 'Mujer' END AS Genero, 
  [DateFirstPurchase] AS [Primera Compra], 
  g.City AS [Ciudad del Cliente] 
FROM 
  [AdventureWorksDW2022].[dbo].[DimCustomer] AS c 
  LEFT JOIN [AdventureWorksDW2022].[dbo].[DimGeography] AS g ON g.geographykey = c.GeographyKey --LEFT JOIN en Ciudad del cliente con DimGeography
ORDER BY 
  CustomerKey ASC  --Orden de forma ascendente la identificación del cliente (Customer Key)