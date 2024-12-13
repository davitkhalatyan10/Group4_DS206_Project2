USE {database_name};

DECLARE @Today DATE = CONVERT(DATE, GETDATE());
DECLARE @Yesterday DATE = CONVERT(DATE, DATEADD(DAY, -1, @Today));

INSERT INTO {schema}.DimEmployees (EmployeeID_NK, EmployeeName, Position, Department, HireDate, EffectiveDate, EndDate, IsCurrent)
SELECT EmployeeID, EmployeeName, Position, Department, HireDate, @Today, NULL, 1
FROM (
    MERGE {schema}.DimEmployees AS DST
    USING {schema}.Employees AS SRC
    ON (SRC.EmployeeID = DST.EmployeeID_NK)
    WHEN NOT MATCHED
    THEN
        INSERT (EmployeeID_NK, EmployeeName, Position, Department, HireDate, EffectiveDate, EndDate, IsCurrent)
        VALUES (SRC.EmployeeID, SRC.EmployeeName, SRC.Position, SRC.Department, SRC.HireDate, @Today, NULL, 1)
    WHEN MATCHED
        AND IsCurrent = 1
        AND (
            ISNULL(DST.EmployeeName, '') <> ISNULL(SRC.EmployeeName, '') OR
            ISNULL(DST.Position, '') <> ISNULL(SRC.Position, '') OR
            ISNULL(DST.Department, '') <> ISNULL(SRC.Department, '')
        )
    THEN
        UPDATE
        SET
            DST.IsCurrent = 0,
            DST.EndDate = @Yesterday
        OUTPUT SRC.EmployeeID, SRC.EmployeeName, SRC.Position, SRC.Department, SRC.HireDate, $Action AS MergeAction
) AS MRG
WHERE MRG.MergeAction = 'UPDATE';
