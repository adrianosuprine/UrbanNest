--Shows all the data
SELECT * 
FROM clean_orders;

--Hightings the completely blanks.non-null rows with no data....for select.. delete deletes the blanks
SELECT * 
FROM clean_orders
WHERE COALESCE(OrderID, '')=''
	AND COALESCE(OrderDate, '')=''
	AND COALESCE(CustomerID, '')=''
	AND COALESCE(ProductID, '')=''
	AND COALESCE(Channel, '')=''
	AND COALESCE(Quantity, '')=''
	AND COALESCE(UnitPrice_KES, '')=''
	AND COALESCE(DiscountPct, '')=''
	AND COALESCE(PaymentMethod , '')=''
	AND COALESCE(OrderStatus, '')=''
	AND COALESCE(ShippingDays , '')='' ;

--Deletes the blank.non-null rows with no data....for select.. delete deletes the blanks
DELETE 
FROM clean_orders
WHERE COALESCE(OrderID, '')=''
	AND COALESCE(OrderDate, '')=''
	AND COALESCE(CustomerID, '')=''
	AND COALESCE(ProductID, '')=''
	AND COALESCE(Channel, '')=''
	AND COALESCE(Quantity, '')=''
	AND COALESCE(UnitPrice_KES, '')=''
	AND COALESCE(DiscountPct, '')=''
	AND COALESCE(PaymentMethod , '')=''
	AND COALESCE(OrderStatus, '')=''
	AND COALESCE(ShippingDays , '')='' ;

--Standardizing the OrderDate Column
SELECT OrderDate AS original,
    CASE
        WHEN OrderDate LIKE '__/__/____'
            THEN substr(OrderDate,7,4) || '-' || substr(OrderDate,4,2) || '-' || substr(OrderDate,1,2)
        WHEN OrderDate LIKE '____-__-__ __:__:__'
            THEN substr(OrderDate,1,10)
        WHEN OrderDate LIKE '____/__/__'
        	THEN substr(OrderDate,1,4) || '-' || substr(OrderDate,6,2) || '-' || substr(OrderDate,9,2)
        WHEN OrderDate LIKE '__-___-____'
            THEN substr(OrderDate,8,4) || '-' ||
                 printf('%02d', (instr('JanFebMarAprMayJunJulAugSepOctNovDec', substr(OrderDate,4,3)) - 1) / 3 + 1)
                 || '-' || substr(OrderDate,1,2)
        ELSE OrderDate
    END AS standardized
FROM clean_orders;

UPDATE clean_orders
SET OrderDate = CASE
        WHEN OrderDate LIKE '__/__/____'
            THEN substr(OrderDate,7,4) || '-' || substr(OrderDate,4,2) || '-' || substr(OrderDate,1,2)
        WHEN OrderDate LIKE '____-__-__ __:__:__'
            THEN substr(OrderDate,1,10)
        WHEN OrderDate LIKE '____/__/__'
        	THEN substr(OrderDate,1,4) || '-' || substr(OrderDate,6,2) || '-' || substr(OrderDate,9,2)
        WHEN OrderDate LIKE '__-___-____'
            THEN substr(OrderDate,8,4) || '-' ||
                 printf('%02d', (instr('JanFebMarAprMayJunJulAugSepOctNovDec', substr(OrderDate,4,3)) - 1) / 3 + 1)
                 || '-' || substr(OrderDate,1,2)
        ELSE OrderDate
    END;

--Checking Invalid Qunatity Entries
SELECT *
FROM clean_orders
WHERE Quantity <= 0
ORDER BY Quantity;

--Updating the quantities below zero to their absolute values, as an assumption of invalid negative data entry errors.
SELECT Quantity, ABS(Quantity) AS new_quantity, *
FROM clean_orders
WHERE Quantity < 0;

UPDATE clean_orders 
SET Quantity = ABS(Quantity)
WHERE Quantity < 0;

--Deleting those of zero quantity of ,1% of the data 
DELETE FROM clean_orders WHERE Quantity = 0;
--Looking into non-distinct orderIds looking in to the details 
SELECT OrderID, COUNT(*) as record_count,
COUNT(DISTINCT StoreID) AS store_count
FROM clean_orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

--Two records that appear with duplicates but with different store_id that dont seem to be in the main store data source
Finding the records whose store_id do not exist in the stores table ,......
SELECT o.* 
FROM clean_orders AS o 
LEFT JOIN stores AS s
	ON o.StoreID = s.StoreID
WHERE s.StoreID IS NULL;

SELECT *
FROM clean_orders
WHERE OrderID = "O006193";

SELECT *
FROM clean_orders
WHERE OrderID = "O007019";



--Duplicates , the COUNT shows both/all occurrences of duplicates
SELECT *
FROM (
    SELECT
        *,
        COUNT(*) OVER (
            PARTITION BY OrderID, OrderDate, CustomerID, ProductID, StoreID ,
                         Channel, Quantity, UnitPrice_KES, DiscountPct ,PaymentMethod , ShippingDays,
                        OrderStatus
        ) AS duplicate_count
    FROM clean_orders
) ranked
WHERE duplicate_count > 1
ORDER BY OrderID;

--Duplicates using cte..... shows occurences that should be deleted
WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID, OrderDate, CustomerID, ProductID, StoreID ,
                         Channel, Quantity, UnitPrice_KES, DiscountPct ,PaymentMethod , ShippingDays,
                        OrderStatus ) AS row_num
FROM clean_orders )
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

--WITH duplicate_cte AS (
--SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID, OrderDate, CustomerID, ProductID, StoreID ,
--                         Channel, Quantity, UnitPrice_KES, DiscountPct ,PaymentMethod , ShippingDays,
--                        OrderStatus ) AS row_num
--FROM clean_orders )
--DELETE
--FROM duplicate_cte
--WHERE row_num > 1;

SELECT *
FROM clean_orders
WHERE OrderID = "O007019";

CREATE TABLE clean_orders_st2 (
    OrderID TEXT,
    OrderDate TEXT,
    CustomerID TEXT,
    ProductID TEXT,
    StoreID TEXT,
    Channel TEXT,
    Quantity INTEGER,
    UnitPrice_KES REAL,
    DiscountPct REAL,
    PaymentMethod TEXT,
    OrderStatus TEXT,
    ShippingDays INTEGER,
    row_num INTEGER
   
);
SELECT * 
FROM clean_orders_st2;

INSERT INTO clean_orders_st2
SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID, OrderDate, CustomerID, ProductID, StoreID ,
                         Channel, Quantity, UnitPrice_KES, DiscountPct ,PaymentMethod , ShippingDays,
                        OrderStatus ) AS row_num
FROM clean_orders;
SELECT * FROM clean_orders_st2
WHERE row_num > 1;
DELETE FROM clean_orders_st2
WHERE row_num > 1;


--Standadizing the relevant columns 
UPDATE clean_orders
SET OrderID = TRIM(OrderID), 
OrderDate = TRIM(OrderDate), 
CustomerID = TRIM(CustomerID), 
ProductID = TRIM(ProductID), 
StoreID = TRIM(StoreID),                    
Channel = TRIM(Channel), 
Quantity = TRIM(Quantity), 
UnitPrice_KES = TRIM(UnitPrice_KES ), 
DiscountPct = TRIM(DiscountPct ),
PaymentMethod = TRIM(PaymentMethod ), 
ShippingDays = TRIM(ShippingDays ),                   
OrderStatus = TRIM(OrderStatus);




SELECT DISTINCT StoreID , COUNT()
FROM clean_orders;

--Standadize OrderStatus column
SELECT DISTINCT OrderStatus 
FROM clean_orders;

UPDATE clean_orders
SET OrderStatus = 
    CASE
        WHEN OrderStatus LIKE '%ancel%' THEN 'Canceled'
        WHEN OrderStatus LIKE '%complete%' THEN 'Completed'
        WHEN OrderStatus LIKE '%eturn%' THEN 'Returned'
        ELSE OrderStatus
    END;

--Standadize Paymentmethod column
SELECT DISTINCT PaymentMethod  
FROM clean_orders;

UPDATE clean_orders
SET PaymentMethod = PROPER(TRIM(PaymentMethod));

--Completely updates the table and standardize the column
UPDATE clean_orders
SET PaymentMethod = 
    CASE
        WHEN PaymentMethod LIKE '%airtel%' THEN 'Airtel Money'
        WHEN PaymentMethod LIKE '%m-pesa%' 
          OR PaymentMethod LIKE '%m pesa%' 
          OR PaymentMethod LIKE '%mpesa%' THEN 'M-Pesa'
        WHEN PaymentMethod LIKE '%credit/debit%' THEN 'Credit/Debit Card'
        WHEN PaymentMethod LIKE '%credit%' THEN 'Credit Card'
        WHEN PaymentMethod LIKE '%debit%' THEN 'Debit Card'
        WHEN PaymentMethod LIKE '%card%' THEN 'Card'
        WHEN PaymentMethod LIKE '%bank%' THEN 'Bank Transfer'
        WHEN PaymentMethod LIKE '%cash%' THEN 'Cash'
        ELSE PaymentMethod
    END;

SELECT PaymentMethod, COUNT(*)
FROM clean_orders
GROUP BY PaymentMethod;

SELECT PaymentMethod ,COUNT(*) 
FROM clean_orders
WHERE  PaymentMethod IS NULL;

SELECT ProductID , COUNT(*)
FROM clean_orders
WHERE COALESCE(OrderID, CustomerID, ProductID ,StoreID ,PaymentMethod ) IS NULL;

--WHERE CLAUSE ... helps filter the rows data
--Logical operators - AND, OR 
SELECT *
FROM clean_orders
WHERE (Channel = "In-Store" AND Quantity > 3) OR UnitPrice_KES > 100000;

--Sorts the data by date
SELECT * 
FROM clean_orders
ORDER BY OrderDate;

--Groups the data by the channel. When grouping if its not an aggregate function, the select column has to match the groupby .. so the select ..groupby ...
SELECT Channel, AVG (Quantity),MAX(Quantity), MIN(Quantity), COUNT(Quantity )
FROM clean_orders
GROUP BY Channel;






