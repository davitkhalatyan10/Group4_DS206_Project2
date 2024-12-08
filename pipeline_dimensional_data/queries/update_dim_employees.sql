USE $(DatabaseName);
GO

MERGE INTO DimEmployees AS target
USING (
    SELECT
        staging_raw_id,
        EmployeeID,
        LastName,
        FirstName,
        HireDate,
        TerminationDate
    FROM StagingEmployees
) AS source
ON target.EmployeeID = source.EmployeeID

WHEN MATCHED THEN
    UPDATE SET
        target.LastName = source.LastName,
        target.FirstName = source.FirstName,
        target.HireDate = source.HireDate,
        target.TerminationDate = source.TerminationDate

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (EmployeeID, LastName, FirstName, HireDate, TerminationDate)
    VALUES (source.EmployeeID, source.LastName, source.FirstName, source.HireDate, source.TerminationDate)

WHEN NOT MATCHED BY SOURCE
THEN
    DELETE;
