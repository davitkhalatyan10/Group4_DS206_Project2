USE $(DatabaseName);
GO

MERGE INTO DimProducts AS target
USING (
    SELECT
        staging_raw_id,
        ProductID,
        ProductName,
        SupplierID,
        CategoryID,
        UnitPrice
    FROM StagingProducts
) AS source
ON target.ProductID = source.ProductID

WHEN MATCHED THEN
    UPDATE SET
        target.ProductName = source.ProductName,
        target.SupplierID = source.SupplierID,
        target.CategoryID = source.CategoryID,
        target.UnitPrice = source.UnitPrice

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (ProductID, ProductName, SupplierID, CategoryID, UnitPrice)
    VALUES (source.ProductID, source.ProductName, source.SupplierID, source.CategoryID, source.UnitPrice);
