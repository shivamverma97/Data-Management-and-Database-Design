-------------------------------E COMMERCE DATABASE----------------
Create DATABASE Project
USE  Project

CREATE TABLE Customer(
    Cust_ID INT Not NULL,
    Cust_Name VARCHAR(50),
    Cust_Type VARCHAR(20),
	Cust_DiscountPercentage INT,
    Cust_Addr VARCHAR(100),
    Cust_City VARCHAR(20),
    Cust_State CHAR(2),
    Cust_Country VARCHAR(20),
    Cust_ZipCode INT,
    Cust_PhoneNo INT,
    CONSTRAINT Customer_PK PRIMARY KEY (Cust_ID),
    CONSTRAINT CHK_Cust_Type CHECK (Cust_Type='Prime' OR Cust_Type='NonPrime'),
	CONSTRAINT CHK_Cust_PhoneNo CHECK (Cust_PhoneNo>=100000000 AND Cust_PhoneNo<=999999999)
);

CREATE TABLE Department 
(
	Dept_ID INT NOT NULL,
	Dept_Name VARCHAR(30),
	Dept_Type VARCHAR(20),
	Dept_Descr VARCHAR(250),
	CONSTRAINT Department_PK PRIMARY KEY (Dept_ID),
	CONSTRAINT CHK_Dept_Type CHECK (Dept_Type IN ('Computer','Music', 'Electronics','Mobile','Add-ons'))
);

CREATE TABLE Employee(
    Emp_ID INT NOT NULL,
    Dept_ID INT,
    Emp_FName VARCHAR(50),
    Emp_LName VARCHAR(50),
    Emp_Type VARCHAR(20),
    Emp_DOB DATE,
    Emp_DOH DATE,
    Emp_Addr VARCHAR(100),
    Emp_City VARCHAR(20),
    Emp_State CHAR(2),
    Emp_Country VARCHAR(20),
    Emp_ZipCode INT,
    Emp_PhoneNo INT,
    Emp_SSN INT,
    Emp_Status VARCHAR(50),
    Emp_ManID INT,
    Emp_Salary FLOAT,
	Emp_FullName VARCHAR(100),
    CONSTRAINT Employee_PK PRIMARY KEY (Emp_ID),
    CONSTRAINT Employee_FK1 FOREIGN KEY (Dept_ID) REFERENCES [Department](Dept_ID),
	CONSTRAINT CHK_Emp_Type CHECK (Emp_Type IN ('Junior', 'Mid Level', 'Senior','Manager')),
	CONSTRAINT CHK_Emp_Status CHECK (Emp_Status IN ('Active', 'Inactive')),
	CONSTRAINT CHK_Emp_PhoneNo CHECK (Emp_PhoneNo>=100000000 AND Emp_PhoneNo<=999999999),
	CONSTRAINT CHK_Emp_SSN CHECK (Emp_SSN>=100000 AND Emp_SSN<=999999)
);

CREATE TABLE [Order] (
    Order_ID INT Not NULL,
    Cust_ID INT,
    Emp_ID INT,
    Qty INT,
    CONSTRAINT Order_PK PRIMARY KEY (Order_ID),
    CONSTRAINT Order_FK FOREIGN KEY (Cust_ID) REFERENCES Customer(Cust_ID)
);

CREATE TABLE Product(
    Prod_ID INT NOT NULL,
    Dept_ID INT,
    Product_Name VARCHAR(30),
    Product_Type VARCHAR(30),
    Product_Descr VARCHAR (250),
    Unit_Price FLOAT,
    CONSTRAINT Product_PK PRIMARY KEY (Prod_ID),
	CONSTRAINT Product_FK FOREIGN KEY (Dept_ID) REFERENCES [Department](Dept_ID)
);


CREATE TABLE Order_Details(
    Order_ID INT ,
    Prod_ID INT ,
    Order_Date DATE,
    Delivery_Date DATE,
	Invoice_ID FLOAT NOT NULL,
    CONSTRAINT Order_Details_PK PRIMARY KEY (Invoice_ID),
	CONSTRAINT Order_Details_FK1 FOREIGN KEY (Order_ID) REFERENCES [Order](Order_ID),
	CONSTRAINT Order_Details_FK2 FOREIGN KEY (Prod_ID) REFERENCES [Product](Prod_ID)
);

CREATE TABLE Warehouse
(
	WH_ID INT NOT NULL,
	WH_Name VARCHAR(30),
	WH_Loc VARCHAR(20),
	WH_Capacity VARCHAR(30),
	CONSTRAINT Warehouse_PK PRIMARY KEY (WH_ID)
);

CREATE TABLE Carriers
(
	Carrier_ID INT NOT NULL,
	Carrier_Company VARCHAR(30),
	Carrier_Type VARCHAR(20),
	Carrier_Contact VARCHAR(30),
	Carrier_PhoneNo INT,
	CONSTRAINT Carrier_PK PRIMARY KEY (Carrier_ID),
	CONSTRAINT CHK_Carrier_PhoneNo CHECK (Carrier_PhoneNo>=100000000 AND Carrier_PhoneNo<=999999999),
	CONSTRAINT CHK_Carrier_Type CHECK (Carrier_Type='Air' OR Carrier_Type='Ground')
);

CREATE TABLE Supplier
(
	Supp_ID INT NOT NULL,
	Supp_Contact VARCHAR(30),
	Supp_Company VARCHAR(30),
	Supp_Type VARCHAR(20),
	Supp_Addr VARCHAR(100),
	Supp_City VARCHAR(20),
	Supp_State CHAR(2),
	Supp_Country VARCHAR(20),
	Supp_ZipCode INT,
	Supp_PhoneNo INT,
	CONSTRAINT Supplier_PK PRIMARY KEY (Supp_ID),
    CONSTRAINT CHK_Supp_PhoneNo CHECK (Supp_PhoneNo>=100000000 AND Supp_PhoneNo<=999999999),
	CONSTRAINT CHK_Supp_Type CHECK (Supp_Type='Retail' OR Supp_Type='Wholesale')
);

CREATE TABLE Shipment
(
	Ship_ID INT NOT NULL,
	Carrier_ID INT,
	WH_ID INT,
	Supp_ID INT,
	Ship_Status VARCHAR(30),
	Ship_Qty INT,
	Supp_Date DATE,
	Invoice_ID FLOAT,
	CONSTRAINT Shipment_PK PRIMARY KEY (Ship_ID),
	CONSTRAINT Shipment_FK1 FOREIGN KEY (Carrier_ID) REFERENCES [Carriers](Carrier_ID),
	CONSTRAINT Shipment_FK2 FOREIGN KEY (WH_ID) REFERENCES [Warehouse](WH_ID),
	CONSTRAINT Shipment_FK3 FOREIGN KEY (Invoice_ID) REFERENCES [Order_Details](Invoice_ID),
	CONSTRAINT Shipment_FK4 FOREIGN KEY (Supp_ID) REFERENCES [Supplier](Supp_ID),
    CONSTRAINT CHK_Ship_Status CHECK (Ship_Status IN ('Delivered','Shipped', 'Ordered'))
);

----------------------------------TRIGGERS---------------------------------

CREATE TRIGGER Get_Invoice_Details
ON Order_Details
FOR INSERT
AS
BEGIN
	UPDATE Order_Details SET   Delivery_Date = DATEADD(DAY, 7, O_Date)

       FROM  (
                    SELECT  Order_ID OID, Prod_ID PID, Order_Date O_Date
                      FROM  inserted
               ) Query
		WHERE Order_Details.Order_ID = Query.OID
         AND Order_Details.Prod_ID = Query.PID

END

GO