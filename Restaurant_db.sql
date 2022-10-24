/*
	A Simple Restaurant Database

	The main purpose of this database is to break down the sales of a restaurant over a one month
	period to see how much was spent on each food category (beef/pork/poultry/fish/shellfish/liquor/beer/wine/NABs),
	and how much was sold in each category. Sales can be analyzed over the whole month, or one day, or an
	arbitrary period within the month that I tracked. If I wanted to get real fancy, I would 
	add other expsenses than food, like labor, maintenance, and everything else that's on the P&L,
	but this should be good for now I hope. 

*/

USE Master;
GO

CREATE DATABASE Restaurants;

USE Restaurants;
GO

/*
	*************************************************************************
	                             DATA ENTRY
	*************************************************************************
*/

/*
	This table contains the name and itemID of all items on the menu.
	Items have food categories, and the cost to purchase one unit
	(these things are actually purchased cases at a time but I 
	don't know if I'll have time to add that new level of 
	complexity). Also all have a menu price.
*/
CREATE TABLE Items (
	ItemID				INT				NOT NULL IDENTITY PRIMARY KEY,
	VendorID			INT				NOT NULL,
	ItemName			VARCHAR(25)		NOT NULL,
	ItemCategory		VARCHAR(15)		NOT NULL,
	ItemVendorPrice		MONEY			NOT NULL,
	ItemMenuPrice		MONEY			NOT NULL
);

/*
	This table is where the daily sales for each food category and for the restaurant as 
	a whole can be calculated. Daily sales would be the sum of the procuct of every
	items price and the number of times it was sold in a day. 
*/
CREATE TABLE DailyItemSales (	
	SalesDate				DATETIME		NOT NULL,
	ItemID					INT				NOT NULL REFERENCES Items(ItemID),
	QuantityOfItemSold		INT				NOT NULL
);

/*
	Because we want to be able to calculate profits and stuff, I need
	to have an invoice table to find out how much is being spent on
	product. Every invoice has an invoiceID, is associated with a 
	vendor, and has a date.
*/

-- I want to add invoice total to this table.... maybe?

CREATE TABLE Invoices(
	InvoiceID		INT			NOT NULL IDENTITY PRIMARY KEY,
	VendorID		INT			NOT NULL REFERENCES Vendors(VendorID),	
	InvoiceDate		DATETIME	NOT NULL
);

/*
	This table holds details relevant to each invoice. InvoiceItems 
	breaks down each invoice, because an invoice total alone
	isn't enough. I want to know how much of what item was
	purchased for each invoice.
*/
CREATE TABLE InvoiceItems (
	InvoiceItemsID	INT		NOT NULL IDENTITY PRIMARY KEY,
	InvoiceID		INT		NOT NULL REFERENCES Invoices(InvoiceID),
	ItemID			INT		NOT NULL REFERENCES Items(ItemID),
	ItemQuantity	INT		NOT NULL
);

/*
	Nothing special here. Just information about the vendors
	the restaurant uses.
*/
CREATE TABLE Vendors (
	VendorID				INT					NOT NULL IDENTITY PRIMARY KEY,
	VendorName				VARCHAR(35)			NOT NULL,
	VendorContactFName		VARCHAR(20)			NULL,
	VendorContactLName		VARCHAR(20)			NULL,
	VendorPhone				VARCHAR(12)			NULL,
	VendorEmail				VARCHAR(35)			NULL,
	VendorState				VARCHAR(15)			NULL,
	VendorCity				VARCHAR(20)			NULL,
	VendorZipCode			VARCHAR(5)			NULL
);

/*
	Employees, of course.
*/
CREATE TABLE Employees (
	EmployeeID			INT				IDENTITY PRIMARY KEY,
	FirstName			VARCHAR(20)		NOT NULL,
	LastName			VARCHAR(20)		NOT NULL,
	Position			VARCHAR(20)		NOT NULL,
	HourlyPay			MONEY			NOT NULL
);


/*
	*************************************************************************
	                             DATA ENTRY
	*************************************************************************
*/

/*
	The menu for this restaurant is small, as you can see. If it were a normally sized
	menu I would be wasting a lot of time just creating data. A smaller unrealistic
	should be good enough right? lol These vendorPrices aren't too close to reality
	most likely but the menu prices are.
*/
INSERT INTO Items (VendorID, ItemName, ItemCategory, ItemVendorPrice, ItemMenuPrice)
VALUES
	(1, '12oz Ribeye', 'beef', 4.59, 19.99),
	(1, '11oz Sirloin', 'beef', 7.69, 18.99),
	(1, '22oz Porterhouse', 'beef', 10.69, 25.99),
	(1, '12oz Pork Chops', 'pork', 4.22, 13.99),
	(2, '8oz Salmon', 'fish', 4.25, 14.99),
	(2, '9oz Tilapia', 'fish', 3.66, 12.99),
	(3, '8oz Chicken', 'poultry', 3.33, 12.99),
	(3, 'Wings', 'poultry', 2.01, 10.99),
	(3, 'Lobster Tail', 'shellfish', 6.50, 11.99),
	(4, 'House Salad', 'produce', 1.07, 4.99),
	(5, 'Shot of Jack', 'liquor', 2.00, 5.99),
	(6, 'Bottle of Blue Moon', 'beer', 1.00, 4.99),
	(6, '9oz Glass of Merlot', 'wine', 1.50, 5.99),
	(7, 'Chicken Tenders Basket', 'poultry', 1.32, 8.99);

/*
	I took your suggestion and populated this table by creating data in excel and importing 
	the spreadsheet as a CSV file. There are over 400 rows in this table, but thanks to
	excel I was able create them all in about 15 minutes. A breakdown of how much 
	of each item sold in a day is called a product mix, or P mix. We look over them
	every night where I work to inventory the steak at close, and they are very long
	documents. 
*/
TRUNCATE TABLE dbo.DailyItemSales;
GO

BULK INSERT dbo.DailyItemSales
FROM 'C:\Users\peter\OneDrive\Documents\SQL Server Management Studio\DailyItemSales_db.csv'
WITH
(
	FORMAT = 'CSV',	
	FIRSTROW = 2
);
GO
--CREATE TABLE DailyItemSales(date SalesDate, int ItemID, int QuantityOfItemSold)


/*
	The invoice table doesn't really need to hold much, for my purposes.
	Every invoice has a date and a vendorID. The bulk of the information
	contained in the invoices is in the Invoice Items table.
*/

INSERT INTO Invoices(VendorID, InvoiceDate)
VALUES
	(1, '2022-09-01'),
	(1, '2022-09-15'),
	(1, '2022-09-29'),
	(2, '2022-09-03'),
	(2, '2022-09-17'),
	(2, '2022-09-28'),
	(3, '2022-09-01'),
	(3, '2022-09-14'),
	(3, '2022-09-27'),
	(4, '2022-09-02'),
	(4, '2022-09-16'),
	(4, '2022-09-26'),
	(5, '2022-09-04'),
	(5, '2022-09-13'),
	(5, '2022-09-29'),
	(6, '2022-09-03'),
	(6, '2022-09-13'),
	(6, '2022-09-23'),
	(7, '2022-09-01'),
	(7, '2022-09-17'),
	(7, '2022-09-27');

/*
	Every invoice is associated with multiple InvoiceItems.
	Invoice items store the item purchased, and the quantity.
	Invoice totals are calculated by taking sum of invoiceitems
	for each invoice, where a total for an InvoiceItem is
	ItemVendorPrice * quantity. This table is long and ugly
	but I created it befor the CSV idea.
*/
INSERT INTO InvoiceItems (InvoiceID, ItemID, ItemQuantity)
VALUES	
	(1, 1, 50),
	(1, 2, 25),
	(1, 3, 20),
	(1, 4, 15),

	(2, 1, 40),
	(2, 2, 15),
	(2, 3, 10),
	(2, 4, 5),

	(3, 1, 55),
	(3, 2, 25),
	(3, 3, 25),
	(3, 4, 15),

	(4, 5, 30),
	(4, 6, 5),

	(5, 5, 40),
	(5, 6, 8),

	(6, 5, 35),
	(6, 6, 1),

	(7, 7, 50),
	(7, 8, 40),
	(7, 9, 45),

	(8, 7, 10),
	(8, 8, 20),
	(8, 9, 35),

	(9, 7, 22),
	(9, 8, 33),
	(9, 9, 44),

	(10, 10, 100),
	(11, 10, 120),
	(12, 10, 90),

	(13, 11, 75),
	(14, 11, 85),
	(15, 11, 65),

	(16, 12, 55),
	(16, 13, 45),

	(17, 12, 50),
	(17, 13, 40),
	
	(18, 12, 40),
	(18, 13, 20),

	(19, 14, 30),
	(20, 14, 25),
	(21, 14, 45);


/*
	The only notable thing here is that some of the vendors have amusing names.
*/

INSERT INTO Vendors (VendorName, VendorContactFName, VendorContactLName, VendorPhone,
	VendorEmail, VendorState, VendorCity, VendorZipCode)
VALUES
	('Ultimate Beef and Pork Plus', 'Laura', 'Hammond', '513-629-0753',
		'bensonultimate@bsc.com', 'OH', 'Cincinnati', '45237'),
	('Willy''s Fish Hut', 'Emma', 'King', '784-451-2314',
		'willyfish@gmail.com', 'IN', 'Kokomo', '45787'),
	('Jerry''s Raw Poultry Over Shellfish', 'Gabrielle', 'Baggins', NULL,
		NULL, 'KY', 'Covington', '45269'),
	('Cassandra, Alexa, and Eggplants', 'Melinda', 'Franklin', '513-623-4577',
		NULL, 'OH', 'Cincinnati', '45230'),
	('Crooked Larry Liquore Store', 'Megan', 'Fox', '513-222-5555',
		'crookedlarry@yahoo.com', NULL, NULL, NULL),
	('Jessica''s Ohio Beer and Wine', 'Jessica', 'Greyhame', NULL,
		NULL, 'OH', 'Dayton', '45123'),
	('Rebecca and Chicken Delux Supplier', 'Rebecca', 'Brandybuck', '421-451-7819',
		'rebeccachicken66@gmail.com', 'KY', 'Lexington', '45222');

-- This is a small family owned business with only one employee
INSERT INTO Employees (FirstName, LastName, Position, HourlyPay) 
VALUES
	('Jimbo', 'Higgins', 'dishwasher', 12.25);


/*
	I decided that I want to add a column to Invoices called InvoiceTotal
	Because that would simplify future queries. 
*/
ALTER TABLE Invoices
ADD InvoiceTotal MONEY;

UPDATE Invoices
SET InvoiceTotal = CASE InvoiceID
	WHEN 1 THEN 698.85
	WHEN 2 THEN 426.95
	WHEN 3 THEN 775.25
	WHEN 4 THEN 145.80
	WHEN 5 THEN 199.28
	WHEN 6 THEN 152.41
	WHEN 7 THEN 539.40
	WHEN 8 THEN 301.00
	WHEN 9 THEN 425.59
	WHEN 10 THEN 107.00
	WHEN 11 THEN 128.40
	WHEN 12 THEN 96.30
	WHEN 13 THEN 150.00
	WHEN 14 THEN 170.00
	WHEN 15 THEN 130.00
	WHEN 16 THEN 122.50
	WHEN 17 THEN 110.00
	WHEN 18 THEN 70.00
	WHEN 19 THEN 39.60
	WHEN 20 THEN 33.00
	WHEN 21 THEN 59.40
	ELSE NULL
END;

/*
	I decided that I want to remove the InvoiceItemsID from InvoiceItems
	because I can't think of a single reason why I would ever need it.
	It is an identity primary key, so I had to use google to figure out
	the riddle.
*/
-- I figured out I had to find the actual name of the primary key itself to remove the primary key on this column.
-- I Found the proper way to reference the key using this code, but and I changed the name of the key in the UI.
EXEC sp_fkeys 'InvoiceItems';

--Column is no longer a primary key
ALTER TABLE InvoiceItems
DROP CONSTRAINT PK_Trouble;

-- The pointless column is gone.
ALTER TABLE InvoiceItems DROP COLUMN InvoiceItemsID;

SELECT * FROM InvoiceItems;
SELECT * FROM Employees;

-- They fired their only employee
DELETE FROM Employees
WHERE EmployeeID = 1;

/*
	A new vendor is offering to supply produce but they failed to provide
	And contact information. 
*/

INSERT INTO Vendors (VendorName, VendorContactFName, VendorContactLName, VendorPhone,
	VendorEmail, VendorState, VendorCity, VendorZipCode)
VALUES
	('King Tomato Produce', NULL, NULL, NULL,
	 NULL, NULL, NULL, NULL);

/*
	*************************************************************************
	                             QUERIES
	*************************************************************************
*/

/*
   This list shows the net sales for each item over the whole month.
   Somebody might want this in ascending order to analyze poor 
   menu performers
*/
SELECT ItemName, CONVERT(VARCHAR,SUM(ItemMenuPrice * QuantityOfItemSold), 1) 
	AS NetSalesPerItemInSeptember
FROM Items JOIN DailyItemSales
	ON Items.ItemID = DailyItemSales.ItemID
GROUP BY ItemName
ORDER BY SUM(ItemMenuPrice * QuantityOfItemSold) ASC;

-- This table shows how much of each category is sold in the whole month
SELECT ItemCategory, SUM(QuantityOfItemSold) AS TotalSoldInSeptember
FROM Items JOIN DailyItemSales
	ON Items.ItemID = DailyItemSales.ItemID
GROUP BY ItemCategory
ORDER BY TotalSoldInSeptember DESC;

-- This shows the 10 most expensive invoices of the month
SELECT TOP 10 VendorName, InvoiceDate, InvoiceTotal
FROM Vendors JOIN Invoices
	ON Vendors.VendorID = Invoices.VendorID
ORDER BY InvoiceTotal DESC;

-- This shows which vendors sell poultry
SELECT DISTINCT VendorName, ItemCategory
FROM Vendors JOIN Items
	ON Items.VendorID = Vendors.VendorID
WHERE ItemCategory IN ('poultry');

-- Sales for the week of 9/12 - 9/18
SELECT SalesDate, SUM(ItemMenuPrice * QuantityOfItemSold) AS DailySales
FROM DailyItemSales JOIN Items
	ON DailyItemSales.ItemID = Items.ItemID
WHERE SalesDate BETWEEN '2022-09-12' AND '2022-09-18'
GROUP BY SalesDate
ORDER BY SalesDate;

SELECT DISTINCT VendorName, CONCAT(VendorContactFName, ' ', VendorContactLName) AS VendorContact,
	VendorPhone
FROM Vendors LEFT JOIN Items
	ON Vendors.VendorID = Items.VendorID
	--AND Vendors.VendorPhone IS NOT NULL
WHERE ItemCategory IN ('poultry');

/*
	A of which vendor to call, unless the contact
	information needs an update. If this were just a regular
	join statement, we wouldn't be able to see which
	food categories are comming from vendors without a 
	phone number.
*/
SELECT ItemCategory, VendorName, VendorContact, VendorPhone
FROM Items LEFT JOIN
	(SELECT VendorID, VendorName, CONCAT(VendorContactFName, ' ', VendorContactLName) AS VendorContact,
		VendorPhone
	FROM Vendors
	WHERE VendorPhone IS NOT NULL) AS Sub_Vendors	
		ON Sub_Vendors.VendorID = Items.VendorID	
GROUP BY ItemCategory, VendorName, VendorContact, VendorPhone
ORDER BY VendorPhone DESC;

/*
	This is a statement that shows when more than average was spent on an item in an invoice.
	I tried to use a CTE construction for this but I wasn't able to figure it out.
*/
SELECT InvoiceID, Main_InvoiceItems.ItemID, ItemVendorPrice * ItemQuantity AS InvoiceItemCost
FROM InvoiceItems AS Main_InvoiceItems JOIN Items
	ON Main_InvoiceItems.ItemID = Items.ItemID
WHERE ItemVendorPrice * ItemQuantity > 
	(SELECT AVG(SumItemInvoiceCost) AS AvgInvoiceItemCost
	 FROM
		(SELECT InvoiceID, InvoiceItems.ItemID, SUM(ItemVendorPrice * ItemQuantity) AS SumItemInvoiceCost
		 FROM InvoiceItems JOIN Items
			 ON InvoiceItems.ItemID = Items.ItemID
		 WHERE InvoiceItems.ItemID = Main_InvoiceItems.ItemID	
		 GROUP BY InvoiceID, InvoiceItems.ItemID) AS SumInvoiceItemCosts
	 GROUP BY ItemID)
ORDER BY InvoiceID;

/*
 This list shows who to email if there is an issue with a product.
*/
SELECT ItemName, ItemCategory, VendorEmail
FROM Vendors RIGHT JOIN Items
	ON Items.VendorID = Vendors.VendorID

-- Here is a count of all invoices for the month
SELECT COUNT(*) AS TotalNumberOfInvoices
FROM Invoices;

-- Here is a count of all the vendor phone numbers on file
SELECT COUNT(VendorPhone) AS TotalNumberOfPhoneRecords
FROM Vendors;











		 





	

	



