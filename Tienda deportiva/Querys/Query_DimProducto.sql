--Limpieza y formato de DimProducto
SELECT 
  [ProductKey] AS [ID Producto], 
  [ProductAlternateKey] AS [Codigo de producto], 
  [EnglishProductName], 
  [SpanishProductName] AS [Nombre de producto], 
  ps.[SpanishProductSubcategoryName] AS [SubCategoria] --LeftJoin con DimSubcategoria
  , 
  pc.[SpanishProductCategoryName] AS [Categoria] --LeftJoin con DimCategoriaProducto
  , 
  [Color] AS [Color del Producto]
  , 
  [Size] AS [Tamaño del Producto], 
  [ProductLine] AS [Linea de producto]
  , 
  [ModelName] AS [Modelo], 
  [EnglishDescription] AS [Descripción en inglés], 
  CASE WHEN [Status] = 'Current' THEN 'Disponible' WHEN [Status] IS NULL THEN 'Agotado' END AS [Estado del Producto]  --Cambiamos el estatus a español
FROM 
  [AdventureWorksDW2022].[dbo].[DimProduct] AS p 
  LEFT JOIN dbo.DimProductSubcategory AS ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey 
  LEFT JOIN dbo.DimProductCategory AS pc ON pc.ProductCategoryKey = ps.ProductCategoryKey 
ORDER BY 
  ProductKey ASC
