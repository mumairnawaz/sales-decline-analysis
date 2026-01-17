-- BULK INSERT all three CSVs into staging
USE SalesDW;
GO

IF OBJECT_ID('dbo.etl_error_log','U') IS NULL
BEGIN
    CREATE TABLE dbo.etl_error_log (
        err_id INT IDENTITY(1,1) PRIMARY KEY,
        step_name VARCHAR(100),
        err_message VARCHAR(4000),
        err_time DATETIME2 DEFAULT SYSUTCDATETIME()
    );
END
GO

-- Load dim_customer
BEGIN TRY
    BULK INSERT stg.stg_dim_customer
    FROM '\project_csvs\dim_customer.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',    -- UTF-8
        TABLOCK
    );
    PRINT 'Loaded dim_customer.csv';
END TRY
BEGIN CATCH
    INSERT INTO dbo.etl_error_log(step_name, err_message)
    VALUES ('BULK_INSERT_dim_customer', ERROR_MESSAGE());
    PRINT 'Error loading dim_customer.csv. Check etl_error_log for details.';
END CATCH;
GO

--  Load dim_product
BEGIN TRY
    BULK INSERT stg.stg_dim_product
    FROM '\project_csvs\dim_product.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Loaded dim_product.csv';
END TRY
BEGIN CATCH
    INSERT INTO dbo.etl_error_log(step_name, err_message)
    VALUES ('BULK_INSERT_dim_product', ERROR_MESSAGE());
    PRINT 'Error loading dim_product.csv. Check etl_error_log for details.';
END CATCH;
GO

delete  from stg.stg_dim_product



-- Load fact_sales
BEGIN TRY
    BULK INSERT stg.stg_fact_sales
    FROM '\project_csvs\fact_sales.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'Loaded fact_sales.csv';
END TRY
BEGIN CATCH
    INSERT INTO dbo.etl_error_log(step_name, err_message)
    VALUES ('BULK_INSERT_fact_sales', ERROR_MESSAGE());
    PRINT 'Error loading fact_sales.csv. Check etl_error_log for details.';
END CATCH;
GO

-- Quick verification
SELECT 'customer_rows' = COUNT(*) FROM stg.stg_dim_customer;

SELECT 'product_rows'  = COUNT(*) FROM stg.stg_dim_product;
SELECT 'sales_rows'    = COUNT(*) FROM stg.stg_fact_sales;

SELECT TOP(50) * FROM dbo.etl_error_log ORDER BY err_id DESC;
GO

