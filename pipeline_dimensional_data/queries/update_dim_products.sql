USE {database_name};

MERGE INTO {schema}.DimProducts AS target
USING (
    SELECT
        sp.staging_raw_id,
        sp.ProductID,
        sp.ProductName,
        sp.SupplierID,
        sp.CategoryID,
        sp.UnitPrice,
        ds.SORKey
    FROM {schema}..StagingProducts sp
    JOIN {schema}..Dim_SOR ds
        ON ds.StagingTableName = 'StagingProducts'
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
    INSERT (
        ProductID,
        ProductName,
        SupplierID,
        CategoryID,
        UnitPrice,
        SORKey,
        StagingRawID
    )
    VALUES (
        source.ProductID,
        source.ProductName,
        source.SupplierID,
        source.CategoryID,
        source.UnitPrice,
        source.SORKey,
        source.staging_raw_id
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
