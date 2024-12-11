USE {database_name};
GO

DECLARE @Today DATE = CONVERT(DATE, GETDATE());
DECLARE @Yesterday DATE = CONVERT(DATE, DATEADD(DAY, -1, @Today));

INSERT INTO {schema}.DimTerritories (TerritoryID_NK, TerritoryName, RegionID, EffectiveDate, EndDate, IsCurrent)
SELECT TerritoryID, TerritoryName, RegionID, @Today, NULL, 1
FROM (
    MERGE {schema}.DimTerritories AS DST
    USING {schema}.Territories AS SRC
    ON (SRC.TerritoryID = DST.TerritoryID_NK)
    WHEN NOT MATCHED
    THEN
        INSERT (TerritoryID_NK, TerritoryName, RegionID, EffectiveDate, EndDate, IsCurrent)
        VALUES (SRC.TerritoryID, SRC.TerritoryName, SRC.RegionID, @Today, NULL, 1)
    WHEN MATCHED
        AND IsCurrent = 1
        AND (
            ISNULL(DST.TerritoryName, '') <> ISNULL(SRC.TerritoryName, '') OR
            ISNULL(DST.RegionID, 0) <> ISNULL(SRC.RegionID, 0)
        )
    THEN
        UPDATE
        SET
            DST.IsCurrent = 0,
            DST.EndDate = @Yesterday
        OUTPUT SRC.TerritoryID, SRC.TerritoryName, SRC.RegionID, $Action AS MergeAction
) AS MRG
WHERE MRG.MergeAction = 'UPDATE';
