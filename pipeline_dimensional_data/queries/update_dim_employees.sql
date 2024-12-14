USE {database_name};

DECLARE @Today DATE = CONVERT(DATE, GETDATE());
DECLARE @Yesterday DATE = CONVERT(DATE, DATEADD(DAY, -1, @Today));

-- Step 1: Perform SCD Type 2 Update/Insert
MERGE INTO {schema}.DimEmployees AS DST
USING (
    SELECT
        SRC.staging_raw_id,
        SOR.Dim_SOR_ID_SK_PK,
        SRC.EmployeeID,
        SRC.LastName,
        SRC.FirstName,
        SRC.Title,
        SRC.TitleOfCourtesy,
        SRC.BirthDate,
        SRC.HireDate,
        SRC.Address,
        SRC.City,
        SRC.Region,
        SRC.PostalCode,
        SRC.Country,
        SRC.HomePhone,
        SRC.Extension,
        SRC.Notes,
        SRC.ReportsTo,
        SRC.PhotoPath
    FROM {schema}.staging_raw_Employees AS SRC
    INNER JOIN {schema}.Dim_SOR AS SOR
        ON SOR.Staging_Raw_Table_Name = 'staging_raw_Employees'
) AS SRC
ON DST.EmployeeID_NK = SRC.EmployeeID
    AND DST.IsCurrent = 1

-- Update existing records if data has changed
WHEN MATCHED AND (
    ISNULL(DST.LastName, '') <> ISNULL(SRC.LastName, '') OR
    ISNULL(DST.FirstName, '') <> ISNULL(SRC.FirstName, '') OR
    ISNULL(DST.Title, '') <> ISNULL(SRC.Title, '') OR
    ISNULL(DST.TitleOfCourtesy, '') <> ISNULL(SRC.TitleOfCourtesy, '') OR
    ISNULL(DST.BirthDate, '') <> ISNULL(SRC.BirthDate, '') OR
    ISNULL(DST.HireDate, '') <> ISNULL(SRC.HireDate, '') OR
    ISNULL(DST.Address, '') <> ISNULL(SRC.Address, '') OR
    ISNULL(DST.City, '') <> ISNULL(SRC.City, '') OR
    ISNULL(DST.Region, '') <> ISNULL(SRC.Region, '') OR
    ISNULL(DST.PostalCode, '') <> ISNULL(SRC.PostalCode, '') OR
    ISNULL(DST.Country, '') <> ISNULL(SRC.Country, '') OR
    ISNULL(DST.HomePhone, '') <> ISNULL(SRC.HomePhone, '') OR
    ISNULL(DST.Extension, '') <> ISNULL(SRC.Extension, '') OR
    ISNULL(DST.Notes, '') <> ISNULL(SRC.Notes, '') OR
    ISNULL(DST.ReportsTo, '') <> ISNULL(SRC.ReportsTo, '') OR
    ISNULL(DST.PhotoPath, '') <> ISNULL(SRC.PhotoPath, '')
)
THEN
    UPDATE SET
        DST.IsCurrent = 0,
        DST.EndDate = @Yesterday

-- Insert new records for new or updated rows
WHEN NOT MATCHED THEN
    INSERT (
        staging_raw_id,
        Dim_SOR_ID,
        EmployeeID_NK,
        LastName,
        FirstName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        Notes,
        ReportsTo,
        PhotoPath,
        EffectiveDate,
        EndDate,
        IsCurrent
    )
    VALUES (
        SRC.staging_raw_id,
        SRC.Dim_SOR_ID_SK_PK,
        SRC.EmployeeID,
        SRC.LastName,
        SRC.FirstName,
        SRC.Title,
        SRC.TitleOfCourtesy,
        SRC.BirthDate,
        SRC.HireDate,
        SRC.Address,
        SRC.City,
        SRC.Region,
        SRC.PostalCode,
        SRC.Country,
        SRC.HomePhone,
        SRC.Extension,
        SRC.Notes,
        SRC.ReportsTo,
        SRC.PhotoPath,
        @Today,
        NULL,
        1
    );
