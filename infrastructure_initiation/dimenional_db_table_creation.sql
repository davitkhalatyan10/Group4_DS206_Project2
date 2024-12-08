USE ORDER_DDS;
GO

CREATE TABLE DimCategories (
    CategoryKey INT IDENTITY PRIMARY KEY,
    CategoryID INT NOT NULL,
    CategoryName NVARCHAR(255),
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE DimCustomers (
    CustomerKey INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerName NVARCHAR(255),
    ContactName NVARCHAR(255),
    Country NVARCHAR(255),
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE DimEmployees (
    EmployeeKey INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,
    LastName NVARCHAR(255),
    FirstName NVARCHAR(255),
    HireDate DATE,
    TerminationDate DATE
);

CREATE TABLE DimProducts (
    ProductKey INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(255),
    CategoryKey INT,
    SupplierKey INT,
    UnitPrice DECIMAL(10, 2),
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE DimRegion (
    RegionKey INT IDENTITY PRIMARY KEY,
    RegionID INT NOT NULL,
    RegionDescription NVARCHAR(255),
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE DimShippers (
    ShipperKey INT IDENTITY PRIMARY KEY,
    ShipperID INT NOT NULL,
    ShipperName NVARCHAR(255),
    Phone NVARCHAR(50),
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE DimSuppliers (
    SupplierKey INT IDENTITY PRIMARY KEY,
    SupplierID INT NOT NULL,
    SupplierName NVARCHAR(255),
    ContactName NVARCHAR(255),
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE DimTerritories (
    TerritoryKey INT IDENTITY PRIMARY KEY,
    TerritoryID INT NOT NULL,
    TerritoryDescription NVARCHAR(255),
    RegionKey INT,
    EffectiveDate DATE,
    ExpirationDate DATE
);

CREATE TABLE Dim_SOR (
    SORKey INT IDENTITY PRIMARY KEY,
    StagingTableName NVARCHAR(255) NOT NULL,
    SurrogateKeyColumn NVARCHAR(255) NOT NULL
);

CREATE TABLE FactOrders (
    OrderKey INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    CustomerKey INT,
    EmployeeKey INT,
    OrderDate DATE,
    ShipVia INT,
    Freight DECIMAL(10, 2),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomers(CustomerKey),
    FOREIGN KEY (EmployeeKey) REFERENCES DimEmployees(EmployeeKey)
);
