USE {database_name};

MERGE INTO {schema}.DimCategories AS target
USING (
    SELECT
        sc.staging_raw_id,
        sc.CategoryID,
        sc.CategoryName,
        sc.Description,
        ds.Dim_SOR_ID_SK_PK
    FROM {schema}.staging_raw_Categories sc
    JOIN {schema}.Dim_SOR ds
        ON ds.Staging_Raw_Table_Name = 'staging_raw_Categories'
) AS source
ON target.CategoryID_NK = source.CategoryID

WHEN MATCHED THEN
    UPDATE SET
        target.CategoryName = source.CategoryName

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        CategoryID_NK,
        CategoryName,
        Description,
        Dim_SOR_ID,
        staging_raw_id
    )
    VALUES (
        source.CategoryID,
        source.CategoryName,
        source.Description,
        source.Dim_SOR_ID_SK_PK,
        source.staging_raw_id
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
