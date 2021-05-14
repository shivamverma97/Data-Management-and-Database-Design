----------------------------VIEWS-------------------------------
-----1) Order_Summary-------

CREATE VIEW Order_Summary 
AS
select c.Cust_ID, c.Cust_Name,e.Emp_ID, s.Invoice_ID, p.Prod_ID, c.Cust_Type,
		p.Product_Name, p.Product_Type, p.Unit_Price, o.Qty as 'Order Qty',
		case when c.Cust_Type = 'Prime' then (p.Unit_Price*o.Qty)*0.9
		when c.Cust_Type = 'NonPrime' then  (p.Unit_Price*o.Qty)
		end as Total_Cost,
		s.Ship_ID, od.Order_Date, 
		od.Delivery_Date, s.Supp_Date, s.Ship_Qty,s.Ship_Status 
from customer c
inner join [Order] o on c.Cust_ID = o.Cust_ID
inner join Employee e on e.Emp_ID = o.Emp_ID
inner join Order_Details od on od.Order_ID = o.Order_ID
inner join Product p on p.Prod_ID = od.Prod_ID
inner join Shipment s on s.Invoice_ID = od.Invoice_ID
;


--------2) Inventory_Details--------
CREATE VIEW Inventory_Details
AS
select od.Invoice_ID, o.Qty, od.Order_Date, od.Delivery_Date, 
o.Emp_ID, p.Prod_ID, s.Ship_ID, s.Ship_Status, s.Ship_Qty, s.Supp_Date, 
w.WH_ID, w.WH_Name, sp.Supp_ID, sp.Supp_Company, ca.Carrier_ID, ca.Carrier_Company
from Order_Details od
inner join [Order] o on od.Order_ID = o.Order_ID
inner join Product p on p.Prod_ID = od.Prod_ID
inner join Shipment s on s.Invoice_ID = od.Invoice_ID
inner join Carriers ca on s.Carrier_ID = ca.Carrier_ID
inner join Supplier sp on sp.Supp_ID = s.Supp_ID
inner join Warehouse w on w.WH_ID = s.WH_ID
inner join Customer c on c.Cust_ID = o.Cust_ID
;


-------3) Employee Responsibility-------

CREATE VIEW Employee_Responsibility 
AS
select e.Emp_ID, e.Emp_FName, e.Emp_LName, c.Cust_ID, o.Order_ID, 
od.Prod_ID, d.Dept_ID, c.Cust_Name, c.Cust_Type, d.Dept_Name,
p.Product_Name, od.Order_Date, od.Delivery_Date, p.Unit_Price, o.Qty,
case when c.Cust_Type = 'Prime' then (p.Unit_Price*o.Qty)*0.9
	 when c.Cust_Type = 'NonPrime' then  (p.Unit_Price*o.Qty)
	 end as Total_Cost
from customer c
inner join [Order] o on c.Cust_ID = o.Cust_ID
inner join Order_Details od on od.Order_ID = o.Order_ID
inner join Product p on p.Prod_ID = od.Prod_ID
inner join Employee e on e.Emp_ID = o.Emp_ID
inner join Department d on d.Dept_ID = p.Dept_ID
;

---------Stored Procedures-----------


---------1) Get_Department_Employee----------

CREATE PROCEDURE Get_Department_Employee @Dept_Name VARCHAR(30)
AS 
BEGIN
SELECT e.emp_ID, d.Dept_ID, e.Emp_FName, e.Emp_LName, d.Dept_Name, e.Emp_ManID , e.Emp_Status
from Employee e 
INNER JOIN Department d ON d.Dept_ID = e.Dept_ID
WHERE d.Dept_Name= @Dept_Name
END;

EXEC Get_Department_Employee 'Smartphones'

-----------2) Order_Summary--------------
CREATE PROCEDURE Get_Order_Status @Ship_Status VARCHAR(30)
AS 
BEGIN
SELECT od.Invoice_ID, c.Cust_ID, c.Cust_Name, s.Ship_ID, s.Ship_Status, s.Supp_Date, od.Order_Date, od.Delivery_Date
from customer c
inner join [Order] o on c.Cust_ID = o.Cust_ID
inner join Order_Details od on od.Order_ID = o.Order_ID
inner join Product p on p.Prod_ID = od.Prod_ID
inner join Shipment s on s.Invoice_ID = od.Invoice_ID
WHERE s.Ship_Status= @Ship_Status
END;

EXEC Get_Order_Status 'Shipped'

-----------3) Product_Tracking------------
CREATE PROCEDURE Get_Product_Tracking @Product_Type VARCHAR(30), @WH_Name VARCHAR(30)
AS 
BEGIN
SELECT p.Prod_ID, w.WH_ID,sp.Supp_ID, s.ship_ID, ca.Carrier_ID, p.Product_Type,
p.Product_Name, p.Unit_Price, o.Qty,
case when c.Cust_Type = 'Prime' then (p.Unit_Price*o.Qty)*0.9
	when c.Cust_Type = 'NonPrime' then  (p.Unit_Price*o.Qty)
	end as Total_Cost,
w.WH_Name, ca.Carrier_Company, sp.Supp_Company, ca.Carrier_Type, s.Ship_Qty, s.Supp_Date
from customer c
inner join [Order] o on c.Cust_ID = o.Cust_ID
inner join Order_Details od on od.Order_ID = o.Order_ID
inner join Product p on p.Prod_ID = od.Prod_ID
inner join Shipment s on s.Invoice_ID = od.Invoice_ID
inner join Carriers ca on s.Carrier_ID = ca.Carrier_ID
inner join Supplier sp on sp.Supp_ID = s.Supp_ID
inner join Warehouse w on w.WH_ID = s.WH_ID
WHERE (p.Product_Type= @Product_Type AND w.WH_Name= @WH_Name)
END;

EXEC Get_Product_Tracking 'Mobile' , 'DA19'

---------- Functions------------------------------------------------------------------------

-----------1) Get_State-------------

CREATE FUNCTION Get_Cust_State (@Cust_ID INT)
RETURNS Char(2)
AS
BEGIN
DECLARE @temp CHAR(2)
SELECT @temp= c.Cust_State
FROM Customer c
WHERE c.Cust_ID= @Cust_ID
RETURN @temp
END;

SELECT dbo.Get_Cust_State(10001) As Cust_State

---------2) Get_Total_Cost-----------------

CREATE FUNCTION Get_Total_Cost (@Invoice_ID FLOAT)
RETURNS FLOAT
AS
BEGIN
DECLARE @temp FLOAT
SELECT @temp= case when c.Cust_Type = 'Prime' then (p.Unit_Price*o.Qty)*0.9
	when c.Cust_Type = 'NonPrime' then  (p.Unit_Price*o.Qty)
	end
FROM  customer c
inner join [Order] o on c.Cust_ID = o.Cust_ID
inner join Order_Details od on od.Order_ID = o.Order_ID
inner join Product p on p.Prod_ID = od.Prod_ID
WHERE od.Invoice_ID= @Invoice_ID
RETURN @temp
END;

SELECT dbo.Get_Total_Cost(90015015000001) As Total_Cost


SELECT o.Order_ID, p.Prod_ID, o.Qty, p.Unit_Price,dbo.Get_Total_Cost(Invoice_ID) As Total_Cost
FROM [Order] o INNER JOIN Order_Details od ON
o.Order_ID= od.Order_ID
INNER JOIN Product p ON od.Prod_ID= p.Prod_ID

----------3) Delivery Days-----------------------------------------

CREATE FUNCTION Get_Order_Lead_Time (@Invoice_ID FLOAT)
RETURNS INT
AS
BEGIN
DECLARE @temp INT 
SELECT @temp= DATEDIFF(DAY, od.Order_Date, od.Delivery_Date)
FROM Order_Details od 
WHERE od.Invoice_ID= @Invoice_ID
RETURN @temp
END;

SELECT Invoice_ID, Order_Date, Delivery_Date, dbo.Get_Order_Lead_Time (Invoice_ID)AS [Days]
FROM Order_Details


------Nonclustered Index------------

CREATE NONCLUSTERED INDEX IX_Customer_List ON Customer(Cust_Name, Cust_Type, Cust_Addr);

CREATE NONCLUSTERED INDEX IX_Employee_List ON Employee(Emp_FName, Emp_LName, Emp_SSN);

CREATE NONCLUSTERED INDEX IX_Supplier_List ON Supplier(Supp_Contact, Supp_Company, Supp_PhoneNo);



