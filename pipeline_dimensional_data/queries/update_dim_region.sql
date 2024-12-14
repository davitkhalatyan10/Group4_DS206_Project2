USE {database_name};

MERGE INTO {schema}.DimRegion AS target
USING (
    SELECT
        sr.staging_raw_id,
        sr.RegionID,
        sr.RegionDescription,
        sr.RegionCategory,
        sr.RegionImportance,
        ds.Dim_SOR_ID_SK_PK
    FROM {schema}.staging_raw_Region sr
    JOIN {schema}.Dim_SOR ds
        ON ds.Staging_Raw_Table_Name = 'staging_raw_Region'
) AS source
ON target.RegionID_NK = source.RegionID

WHEN MATCHED THEN
    UPDATE SET
        target.RegionDescription = source.RegionDescription

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        RegionID_NK,
        RegionDescription,
        RegionCategory,
        RegionImportance,
        Dim_SOR_ID,
        staging_raw_id
    )
    VALUES (
        source.RegionID,
        source.RegionDescription,
        source.RegionDescription,
        source.RegionCategory,
        source.Dim_SOR_ID_SK_PK,
        source.staging_raw_id
    );

