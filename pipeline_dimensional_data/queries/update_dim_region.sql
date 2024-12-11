USE {database_name};
GO

MERGE INTO {schema}.DimRegion AS target
USING (
    SELECT
        sr.staging_raw_id,
        sr.RegionID,
        sr.RegionDescription,
        ds.SORKey
    FROM {schema}.StagingRegion sr
    JOIN {schema}.Dim_SOR ds
        ON ds.StagingTableName = 'StagingRegion'
) AS source
ON target.RegionID = source.RegionID

WHEN MATCHED THEN
    UPDATE SET
        target.RegionDescription = source.RegionDescription

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        RegionID,
        RegionDescription,
        SORKey,
        StagingRawID
    )
    VALUES (
        source.RegionID,
        source.RegionDescription,
        source.SORKey,
        source.staging_raw_id
    );
GO

