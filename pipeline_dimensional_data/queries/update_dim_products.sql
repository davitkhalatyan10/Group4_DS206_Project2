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
        ds.Dim_SOR_ID_SK_PK
    FROM {schema}.staging_raw_Products sp
    JOIN {schema}.Dim_SOR ds
        ON ds.Staging_Raw_Table_Name = 'staging_raw_Products'
) AS source
ON target.ProductID_NK = source.ProductID

WHEN MATCHED THEN
    UPDATE SET
        target.ProductName = source.ProductName,
        target.SupplierID = source.SupplierID,
        target.CategoryID = source.CategoryID,
        target.UnitPrice = source.UnitPrice

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        ProductID_NK,
        ProductName,
        SupplierID,
        CategoryID,
        UnitPrice,
        Dim_SOR_ID,
        staging_raw_id
    )
    VALUES (
        source.ProductID,
        source.ProductName,
        source.SupplierID,
        source.CategoryID,
        source.UnitPrice,
        source.Dim_SOR_ID_SK_PK,
        source.staging_raw_id
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
