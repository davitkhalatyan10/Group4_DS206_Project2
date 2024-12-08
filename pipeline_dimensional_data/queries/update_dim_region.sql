USE $(DatabaseName);
GO

MERGE INTO DimRegion AS target
USING (
    SELECT
        staging_raw_id,
        RegionID,
        RegionDescription
    FROM StagingRegion
) AS source
ON target.RegionID = source.RegionID

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (RegionID, RegionDescription, EffectiveDate, ExpirationDate)
    VALUES (source.RegionID, source.RegionDescription, GETDATE(), NULL);
