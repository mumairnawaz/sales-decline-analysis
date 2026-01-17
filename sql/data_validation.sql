--Customers validation 

SELECT COUNT(*) AS missing_customer_key
FROM stg.stg_dim_customer
WHERE Customer_ID IS NULL OR RTRIM(LTRIM(Customer_ID)) = '';

SELECT Customer_ID, COUNT(*) AS cnt
FROM stg.stg_dim_customer
WHERE Customer_ID IS NOT NULL AND RTRIM(LTRIM(Customer_ID)) <> ''
GROUP BY Customer_ID
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

SELECT ISNULL(RTRIM(LTRIM(Gender)),'<blank>') AS Gender, COUNT(*) AS cnt
FROM stg.stg_dim_customer
GROUP BY ISNULL(RTRIM(LTRIM(Gender)),'<blank>')
ORDER BY cnt DESC;

SELECT ISNULL(RTRIM(LTRIM(Loyalty_Tier)),'<blank>') AS Loyalty_Tier, COUNT(*) AS cnt
FROM stg.stg_dim_customer
GROUP BY ISNULL(RTRIM(LTRIM(Loyalty_Tier)),'<blank>')
ORDER BY cnt DESC;
GO


--Product validation 


SELECT COUNT(*) AS missing_product_key
FROM stg.stg_dim_product
WHERE Product_Category IS NULL OR RTRIM(LTRIM(Product_Category)) = '';

SELECT Product_Category, COUNT(*) AS cnt
FROM stg.stg_dim_product
WHERE Product_Category IS NOT NULL AND RTRIM(LTRIM(Product_Category)) <> ''
GROUP BY Product_Category
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

SELECT DISTINCT RTRIM(LTRIM(Product_Category)) AS Product_Category
FROM stg.stg_dim_product
WHERE Product_Category IS NOT NULL
ORDER BY Product_Category;
GO


-- Sales basic checks 

SELECT 
  SUM(CASE WHEN Order_ID IS NULL OR RTRIM(LTRIM(Order_ID)) = '' THEN 1 ELSE 0 END) AS missing_order_id,
  SUM(CASE WHEN Customer_ID IS NULL OR RTRIM(LTRIM(Customer_ID)) = '' THEN 1 ELSE 0 END) AS missing_customer_id,
  SUM(CASE WHEN Product_Category IS NULL OR RTRIM(LTRIM(Product_Category)) = '' THEN 1 ELSE 0 END) AS missing_product_category
FROM stg.stg_fact_sales;

SELECT TOP(20) RTRIM(LTRIM(Customer_ID)) AS Customer_ID, COUNT(*) AS cnt
FROM stg.stg_fact_sales
GROUP BY RTRIM(LTRIM(Customer_ID))
ORDER BY cnt DESC;

SELECT TOP(20) RTRIM(LTRIM(Product_Category)) AS Product_Category, COUNT(*) AS cnt
FROM stg.stg_fact_sales
GROUP BY RTRIM(LTRIM(Product_Category))
ORDER BY cnt DESC;
GO



--Sales date validation

SELECT
  SUM(CASE WHEN TRY_CAST([Date] AS DATE) IS NOT NULL THEN 1 ELSE 0 END) AS parseable_dates,
  SUM(CASE WHEN [Date] IS NULL OR RTRIM(LTRIM([Date])) = '' THEN 1 ELSE 0 END) AS null_blank_dates,
  SUM(CASE WHEN TRY_CAST([Date] AS DATE) IS NULL AND NOT ([Date] IS NULL OR RTRIM(LTRIM([Date])) = '') THEN 1 ELSE 0 END) AS bad_format_dates
FROM stg.stg_fact_sales;

SELECT TOP(50) [Date], COUNT(*) AS cnt
FROM stg.stg_fact_sales
WHERE [Date] IS NOT NULL AND RTRIM(LTRIM([Date])) <> '' AND TRY_CAST([Date] AS DATE) IS NULL
GROUP BY [Date]
ORDER BY cnt DESC;
GO


BLOCK 6 — Numeric field validation (Unit_Price, Quantity, Total_Amount)

-- NUMERIC VALIDATION

SELECT 
  SUM(CASE WHEN TRY_CAST(Unit_Price AS DECIMAL(18,2)) IS NOT NULL THEN 1 END) AS unit_price_ok,
  SUM(CASE WHEN TRY_CAST(Unit_Price AS DECIMAL(18,2)) IS NULL THEN 1 END) AS unit_price_bad
FROM stg.stg_fact_sales

SELECT 
  SUM(CASE WHEN TRY_CAST(Quantity AS INT) IS NOT NULL THEN 1 END) AS quantity_ok,
  SUM(CASE WHEN TRY_CAST(Quantity AS INT) IS NULL THEN 1 END) AS quantity_bad
FROM stg.stg_fact_sales;

SELECT 
  SUM(CASE WHEN TRY_CAST(Total_Amount AS DECIMAL(18,2)) IS NOT NULL THEN 1 END) AS total_ok,
  SUM(CASE WHEN TRY_CAST(Total_Amount AS DECIMAL(18,2)) IS NULL THEN 1 END) AS total_bad
FROM stg.stg_fact_sales;



SELECT TOP 20
    Order_ID,
    Quantity,
    Unit_Price,
    Discount_Amount,
    Total_Amount,
    (TRY_CAST(Unit_Price AS DECIMAL(18,2)) * TRY_CAST(Quantity AS INT))
       - TRY_CAST(Discount_Amount AS DECIMAL(18,2)) AS expected_total,
    TRY_CAST(Total_Amount AS DECIMAL(18,2)) AS actual_total
FROM stg.stg_fact_sales
WHERE 
    TRY_CAST(Unit_Price AS DECIMAL(18,2)) IS NOT NULL
    AND TRY_CAST(Quantity AS INT) IS NOT NULL
    AND TRY_CAST(Total_Amount AS DECIMAL(18,2)) IS NOT NULL
    AND ABS(
        ((TRY_CAST(Unit_Price AS DECIMAL(18,2)) * TRY_CAST(Quantity AS INT))
        - TRY_CAST(Discount_Amount AS DECIMAL(18,2)))
        -
        TRY_CAST(Total_Amount AS DECIMAL(18,2))
    ) > 1  
ORDER BY 1;



SELECT
  SUM(CASE WHEN TRY_CAST(Unit_Price AS DECIMAL(18,2)) <= 0 THEN 1 ELSE 0 END) AS unitprice_zero_or_negative,
  SUM(CASE WHEN TRY_CAST(Total_Amount AS DECIMAL(18,2)) <= 0 THEN 1 ELSE 0 END) AS total_zero_or_negative
FROM stg.stg_fact_sales
WHERE TRY_CAST(Unit_Price AS DECIMAL(18,2)) IS NOT NULL OR TRY_CAST(Total_Amount AS DECIMAL(18,2)) IS NOT NULL;


SELECT SUM(TRY_CAST(Total_Amount AS DECIMAL(18,2))) AS stg_total_amount, COUNT(*) AS stg_rows
FROM stg.stg_fact_sales;

SELECT COUNT(DISTINCT RTRIM(LTRIM(Customer_ID))) AS distinct_customers_in_sales FROM stg.stg_fact_sales;
SELECT COUNT(DISTINCT RTRIM(LTRIM(Product_Category))) AS distinct_products_in_sales FROM stg.stg_fact_sales;