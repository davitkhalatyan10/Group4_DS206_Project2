USE {database_name};

-- Declare parameters
--DECLARE @start_date DATE = {start_date};
--DECLARE @end_date DATE = {end_date};

-- Insert faulty rows into FactError table
INSERT INTO {schema}.fact_error (
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
    sr.staging_raw_id,
    sr.Dim_SOR_ID,
    sr.OrderID_NK,
    sr.ProductID,
    sr.UnitPrice,
    sr.Quantity,
    sr.Discount,
    sr.CustomerID,
    sr.EmployeeID,
    sr.OrderDate,
    sr.RequiredDate,
    sr.ShippedDate,
    sr.ShipVia,
    sr.Freight,
    sr.ShipName,
    sr.ShipAddress,
    sr.ShipCity,
    sr.ShipRegion,
    sr.ShipPostalCode,
    sr.ShipCountry,
    sr.TerritoryID
FROM {schema}.FactOrders sr
LEFT JOIN {schema}.DimCustomers dc
    ON sr.CustomerID = dc.CustomerID_NK
LEFT JOIN {schema}.DimProducts dp
    ON sr.ProductID = dp.ProductID_NK
LEFT JOIN {schema}.DimTerritories dt
    ON sr.TerritoryID = dt.TerritoryID_NK
LEFT JOIN {schema}.DimEmployees de
    ON sr.EmployeeID = de.EmployeeID_NK
LEFT JOIN {schema}.DimShippers ds
    ON sr.ShipVia = ds.ShipperID_NK
WHERE (dc.CustomerID_NK IS NULL OR dp.ProductID_NK IS NULL OR dt.TerritoryID_NK IS NULL OR de.EmployeeID_NK IS NULL OR ds.ShipperID_NK IS NULL);
