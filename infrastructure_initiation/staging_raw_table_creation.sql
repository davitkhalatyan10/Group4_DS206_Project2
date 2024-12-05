USE ORDER_DDS;
GO

CREATE TABLE dbo.StagingCategories (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    CategoryID INT,
    CategoryName NVARCHAR(255)
);

CREATE TABLE dbo.StagingCustomers (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    CustomerID INT,
    CustomerName NVARCHAR(255),
    ContactName NVARCHAR(255),
    Country NVARCHAR(255)
);

CREATE TABLE dbo.StagingEmployees (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    EmployeeID INT,
    LastName NVARCHAR(255),
    FirstName NVARCHAR(255),
    BirthDate DATE,
    HireDate DATE,
    ReportsTo INT
);

CREATE TABLE dbo.StagingProducts (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    ProductID INT,
    ProductName NVARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(10, 2)
);

CREATE TABLE dbo.StagingRegion (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    RegionID INT,
    RegionDescription NVARCHAR(255)
);

CREATE TABLE dbo.StagingShippers (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    ShipperID INT,
    ShipperName NVARCHAR(255),
    Phone NVARCHAR(50)
);

CREATE TABLE dbo.StagingSuppliers (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    SupplierID INT,
    SupplierName NVARCHAR(255),
    ContactName NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(255),
    PostalCode NVARCHAR(50),
    Country NVARCHAR(255)
);

CREATE TABLE dbo.StagingTerritories (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    TerritoryID INT,
    TerritoryDescription NVARCHAR(255),
    RegionID INT
);

CREATE TABLE dbo.StagingOrders (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    OrderID INT,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    ShipVia INT,
    Freight DECIMAL(10, 2)
);

CREATE TABLE dbo.StagingOrderDetails (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(5, 2)
);