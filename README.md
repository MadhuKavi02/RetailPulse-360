# RetailPulse — 360° E-Commerce Intelligence Platform

## KartZone India Pvt. Ltd. | End-to-End Analytics Project

![Tools](https://img.shields.io/badge/Tools-Python%20%7C%20SQL%20Server%20%7C%20Power%20BI-blue)
![Status](https://img.shields.io/badge/Status-Completed-green)

---

## Project Overview

RetailPulse is a complete end-to-end data analytics project built for a 
fictional Indian e-commerce company — KartZone India Pvt. Ltd. The project 
covers the full analytics pipeline from synthetic data generation and cleaning 
to SQL analysis and interactive Power BI dashboarding.

**Business Problem:** KartZone India is generating strong revenue but profit 
margins are shrinking. The goal is to identify why — and give actionable 
recommendations.

---

## Key Findings

- Orders with discount above 20% generate negative profit margins — 
  especially in Electronics
- DTDC delivery partner has 0% on-time delivery rate across all cities
- Festive season (Oct-Nov-Dec) drives 44% of annual revenue in 3 months
- Fashion returns increase significantly when delivery exceeds 5 days
- Top 20% of customers generate 65% of total revenue
- 1,791 loss-making orders identified — concentrated in high-discount 
  Electronics

---

## Tech Stack

| Layer | Tools Used |
|---|---|
| Data Generation | Python — Faker, NumPy, Pandas, Random |
| Data Cleaning | Python — Pandas, NumPy, Regex, Sklearn |
| Data Storage | Microsoft SQL Server — SSMS |
| SQL Analysis | T-SQL — Window Functions, CTEs, Joins |
| Visualization | Power BI Desktop — DAX, Power Query |

---
## Project Structure

```text
RetailPulse/
│
├── Data Generation
├── Data Cleaning - Python
├── SQL Analysis
├── Power BI
└── Documentation
```

## Dataset

Synthetically generated using Python — 4 tables with intentional data 
quality issues for realistic cleaning practice.

| Table | Raw Rows | Clean Rows | Key Columns |
|---|---|---|---|
| Customers | 1,035 | 1,000 | Customer_ID, Segment, City, Registration_Source |
| Products | 825 | 800 | Product_ID, Category, MRP, Cost_Price, Discount_Pct |
| Orders | 10,170 | 9,791 | Order_ID, Final_Amount, Profit, Order_Status |
| Deliveries | 10,115 | 9,791 | Delivery_Partner, Delay_Days, On_Time_Flag |

---

---

## Data Cleaning Highlights

Each table had intentional data quality issues —

- Mixed date formats — 5 different formats in same column
- Currency symbols in price columns — ₹, Rs., INR
- Inconsistent city names — Mumbai, mumbai, Bombay, MUMBAI
- Invalid values — negative ages, ratings above 5
- Duplicate rows and blank rows
- Orphan Product IDs — 7,259 orders reference archived products

**Techniques applied:**
Multi-format date parsing, Regex symbol removal, Dictionary mapping 
standardization, IQR outlier capping, Median imputation grouped by segment

---

## SQL Analysis — 15 Business Queries

| Query | Business Question | SQL Concept |
|---|---|---|
| Q1 | Overall revenue, profit, margin | Basic aggregation |
| Q2 | Monthly revenue trend | DATE functions + GROUP BY |
| Q3 | Month over month growth | LAG window function |
| Q4 | Category performance | Multiple aggregations |
| Q5 | Top 10 profitable products | TOP + JOIN + ORDER BY |
| Q6 | Bottom 10 loss-making products | DENSE_RANK |
| Q7 | Discount impact on profit | CASE WHEN ranges |
| Q8 | Customer segmentation by spend | NTILE |
| Q9 | City wise performance | GROUP BY + RANK |
| Q10 | Payment mode analysis | Conditional aggregation |
| Q11 | Delivery partner performance | Multi-table JOIN |
| Q12 | Festive vs non-festive | CASE WHEN + GROUP BY |
| Q13 | Running revenue total | SUM OVER |
| Q14 | At-risk customer identification | DATEDIFF + subquery |
| Q15 | Category risk classification | CTE + CASE WHEN |

---

## Power BI Dashboard — 4 Pages

**Page 1 — Executive Summary**
KPI cards, monthly trend line, revenue by city map, category bar chart

**Page 2 — Discount Impact Analysis**
Scatter plot showing discount vs profit correlation, bar chart by 
discount range, matrix with conditional formatting

**Page 3 — Customer Intelligence**
Revenue by segment, acquisition channel analysis, payment distribution

**Page 4 — Delivery Operations**
Partner performance matrix with color coding, failure reason analysis, 
delay trend line

## Recent Updates
**Page 5 — Time Intelligence**
Implemented Revenue YTD, MoM and YoY measures.

**Page 6 — Category Detail**
- Dynamic title using SELECTEDVALUE function
- Shows category specific:
  → Total Revenue, Profit, Orders, Return Rate
  → Revenue Trend 2023 vs 2024
  → Profit Margin by Discount Range
  → Revenue by City
  → Top 10 Products by Profit
- Accessible by right clicking any 
  category in Executive Summary

---

## DAX Measures Created

```dax
Total Revenue = SUM(Orders[Final_Amount])
Total Profit = SUM(Orders[Profit])
Profit Margin % = DIVIDE([Total Profit], [Total Revenue]) * 100
Return Rate % = DIVIDE(SUM(Orders[Is_Returned]), COUNT(Orders[Order_ID])) * 100
On Time Delivery % = DIVIDE(SUM(Deliveries[On_Time_Flag]), 
                     COUNT(Deliveries[Delivery_ID])) * 100
Revenue YTD = 
TOTALYTD([Total Revenue], Date_Table[Date])

Revenue Previous Month = 
CALCULATE(
    [Total Revenue],
    PREVIOUSMONTH(Date_Table[Date])
)

MoM Revenue Growth % = 
DIVIDE(
    [Total Revenue] - [Revenue Previous Month],
    [Revenue Previous Month]
) * 100

YoY Revenue Growth % = 
DIVIDE(
    [Total Revenue] - [Revenue Last Year],
    [Revenue Last Year]
) * 100

Dynamic_Category_Title = 
"Category Detail Analysis - " & 
SELECTEDVALUE(Orders[Category], "All Categories")
```

---
## Row Level Security section
Static RLS:
- Created city level roles for all 6 cities
- Mumbai, Delhi, Chennai, Bangalore, 
  Hyderabad, Pune managers
- Validated using View As Role feature

Dynamic RLS:
- Created User_City_Mapping table
- Implemented USERPRINCIPALNAME() function
- Tested with fake emails per city
- Automatically filters data based on 
  logged in user

  ---

## Business Recommendations

1. Cap Electronics discounts at 20% maximum
2. Terminate or renegotiate DTDC partnership immediately
3. Prioritize express delivery for Fashion category
4. Launch re-engagement campaign for 216 at-risk customers
5. Build festive season inventory strategy from August onwards
6. Implement minimum 5% profit margin threshold per order

---

## Project Limitations

- Synthetic dataset — not real company data
- 7,259 orphan Product IDs limit product-level analysis
- No predictive analytics or forecasting included
- No real-time data pipeline — manual refresh required
---

## Author

**Madhumitha Mathivanan**
Data Analyst | SQL | Python | Power BI
www.linkedin.com/in/madhumithamathi07

---
