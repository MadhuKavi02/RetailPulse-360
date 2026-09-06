/*
====================================================================
PROJECT : RetailPulse 360 — E-Commerce Intelligence System
DOMAIN  : E-Commerce Analytics
TOOL    : SQL Server
AUTHOR  : Madhumitha
PURPOSE : Business-focused analysis of sales, customers,
          products, payments and delivery performance

DATASET : Synthetic KartZone India E-Commerce Datasets

KEY TABLES USED :
    Orders
    Products
    Customers
    Deliveries

ANALYSIS COVERED :
    Q01 - Overall Business Summary
    Q02 - Monthly Revenue Trend
    Q03 - Month-over-Month Revenue Growth
    Q04 - Category Performance
    Q05 - Top 10 Profitable Products
    Q06 - Bottom 10 Loss-Making Products
    Q07 - Discount Impact on Profit
    Q08 - Customer Segmentation by Revenue
    Q09 - City-wise Performance
    Q10 - Payment Mode Analysis
    Q11 - Delivery Partner Performance
    Q12 - Festive vs Non-Festive Season
    Q13 - Running Total of Revenue
    Q14 - At-Risk Customer Identification
    Q15 - Category Risk Classification

====================================================================
*/


/*
====================================================================
Q01 — OVERALL BUSINESS SUMMARY
====================================================================

Business Question:
What is the overall revenue, profit, profit margin and order
volume of the business?

Additional KPIs:
- Return Rate
- Cancellation Rate
- Loss-Making Orders

Purpose:
This gives a high-level view of the overall business performance.
====================================================================
*/

SELECT
    COUNT(Order_ID) AS Total_Orders,

    ROUND(SUM(Final_Amount), 2) AS Total_Revenue,

    ROUND(SUM(Profit), 2) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Final_Amount), 0),
        2
    ) AS Overall_Profit_Margin_Pct,

    ROUND(
        SUM(Is_Returned) * 100.0 /
        COUNT(*),
        2
    ) AS Return_Rate_Pct,

    ROUND(
        SUM(Is_Cancelled) * 100.0 /
        COUNT(*),
        2
    ) AS Cancellation_Rate_Pct,

    SUM(Is_Loss_Order) AS Loss_Making_Orders

FROM Orders;


/*
====================================================================
Q02 — MONTHLY REVENUE TREND
====================================================================

Business Question:
How did revenue and profit change month by month across the
available years?

Purpose:
Identify strong and weak months and understand seasonal patterns.
====================================================================
*/

SELECT
    FORMAT(CAST(Order_Date AS DATE), 'yyyy-MM') AS Order_Month,

    COUNT(*) AS Total_Orders,

    ROUND(SUM(Final_Amount), 2) AS Total_Revenue,

    ROUND(SUM(Profit), 2) AS Total_Profit

FROM Orders

GROUP BY
    FORMAT(CAST(Order_Date AS DATE), 'yyyy-MM')

ORDER BY
    Order_Month;


/*
====================================================================
Q03 — MONTH-OVER-MONTH REVENUE GROWTH
====================================================================

Business Question:
How much did revenue increase or decrease compared with the
previous month?

Purpose:
Measure monthly business momentum using the LAG() window function.
====================================================================
*/

WITH MonthlyRevenue AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,

        ROUND(SUM(Final_Amount), 2) AS Monthly_Revenue

    FROM Orders

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
)

SELECT
    Order_Year,
    Order_Month,
    Monthly_Revenue,

    LAG(Monthly_Revenue) OVER
    (
        ORDER BY Order_Year, Order_Month
    ) AS Previous_Month_Revenue,

    ROUND(
        Monthly_Revenue -
        LAG(Monthly_Revenue) OVER
        (
            ORDER BY Order_Year, Order_Month
        ),
        2
    ) AS Revenue_Change,

    ROUND(
        (
            Monthly_Revenue -
            LAG(Monthly_Revenue) OVER
            (
                ORDER BY Order_Year, Order_Month
            )
        ) * 100.0
        /
        NULLIF(
            LAG(Monthly_Revenue) OVER
            (
                ORDER BY Order_Year, Order_Month
            ),
            0
        ),
        2
    ) AS Growth_Pct

FROM MonthlyRevenue

ORDER BY
    Order_Year,
    Order_Month;


/*
====================================================================
Q04 — CATEGORY PERFORMANCE
====================================================================

Business Question:
Which product categories generate the most revenue and profit,
and which categories have higher return rates?

Purpose:
Compare category-level business performance using multiple KPIs.
====================================================================
*/

SELECT
    Category,

    COUNT(*) AS Total_Orders,

    ROUND(SUM(Final_Amount), 2) AS Total_Revenue,

    ROUND(SUM(Profit), 2) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Final_Amount), 0),
        2
    ) AS Profit_Margin_Pct,

    ROUND(
        SUM(Is_Returned) * 100.0 /
        COUNT(*),
        2
    ) AS Return_Rate_Pct

FROM Orders

GROUP BY
    Category

ORDER BY
    Total_Revenue DESC;


/*
====================================================================
Q05 — TOP 10 PROFITABLE PRODUCTS
====================================================================

Business Question:
Which products contribute the highest total profit?

Purpose:
Identify products that are strong contributors to business
profitability rather than looking only at sales volume.
====================================================================
*/

WITH ProductSummary AS
(
    SELECT
        o.Product_ID,

        COUNT(*) AS Total_Orders,

        ROUND(SUM(o.Final_Amount), 2) AS Total_Revenue,

        ROUND(SUM(o.Profit), 2) AS Total_Profit,

        ROUND(
            SUM(o.Profit) * 100.0 /
            NULLIF(SUM(o.Final_Amount), 0),
            2
        ) AS Profit_Margin_Pct

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

    ps.Total_Revenue,

    ps.Total_Profit,

    ps.Profit_Margin_Pct

FROM ProductSummary ps

LEFT JOIN Products p
    ON ps.Product_ID = p.Product_ID

ORDER BY
    ps.Total_Profit DESC;


/*
====================================================================
Q06 — BOTTOM 10 LOSS-MAKING PRODUCTS
====================================================================

Business Question:
Which products are generating the largest overall losses?

Purpose:
Identify products that may require pricing, discount or product-
level review.
====================================================================
*/

WITH ProductLoss AS
(
    SELECT
        o.Product_ID,

        ISNULL(p.Product_Name, 'Product Not in Catalog')
            AS Product_Name,

        ISNULL(p.Category, o.Category)
            AS Category,

        COUNT(*) AS Total_Orders,

        ROUND(SUM(o.Profit), 2)
            AS Total_Profit_Loss,

        SUM(o.Is_Loss_Order)
            AS Loss_Order_Count

    FROM Orders o

    LEFT JOIN Products p
        ON o.Product_ID = p.Product_ID

    GROUP BY
        o.Product_ID,
        p.Product_Name,
        p.Category,
        o.Category

    HAVING
        SUM(o.Profit) < 0
)

SELECT TOP 10

    Product_ID,
    Product_Name,
    Category,
    Total_Orders,
    Total_Profit_Loss,
    Loss_Order_Count

FROM ProductLoss

ORDER BY
    Total_Profit_Loss ASC;


/*
====================================================================
Q07 — DISCOUNT IMPACT ON PROFIT
====================================================================

Business Question:
Does higher discounting have an impact on profitability?

Discount Bands:
    0%
    1-10%
    11-20%
    21-30%
    Above 30%

Metrics:
    Total Orders
    Average Profit Margin
    Loss-Making Orders
    Loss Rate
    Average Order Value

Purpose:
Understand whether aggressive discounting is associated with
lower margins and more loss-making orders.
====================================================================
*/

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

    ROUND(
        AVG(Profit_Margin_Pct),
        2
    ) AS Avg_Profit_Margin_Pct,

    SUM(Is_Loss_Order) AS Loss_Order_Count,

    ROUND(
        SUM(Is_Loss_Order) * 100.0 /
        COUNT(*),
        2
    ) AS Loss_Rate_Pct,

    ROUND(
        AVG(Final_Amount),
        2
    ) AS Avg_Order_Value

FROM DiscountBands

GROUP BY
    Discount_Range,
    Sort_Order

ORDER BY
    Sort_Order;


/*
====================================================================
Q08 — CUSTOMER SEGMENTATION BY REVENUE
====================================================================

Business Question:
How is customer spending distributed across four equal customer
groups?

Segments:
    Top 25%       - High Value
    Upper Middle
    Lower Middle
    Bottom 25%    - Low Value

Purpose:
Understand how much revenue comes from high-value customers.
====================================================================
*/

WITH CustomerSpend AS
(
    SELECT
        Customer_ID,

        ROUND(SUM(Final_Amount), 2)
            AS Total_Spending,

        COUNT(*) AS Total_Orders

    FROM Orders

    GROUP BY
        Customer_ID
),

CustomerTile AS
(
    SELECT
        *,

        NTILE(4) OVER
        (
            ORDER BY Total_Spending DESC
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

    ROUND(
        SUM(Total_Spending),
        2
    ) AS Segment_Revenue,

    ROUND(
        SUM(Total_Spending) * 100.0 /
        SUM(SUM(Total_Spending)) OVER (),
        2
    ) AS Revenue_Contribution_Pct,

    ROUND(
        AVG(Total_Spending),
        2
    ) AS Avg_Customer_Spend,

    ROUND(
        AVG(CAST(Total_Orders AS FLOAT)),
        1
    ) AS Avg_Orders_Per_Customer

FROM CustomerTile

GROUP BY
    Spending_Tile

ORDER BY
    Spending_Tile;


/*
====================================================================
Q09 — CITY-WISE PERFORMANCE
====================================================================

Business Question:
How does business performance vary across cities?

Metrics:
    Revenue
    Profit
    Profit Margin
    Cancellation Rate
    Return Rate
    Average Order Value

Purpose:
Identify high-performing locations and potential operational
issues by city.
====================================================================
*/

SELECT
    City,

    COUNT(*) AS Total_Orders,

    ROUND(SUM(Final_Amount), 2)
        AS Total_Revenue,

    ROUND(SUM(Profit), 2)
        AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Final_Amount), 0),
        2
    ) AS Profit_Margin_Pct,

    ROUND(
        SUM(Is_Cancelled) * 100.0 /
        COUNT(*),
        2
    ) AS Cancellation_Rate_Pct,

    ROUND(
        SUM(Is_Returned) * 100.0 /
        COUNT(*),
        2
    ) AS Return_Rate_Pct,

    ROUND(
        AVG(Final_Amount),
        2
    ) AS Avg_Order_Value,

    RANK() OVER
    (
        ORDER BY SUM(Final_Amount) DESC
    ) AS Revenue_Rank

FROM Orders

GROUP BY
    City

ORDER BY
    Total_Revenue DESC;


/*
====================================================================
Q10 — PAYMENT MODE ANALYSIS
====================================================================

Business Question:
Which payment methods have higher order values and which have
higher cancellation rates?

Purpose:
Compare customer payment behavior and identify whether COD has
a relatively higher cancellation rate.
====================================================================
*/

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


/*
====================================================================
Q11 — DELIVERY PARTNER PERFORMANCE
====================================================================

Business Question:
How do delivery partners compare in terms of delivery speed,
customer experience, cost and failure rate?

Metrics:
    On-Time Rate
    Average Delay
    Customer Rating
    Delivery Cost
    Failed Deliveries
    Failure Rate

Purpose:
Evaluate operational performance of delivery partners.
====================================================================
*/

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
    --note that the BEST/WORST and HIGH/MEDIUM/LOW thresholds are project-defined business rules, not industry standards.

/*
====================================================================
Q12 — FESTIVE VS NON-FESTIVE SEASON
====================================================================

Business Question:
Does the festive season perform differently from the rest of
the year?

Metrics:
    Orders
    Revenue
    Revenue Share
    Profit Margin
    Return Rate
    Average Order Value
    Cancellation Rate

Purpose:
Understand the contribution and profitability of festive-period
sales.
====================================================================
*/

SELECT

    CASE
        WHEN Is_Festive_Season = 1
            THEN 'Festive Season (Oct-Dec)'
        ELSE 'Non-Festive Season'
    END AS Season,

    COUNT(*) AS Total_Orders,

    ROUND(
        SUM(Final_Amount),
        2
    ) AS Total_Revenue,

    ROUND(
        SUM(Final_Amount) * 100.0 /
        SUM(SUM(Final_Amount)) OVER (),
        2
    ) AS Revenue_Share_Pct,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Final_Amount), 0),
        2
    ) AS Profit_Margin_Pct,

    ROUND(
        SUM(Is_Returned) * 100.0 /
        COUNT(*),
        2
    ) AS Return_Rate_Pct,

    ROUND(
        AVG(Final_Amount),
        2
    ) AS Avg_Order_Value,

    ROUND(
        SUM(Is_Cancelled) * 100.0 /
        COUNT(*),
        2
    ) AS Cancellation_Rate_Pct

FROM Orders

GROUP BY
    Is_Festive_Season

ORDER BY
    Is_Festive_Season DESC;


/*
====================================================================
Q13 — RUNNING TOTAL OF REVENUE
====================================================================

Business Question:
How does cumulative revenue build throughout each year, and in
which month does the business cross 50% of annual revenue?

Purpose:
Use window functions to track cumulative performance and identify
the 50% revenue milestone.
====================================================================
*/

WITH Monthly AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,

        ROUND(
            SUM(Final_Amount),
            2
        ) AS Monthly_Revenue

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
        Monthly_Revenue,

        /* Cumulative revenue across the dataset */
        SUM(Monthly_Revenue) OVER
        (
            ORDER BY Order_Year, Order_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Total_All,

        /* Cumulative revenue within each year */
        SUM(Monthly_Revenue) OVER
        (
            PARTITION BY Order_Year
            ORDER BY Order_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Total_Year,

        /* Total revenue for each year */
        SUM(Monthly_Revenue) OVER
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
    Monthly_Revenue,
    Running_Total_All,
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


/*
====================================================================
Q14 — AT-RISK CUSTOMER IDENTIFICATION
====================================================================

Business Question:
Which customers have not purchased in the last 90 days but have
placed at least 3 orders historically?


Purpose:
Identify valuable customers who may require retention campaigns.
====================================================================
*/

WITH DatasetEndDate AS
(
    SELECT
        MAX(
            CAST(Order_Date AS DATE)
        ) AS Dataset_End_Date

    FROM Orders
),

CustomerHistory AS
(
    SELECT
        Customer_ID,

        COUNT(*) AS Total_Orders,

        MAX(
            CAST(Order_Date AS DATE)
        ) AS Last_Order_Date,

        ROUND(
            SUM(Final_Amount),
            2
        ) AS Lifetime_Value

    FROM Orders

    GROUP BY
        Customer_ID

    HAVING
        COUNT(*) >= 3
),

AtRiskCustomers AS
(
    SELECT
        ch.Customer_ID,
        ch.Total_Orders,
        ch.Last_Order_Date,
        ch.Lifetime_Value,

        DATEDIFF(
            DAY,
            ch.Last_Order_Date,
            d.Dataset_End_Date
        ) AS Days_Since_Last_Order

    FROM CustomerHistory ch

    CROSS JOIN DatasetEndDate d

    WHERE
        DATEDIFF(
            DAY,
            ch.Last_Order_Date,
            d.Dataset_End_Date
        ) > 90
)

SELECT
    a.Customer_ID,

    c.Customer_Name,

    c.Customer_Segment,

    c.City,

    c.Registration_Source,

    a.Total_Orders,

    a.Last_Order_Date,

    a.Days_Since_Last_Order,

    a.Lifetime_Value

FROM AtRiskCustomers a

LEFT JOIN Customers c
    ON a.Customer_ID = c.Customer_ID

ORDER BY
    a.Lifetime_Value DESC;


/*
====================================================================
Q15 — CATEGORY RISK CLASSIFICATION
====================================================================

Business Question:
Which product categories require the most attention based on
return rate and profit margin?

Risk Logic:

HIGH RISK
    Return Rate > 20%
    AND
    Profit Margin < 15%

MEDIUM RISK
    Return Rate > 20%
    OR
    Profit Margin < 15%

LOW RISK
    Neither condition is met.

Purpose:
Create a simple business-risk classification that can later be
used directly in Power BI for category-level monitoring.
====================================================================
*/

WITH CategoryMetrics AS
(
    SELECT
        Category,

        COUNT(*) AS Total_Orders,

        ROUND(
            SUM(Final_Amount),
            2
        ) AS Total_Revenue,

        ROUND(
            SUM(Profit),
            2
        ) AS Total_Profit,

        ROUND(
            SUM(Profit) * 100.0 /
            NULLIF(SUM(Final_Amount), 0),
            2
        ) AS Profit_Margin_Pct,

        ROUND(
            SUM(Is_Returned) * 100.0 /
            NULLIF(COUNT(*), 0),
            2
        ) AS Return_Rate_Pct,

        SUM(Is_Loss_Order) AS Loss_Orders,

        ROUND(
            AVG(Discount_Pct),
            2
        ) AS Avg_Discount_Pct

    FROM Orders

    GROUP BY
        Category
)

SELECT

    Category,

    Total_Orders,

    Total_Revenue,

    Total_Profit,

    Profit_Margin_Pct,

    Return_Rate_Pct,

    Loss_Orders,

    Avg_Discount_Pct,

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
            THEN
                'Both return rate and profit margin are problematic'

        WHEN Return_Rate_Pct > 20
            THEN
                'High return rate - investigate product quality or customer experience'

        WHEN Profit_Margin_Pct < 15
            THEN
                'Low profit margin - review pricing and discount strategy'

        ELSE
                'Category is performing well'

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
    END,

    Return_Rate_Pct DESC;

--note that the BEST/WORST and HIGH/MEDIUM/LOW thresholds are project-defined business rules, not industry standards.
/*
====================================================================
END OF SQL BUSINESS ANALYSIS
====================================================================

Key SQL concepts demonstrated:

    - Aggregations
    - GROUP BY
    - CASE statements
    - CTEs
    - Window Functions
    - LAG()
    - RANK()
    - NTILE()
    - DATEDIFF()
    - CROSS JOIN
    - LEFT JOIN
    - NULLIF()
    - Conditional business classification
    - Revenue and profitability analysis
    - Customer segmentation
    - Operational performance analysis

====================================================================
*/
