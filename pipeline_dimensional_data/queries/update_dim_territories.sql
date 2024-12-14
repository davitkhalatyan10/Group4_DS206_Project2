USE {database_name};

DECLARE @Today DATE = CONVERT(DATE, GETDATE());
DECLARE @Yesterday DATE = CONVERT(DATE, DATEADD(DAY, -1, @Today));

INSERT INTO {schema}.DimTerritories (TerritoryID_NK, TerritoryDescription, TerritoryCode, RegionID, Dim_SOR_ID, EffectiveDate, EndDate, IsCurrent)
SELECT TerritoryID, TerritoryName, RegionID, SOR.Dim_SOR_ID_SK_PK, @Today, NULL, 1
FROM (
    MERGE {schema}.DimTerritories AS DST
    USING {schema}.staging_raw_Territories AS SRC
    INNER JOIN {schema}.Dim_SOR AS SOR  -- Join with Dim_SOR to get Dim_SOR_ID
    ON SOR.Staging_Raw_Table_Name = 'staging_raw_Territories'  -- Join condition for Dim_SOR
    ON (SRC.TerritoryID = DST.TerritoryID_NK)
    WHEN NOT MATCHED
    THEN
        INSERT (TerritoryID_NK, TerritoryDescription, TerritoryCode, RegionID, Dim_SOR_ID, EffectiveDate, EndDate, IsCurrent)
        VALUES (SRC.TerritoryID, SRC.TerritoryDescription, SRC.TerritoryCode, SRC.RegionID, SOR.Dim_SOR_ID_SK_PK, @Today, NULL, 1)
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
        OUTPUT SRC.TerritoryID, SRC.TerritoryDescription, SRC.TerritoryCode, SRC.RegionID, SOR.Dim_SOR_ID_SK_PK, $Action AS MergeAction
) AS MRG
WHERE MRG.MergeAction = 'UPDATE';
