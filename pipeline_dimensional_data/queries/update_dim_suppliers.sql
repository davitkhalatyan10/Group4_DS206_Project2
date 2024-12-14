USE {database_name};

DECLARE @Now DATETIME2(3) = GETDATE();

DECLARE @suppliers_SCD4 TABLE
(
    DimSuppliers_ID_SK_PK_Durable INT NULL,
    SupplierID_NK VARCHAR(255) NULL,
    CompanyName VARCHAR(255) NULL,
    Address VARCHAR(255) NULL,
    City VARCHAR(255) NULL,
    Region VARCHAR(255) NULL,
    PostalCode VARCHAR(255) NULL,
    Country VARCHAR(255) NULL,
    Phone VARCHAR(255) NULL,
    Fax VARCHAR(255) NULL,
    HomePage VARCHAR(255) NULL,
    staging_raw_id INT NULL,
    Dim_SOR_ID INT NULL,
    MergeAction VARCHAR(10) NULL,
    OldValidFrom DATETIME2(3) NULL
);

MERGE {schema}.DimSuppliersCurrent AS DST
USING {schema}.staging_raw_Suppliers AS SRC
    INNER JOIN {schema}.Dim_SOR AS SOR
    ON SOR.Staging_Raw_Table_Name = 'staging_raw_Suppliers'  -- Join with Dim_SOR to get Dim_SOR_ID
ON (SRC.SupplierID = DST.SupplierID_NK)

WHEN NOT MATCHED THEN
    INSERT (
        staging_raw_id,
        Dim_SOR_ID,
        SupplierID_NK,
        CompanyName,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        Phone,
        Fax,
        HomePage,
        ValidFrom
    )
    VALUES (
        SRC.staging_raw_id,
        SOR.Dim_SOR_ID_SK_PK,
        SRC.SupplierID,
        SRC.CompanyName,
        SRC.Address,
        SRC.City,
        SRC.Region,
        SRC.PostalCode,
        SRC.Country,
        SRC.Phone,
        SRC.Fax,
        SRC.HomePage,
        @Now
    )

WHEN MATCHED
AND (
    ISNULL(DST.CompanyName, '') <> ISNULL(SRC.CompanyName, '') OR
    ISNULL(DST.Address, '') <> ISNULL(SRC.Address, '') OR
    ISNULL(DST.City, '') <> ISNULL(SRC.City, '') OR
    ISNULL(DST.Region, '') <> ISNULL(SRC.Region, '') OR
    ISNULL(DST.PostalCode, '') <> ISNULL(SRC.PostalCode, '') OR
    ISNULL(DST.Country, '') <> ISNULL(SRC.Country, '') OR
    ISNULL(DST.Phone, '') <> ISNULL(SRC.Phone, '') OR
    ISNULL(DST.Fax, '') <> ISNULL(SRC.Fax, '') OR
    ISNULL(DST.HomePage, '') <> ISNULL(SRC.HomePage, '')
)
THEN
    UPDATE
    SET
        DST.CompanyName = SRC.CompanyName,
        DST.Address = SRC.Address,
        DST.City = SRC.City,
        DST.Region = SRC.Region,
        DST.PostalCode = SRC.PostalCode,
        DST.Country = SRC.Country,
        DST.Phone = SRC.Phone,
        DST.Fax = SRC.Fax,
        DST.HomePage = SRC.HomePage,
        DST.staging_raw_id = SRC.staging_raw_id,
        DST.Dim_SOR_ID = SOR.Dim_SOR_ID_SK_PK,
        DST.ValidFrom = @Now
OUTPUT
    DELETED.DimSuppliersCurrent_ID_SK_PK_Durable AS DimSuppliers_ID_SK_PK_Durable,
    DELETED.SupplierID_NK,
    DELETED.CompanyName,
    DELETED.Address,
    DELETED.City,
    DELETED.Region,
    DELETED.PostalCode,
    DELETED.Country,
    DELETED.Phone,
    DELETED.Fax,
    DELETED.HomePage,
    DELETED.staging_raw_id,
    DELETED.Dim_SOR_ID,
    $Action AS MergeAction,
    DELETED.ValidFrom AS OldValidFrom
INTO @suppliers_SCD4;

INSERT INTO dbo.DimSuppliersHistory (
    staging_raw_id,
    Dim_SOR_ID,
    SupplierID_NK,
    CompanyName,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    HomePage,
    DimSuppliers_ID_SK_Durable,
    ValidFrom,
    ValidTo
)
SELECT
    staging_raw_id,
    Dim_SOR_ID,
    SupplierID_NK,
    CompanyName,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    HomePage,
    DimSuppliers_ID_SK_PK_Durable,
    OldValidFrom,
    @Now
FROM @suppliers_SCD4
WHERE MergeAction = 'UPDATE';
