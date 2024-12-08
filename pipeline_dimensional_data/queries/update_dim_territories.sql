USE $(DatabaseName);
GO

MERGE INTO DimTerritories AS target
USING (
    SELECT
        staging_raw_id,
        TerritoryID,
        TerritoryDescription,
        RegionID
    FROM StagingTerritories
) AS source
ON target.TerritoryID = source.TerritoryID

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (TerritoryID, TerritoryDescription, RegionID, EffectiveDate, ExpirationDate)
    VALUES (source.TerritoryID, source.TerritoryDescription, source.RegionID, GETDATE(), NULL);
