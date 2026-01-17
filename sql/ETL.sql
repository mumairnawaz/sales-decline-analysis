-- Loading data in production tables
SELECT * FROM stg.stg_dim_customer;
SELECT * FROM stg.stg_dim_product;
SELECT 'fact_sales'   AS table_name, COUNT(*) AS rows FROM stg.stg_fact_sales;




USE SalesDW;
GO

    CREATE TABLE dbo.customers (
        Customer_ID VARCHAR(50) PRIMARY KEY,
        Age INT NULL,
        Gender VARCHAR(20) NULL,
        City VARCHAR(100) NULL,
		State VARCHAR(100) NULL,
        Purchase_Count INT NULL,
        Loyalty_Tier VARCHAR(50) NULL,
        CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
)

--Insert distinct cleaned customers from staging

INSERT INTO dbo.customers (Customer_ID, Age, Gender, City, Purchase_Count, Loyalty_Tier)
SELECT DISTINCT
    RTRIM(LTRIM(Customer_ID)) AS Customer_ID,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Age)),'') AS INT) AS Age,
    NULLIF(RTRIM(LTRIM(Gender)),'') AS Gender,
    NULLIF(RTRIM(LTRIM(City)),'') AS City,
    TRY_CAST(NULLIF(RTRIM(LTRIM(purchase_count)),'') AS INT) AS Purchase_Count,
    NULLIF(RTRIM(LTRIM(Loyalty_Tier)),'') AS Loyalty_Tier
FROM stg.stg_dim_customer s
WHERE RTRIM(LTRIM(s.Customer_ID)) <> ''
  AND RTRIM(LTRIM(s.Customer_ID)) IS NOT NULL
  AND RTRIM(LTRIM(s.Customer_ID)) NOT IN (SELECT Customer_ID FROM dbo.customers);



USE SalesDW;
 CREATE TABLE dbo.product_category (
        Product_Category VARCHAR(150) PRIMARY KEY
    );


-- Insert distinct cleaned categories from stg_dim_product
INSERT INTO dbo.product_category (Product_Category)
SELECT DISTINCT RTRIM(LTRIM(Product_Category)) AS Product_Category
FROM stg.stg_dim_product
WHERE RTRIM(LTRIM(Product_Category)) <> ''
  AND RTRIM(LTRIM(Product_Category)) NOT IN (SELECT Product_Category FROM dbo.product_category);
GO


 CREATE TABLE dbo.sales (
        Sales_ID INT IDENTITY(1,1) PRIMARY KEY,
        Order_ID VARCHAR(100) NULL,
        Customer_ID VARCHAR(50) NULL,
        Product_Category VARCHAR(150) NULL,
        Order_Date DATE NULL,
        Unit_Price DECIMAL(18,2) NULL,
        Quantity INT NULL,
        Discount_Amount DECIMAL(18,2) NULL,
        Total_Amount DECIMAL(18,2) NULL,
        Payment_Method VARCHAR(50) NULL,
        Device_Type VARCHAR(50) NULL,
        Session_Duration_Minutes INT NULL,
        Pages_Viewed INT NULL,
        Is_Returning_Customer BIT NULL,
        Delivery_Time_Days INT NULL,
        Customer_Rating INT NULL,
        Revenue DECIMAL(18,2) NULL,
        Sales_Channel VARCHAR(100) NULL,
        Shipping_Cost DECIMAL(18,2) NULL,
        Return_Flag BIT NULL,
        Order_Status VARCHAR(50) NULL,
        Cost_Price DECIMAL(18,2) NULL,
        Gross_Profit DECIMAL(18,2) NULL,
        Profit_Margin_Pc DECIMAL(9,4) NULL,
        [Year] INT NULL,
        [Month] INT NULL,
        MonthName VARCHAR(20) NULL,
        Quarter INT NULL,
        [Week] INT NULL,
        DayOfWeek VARCHAR(20) NULL,
        IsWeekend BIT NULL,
        Month_Year VARCHAR(20) NULL,
        Weekday_Number INT NULL,
        Delivery_Speed_Category VARCHAR(50) NULL,
        Effective_Discount_Pc DECIMAL(9,4) NULL,
        Markup_Pct DECIMAL(9,4) NULL,
        Return_Loss DECIMAL(18,2) NULL
    );


	INSERT INTO dbo.sales (
    Order_ID, Customer_ID, Product_Category, Order_Date,
    Unit_Price, Quantity, Discount_Amount, Total_Amount,
    Payment_Method, Device_Type, Session_Duration_Minutes, Pages_Viewed,
    Is_Returning_Customer, Delivery_Time_Days, Customer_Rating, Revenue,
    Sales_Channel, Shipping_Cost, Return_Flag, Order_Status,
    Cost_Price, Gross_Profit, Profit_Margin_Pc, [Year], [Month], MonthName,
    Quarter, [Week], DayOfWeek, IsWeekend, Month_Year, Weekday_Number,
    Delivery_Speed_Category, Effective_Discount_Pc, Markup_Pct, Return_Loss
)
SELECT
    RTRIM(LTRIM(Order_ID)) AS Order_ID,
    RTRIM(LTRIM(Customer_ID)) AS Customer_ID,
    RTRIM(LTRIM(Product_Category)) AS Product_Category,
    TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) AS Order_Date,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Unit_Price)),'') AS DECIMAL(18,2)) AS Unit_Price,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Quantity)),'') AS INT) AS Quantity,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Discount_Amount)),'') AS DECIMAL(18,2)) AS Discount_Amount,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Total_Amount)),'') AS DECIMAL(18,2)) AS Total_Amount,
    NULLIF(RTRIM(LTRIM(Payment_Method)),'') AS Payment_Method,
    NULLIF(RTRIM(LTRIM(Device_Type)),'') AS Device_Type,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Session_Duration_Minutes)),'') AS INT) AS Session_Duration_Minutes,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Pages_Viewed)),'') AS INT) AS Pages_Viewed,
    CASE 
      WHEN LOWER(ISNULL(RTRIM(LTRIM(Is_Returning_Customer)),'0')) IN ('true','1','yes','y') THEN 1
      WHEN LOWER(RTRIM(LTRIM(Is_Returning_Customer))) IN ('false','0','no','n') THEN 0
      ELSE NULL END AS Is_Returning_Customer,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Delivery_Time_Days)),'') AS INT) AS Delivery_Time_Days,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Customer_Rating)),'') AS INT) AS Customer_Rating,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Revenue)),'') AS DECIMAL(18,2)) AS Revenue,
    NULLIF(RTRIM(LTRIM(Sales_Channel)),'') AS Sales_Channel,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Shipping_Cost)),'') AS DECIMAL(18,2)) AS Shipping_Cost,
    CASE 
      WHEN LOWER(ISNULL(RTRIM(LTRIM(Return_Flag)),'0')) IN ('true','1','yes','y') THEN 1
      WHEN LOWER(RTRIM(LTRIM(Return_Flag))) IN ('false','0','no','n') THEN 0
      ELSE NULL END AS Return_Flag,
    NULLIF(RTRIM(LTRIM(Order_Status)),'') AS Order_Status,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Cost_Price)),'') AS DECIMAL(18,2)) AS Cost_Price,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Gross_Profit)),'') AS DECIMAL(18,2)) AS Gross_Profit,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Profit_Margin_Pc)),'') AS DECIMAL(9,4)) AS Profit_Margin_Pc,
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL THEN DATEPART(YEAR, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) ELSE NULL END AS [Year],
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL THEN DATEPART(MONTH, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) ELSE NULL END AS [Month],
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL THEN DATENAME(MONTH, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) ELSE NULL END AS MonthName,
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL THEN DATEPART(QUARTER, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) ELSE NULL END AS Quarter,
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL THEN DATEPART(WEEK, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) ELSE NULL END AS [Week],
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL THEN DATENAME(WEEKDAY, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) ELSE NULL END AS DayOfWeek,
    CASE WHEN TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE) IS NOT NULL AND DATEPART(WEEKDAY, TRY_CAST(NULLIF(RTRIM(LTRIM([Date])),'') AS DATE)) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend,
    NULLIF(RTRIM(LTRIM(Month_Year)),'') AS Month_Year,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Weekday_Number)),'') AS INT) AS Weekday_Number,
    NULLIF(RTRIM(LTRIM(Delivery_Speed_Category)),'') AS Delivery_Speed_Category,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Effective_Discount_Pc)),'') AS DECIMAL(9,4)) AS Effective_Discount_Pc,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Markup_Pct)),'') AS DECIMAL(9,4)) AS Markup_Pct,
    TRY_CAST(NULLIF(RTRIM(LTRIM(Return_Loss)),'') AS DECIMAL(18,2)) AS Return_Loss
FROM stg.stg_fact_sales s
WHERE RTRIM(LTRIM(s.Order_ID)) <> '' OR RTRIM(LTRIM(s.Customer_ID)) <> '' OR RTRIM(LTRIM(s.Product_Category)) <> '';
GO


-- Foreign Key: sales ? customers
ALTER TABLE dbo.sales
ADD CONSTRAINT FK_sales_customer
FOREIGN KEY (Customer_ID)
REFERENCES dbo.customers(Customer_ID);
GO

--Foreign Key: sales ? product_category
ALTER TABLE dbo.sales
ADD CONSTRAINT FK_sales_product_category
FOREIGN KEY (Product_Category)
REFERENCES dbo.product_category(Product_Category);
GO

UPDATE dbo.sales
SET Effective_Discount_Pc = TRY_CAST(REPLACE(REPLACE(RTRIM(LTRIM(s.Effective_Discount_Pc)),'%',''),',','') AS DECIMAL(9,4))
FROM stg.stg_fact_sales s
WHERE dbo.sales.Order_ID = s.Order_ID
  AND s.Effective_Discount_Pc IS NOT NULL
  AND dbo.sales.Effective_Discount_Pc IS NULL;



UPDATE s
SET s.Effective_Discount_Pc =
        TRY_CAST(
            REPLACE(
                REPLACE(RTRIM(LTRIM(t.Effective_Discount_Pc)), '%', ''),
            ',', '')  -- remove commas too
        AS DECIMAL(9,2)),
    s.Markup_Pct =
        TRY_CAST(
            REPLACE(
                REPLACE(RTRIM(LTRIM(t.Markup_Pct)), '%', ''),
            ',', '')
        AS DECIMAL(9,2))
FROM dbo.sales s
JOIN stg.stg_fact_sales t
  ON RTRIM(LTRIM(s.Order_ID)) = RTRIM(LTRIM(t.Order_ID))
WHERE 
    (
        s.Effective_Discount_Pc IS NULL
        AND t.Effective_Discount_Pc IS NOT NULL
        AND RTRIM(LTRIM(t.Effective_Discount_Pc)) <> ''
    )
    OR
    (
        s.Markup_Pct IS NULL
        AND t.Markup_Pct IS NOT NULL
        AND RTRIM(LTRIM(t.Markup_Pct)) <> ''
    );

	ALTER TABLE dbo.sales
ALTER COLUMN Effective_Discount_Pc DECIMAL(9,2);
GO

ALTER TABLE dbo.sales
ALTER COLUMN Markup_Pct DECIMAL(9,2);
GO


CREATE INDEX IX_sales_customer ON dbo.sales(Customer_ID);
CREATE INDEX IX_sales_product ON dbo.sales(Product_Category);
CREATE INDEX IX_sales_orderdate ON dbo.sales(Order_Date);