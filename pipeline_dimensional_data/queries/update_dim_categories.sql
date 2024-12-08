USE $(DatabaseName);
GO

MERGE INTO DimCategories AS target
USING (
    SELECT
        staging_raw_id,
        CategoryID,
        CategoryName
    FROM StagingCategories
) AS source
ON target.CategoryID = source.CategoryID

WHEN MATCHED THEN
    UPDATE SET target.CategoryName = source.CategoryName

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (CategoryID, CategoryName)
    VALUES (source.CategoryID, source.CategoryName);
