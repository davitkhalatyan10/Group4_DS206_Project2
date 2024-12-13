USE {database_name};

MERGE INTO {schema}.DimShippers AS target
USING (
    SELECT
        ss.staging_raw_id,
        ss.ShipperID,
        ss.ShipperName,
        ss.Phone,
        ds.SORKey
    FROM {schema}..StagingShippers ss
    JOIN {schema}.Dim_SOR ds
        ON ds.StagingTableName = 'StagingShippers'
) AS source
ON target.ShipperID = source.ShipperID

WHEN MATCHED THEN
    UPDATE SET
        target.ShipperName = source.ShipperName,
        target.Phone = source.Phone

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        ShipperID,
        ShipperName,
        Phone,
        SORKey,
        StagingRawID
    )
    VALUES (
        source.ShipperID,
        source.ShipperName,
        source.Phone,
        source.SORKey,
        source.staging_raw_id
    );
