USE {database_name};

-- Declare parameters
--DECLARE @start_date DATE = CAST({start_date} AS DATE);
--DECLARE @end_date DATE = CAST({end_date} AS DATE);

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
        COALESCE(ds_orders.staging_raw_id, ''),
        '_',
        COALESCE(ds_details.staging_raw_id, '')
    ) AS Dim_SOR_ID, -- Concatenated SORKey
    o.OrderID,
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
FROM {schema}.staging_raw_Orders o
LEFT JOIN {schema}.staging_raw_OrderDetails od
    ON o.OrderID = od.OrderID
JOIN {schema}.Dim_SOR ds_orders
    ON ds_orders.Staging_Raw_Table_Name = 'staging_raw_Orders'
JOIN {schema}.Dim_SOR ds_details
    ON ds_details.Staging_Raw_Table_Name = 'staging_raw_OrderDetails';
/*WHERE CAST(o.OrderDate AS DATE) BETWEEN @start_date AND @end_date;*/
