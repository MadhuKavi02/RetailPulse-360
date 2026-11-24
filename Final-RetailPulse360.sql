/*
RetailPulse 360 - SQL Analysis
Database: SQL Server
Dataset: Synthetic KartZone India e-commerce data

Tables used: Orders, Products, Customers, Deliveries
Queries: Q01-Q15


*/

-- Q01: OVERALL BUSINESS SUMMARY

SELECT
    COUNT(Order_ID) AS Total_Orders,

    -- All-status metrics
    ROUND(SUM(Final_Amount), 2) AS Total_Order_Value,

    ROUND(SUM(Profit), 2) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Final_Amount), 0),
        2
    ) AS Overall_Profit_Margin_Pct,

    -- Delivered-only metrics
    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Final_Amount ELSE 0
        END), 2
    ) AS Delivered_Sales,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END), 2
    ) AS Delivered_Profit,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END) * 100.0 /
        NULLIF(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 0
        ),
        2
    ) AS Delivered_Profit_Margin_Pct,

    -- Order performance metrics
    ROUND(
        SUM(Is_Returned) * 100.0 / COUNT(*),
        2
    ) AS Return_Rate_Pct,

    ROUND(
        SUM(Is_Cancelled) * 100.0 / COUNT(*),
        2
    ) AS Cancellation_Rate_Pct,

    SUM(Is_Loss_Order) AS Loss_Making_Orders

FROM Orders;

-- Q02: MONTHLY REVENUE TREND

SELECT
    FORMAT(CAST(Order_Date AS DATE), 'yyyy-MM') AS Order_Month,

    COUNT(*) AS Total_Orders,

    -- All-status metrics
    ROUND(SUM(Final_Amount), 2) AS Total_Order_Value,

    ROUND(SUM(Profit), 2) AS Total_Profit,

    -- Delivered-only metrics
    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Final_Amount ELSE 0
        END), 2
    ) AS Delivered_Sales,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END), 2
    ) AS Delivered_Profit

FROM Orders

GROUP BY
    FORMAT(CAST(Order_Date AS DATE), 'yyyy-MM')

ORDER BY
    Order_Month;

-- Q03: MONTH-OVER-MONTH REVENUE GROWTH

WITH MonthlyRevenue AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,

        -- All-status order value
        ROUND(SUM(Final_Amount), 2) AS Monthly_Order_Value,

        -- Delivered-only sales
        ROUND(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 2
        ) AS Monthly_Delivered_Sales

    FROM Orders

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),

MonthlyGrowth AS
(
    SELECT
        Order_Year,
        Order_Month,
        Monthly_Order_Value,
        Monthly_Delivered_Sales,

        LAG(Monthly_Delivered_Sales) OVER
        (
            ORDER BY Order_Year, Order_Month
        ) AS Previous_Month_Delivered_Sales

    FROM MonthlyRevenue
)

SELECT
    Order_Year,
    Order_Month,
    Monthly_Order_Value,
    Monthly_Delivered_Sales,
    Previous_Month_Delivered_Sales,

    ROUND(
        Monthly_Delivered_Sales - Previous_Month_Delivered_Sales,
        2
    ) AS Delivered_Sales_Change,

    ROUND(
        (Monthly_Delivered_Sales - Previous_Month_Delivered_Sales)
        * 100.0
        / NULLIF(Previous_Month_Delivered_Sales, 0),
        2
    ) AS Delivered_Sales_Growth_Pct

FROM MonthlyGrowth

ORDER BY
    Order_Year,
    Order_Month;

-- Q04: CATEGORY PERFORMANCE

SELECT
    Category,

    COUNT(*) AS Total_Orders,

    -- All-status metrics
    ROUND(SUM(Final_Amount), 2) AS Total_Order_Value,

    ROUND(SUM(Profit), 2) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Final_Amount), 0),
        2
    ) AS Overall_Profit_Margin_Pct,

    -- Delivered-only metrics
    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Final_Amount ELSE 0
        END), 2
    ) AS Delivered_Sales,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END), 2
    ) AS Delivered_Profit,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END) * 100.0 /
        NULLIF(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 0
        ),
        2
    ) AS Delivered_Profit_Margin_Pct,

    -- Return rate
    ROUND(
        SUM(Is_Returned) * 100.0 /
        COUNT(*),
        2
    ) AS Return_Rate_Pct

FROM Orders

GROUP BY
    Category

ORDER BY
    Delivered_Sales DESC;

-- Q05: TOP 10 PROFITABLE PRODUCTS

WITH ProductSummary AS
(
    SELECT
        o.Product_ID,

        COUNT(*) AS Total_Orders,

        -- All-status metrics
        ROUND(SUM(o.Final_Amount), 2) AS Total_Order_Value,

        ROUND(SUM(o.Profit), 2) AS Total_Profit,

        -- Delivered-only metrics
        ROUND(
            SUM(CASE
                WHEN o.Order_Status = 'Delivered'
                THEN o.Final_Amount ELSE 0
            END), 2
        ) AS Delivered_Sales,

        ROUND(
            SUM(CASE
                WHEN o.Order_Status = 'Delivered'
                THEN o.Profit ELSE 0
            END), 2
        ) AS Delivered_Profit,

        ROUND(
            SUM(CASE
                WHEN o.Order_Status = 'Delivered'
                THEN o.Profit ELSE 0
            END) * 100.0 /
            NULLIF(
                SUM(CASE
                    WHEN o.Order_Status = 'Delivered'
                    THEN o.Final_Amount ELSE 0
                END), 0
            ),
            2
        ) AS Delivered_Profit_Margin_Pct

    FROM Orders o

    GROUP BY
        o.Product_ID
)

SELECT TOP 10

    ps.Product_ID,

    ISNULL(p.Product_Name, 'Product Not in Catalog') AS Product_Name,

    ISNULL(p.Category, 'Unknown') AS Category,

    ISNULL(p.Brand, 'Unknown') AS Brand,

    ps.Total_Orders,

    ps.Total_Order_Value,

    ps.Total_Profit,

    ps.Delivered_Sales,

    ps.Delivered_Profit,

    ps.Delivered_Profit_Margin_Pct

FROM ProductSummary ps

LEFT JOIN Products p
    ON ps.Product_ID = p.Product_ID

ORDER BY
    ps.Delivered_Profit DESC;

-- Q06: BOTTOM 10 LOSS-MAKING PRODUCTS

WITH ProductLoss AS
(
    SELECT
        o.Product_ID,

        ISNULL(p.Product_Name, 'Product Not in Catalog')
            AS Product_Name,

        ISNULL(p.Category, o.Category)
            AS Category,

        COUNT(*) AS Total_Orders,

        SUM(o.Is_Loss_Order) AS Loss_Order_Count,

        ROUND(
            SUM(CASE
                WHEN o.Order_Status = 'Delivered'
                THEN o.Profit ELSE 0
            END), 2
        ) AS Delivered_Profit,

        SUM(CASE
            WHEN o.Order_Status = 'Delivered'
                 AND o.Profit < 0
            THEN 1 ELSE 0
        END) AS Delivered_Loss_Order_Count

    FROM Orders o

    LEFT JOIN Products p
        ON o.Product_ID = p.Product_ID

    GROUP BY
        o.Product_ID,
        p.Product_Name,
        p.Category,
        o.Category

    HAVING
        SUM(CASE
            WHEN o.Order_Status = 'Delivered'
            THEN o.Profit ELSE 0
        END) < 0
)

SELECT TOP 10

    Product_ID,
    Product_Name,
    Category,
    Total_Orders,
    Delivered_Profit,
    Loss_Order_Count,
    Delivered_Loss_Order_Count

FROM ProductLoss

ORDER BY
    Delivered_Profit ASC;

-- Q07: DISCOUNT IMPACT ON PROFIT

WITH DiscountBands AS
(
    SELECT
        *,

        CASE
            WHEN Discount_Pct = 0 THEN '0%'
            WHEN Discount_Pct <= 10 THEN '1-10%'
            WHEN Discount_Pct <= 20 THEN '11-20%'
            WHEN Discount_Pct <= 30 THEN '21-30%'
            ELSE 'Above 30%'
        END AS Discount_Range,

        CASE
            WHEN Discount_Pct = 0 THEN 1
            WHEN Discount_Pct <= 10 THEN 2
            WHEN Discount_Pct <= 20 THEN 3
            WHEN Discount_Pct <= 30 THEN 4
            ELSE 5
        END AS Sort_Order

    FROM Orders
)

SELECT
    Discount_Range,

    COUNT(*) AS Total_Orders,

    ROUND(AVG(Profit_Margin_Pct), 2)
        AS Avg_Order_Profit_Margin_Pct,

    SUM(Is_Loss_Order) AS Loss_Order_Count,

    ROUND(
        SUM(Is_Loss_Order) * 100.0 / COUNT(*),
        2
    ) AS Loss_Rate_Pct,

    ROUND(AVG(Final_Amount), 2)
        AS Avg_Order_Value

FROM DiscountBands

GROUP BY
    Discount_Range,
    Sort_Order

ORDER BY
    Sort_Order;

-- Q08: CUSTOMER SEGMENTATION BY REVENUE

WITH CustomerSpend AS
(
    SELECT
        Customer_ID,

        ROUND(SUM(Final_Amount), 2)
            AS Delivered_Spending,

        COUNT(*) AS Delivered_Orders

    FROM Orders

    WHERE Order_Status = 'Delivered'

    GROUP BY
        Customer_ID
),

CustomerTile AS
(
    SELECT
        *,

        NTILE(4) OVER
        (
            ORDER BY Delivered_Spending DESC
        ) AS Spending_Tile

    FROM CustomerSpend
)

SELECT

    CASE Spending_Tile
        WHEN 1 THEN 'Top 25% - High Value'
        WHEN 2 THEN 'Upper Middle 25%'
        WHEN 3 THEN 'Lower Middle 25%'
        WHEN 4 THEN 'Bottom 25% - Low Value'
    END AS Customer_Segment,

    COUNT(*) AS Customer_Count,

    ROUND(SUM(Delivered_Spending), 2)
        AS Delivered_Sales,

    ROUND(
        SUM(Delivered_Spending) * 100.0 /
        SUM(SUM(Delivered_Spending)) OVER (),
        2
    ) AS Sales_Contribution_Pct,

    ROUND(AVG(Delivered_Spending), 2)
        AS Avg_Customer_Spend,

    ROUND(
        AVG(CAST(Delivered_Orders AS FLOAT)),
        1
    ) AS Avg_Delivered_Orders_Per_Customer

FROM CustomerTile

GROUP BY
    Spending_Tile

ORDER BY
    Spending_Tile;

-- Q09: CITY-WISE PERFORMANCE

SELECT
    City,

    COUNT(*) AS Total_Orders,

    -- Delivered-only metrics
    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Final_Amount ELSE 0
        END), 2
    ) AS Delivered_Sales,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END), 2
    ) AS Delivered_Profit,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END) * 100.0 /
        NULLIF(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 0
        ), 2
    ) AS Delivered_Profit_Margin_Pct,

    -- All-status operational metrics
    ROUND(
        SUM(Is_Cancelled) * 100.0 / COUNT(*),
        2
    ) AS Cancellation_Rate_Pct,

    ROUND(
        SUM(Is_Returned) * 100.0 / COUNT(*),
        2
    ) AS Return_Rate_Pct,

    ROUND(
        AVG(CASE
            WHEN Order_Status = 'Delivered'
            THEN Final_Amount
        END), 2
    ) AS Avg_Delivered_Order_Value,

    RANK() OVER
    (
        ORDER BY
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END) DESC
    ) AS Delivered_Sales_Rank

FROM Orders

GROUP BY
    City

ORDER BY
    Delivered_Sales DESC;

-- Q10: PAYMENT MODE ANALYSIS

SELECT
    Payment_Mode,

    COUNT(*) AS Total_Orders,

    ROUND(
        AVG(Final_Amount),
        2
    ) AS Avg_Order_Value,

    SUM(Is_Cancelled) AS Cancelled_Orders,

    ROUND(
        SUM(Is_Cancelled) * 100.0 /
        COUNT(*),
        2
    ) AS Cancellation_Rate_Pct

FROM Orders

GROUP BY
    Payment_Mode

ORDER BY
    Cancellation_Rate_Pct DESC;

-- Q11: DELIVERY PARTNER PERFORMANCE

WITH PartnerStats AS
(
    SELECT
        Delivery_Partner,

        COUNT(*) AS Total_Deliveries,

        ROUND(
            SUM(On_Time_Flag) * 100.0 /
            COUNT(*),
            2
        ) AS OnTime_Rate_Pct,

        ROUND(
            AVG(CAST(Delay_Days AS FLOAT)),
            2
        ) AS Avg_Delay_Days,

        ROUND(
            AVG(Customer_Rating),
            2
        ) AS Avg_Customer_Rating,

        ROUND(
            AVG(Delivery_Cost),
            2
        ) AS Avg_Delivery_Cost,

        SUM(Is_Failed) AS Failed_Deliveries,

        ROUND(
            SUM(Is_Failed) * 100.0 /
            COUNT(*),
            2
        ) AS Failure_Rate_Pct

    FROM Deliveries

    GROUP BY
        Delivery_Partner
)

SELECT
    *,

    RANK() OVER
    (
        ORDER BY OnTime_Rate_Pct DESC
    ) AS Overall_Rank,

    CASE
        WHEN OnTime_Rate_Pct >= 60
            THEN 'BEST'

        WHEN OnTime_Rate_Pct >= 30
            THEN 'AVERAGE'

        ELSE 'WORST'
    END AS Performance_Label

FROM PartnerStats

ORDER BY
    Overall_Rank;

-- Q12: FESTIVE VS NON-FESTIVE SEASON

SELECT

    CASE
        WHEN Is_Festive_Season = 1
            THEN 'Festive Season (Oct-Dec)'
        ELSE 'Non-Festive Season'
    END AS Season,

    COUNT(*) AS Total_Orders,

    -- All-status metrics
    ROUND(SUM(Final_Amount), 2)
        AS Total_Order_Value,

    ROUND(
        SUM(Final_Amount) * 100.0 /
        SUM(SUM(Final_Amount)) OVER (),
        2
    ) AS Order_Value_Share_Pct,

    -- Delivered-only metrics
    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Final_Amount ELSE 0
        END), 2
    ) AS Delivered_Sales,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END), 2
    ) AS Delivered_Profit,

    ROUND(
        SUM(CASE
            WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0
        END) * 100.0 /
        NULLIF(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 0
        ),
        2
    ) AS Delivered_Profit_Margin_Pct,

    -- All-status operational metrics
    ROUND(
        SUM(Is_Returned) * 100.0 / COUNT(*),
        2
    ) AS Return_Rate_Pct,

    ROUND(AVG(Final_Amount), 2)
        AS Avg_Order_Value,

    ROUND(
        SUM(Is_Cancelled) * 100.0 / COUNT(*),
        2
    ) AS Cancellation_Rate_Pct

FROM Orders

GROUP BY
    Is_Festive_Season

ORDER BY
    Is_Festive_Season DESC;

-- Q13: RUNNING TOTAL OF REVENUE

WITH Monthly AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,

        ROUND(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 2
        ) AS Monthly_Delivered_Sales

    FROM Orders

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),

WithRunning AS
(
    SELECT
        Order_Year,
        Order_Month,
        Monthly_Delivered_Sales,

        -- Cumulative delivered sales across the dataset
        SUM(Monthly_Delivered_Sales) OVER
        (
            ORDER BY Order_Year, Order_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Total_Overall,

        -- Cumulative delivered sales within each year
        SUM(Monthly_Delivered_Sales) OVER
        (
            PARTITION BY Order_Year
            ORDER BY Order_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Total_Year,

        -- Annual delivered sales
        SUM(Monthly_Delivered_Sales) OVER
        (
            PARTITION BY Order_Year
        ) AS Annual_Total

    FROM Monthly
),

Final AS
(
    SELECT
        *,

        ROUND(
            Running_Total_Year * 100.0 /
            NULLIF(Annual_Total, 0),
            2
        ) AS Cumulative_Pct_Of_Year,

        LAG(Running_Total_Year) OVER
        (
            PARTITION BY Order_Year
            ORDER BY Order_Month
        ) AS Previous_Running_Total_Year

    FROM WithRunning
)

SELECT
    Order_Year,
    Order_Month,
    Monthly_Delivered_Sales,
    Running_Total_Overall,
    Running_Total_Year,
    Annual_Total,
    Cumulative_Pct_Of_Year,

    CASE
        WHEN Running_Total_Year >= Annual_Total * 0.50
             AND
             (
                 Previous_Running_Total_Year IS NULL
                 OR Previous_Running_Total_Year < Annual_Total * 0.50
             )
            THEN 'CROSSED 50% HERE'

        ELSE ''
    END AS Milestone

FROM Final

ORDER BY
    Order_Year,
    Order_Month;

-- Q14: AT-RISK CUSTOMER IDENTIFICATION

WITH DatasetEndDate AS
(
    SELECT
        MAX(CAST(Order_Date AS DATE)) AS Dataset_End_Date
    FROM Orders
),

CustomerHistory AS
(
    SELECT
        Customer_ID,

        COUNT(*) AS Total_Delivered_Orders,

        MAX(CAST(Order_Date AS DATE)) AS Last_Delivered_Order_Date,

        ROUND(SUM(Final_Amount), 2) AS Delivered_Lifetime_Value

    FROM Orders

    WHERE Order_Status = 'Delivered'

    GROUP BY
        Customer_ID

    HAVING
        COUNT(*) >= 3
),

AtRiskCustomers AS
(
    SELECT
        ch.Customer_ID,
        ch.Total_Delivered_Orders,
        ch.Last_Delivered_Order_Date,
        ch.Delivered_Lifetime_Value,

        DATEDIFF(
            DAY,
            ch.Last_Delivered_Order_Date,
            d.Dataset_End_Date
        ) AS Days_Since_Last_Order

    FROM CustomerHistory ch

    CROSS JOIN DatasetEndDate d

    WHERE
        DATEDIFF(
            DAY,
            ch.Last_Delivered_Order_Date,
            d.Dataset_End_Date
        ) > 90
)

SELECT
    a.Customer_ID,

    c.Customer_Name,

    c.Customer_Segment,

    c.City,

    c.Registration_Source,

    a.Total_Delivered_Orders,

    a.Last_Delivered_Order_Date,

    a.Days_Since_Last_Order,

    a.Delivered_Lifetime_Value

FROM AtRiskCustomers a

LEFT JOIN Customers c
    ON a.Customer_ID = c.Customer_ID

ORDER BY
    a.Delivered_Lifetime_Value DESC;

-- Q15: CATEGORY RISK CLASSIFICATION

WITH CategoryMetrics AS
(
    SELECT
        Category,

        COUNT(*) AS Total_Orders,

        -- Delivered-only profitability
        ROUND(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Final_Amount ELSE 0
            END), 2
        ) AS Delivered_Sales,

        ROUND(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Profit ELSE 0
            END), 2
        ) AS Delivered_Profit,

        ROUND(
            SUM(CASE
                WHEN Order_Status = 'Delivered'
                THEN Profit ELSE 0
            END) * 100.0 /
            NULLIF(
                SUM(CASE
                    WHEN Order_Status = 'Delivered'
                    THEN Final_Amount ELSE 0
                END), 0
            ), 2
        ) AS Delivered_Profit_Margin_Pct,

        -- All-status operational metrics
        ROUND(
            SUM(Is_Returned) * 100.0 /
            NULLIF(COUNT(*), 0), 2
        ) AS Return_Rate_Pct,

        SUM(Is_Loss_Order) AS Loss_Orders,

        ROUND(
            AVG(Discount_Pct), 2
        ) AS Avg_Discount_Pct

    FROM Orders

    GROUP BY
        Category
)

SELECT

    Category,
    Total_Orders,
    Delivered_Sales,
    Delivered_Profit,
    Delivered_Profit_Margin_Pct,
    Return_Rate_Pct,
    Loss_Orders,
    Avg_Discount_Pct,

    CASE
        WHEN Return_Rate_Pct > 20
             AND Delivered_Profit_Margin_Pct < 15
            THEN 'HIGH RISK'

        WHEN Return_Rate_Pct > 20
             OR Delivered_Profit_Margin_Pct < 15
            THEN 'MEDIUM RISK'

        ELSE 'LOW RISK'
    END AS Risk_Level,

    CASE
        WHEN Return_Rate_Pct > 20
             AND Delivered_Profit_Margin_Pct < 15
            THEN
                'Both return rate and delivered profit margin are problematic'

        WHEN Return_Rate_Pct > 20
            THEN
                'High return rate - investigate product quality or customer experience'

        WHEN Delivered_Profit_Margin_Pct < 15
            THEN
                'Low delivered profit margin - review pricing and discount strategy'

        ELSE
            'Category is performing well'
    END AS Risk_Reason

FROM CategoryMetrics

ORDER BY

    CASE
        WHEN Return_Rate_Pct > 20
             AND Delivered_Profit_Margin_Pct < 15
            THEN 1

        WHEN Return_Rate_Pct > 20
             OR Delivered_Profit_Margin_Pct < 15
            THEN 2

        ELSE 3
    END,

    Return_Rate_Pct DESC;
-- End of SQL analysis
