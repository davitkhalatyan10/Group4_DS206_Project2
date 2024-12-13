USE {database_name};

MERGE INTO {schema}.DimCustomers AS target
USING (
    SELECT
        sc.CustomerID_NK,
        sc.CompanyName,
        sc.ContactName,
        sc.ContactTitle,
        sc.Address,
        sc.City,
        sc.Region,
        sc.PostalCode,
        sc.Country,
        sc.Phone,
        sc.Fax,
        ds.SOR_Key,
        sc.staging_raw_id
    FROM {schema}.StagingCustomers sc
    JOIN {schema}.Dim_SOR ds
        ON ds.Staging_Raw_Table_Name = 'StagingCustomers'
) AS source
ON target.CustomerID_NK = source.CustomerID_NK

-- Update existing records in DimCustomers
WHEN MATCHED THEN
    UPDATE SET
        target.CompanyName = source.CompanyName,
        target.PriorContactName = target.ContactName,
        target.ContactName = source.ContactName,
        target.PriorContactTitle = target.ContactTitle,
        target.ContactTitle = source.ContactTitle,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country = source.Country,
        target.Phone = source.Phone,
        target.Fax = source.Fax,
        target.staging_raw_id = source.staging_raw_id,
        target.Dim_SOR_ID = source.SOR_Key

-- Insert new records into DimCustomers
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        staging_raw_id,
        Dim_SOR_ID,
        CustomerID_NK,
        CompanyName,
        ContactName,
        PriorContactName,
        ContactTitle,
        PriorContactTitle,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        Phone,
        Fax
    )
    VALUES (
        source.staging_raw_id,
        source.SOR_Key,
        source.CustomerID_NK,
        source.CompanyName,
        source.ContactName,
        source.ContactName,
        source.ContactTitle,
        source.ContactTitle,
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        source.Phone,
        source.Fax
    );

-- Insert historical records into DimCustomers
INSERT INTO {schema}.DimCustomersHistory (
    staging_raw_id,
    Dim_SOR_ID,
    CustomerID_NK,
    CompanyName,
    ContactName,
    PriorContactName,
    ContactTitle,
    PriorContactTitle,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    DimCustomers_ID_SK_PK
)
SELECT
    target.staging_raw_id,
    target.Dim_SOR_ID,
    target.CustomerID_NK,
    target.CompanyName,
    target.ContactName,
    target.PriorContactName,
    target.ContactTitle,
    target.PriorContactTitle,
    target.Address,
    target.City,
    target.Region,
    target.PostalCode,
    target.Country,
    target.Phone,
    target.Fax,
    target.DimCustomers_ID_SK_PK
FROM {schema}.DimCustomers AS target
WHERE EXISTS (
    SELECT 1
    FROM {schema}.StagingCustomers AS source
    WHERE source.CustomerID_NK = target.CustomerID_NK
        AND (
            ISNULL(target.CompanyName, '') <> ISNULL(source.CompanyName, '') OR
            ISNULL(target.ContactName, '') <> ISNULL(source.ContactName, '') OR
            ISNULL(target.ContactTitle, '') <> ISNULL(source.ContactTitle, '') OR
            ISNULL(target.Address, '') <> ISNULL(source.Address, '') OR
            ISNULL(target.City, '') <> ISNULL(source.City, '') OR
            ISNULL(target.Region, '') <> ISNULL(source.Region, '') OR
            ISNULL(target.PostalCode, '') <> ISNULL(source.PostalCode, '') OR
            ISNULL(target.Country, '') <> ISNULL(source.Country, '') OR
            ISNULL(target.Phone, '') <> ISNULL(source.Phone, '') OR
            ISNULL(target.Fax, '') <> ISNULL(source.Fax, '')
        )
);

-- Update historical records in DimCustomersHistory to set ValidTo date and close them
UPDATE hist
SET hist.ValidTo = GETDATE()
FROM {schema}.DimCustomersHistory AS hist
INNER JOIN {schema}.DimCustomers AS target
    ON hist.DimCustomers_ID_SK_PK = target.DimCustomers_ID_SK_PK
WHERE hist.ValidTo IS NULL;

