USE $(DatabaseName);
GO

MERGE INTO DimCustomers AS target
USING (
    SELECT
        staging_raw_id,
        CustomerID,
        CustomerName,
        ContactName,
        Country
    FROM StagingCustomers
) AS source
ON target.CustomerID = source.CustomerID
AND target.ExpirationDate IS NULL

WHEN MATCHED AND (
    target.CustomerName <> source.CustomerName
    OR target.ContactName <> source.ContactName
    OR target.Country <> source.Country
)
THEN
    UPDATE SET target.ExpirationDate = GETDATE()

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (CustomerID, CustomerName, ContactName, Country, EffectiveDate, ExpirationDate)
    VALUES (source.CustomerID, source.CustomerName, source.ContactName, source.Country, GETDATE(), NULL);
