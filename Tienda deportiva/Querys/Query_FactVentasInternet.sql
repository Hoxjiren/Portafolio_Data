SELECT
[ProductKey] AS [ID Producto]
      ,[OrderDateKey] AS [ID FechaOrden]
	  ,[DueDateKey] AS [ID FechaEntrega]
      ,[ShipDateKey] AS [ID FechaEnvio]
      ,[CustomerKey] AS [ID Cliente]
      ,[SalesOrderNumber] AS [Numero de Orden]
      ,[SalesAmount] AS [Cantidad de Venta]
  FROM [AdventureWorksDW2022].[dbo].[FactInternetSales]
    WHERE
  LEFT ([OrderDateKey], 4) >= (2021 -2) --El cliente solicitó que el análisis sea de los últimos dos años
  ORDER BY
  [OrderDateKey] ASC
