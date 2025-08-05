USE hermira;
-- Show all records

SELECT * FROM ecomerce;

-- Unprofitable Products (Total Negative Profit Overall)
WITH product_profit AS (
    SELECT Product_Name, SUM(Profit) AS total_profit
    FROM ecomerce
    GROUP BY Product_Name
)
SELECT Product_Name, total_profit
FROM product_profit
WHERE total_profit < 0
ORDER BY total_profit ASC
LIMIT 10;



-- Unprofitable Categories 
 SELECT Category, ROUND(SUM(profit)) AS total_profit
 FROM ecomerce
 GROUP BY Category
 ORDER BY SUM(profit) DESC;
 
 
-- Unprofitable Region
SELECT Region, ROUND(SUM(profit)) AS total_profit
 FROM ecomerce
 GROUP BY Region
 ORDER BY total_profit DESC;
 
 
 -- Are there discounts that negatively impact profit margins?
SELECT 
    discount, 
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin -- Avoid Zero Divisions
FROM ecomerce
GROUP BY discount 
ORDER BY profit_margin ASC;


-- Which shipping modes result in the most delays?
SELECT 
   `Ship Mode`, 
   AVG(datediff(`Ship Date`,`Order Date`)) AS avg_shipping_delay
FROM ecomerce
GROUP BY `Ship Mode`
ORDER BY avg_shipping_delay DESC;

SELECT * FROM ecomerce;


-- What % of products are returned and how does this affect profits?
-- Step 1: Return Rate (%) and Count
SELECT 
  Returned, 
  COUNT(*) AS total_returns,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM ecomerce), 2) AS percent_of_orders
FROM ecomerce
GROUP BY Returned
ORDER BY percent_of_orders DESC;

--  Step 2: How Returns Affect Profits
SELECT 
    Returned,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    COUNT(*) AS num_orders
FROM ecomerce
GROUP BY Returned
ORDER BY total_profit;


-- Are certain customer segments or product categories more likely to return products?
-- 1. Return Rate by Customer Segment
SELECT 
   Segment,
   COUNT(*) AS total_orders,
   SUM(Returned) As returned_orders,
   ROUND(100* SUM(Returned)/COUNT(*),2) AS return_rate
FROM ecomerce
GROUP BY Segment
ORDER BY return_rate  DESC;


-- 2. Return Rate by Product Category

SELECT 
   Category,
   COUNT(*) AS total_orders,
   SUM(Returned) As returned_orders,
   ROUND(100* SUM(Returned)/COUNT(*),2) AS return_rate
FROM ecomerce
GROUP BY Category
ORDER BY return_rate  DESC;

-- 3. By Customer Segment and Category Combo View
SELECT 
   Category, Segment,
   COUNT(*) AS total_orders,
   SUM(Returned) As returned_orders,
   ROUND(100* SUM(Returned)/COUNT(*),2) AS return_rate
FROM ecomerce
GROUP BY Category, Segment
ORDER BY return_rate  DESC;

-- Who are the top 10 customers by total purchases or lifetime value?
--  1. TOp 10 Customers by Total Purchases
SELECT 
    `Customer Name`,
    COUNT(*) AS total_purchases
FROM ecomerce
GROUP BY `Customer Name`
ORDER BY total_purchases DESC
LIMIT 10;


-- 2. Top 10 Customers by Total Sales
SELECT 
    `Customer Name`,
    ROUND(SUM(Sales),2) AS total_sales,
    ROUND(SUM(Profit) ,2) AS total_profit
FROM ecomerce
GROUP BY `Customer Name`
ORDER BY total_sales DESC
LIMIT 10;


-- Which customer segments are the most/least profitable?
-- 1. Top Customer Segments by Profit
SELECT
   Segment,
   ROUND(SUM(Profit), 2) AS total_profit
FROM ecomerce
GROUP BY Segment
ORDER BY total_profit DESC;

-- 2. Bottom Customer Segments by Profit
SELECT
   Segment,
   ROUND(SUM(Profit), 2) AS total_profit
FROM ecomerce
GROUP BY Segment
ORDER BY total_profit ASC;

-- What are the quarterly/monthly sales and profit trends over time?
-- 1. Monthly Sales & Profit Trends
SELECT
   DATE_FORMAT(`Order Date`, '%Y-%M') AS Month,
   ROUND(SUM(Sales),2) AS total_sales,
   ROUND(SUM(Profit), 2) AS total_profit
FROM ecomerce
GROUP BY Month
ORDER BY total_sales DESC;

-- 2. Quarterly Sales & Profit Trends
SELECT
   CONCAT(YEAR(`Order Date`), '-Q', QUARTER(`Order Date`)) AS quarter,
   ROUND(SUM(Sales),2) AS total_sales,
   ROUND(SUM(Profit), 2) AS total_profit
FROM ecomerce
GROUP BY quarter
ORDER BY total_sales DESC;

-- Create a view of dynamic KPIs like:
  -- Total Sales
  -- Total Profit
  -- Profit Margin %
  -- Return Rate
  -- Delivery Delay Rate

WITH Dynamic_KPIs AS(
SELECT
    YEAR(`Order Date`) AS Year,
    Segment,
    ROUND(SUM(Sales),2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit)/ NULLIF(SUM(Sales),0) *100, 2) AS profit_margin_rate,
    ROUND(SUM(Returned)/COUNT(*) *100, 2) AS return_rate,
    ROUND(SUM(CASE
               WHEN DATEDIFF(`Ship Date`, `Order Date`) >0 THEN 1
               ELSE 0
               END ) /COUNT(*)*100, 2) AS delivery_delay_rate
FROM ecomerce
GROUP BY YEAR(`Order Date`), Segment
)
SELECT * FROM Dynamic_KPIs WHERE year = 2024 AND Segment = 'Consumer';




   
