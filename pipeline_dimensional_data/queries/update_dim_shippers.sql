USE $(DatabaseName);
GO

MERGE INTO DimShippers AS target
USING (
    SELECT
        staging_raw_id,
        ShipperID,
        ShipperName,
        Phone
    FROM StagingShippers
) AS source
ON target.ShipperID = source.ShipperID

WHEN MATCHED THEN
    UPDATE SET
        target.ShipperName = source.ShipperName,
        target.Phone = source.Phone

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (ShipperID, ShipperName, Phone)
    VALUES (source.ShipperID, source.ShipperName, source.Phone)

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
