USE $(DatabaseName);
GO

MERGE INTO DimSuppliers AS target
USING (
    SELECT
        staging_raw_id,
        SupplierID,
        SupplierName,
        ContactName
    FROM StagingSuppliers
) AS source
ON target.SupplierID = source.SupplierID

WHEN MATCHED THEN
    UPDATE SET
        target.SupplierName = source.SupplierName,
        target.ContactName = source.ContactName,
        target.PriorName = target.SupplierName

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (SupplierID, SupplierName, ContactName, PriorName)
    VALUES (source.SupplierID, source.SupplierName, source.ContactName, NULL);
