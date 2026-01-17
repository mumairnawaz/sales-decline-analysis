IF DB_ID(N'SalesDW') IS NULL
BEGIN
    CREATE DATABASE SalesDW;
    PRINT 'Created database SalesDW';
END
ELSE
    PRINT 'Database SalesDW already exists';
GO

USE SalesDW;
GO

-- Step 2: Create a staging schema to store raw CSV data
IF NOT EXISTS (
    SELECT 1 
    FROM sys.schemas 
    WHERE name = N'stg'
)
BEGIN
    EXEC('CREATE SCHEMA stg');
    PRINT 'Schema stg created.';
END
ELSE
    PRINT 'Schema stg already exists.';
GO




-- Step 3: Create staging tables for raw CSV import

-- Drop if exist (safe for re-runs)
IF OBJECT_ID('stg.stg_dim_customer') IS NOT NULL DROP TABLE stg.stg_dim_customer;
IF OBJECT_ID('stg.stg_dim_product') IS NOT NULL DROP TABLE stg.stg_dim_product;
IF OBJECT_ID('stg.stg_fact_sales') IS NOT NULL DROP TABLE stg.stg_fact_sales;

-- stg_dim_customer (raw customer CSV)
CREATE TABLE stg.stg_dim_customer (
    Customer_ID VARCHAR(MAX),
    Age VARCHAR(MAX),
    Gender VARCHAR(MAX),
    City VARCHAR(MAX),
	State VARCHAR(MAX),
    purchase_count VARCHAR(MAX),
    Loyalty_Tier VARCHAR(MAX)
);

-- stg_dim_product (raw product CSV)
CREATE TABLE stg.stg_dim_product (
    Product_Category VARCHAR(MAX)
);

-- stg_fact_sales (raw sales CSV)
CREATE TABLE stg.stg_fact_sales (
    Order_ID VARCHAR(MAX),
    Customer_ID VARCHAR(MAX),
    [Date] VARCHAR(MAX),
    Product_Category VARCHAR(MAX),
    Unit_Price VARCHAR(MAX),
    Quantity VARCHAR(MAX),
    Discount_Amount VARCHAR(MAX),
    Total_Amount VARCHAR(MAX),
    Payment_Method VARCHAR(MAX),
    Device_Type VARCHAR(MAX),
    Session_Duration_Minutes VARCHAR(MAX),
    Pages_Viewed VARCHAR(MAX),
    Is_Returning_Customer VARCHAR(MAX),
    Delivery_Time_Days VARCHAR(MAX),
    Customer_Rating VARCHAR(MAX),
    Revenue VARCHAR(MAX),
    Return_Flag VARCHAR(MAX),
    Order_Status VARCHAR(MAX),
    Cost_Price VARCHAR(MAX),
    Gross_Profit VARCHAR(MAX),
    Profit_Margin_Pc VARCHAR(MAX),
    Year VARCHAR(MAX),
    Month VARCHAR(MAX),
    MonthName VARCHAR(MAX),
    Quarter VARCHAR(MAX),
    [Week] VARCHAR(MAX),
    DayOfWeek VARCHAR(MAX),
    IsWeekend VARCHAR(MAX),
    Month_Year VARCHAR(MAX),
    Weekday_Number VARCHAR(MAX),
    Delivery_Speed_Category VARCHAR(MAX),
    Effective_Discount_Pc VARCHAR(MAX),
    Markup_Pct VARCHAR(MAX),
    Return_Loss VARCHAR(MAX),
    Other_Extra_Info VARCHAR(MAX)
);
GO
