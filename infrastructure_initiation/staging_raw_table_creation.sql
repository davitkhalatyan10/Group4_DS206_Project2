CREATE TABLE staging_raw_Categories (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    CategoryID INT,
    CategoryName VARCHAR(255),
    Description VARCHAR(255)
);

CREATE TABLE staging_raw_Customers (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    CustomerID VARCHAR(255),
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region INT,
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255)
);

CREATE TABLE staging_raw_Employees (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    EmployeeID INT,
    LastName VARCHAR(255),
    FirstName VARCHAR(255),
    Title VARCHAR(255),
    TitleOfCourtesy VARCHAR(255),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    HomePhone VARCHAR(255),
    Extension INT,
    Notes VARCHAR(255),
    ReportsTo INT,
    PhotoPath VARCHAR(255)
);

CREATE TABLE staging_raw_OrderDetails (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice INT,
    Quantity INT,
    Discount INT
);

CREATE TABLE staging_raw_Orders (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    OrderID INT,
    CustomerID VARCHAR(255),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight INT,
    ShipName VARCHAR(255),
    ShipAddress VARCHAR(255),
    ShipCity VARCHAR(255),
    ShipRegion VARCHAR(255),
    ShipPostalCode VARCHAR(255),
    ShipCountry VARCHAR(255),
    TerritoryID INT
);

CREATE TABLE staging_raw_Products (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    ProductID INT,
    ProductName VARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(255),
    UnitPrice INT,
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued INT
);

CREATE TABLE staging_raw_Region (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    RegionID INT,
    RegionDescription VARCHAR(255),
    RegionCategory VARCHAR(255),
    RegionImportance VARCHAR(255)
);

CREATE TABLE staging_raw_Shippers (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    ShipperID INT,
    CompanyName VARCHAR(255),
    Phone VARCHAR(255)
);

CREATE TABLE staging_raw_Suppliers (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    SupplierID INT,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(255),
    Country VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255),
    HomePage VARCHAR(255)
);

CREATE TABLE staging_raw_Territories (
    staging_raw_id INT IDENTITY PRIMARY KEY,
    TerritoryID INT,
    TerritoryDescription VARCHAR(255),
    TerritoryCode VARCHAR(255),
    RegionID INT
);
