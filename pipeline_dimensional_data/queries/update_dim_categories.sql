USE {database_name};
GO

MERGE INTO {schema}.DimCategories AS target
USING (
    SELECT
        sc.staging_raw_id,
        sc.CategoryID,
        sc.CategoryName,
        sc.Description,
        ds.SORKey
    FROM {schema}.StagingCategories sc
    JOIN {schema}.Dim_SOR ds
        ON ds.StagingTableName = 'StagingCategories'
) AS source
ON target.CategoryID = source.CategoryID

WHEN MATCHED THEN
    UPDATE SET
        target.CategoryName = source.CategoryName

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        CategoryID,
        CategoryName,
        Description,
        SORKey,
        StagingRawID
    )
    VALUES (
        source.CategoryID,
        source.CategoryName,
        source.Description,
        source.SORKey,
        source.staging_raw_id
    )

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
GO
