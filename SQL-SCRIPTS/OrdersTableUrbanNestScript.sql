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

--Checks for disctinct values on Channel column
SELECT DISTINCT OrderID  
FROM clean_orders;

SELECT PaymentMethod ,COUNT(*) 
FROM clean_orders
WHERE  PaymentMethod IS NULL;

SELECT ProductID , COUNT(*)
FROM clean_orders
WHERE COALESCE(OrderID, CustomerID, ProductID ,StoreID ,PaymentMethod ) IS NULL;

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

WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID, OrderDate, CustomerID, ProductID, StoreID ,
                         Channel, Quantity, UnitPrice_KES, DiscountPct ,PaymentMethod , ShippingDays,
                        OrderStatus ) AS row_num
FROM clean_orders )
DELETE
FROM duplicate_cte
WHERE row_num > 1;

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
SELECT * FROM clean_orders_st2;
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
--Standadize OrderStatus column
UPDATE clean_orders
SET OrderStatus = 
    CASE
        WHEN OrderStatus LIKE '%ancel%' THEN 'Canceled'
        WHEN OrderStatus LIKE '%complete%' THEN 'Completed'
        WHEN OrderStatus LIKE '%eturn%' THEN 'Returned'
        ELSE OrderStatus
    END;

SELECT OrderStatus , COUNT(*)
FROM clean_orders
GROUP BY OrderStatus;

--Standadize Paymentmethod column
UPDATE clean_orders
SET PaymentMethod = PROPER(TRIM(PaymentMethod));

SELECT PaymentMethod, COUNT(*)
FROM clean_orders
GROUP BY PaymentMethod;

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






