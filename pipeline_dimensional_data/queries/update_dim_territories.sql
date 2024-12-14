USE {database_name};

DECLARE @Today DATE = CONVERT(DATE, GETDATE());
DECLARE @Yesterday DATE = CONVERT(DATE, DATEADD(DAY, -1, @Today));

-- Merge operation with temporary output table
DECLARE @MergeOutput TABLE (
    TerritoryID INT,
    staging_raw_id INT,
    TerritoryDescription VARCHAR(255),
    TerritoryCode VARCHAR(50),
    RegionID INT,
    Dim_SOR_ID INT, -- Capturing Dim_SOR_ID_SK_PK
    MergeAction VARCHAR(10)
);

MERGE {schema}.DimTerritories AS DST
USING {schema}.staging_raw_Territories AS SRC
INNER JOIN {schema}.Dim_SOR AS SOR  -- Join with Dim_SOR to get Dim_SOR_ID
    ON SOR.Staging_Raw_Table_Name = 'staging_raw_Territories'  -- Join condition for Dim_SOR
ON (SRC.TerritoryID = DST.TerritoryID_NK)
WHEN NOT MATCHED
THEN
    INSERT (TerritoryID_NK, staging_raw_id, TerritoryDescription, TerritoryCode, RegionID, Dim_SOR_ID, EffectiveDate, EndDate, IsCurrent)
    VALUES (SRC.TerritoryID, SRC.staging_raw_id, SRC.TerritoryDescription, SRC.TerritoryCode, SRC.RegionID, SOR.Dim_SOR_ID_SK_PK, @Today, NULL, 1)
WHEN MATCHED
    AND IsCurrent = 1
    AND (
        ISNULL(DST.TerritoryDescription, '') <> ISNULL(SRC.TerritoryDescription, '') OR
        ISNULL(DST.TerritoryCode, '') <> ISNULL(SRC.TerritoryCode, '') OR
        ISNULL(DST.RegionID, 0) <> ISNULL(SRC.RegionID, 0)
    )
THEN
    UPDATE
    SET
        DST.IsCurrent = 0,
        DST.EndDate = @Yesterday
OUTPUT
    SRC.TerritoryID,
    SRC.staging_raw_id,
    SRC.TerritoryDescription,
    SRC.TerritoryCode,
    SRC.RegionID,
    SOR.Dim_SOR_ID_SK_PK,
    $Action AS MergeAction
INTO @MergeOutput; -- Store output in a temporary table

-- Insert valid rows into DimTerritories
INSERT INTO {schema}.DimTerritories (TerritoryID_NK, staging_raw_id, TerritoryDescription, TerritoryCode, RegionID, Dim_SOR_ID, EffectiveDate, EndDate, IsCurrent)
SELECT TerritoryID, staging_raw_id, TerritoryDescription, TerritoryCode, RegionID, Dim_SOR_ID, @Today, NULL, 1
FROM @MergeOutput
WHERE MergeAction = 'UPDATE';
