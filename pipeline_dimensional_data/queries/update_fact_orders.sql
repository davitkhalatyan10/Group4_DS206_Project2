USE {database_name};
GO

-- Declare parameters
DECLARE @start_date DATE = {start_date};
DECLARE @end_date DATE = {end_date};

-- Insert valid rows into the Fact table
INSERT INTO {schema}.FactOrders (
    staging_raw_id,
    Dim_SOR_ID,
    OrderID_NK,
    ProductID,
    UnitPrice,
    Quantity,
    Discount,
    CustomerID,
    EmployeeID,
    OrderDate,
    RequiredDate,
    ShippedDate,
    ShipVia,
    Freight,
    ShipName,
    ShipAddress,
    ShipCity,
    ShipRegion,
    ShipPostalCode,
    ShipCountry,
    TerritoryID
)
SELECT
    od.staging_raw_id,
    CONCAT(
        COALESCE(ds_orders.SOR_Key, ''),
        '_',
        COALESCE(ds_details.SOR_Key, '')
    ) AS Dim_SOR_ID, -- Concatenated SORKey
    o.OrderID_NK,
    od.ProductID,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    o.CustomerID,
    o.EmployeeID,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.ShipVia,
    o.Freight,
    o.ShipName,
    o.ShipAddress,
    o.ShipCity,
    o.ShipRegion,
    o.ShipPostalCode,
    o.ShipCountry,
    o.TerritoryID
FROM {schema}.StagingOrders o
LEFT JOIN {schema}.StagingOrderDetails od
    ON o.OrderID_NK = od.OrderID_NK
JOIN {schema}.Dim_SOR ds_orders
    ON ds_orders.Staging_Raw_Table_Name = 'StagingOrders'
JOIN {schema}.Dim_SOR ds_details
    ON ds_details.Staging_Raw_Table_Name = 'StagingOrderDetails'
WHERE o.OrderDate BETWEEN @start_date AND @end_date;

GO
