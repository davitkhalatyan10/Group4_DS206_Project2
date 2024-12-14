USE {database_name};

MERGE INTO {schema}.DimCustomers AS target
USING (
    SELECT
        sc.CustomerID,
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
        ds.Dim_SOR_ID_SK_PK AS Dim_SOR_ID,
        sc.staging_raw_id
    FROM {schema}.staging_raw_Customers sc
    JOIN {schema}.Dim_SOR ds
        ON ds.Staging_Raw_Table_Name = 'staging_raw_Customers'
) AS source
ON target.CustomerID_NK = source.CustomerID

-- Update existing records with SCD Type 3 changes
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
        target.Dim_SOR_ID = source.Dim_SOR_ID

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
        source.Dim_SOR_ID,
        source.CustomerID,
        source.CompanyName,
        source.ContactName,
        NULL, -- PriorContactName is NULL for new records
        source.ContactTitle,
        NULL, -- PriorContactTitle is NULL for new records
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        source.Phone,
        source.Fax
    );
