--RetailPulse 360 — E-Commerce Intelligence System 
/*
**Q1 — Overall Business Summary**

What is the total revenue, total profit, overall profit margin percentage and total number of orders for KartZone India?

*/
SELECT 
    SUM(Final_Amount) AS total_revenue,
    SUM(Profit) AS total_profit,
    
    ROUND(
        (SUM(Profit) * 100.0) / NULLIF(SUM(Final_Amount),0),
        2
    ) AS overall_profit_margin_pct,
    
    COUNT(Order_ID) AS total_orders,
     ROUND(SUM(Is_Returned) * 100.0 / COUNT(*), 2)            AS Return_Rate_Pct,
    ROUND(SUM(Is_Cancelled) * 100.0 / COUNT(*), 2)           AS Cancellation_Rate_Pct,
    SUM(Is_Loss_Order)                                       AS Loss_Making_Orders
FROM Orders;



/**Q2 — Monthly Revenue Trend**

Show the revenue and profit for each month across both years. Which months had the highest revenue?
*/

SELECT 
    FORMAT(CAST(Order_Date AS DATE),'yyyy-MM') AS order_month,
    
    SUM(Final_Amount) AS total_revenue,
    
    SUM(Profit) AS total_profit

FROM Orders

GROUP BY FORMAT(CAST(Order_Date AS DATE),'yyyy-MM')

ORDER BY order_month;



/**Q3 — Month over Month Growth**

What is the revenue for each month and how much did it grow or decline compared to the previous month in absolute value?
*/

WITH Monthly AS (
    SELECT
        YEAR(Order_Date)                    AS Order_Year,
        MONTH(Order_Date)                   AS Order_Month,
        ROUND(SUM(Final_Amount), 2)         AS Monthly_Revenue
    FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT
    Order_Year,
    Order_Month,
    Monthly_Revenue,
    LAG(Monthly_Revenue) OVER (ORDER BY Order_Year, Order_Month)  AS Prev_Month_Revenue,
    ROUND(
        Monthly_Revenue -
        LAG(Monthly_Revenue) OVER (ORDER BY Order_Year, Order_Month)
    , 2)                                                           AS Revenue_Change,
    ROUND(
        (Monthly_Revenue - LAG(Monthly_Revenue) OVER (ORDER BY Order_Year, Order_Month))
        * 100.0 /
        NULLIF(LAG(Monthly_Revenue) OVER (ORDER BY Order_Year, Order_Month), 0)
    , 2)                                                           AS Growth_Pct
FROM Monthly
ORDER BY Order_Year, Order_Month;



/**Q4 — Category Performance**

Which product category generates the highest revenue, highest profit and highest return rate? Show all three metrics together.

*/

SELECT 
    Category,
    
    SUM(Final_Amount) AS total_revenue,
    
    SUM(Profit) AS total_profit,
        ROUND(SUM(Is_Returned) * 100.0 / COUNT(*), 2)            AS Return_Rate_Pct

FROM Orders
GROUP BY Category
ORDER BY total_revenue DESC;



/**Q5 — Top 10 Profitable Products**

Which are the top 10 products by total profit? Show product name, category, total orders, total revenue and total profit.

*/
WITH ProductSummary AS (
    SELECT
        o.Product_ID,
        COUNT(*)                            AS Total_Orders,
        ROUND(SUM(o.Final_Amount), 2)       AS Total_Revenue,
        ROUND(SUM(o.Profit), 2)             AS Total_Profit,
        ROUND(SUM(o.Profit)*100.0/SUM(o.Final_Amount), 2) AS Margin_Pct
    FROM Orders o
    GROUP BY o.Product_ID
)
SELECT TOP 10
    ps.Product_ID,
    ISNULL(p.Product_Name, 'Product Not in Catalog') AS Product_Name,
    ISNULL(p.Category, o_cat.Category)               AS Category,
    ISNULL(p.Brand, 'Unknown')                        AS Brand,
    ps.Total_Orders,
    ps.Total_Revenue,
    ps.Total_Profit,
    ps.Margin_Pct
FROM ProductSummary ps
LEFT JOIN Products p ON ps.Product_ID = p.Product_ID
LEFT JOIN (
    SELECT DISTINCT Product_ID, Category FROM Orders
) o_cat ON ps.Product_ID = o_cat.Product_ID
ORDER BY ps.Total_Profit DESC;



/**Q6 — Bottom 10 Loss Making Products**

Which 10 products are causing the most loss? Show product name, total orders placed and total loss amount.

*/
WITH ProductLoss AS (
    SELECT
        o.Product_ID,
        ISNULL(p.Product_Name, 'Product Not in Catalog') AS Product_Name,
        ISNULL(p.Category, o.Category)                   AS Category,
        COUNT(*)                                          AS Total_Orders,
        ROUND(SUM(o.Profit), 2)                          AS Total_Profit_Loss,
        SUM(o.Is_Loss_Order)                             AS Loss_Order_Count,
        DENSE_RANK() OVER (ORDER BY SUM(o.Profit) ASC)   AS Loss_Rank
    FROM Orders o
    LEFT JOIN Products p ON o.Product_ID = p.Product_ID
    GROUP BY o.Product_ID, p.Product_Name, p.Category, o.Category
    HAVING SUM(o.Profit) < 0
)
SELECT TOP 10
    Product_ID,
    Product_Name,
    Category,
    Total_Orders,
    Total_Profit_Loss,
    Loss_Order_Count,
    Loss_Rank
FROM ProductLoss
ORDER BY Total_Profit_Loss ASC;



/**Q7 — Discount Impact on Profit**

Classify orders into discount ranges — 0%, 1-10%, 11-20%, 21-30%, above 30%. For each range show average profit margin and count of loss making orders.

*/

WITH DiscountBands AS (
    SELECT *,
        CASE
            WHEN Discount_Pct = 0            THEN '0%'
            WHEN Discount_Pct <= 10          THEN '1-10%'
            WHEN Discount_Pct <= 20          THEN '11-20%'
            WHEN Discount_Pct <= 30          THEN '21-30%'
            ELSE 'Above 30%'
        END AS Discount_Range,
        CASE
            WHEN Discount_Pct = 0            THEN 1
            WHEN Discount_Pct <= 10          THEN 2
            WHEN Discount_Pct <= 20          THEN 3
            WHEN Discount_Pct <= 30          THEN 4
            ELSE 5
        END AS Sort_Order
    FROM Orders
)
SELECT
    Discount_Range,
    COUNT(*)                                                 AS Total_Orders,
    ROUND(AVG(Profit_Margin_Pct), 2)                        AS Avg_Profit_Margin,
    SUM(Is_Loss_Order)                                       AS Loss_Order_Count,
    ROUND(SUM(Is_Loss_Order) * 100.0 / COUNT(*), 2)         AS Loss_Rate_Pct,
    ROUND(AVG(Final_Amount), 2)                             AS Avg_Order_Value
FROM DiscountBands
GROUP BY Discount_Range, Sort_Order
ORDER BY Sort_Order;



/**Q8 — Customer Segmentation by Revenue**

Divide customers into 4 equal groups based on their total spending — Top 25%, Upper Middle, Lower Middle, Bottom 25%. How much revenue does each group contribute?

*/

WITH CustomerSpend AS (
    SELECT
        Customer_ID,
        ROUND(SUM(Final_Amount), 2)  AS Total_Spending,
        COUNT(*)                      AS Total_Orders
    FROM Orders
    GROUP BY Customer_ID
),
CustomerTile AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY Total_Spending DESC) AS Spending_Tile
    FROM CustomerSpend
)
SELECT
    CASE Spending_Tile
        WHEN 1 THEN 'Top 25% — High Value'
        WHEN 2 THEN 'Upper Middle 25%'
        WHEN 3 THEN 'Lower Middle 25%'
        WHEN 4 THEN 'Bottom 25% — Low Value'
    END                                              AS Customer_Segment,
    COUNT(*)                                         AS Customer_Count,
    ROUND(SUM(Total_Spending), 2)                   AS Segment_Revenue,
    ROUND(SUM(Total_Spending) * 100.0 /
        SUM(SUM(Total_Spending)) OVER (), 2)         AS Revenue_Contribution_Pct,
    ROUND(AVG(Total_Spending), 2)                   AS Avg_Customer_Spend,
    ROUND(AVG(CAST(Total_Orders AS FLOAT)), 1)      AS Avg_Orders_Per_Customer
FROM CustomerTile
GROUP BY Spending_Tile
ORDER BY Spending_Tile;




/**Q9 — City wise Performance**

Which city has the highest revenue, highest profit margin and highest cancellation rate? Show all cities ranked.

*/
SELECT
    City,
    COUNT(*)                                                 AS Total_Orders,
    ROUND(SUM(Final_Amount), 2)                             AS Total_Revenue,
    ROUND(SUM(Profit), 2)                                   AS Total_Profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Final_Amount), 2)       AS Profit_Margin_Pct,
    ROUND(SUM(Is_Cancelled) * 100.0 / COUNT(*), 2)          AS Cancellation_Rate_Pct,
    ROUND(SUM(Is_Returned) * 100.0 / COUNT(*), 2)           AS Return_Rate_Pct,
    ROUND(AVG(Final_Amount), 2)                             AS Avg_Order_Value,
    RANK() OVER (ORDER BY SUM(Final_Amount) DESC)           AS Revenue_Rank
FROM Orders
GROUP BY City
ORDER BY Total_Revenue DESC;





/**Q10 — Payment Mode Analysis**

Which payment mode has the highest average order value and which has the highest cancellation rate? Are COD orders really more likely to be cancelled?

*/

SELECT 
    Payment_Mode,

    COUNT(*) AS total_orders,

    ROUND(AVG(Final_Amount),2) AS avg_order_value,

    SUM(Is_Cancelled) AS cancelled_orders,

    ROUND(
        SUM(Is_Cancelled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct

FROM Orders

GROUP BY Payment_Mode

ORDER BY cancellation_rate_pct DESC;




/**Q11 — Delivery Partner Performance**

Compare all delivery partners by on-time delivery rate, average delay days, average customer rating and average delivery cost. Rank them best to worst.

*/

WITH PartnerStats AS (
    SELECT
        d.Delivery_Partner,
        COUNT(*)                                              AS Total_Deliveries,
        ROUND(SUM(d.On_Time_Flag) * 100.0 / COUNT(*), 2)    AS OnTime_Rate_Pct,
        ROUND(AVG(CAST(d.Delay_Days AS FLOAT)), 2)           AS Avg_Delay_Days,
        ROUND(AVG(d.Customer_Rating), 2)                     AS Avg_Customer_Rating,
        ROUND(AVG(d.Delivery_Cost), 2)                       AS Avg_Delivery_Cost,
        SUM(d.Is_Failed)                                     AS Failed_Deliveries,
        ROUND(SUM(d.Is_Failed) * 100.0 / COUNT(*), 2)       AS Failure_Rate_Pct
    FROM Deliveries d
    GROUP BY d.Delivery_Partner
)
SELECT *,
    RANK() OVER (ORDER BY OnTime_Rate_Pct DESC)              AS Overall_Rank,
    CASE
        WHEN OnTime_Rate_Pct >= 60  THEN 'BEST'
        WHEN OnTime_Rate_Pct >= 30  THEN 'AVERAGE'
        ELSE 'WORST'
    END                                                      AS Performance_Label
FROM PartnerStats
ORDER BY Overall_Rank;



/**Q12 — Festive vs Non Festive Season**

Compare revenue, profit margin, return rate and average order value between festive season orders and non festive season orders.

*/

SELECT
    CASE Is_Festive_Season
        WHEN 1 THEN 'Festive Season (Oct-Dec)'
        ELSE 'Non Festive Season'
    END                                                      AS Season,
    COUNT(*)                                                 AS Total_Orders,
    ROUND(SUM(Final_Amount), 2)                             AS Total_Revenue,
    ROUND(SUM(Final_Amount) * 100.0 /
        SUM(SUM(Final_Amount)) OVER (), 2)                   AS Revenue_Share_Pct,
    ROUND(SUM(Profit) * 100.0 / SUM(Final_Amount), 2)       AS Profit_Margin_Pct,
    ROUND(SUM(Is_Returned) * 100.0 / COUNT(*), 2)           AS Return_Rate_Pct,
    ROUND(AVG(Final_Amount), 2)                             AS Avg_Order_Value,
    ROUND(SUM(Is_Cancelled) * 100.0 / COUNT(*), 2)          AS Cancellation_Rate_Pct
FROM Orders
GROUP BY Is_Festive_Season
ORDER BY Is_Festive_Season DESC;



/**Q13 — Running Total of Revenue**

Show the cumulative running total of revenue month by month. At the end of which month did KartZone cross 50% of its annual revenue?

*/

WITH Monthly AS (
    SELECT
        YEAR(Order_Date)                    AS Order_Year,
        MONTH(Order_Date)                   AS Order_Month,
        ROUND(SUM(Final_Amount), 2)         AS Monthly_Revenue
    FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
),
WithRunning AS (
    SELECT
        Order_Year,
        Order_Month,
        Monthly_Revenue,
        -- Running total for all time
        SUM(Monthly_Revenue) OVER (
            ORDER BY Order_Year, Order_Month
        )                                                    AS Running_Total_All,
        -- Running total within each year (to find 50% crossover)
        SUM(Monthly_Revenue) OVER (
            PARTITION BY Order_Year
            ORDER BY Order_Month
        )                                                    AS Running_Total_Year,
        -- Annual total for comparison
        SUM(Monthly_Revenue) OVER (
            PARTITION BY Order_Year
        )                                                    AS Annual_Total
    FROM Monthly
)
SELECT *,
    ROUND(Running_Total_Year * 100.0 / Annual_Total, 2)     AS Cumulative_Pct_Of_Year,
    -- Flag the month where 50% is crossed
    CASE
        WHEN Running_Total_Year >= Annual_Total * 0.50
         AND LAG(Running_Total_Year) OVER (
             PARTITION BY Order_Year ORDER BY Order_Month
         ) < Annual_Total * 0.50
        THEN 'CROSSED 50% HERE'
        ELSE ''
    END                                                      AS Milestone
FROM WithRunning
ORDER BY Order_Year, Order_Month;



/**Q14 — At Risk Customer Identification**

Find all customers who have not placed any order in the last 90 days but had placed at least 3 orders before that. Show their customer segment and total lifetime value.
*/

WITH CustomerHistory AS (
    SELECT
        Customer_ID,
        COUNT(*)                            AS Total_Orders,
        MAX(Order_Date)                     AS Last_Order_Date,
        ROUND(SUM(Final_Amount), 2)         AS Lifetime_Value
    FROM Orders
    GROUP BY Customer_ID
    HAVING COUNT(*) >= 3
),
AtRisk AS (
    SELECT *
    FROM CustomerHistory
    WHERE DATEDIFF(DAY, Last_Order_Date, GETDATE()) > 90
)
SELECT
    a.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment,
    c.City,
    c.Registration_Source,
    a.Total_Orders,
    a.Last_Order_Date,
    DATEDIFF(DAY, a.Last_Order_Date, GETDATE())  AS Days_Since_Last_Order,
    a.Lifetime_Value
FROM AtRisk a
LEFT JOIN Customers c ON a.Customer_ID = c.Customer_ID
ORDER BY a.Lifetime_Value DESC;


/**Q15 — Department Risk Classification**

Using a CTE — classify each product category as HIGH RISK, MEDIUM RISK or LOW RISK based on the following logic —
- HIGH RISK — return rate above 20% AND profit margin below 15%
- MEDIUM RISK — either return rate above 20% OR profit margin below 15%
- LOW RISK — neither condition*/


    WITH CategoryMetrics AS (
    SELECT
        Category,
        COUNT(*)                                            AS Total_Orders,
        ROUND(SUM(Final_Amount), 2)                         AS Total_Revenue,
        ROUND(SUM(Profit), 2)                               AS Total_Profit,

        ROUND(
            SUM(Profit) * 100.0 /
            NULLIF(SUM(Final_Amount),0),
            2
        ) AS Profit_Margin_Pct,

        ROUND(
            SUM(Is_Returned) * 100.0 /
            COUNT(*),
            2
        ) AS Return_Rate_Pct,

        SUM(Is_Loss_Order)                                  AS Loss_Orders,

        ROUND(AVG(Discount_Pct), 2)                         AS Avg_Discount_Pct

    FROM Orders
    GROUP BY Category
)

SELECT *,

    CASE
        WHEN Return_Rate_Pct > 20
             AND Profit_Margin_Pct < 15
            THEN 'HIGH RISK'

        WHEN Return_Rate_Pct > 20
             OR Profit_Margin_Pct < 15
            THEN 'MEDIUM RISK'

        ELSE 'LOW RISK'
    END AS Risk_Level,

    CASE
        WHEN Return_Rate_Pct > 20
             AND Profit_Margin_Pct < 15
            THEN 'Both return rate and margin are problematic'

        WHEN Return_Rate_Pct > 20
            THEN 'High return rate — check delivery and quality'

        WHEN Profit_Margin_Pct < 15
            THEN 'Low margin — check discount strategy'

        ELSE 'Category is performing well'
    END AS Risk_Reason

FROM CategoryMetrics

ORDER BY
    CASE
        WHEN Return_Rate_Pct > 20
             AND Profit_Margin_Pct < 15
            THEN 1

        WHEN Return_Rate_Pct > 20
             OR Profit_Margin_Pct < 15
            THEN 2

        ELSE 3
    END;

