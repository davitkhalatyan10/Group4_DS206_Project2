USE {database_name};

MERGE INTO {schema}.DimShippers AS target
USING (
    SELECT
        ss.staging_raw_id,
        ss.ShipperID,
        ss.CompanyName,
        ss.Phone,
        ds.Dim_SOR_ID_SK_PK
    FROM {schema}.staging_raw_Shippers ss
    JOIN {schema}.Dim_SOR ds
        ON ds.Staging_Raw_Table_Name = 'staging_raw_Shippers'
) AS source
ON target.ShipperID_NK = source.ShipperID

WHEN MATCHED THEN
    UPDATE SET
        target.CompanyName = source.CompanyName,
        target.Phone = source.Phone

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        ShipperID_NK,
        CompanyName,
        Phone,
        Dim_SOR_ID,
        staging_raw_id
    )
    VALUES (
        source.ShipperID,
        source.CompanyName,
        source.Phone,
        source.Dim_SOR_ID_SK_PK,
        source.staging_raw_id
    );
