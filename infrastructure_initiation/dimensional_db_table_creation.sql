USE ORDER_DDS;

DROP TABLE IF EXISTS DimCategories;

CREATE TABLE DimCategories (
    DimCategories_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,        
	Dim_SOR_ID INT,
    CategoryID_NK VARCHAR(255),
    CategoryName VARCHAR(255),
    Description VARCHAR(255)
);

DROP TABLE IF EXISTS DimCustomers;

CREATE TABLE DimCustomers (
    DimCustomers_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,        
	Dim_SOR_ID INT,
    CustomerID_NK VARCHAR(255),
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    PriorContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    PriorContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),		
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255)
    );

DROP TABLE IF EXISTS DimEmployees;

CREATE TABLE DimEmployees (
    DimEmployees_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,     
	Dim_SOR_ID INT,
    EmployeeID_NK VARCHAR(255),
    LastName VARCHAR(255),
    FirstName VARCHAR(255),
    Title VARCHAR(255),
    TitleOfCourtesy VARCHAR(255),
    BirthDate VARCHAR(255),
    HireDate VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    HomePhone VARCHAR(255),
    Extension VARCHAR(255),
    Notes VARCHAR(255),
    ReportsTo VARCHAR(255),
    PhotoPath VARCHAR(255),
    EffectiveDate VARCHAR(255),
    EndDate VARCHAR(255),
    IsCurrent INT
);

DROP TABLE IF EXISTS DimProducts;

CREATE TABLE DimProducts (
    DimProducts_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,          
	Dim_SOR_ID INT,
    ProductID_NK VARCHAR(255),
    ProductName VARCHAR(255),
    SupplierID VARCHAR(255),
    CategoryID VARCHAR(255),
    QuantityPerUnit VARCHAR(255),
    UnitPrice VARCHAR(255),
    UnitsInStock VARCHAR(255),
    UnitsOnOrder VARCHAR(255),
    ReorderLevel VARCHAR(255),
    Discontinued VARCHAR(255)
);

DROP TABLE IF EXISTS DimRegion;

CREATE TABLE DimRegion (
    DimRegion_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,         
	Dim_SOR_ID INT,
    RegionID_NK VARCHAR(255),
    RegionDescription VARCHAR(255),
    RegionCategory VARCHAR(255),
    RegionImportance VARCHAR(255)
);

DROP TABLE IF EXISTS DimShippers;

CREATE TABLE DimShippers (
    DimShippers_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,               
	Dim_SOR_ID INT,
    ShipperID_NK VARCHAR(255),
    CompanyName VARCHAR(255),
    Phone VARCHAR(255)
);

DROP TABLE IF EXISTS DimSuppliersCurrent;
/* stex el valid from*/
CREATE TABLE DimSuppliersCurrent (
    DimSuppliersCurrent_ID_SK_PK_Durable INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,           
	Dim_SOR_ID INT,
    SupplierID_NK VARCHAR(255),
    CompanyName VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255),
    HomePage VARCHAR(255)
);

DROP TABLE IF EXISTS DimSuppliersHistory;
/* stex piti poxenq valid from, valid to avelacnenq*/
CREATE TABLE DimSuppliersHistory (
    DimSuppliers_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,           
	Dim_SOR_ID INT,
    SupplierID_NK VARCHAR(255),
    CompanyName VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255),
    HomePage VARCHAR(255),
	DimSuppliers_ID_SK_Durable INT
	);


DROP TABLE IF EXISTS DimTerritories;

CREATE TABLE DimTerritories (
    DimTerritories_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,        
	Dim_SOR_ID INT,
    TerritoryID_NK VARCHAR(255),
    TerritoryDescription VARCHAR(255),
    TerritoryCode VARCHAR(255),
    RegionID VARCHAR(255),
    EffectiveDate VARCHAR(10),
    EndDate VARCHAR(10),
    IsCurrent INT
);

DROP TABLE IF EXISTS FactOrders;

CREATE TABLE FactOrders (
    FactOrders_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,                         
	Dim_SOR_ID INT,
    OrderID_NK VARCHAR(255),
    ProductID VARCHAR(255),
    UnitPrice VARCHAR(255),
    Quantity VARCHAR(255),
    Discount VARCHAR(255),
    CustomerID VARCHAR(255),
    EmployeeID VARCHAR(255),
    OrderDate VARCHAR(255),
    RequiredDate VARCHAR(255),
    ShippedDate VARCHAR(255),
    ShipVia VARCHAR(255),
    Freight VARCHAR(255),
    ShipName VARCHAR(255),
    ShipAddress VARCHAR(255),
    ShipCity VARCHAR(255),
    ShipRegion VARCHAR(255),
    ShipPostalCode VARCHAR(255),
    ShipCountry VARCHAR(255),
    TerritoryID VARCHAR(255)
);

DROP TABLE IF EXISTS fact_error;

CREATE TABLE fact_error(
    FactOrders_ID_SK_PK INT IDENTITY PRIMARY KEY,
    staging_raw_id INT,                         
	Dim_SOR_ID INT,
    OrderID_NK VARCHAR(255),
    ProductID VARCHAR(255),
    UnitPrice VARCHAR(255),
    Quantity VARCHAR(255),
    Discount VARCHAR(255),
    CustomerID VARCHAR(255),
    EmployeeID VARCHAR(255),
    OrderDate VARCHAR(255),
    RequiredDate VARCHAR(255),
    ShippedDate VARCHAR(255),
    ShipVia VARCHAR(255),
    Freight VARCHAR(255),
    ShipName VARCHAR(255),
    ShipAddress VARCHAR(255),
    ShipCity VARCHAR(255),
    ShipRegion VARCHAR(255),
    ShipPostalCode VARCHAR(255),
    ShipCountry VARCHAR(255),
    TerritoryID VARCHAR(255)
);

DROP TABLE IF EXISTS Dim_SOR;

CREATE TABLE Dim_SOR (
    Dim_SOR_ID_SK_PK INT IDENTITY PRIMARY KEY,  
    staging_raw_id INT,                         
    Staging_Raw_Table_Name VARCHAR(255)  
);

INSERT INTO Dim_SOR (Staging_Raw_Table_Name, staging_raw_id)
SELECT
    t.TABLE_NAME,
    k.COLUMN_NAME
FROM
    INFORMATION_SCHEMA.TABLES t
JOIN
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
    ON t.TABLE_NAME = k.TABLE_NAME
WHERE
    t.TABLE_SCHEMA = 'dbo'
    AND t.TABLE_NAME LIKE 'staging%';
