USE $(DatabaseName);
GO

INSERT INTO FactOrders (
    OrderID,
    CustomerKey,
    EmployeeKey,
    OrderDate,
    ShipVia,
    Freight
)
SELECT
    o.OrderID,
    dc.CustomerKey,
    de.EmployeeKey,
    o.OrderDate,
    o.ShipVia,
    o.Freight
FROM StagingOrders o
LEFT JOIN DimCustomers dc ON o.CustomerID = dc.CustomerID
LEFT JOIN DimEmployees de ON o.EmployeeID = de.EmployeeID
WHERE o.OrderDate BETWEEN @start_date AND @end_date;
