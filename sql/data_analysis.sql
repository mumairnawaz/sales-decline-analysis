---DATA NALYSIS QUERIES:
--1 query 
SELECT 
  (SELECT COUNT(*) FROM dbo.customers) AS customers_count,
  (SELECT COUNT(*) FROM dbo.product_category) AS product_categories_count,
  (SELECT COUNT(*) FROM dbo.sales) AS sales_count;

 -- 2) Total revenue and avg order value (AOV)

  SELECT 
  SUM(Total_Amount) AS Total_revenue,
  AVG(Total_Amount) AS Avg_order_value,
  COUNT(*) AS orders
FROM dbo.sales;



--3 Revenue by Product Category (top categories)
SELECT p.Product_Category, 
       COUNT(*) AS orders,
       SUM(s.Total_Amount) AS revenue,
       AVG(s.Total_Amount) AS aov
FROM dbo.sales s
JOIN dbo.product_category p ON s.Product_Category = p.Product_Category
GROUP BY p.Product_Category
ORDER BY revenue DESC;


--4 Monthly revenue trend (time series)
SELECT [Year], [Month], 
       CONCAT([Year], '-', RIGHT('0'+CAST([Month] AS VARCHAR(2)),2)) AS year_month,
       SUM(Total_Amount) AS revenue
FROM dbo.sales
GROUP BY [Year], [Month]
ORDER BY [Year], [Month];


--5 Top 20 customers by revenue

SELECT s.Customer_ID,
       SUM(s.Total_Amount) AS lifetime_revenue,
       COUNT(*) AS orders,
       AVG(s.Total_Amount) AS avg_order_value
FROM dbo.sales s
GROUP BY s.Customer_ID
ORDER BY lifetime_revenue DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;


--6 Repeat purchase rate 


WITH c AS (
    SELECT Customer_ID, COUNT(*) AS orders
    FROM dbo.sales
    GROUP BY Customer_ID
)
SELECT 
    SUM(CASE WHEN orders BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS low_freq_customers,
    SUM(CASE WHEN orders BETWEEN 6 AND 20 THEN 1 ELSE 0 END) AS medium_freq_customers,
    SUM(CASE WHEN orders > 20 THEN 1 ELSE 0 END) AS high_freq_customers
FROM c;


--07 RFM buckets (simple) — Recency (last order), Frequency, Monetary

WITH last AS (
  SELECT Customer_ID,
         MAX(Order_Date) AS last_order_date,
         COUNT(*) AS frequency,
         SUM(Total_Amount) AS monetary
  FROM dbo.sales
  GROUP BY Customer_ID
)
SELECT Customer_ID,
       DATEDIFF(DAY, last_order_date, GETDATE()) AS recency_days,
       frequency,
       monetary
FROM last
ORDER BY monetary DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


select  * from sales
where customer_id='CUST_01573'

--08  Customer Acquisition Cohort — First Purchase by Month

WITH first_buy AS (
    SELECT 
        Customer_ID,
        MIN(Order_Date) AS first_buy
    FROM dbo.sales
    GROUP BY Customer_ID
)
SELECT 
    YEAR(first_buy) AS cohort_year,
    MONTH(first_buy) AS cohort_month,

    CONCAT(
        YEAR(first_buy), '-', 
        RIGHT('0' + CAST(MONTH(first_buy) AS VARCHAR(2)), 2)
    ) AS cohort_year_month,

    COUNT(*) AS new_customers
FROM first_buy
GROUP BY 
    YEAR(first_buy),
    MONTH(first_buy)
ORDER BY 
    YEAR(first_buy),
    MONTH(first_buy);


--09) Orders by day of week (demand pattern)

SELECT DayOfWeek, COUNT(*) AS orders, SUM(Total_Amount) AS revenue
FROM dbo.sales
GROUP BY DayOfWeek
ORDER BY CASE DayOfWeek
  WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
  WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 WHEN 'Sunday' THEN 7
  ELSE 8 END;


  --10) Channel performance (Sales_Channel)

  SELECT Sales_Channel, COUNT(*) AS orders, SUM(Total_Amount) AS revenue, AVG(Total_Amount) AS aov
FROM dbo.sales
GROUP BY Sales_Channel
ORDER BY revenue DESC;


--11) Device type vs conversion proxy (session metrics)

SELECT Device_Type,
       COUNT(*) AS orders,
       AVG(Session_Duration_Minutes) AS avg_session_mins,
       AVG(Pages_Viewed) AS avg_pages
FROM dbo.sales
GROUP BY Device_Type
ORDER BY orders DESC;

--12) Returns analysis (Return_Flag)

SELECT 
  SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) AS returns_count,
  CAST(100.0 * SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(6,2)) AS return_rate_pct,
  SUM(CASE WHEN Return_Flag = 1 THEN Total_Amount ELSE 0 END) AS return_value
FROM dbo.sales;


--13) Impact of discount on conversion / order value


SELECT 
  CASE WHEN Discount_Amount > 0 THEN 'Discounted' ELSE 'Non-Discounted' END AS bucket,
  COUNT(*) AS orders,
  SUM(Total_Amount) AS revenue,
  AVG(Total_Amount) AS avg_order_value
FROM dbo.sales
GROUP BY CASE WHEN Discount_Amount > 0 THEN 'Discounted' ELSE 'Non-Discounted' END;


--14) Profitability by category (gross profit margin)

SELECT p.Product_Category,
       SUM(s.Gross_Profit) AS gross_profit,
       SUM(s.Total_Amount) AS revenue,
       CASE WHEN SUM(s.Total_Amount) = 0 THEN NULL
            ELSE CAST(SUM(s.Gross_Profit) * 100.0 / SUM(s.Total_Amount) AS DECIMAL(6,2)) END AS profit_margin_pct
FROM dbo.sales s
JOIN dbo.product_category p ON s.Product_Category = p.Product_Category
GROUP BY p.Product_Category
ORDER BY profit_margin_pct DESC;


--15) Delivery speed vs returns (do slow deliveries increase returns?)

SELECT Delivery_Speed_Category,
       COUNT(*) AS orders,
       SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) AS returns,
       CAST(100.0 * SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(6,2)) AS return_rate_pct
FROM dbo.sales
GROUP BY Delivery_Speed_Category
ORDER BY return_rate_pct DESC;


--16) Average days to delivery vs satisfaction (Customer_Rating)

SELECT AVG(Delivery_Time_Days) AS avg_delivery_days,
       AVG(Customer_Rating) AS avg_rating,
       COUNT(*) AS orders
FROM dbo.sales
GROUP BY Delivery_Time_Days
ORDER BY avg_delivery_days;

--17) Time-series decomposition idea (monthly seasonality + trend)

SELECT CONCAT([Year], '-', RIGHT('0' + CAST([Month] AS VARCHAR(2)),2)) AS year_month,
       SUM(Total_Amount) AS revenue
FROM dbo.sales
GROUP BY [Year], [Month]
ORDER BY year_month;


--18) Churn proxy: customers with last purchase > X days

WITH last AS (
  SELECT Customer_ID, MAX(Order_Date) AS last_order
  FROM dbo.sales
  GROUP BY Customer_ID
)
SELECT COUNT(*) AS customers_in_churn_window
FROM last
WHERE DATEDIFF(DAY, last_order, GETDATE()) > 365; 



--19) Simple predictive feature: correlation between session duration and order value


SELECT
  AVG(Session_Duration_Minutes) AS avg_session_mins,
  AVG(Total_Amount) AS avg_order_value
FROM dbo.sales
GROUP BY CAST(Session_Duration_Minutes/5 AS INT)  -- bucket every 5 minutes
ORDER BY CAST(Session_Duration_Minutes/5 AS INT);


--20) Anomaly detection: very large returns or refunds

SELECT TOP(50) Order_ID, Customer_ID, Total_Amount, Return_Loss
FROM dbo.sales
WHERE Return_Loss > 0
ORDER BY Return_Loss DESC;

select distinct(city) from customers
group by city


--21 State Wise Data
SELECT 
    c.State,
    COUNT(*) AS orders,
    SUM(s.Total_Amount) AS revenue,
    AVG(s.Total_Amount) AS avg_order_value
FROM dbo.sales s
JOIN dbo.customers c 
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY revenue DESC;

--22 City Wise Data

SELECT 
    c.City,
    c.State,
    COUNT(*) AS orders,
    SUM(s.Total_Amount) AS revenue
FROM dbo.sales s
JOIN dbo.customers c 
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.City, c.State
ORDER BY revenue DESC;

--23 Profit Margin by State
SELECT 
    c.State,
    SUM(s.Gross_Profit) AS gross_profit,
    SUM(s.Total_Amount) AS revenue,
    CAST(
        100.0 * SUM(s.Gross_Profit) / SUM(s.Total_Amount)
        AS DECIMAL(6,2)
    ) AS profit_margin_pct
FROM dbo.sales s
JOIN dbo.customers c 
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY profit_margin_pct DESC;


--24 Return Rate by State
SELECT 
    c.State,
    COUNT(*) AS orders,
    SUM(CASE WHEN s.Return_Flag = 1 THEN 1 ELSE 0 END) AS returns,
    CAST(
        100.0 * SUM(CASE WHEN s.Return_Flag = 1 THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS return_rate_pct
FROM dbo.sales s
JOIN dbo.customers c 
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY return_rate_pct DESC;

25--Delivery Speed Issues by State
SELECT 
    c.State,

    COUNT(*) AS slow_orders,

    SUM(CASE WHEN s.Delivery_Speed_Category <> 'Slow' THEN 1 ELSE 0 END) AS non_slow_orders,

    COUNT(*) 
    + SUM(CASE WHEN s.Delivery_Speed_Category <> 'Slow' THEN 1 ELSE 0 END)
        AS total_orders,

    CAST(
        100.0 * COUNT(*) /
        (
            COUNT(*) 
            + SUM(CASE WHEN s.Delivery_Speed_Category <> 'Slow' THEN 1 ELSE 0 END)
        )
        AS DECIMAL(6,2)
    ) AS slow_delivery_rate_pct

FROM dbo.sales s
JOIN dbo.customers c 
    ON s.Customer_ID = c.Customer_ID
WHERE s.Delivery_Speed_Category IN ('Slow','Fast','Medium')
GROUP BY c.State
ORDER BY slow_delivery_rate_pct DESC;

--26 Discount Dependency by State

SELECT 
    c.State,
    SUM(CASE WHEN s.Discount_Amount > 0 THEN 1 ELSE 0 END) AS discounted_orders,
    COUNT(*) AS total_orders,
    CAST(
        100.0 * SUM(CASE WHEN s.Discount_Amount > 0 THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(6,2)
    ) AS discount_penetration_pct
FROM dbo.sales s
JOIN dbo.customers c 
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY discount_penetration_pct DESC;
