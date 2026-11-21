# 🛒 RetailPulse 360 — E-Commerce Intelligence System

> **An end-to-end Data Analyst portfolio project simulating an Indian e-commerce business using Python, SQL Server, and Power BI.**

---

## 📌 Project Overview

RetailPulse 360 is an end-to-end analytics project built around a fictional Indian e-commerce retailer — **KartZone India** — operating across six cities and four product categories.

The core business question driving this project:

> *"KartZone's revenue is large but flat, and profit margins are uneven across categories. Where is the money leaking?"*

The project addresses this question through a complete analytics workflow — from raw data generation and cleaning to SQL-based business analysis and an interactive six-page Power BI dashboard.

The analysis focuses on sales performance, profitability, discount impact, customer behaviour, delivery operations, and time-based trends.

---

## 🛠️ Technology Stack

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, NumPy) | Data generation, cleaning, validation, feature engineering |
| **SQL Server** | Structured business analysis — 15 analytical queries |
| **Power BI Desktop** | Interactive six-page dashboard with DAX measures |

---

## 📊 Dataset Summary

Four synthetic datasets were generated using Python to simulate realistic e-commerce business data for KartZone India.

| Table | Rows | Description |
|-------|------|-------------|
| Customers | 1,000 | Customer profiles, segments, acquisition channels, activity |
| Products | 800 | Product catalogue, pricing, categories, ratings, stock |
| Orders | 9,598 | Order-level revenue, profit, discounts, status |
| Deliveries | 9,598 | Delivery partner, timing, cost, failure, ratings |

**Geographical Coverage:** Mumbai, Delhi, Chennai, Bangalore, Hyderabad, Pune

**Period:** 2023–2024

**Product Categories:** Electronics, Fashion, Home & Kitchen, Beauty

**Note:** All datasets are synthetic and created exclusively for portfolio and analytical demonstration purposes.

---

## 🔄 End-to-End Pipeline

```text
Raw CSV Files
      ↓
Python — Data Cleaning & Feature Engineering
      ↓
SQL Server — Business Analysis (15 Queries)
      ↓
Power BI — Interactive Dashboard (6 Pages)
      ↓
Business Findings & Recommendations
```

---

## 🐍 Phase 1 — Python: Data Cleaning & Feature Engineering

Python was used to generate, clean, validate, and prepare the datasets for analysis.

### Data Quality Issues Handled

- Blank and duplicate rows
- Mixed capitalisation and spelling variations in categorical fields
- Mixed date formats and parsing issues
- Currency strings and numeric conversion problems
- Invalid numeric ranges, including ratings outside the 1–5 scale
- Foreign-key validation between Orders and Customers/Products

### Feature Engineering Highlights

**Customer Features**

- `Churn_Flag` — 1 when customer segment is Churned or At-Risk
- `Is_Dormant` — 1 when Days_Since_Login > 90
- `Age_Group` — 18–25 / 26–35 / 36–45 / 46+
- `Tenure_Band` — New / Growing / Established / Loyal

**Order Features**

- `Is_Festive_Season` — 1 for October–December orders
- `Is_Loss_Order` — 1 when Profit < 0
- `Order_Value_Band` — Low / Medium / High / Premium
- `High_Discount_Flag` — 1 when Discount_Pct > 20%

**Delivery Features**

- `On_Time_Flag` — 1 when Delay_Days <= 0
- `Delay_Severity` — Early / On Time / Slightly / Moderately / Severely Delayed

---

## 🗄️ Phase 2 — SQL Server: Business Analysis

A total of 15 SQL queries were developed to answer business-oriented analytical questions.

| No. | Business Question | SQL Techniques |
|-----|-------------------|-----------------|
| Q1 | Overall revenue, profit, margin, return and cancellation rates | SUM, COUNT, percentage calculations |
| Q2 | Monthly revenue and profit trends across years | GROUP BY, date functions |
| Q3 | Month-over-month revenue growth | LAG(), window functions |
| Q4 | Category performance — revenue, profit, return rate | GROUP BY, KPI calculations |
| Q5 | Top 10 most profitable products | TOP, JOIN, aggregation |
| Q6 | Products causing the highest losses | HAVING, CTE, aggregation |
| Q7 | How discounts affect margins and loss-making orders | CASE WHEN, CTE, segmentation |
| Q8 | Revenue contribution by customer segment | JOIN, GROUP BY, window functions |
| Q9 | City-wise revenue and profit margin | RANK(), GROUP BY |
| Q10 | Payment mode cancellation and order value | GROUP BY, percentage calculations |
| Q11 | Best and worst delivery partner performance | CTE, RANK(), KPI benchmarking |
| Q12 | Festive vs non-festive season comparison | CASE WHEN, aggregation |
| Q13 | When did the business cross 50% of annual revenue? | Running total, SUM() OVER, LAG() |
| Q14 | Customers at risk of churn | DATEDIFF, CTE, behaviour analysis |
| Q15 | Product category risk classification | Multi-condition CASE WHEN |

---

## 📈 Phase 3 — Power BI: Interactive Dashboard

A six-page interactive Power BI report was developed using slicers, KPI cards, drill-through functionality, conditional formatting, and DAX measures.

### Report Pages

| Page | Focus | Key Visuals |
|------|-------|-------------|
| **Executive Summary** | Overall business performance | KPI cards, monthly sales and profit trends, order status, city and category performance |
| **Discount Impact** | Discount vs profitability | Discount range analysis, delivered profit margin matrix, loss-making order KPIs |
| **Customer Intelligence** | Customer behaviour | Customer segment sales, acquisition channel, payment mode distribution, top customers |
| **Delivery Operations** | Delivery performance | Delivery partner performance matrix, failure reason analysis, monthly delay trends |
| **Time Intelligence** | Period comparison | Delivered Sales YTD, YoY and MoM growth, cumulative sales trend |
| **Category Detail** | Category-level drill-through analysis | Category KPIs, delivered sales trends, discount margin analysis, top 10 products by profit |

### Key DAX Measures

**Delivered Sales**

```dax
Delivered Sales =
CALCULATE(
    SUM(Orders[Final_Amount]),
    Orders[Order_Status] = "Delivered"
)
```

**Delivered Profit**

```dax
Delivered Profit =
CALCULATE(
    SUM(Orders[Profit]),
    Orders[Order_Status] = "Delivered"
)
```

**Delivered Profit Margin %**

```dax
Delivered Profit Margin % =
DIVIDE(
    [Delivered Profit],
    [Delivered Sales]
)
```

**Revenue YTD**

```dax
Revenue YTD =
TOTALYTD(
    [Delivered Sales],
    Date_Table[Date]
)
```

**Revenue Last Year**

```dax
Revenue Last Year =
CALCULATE(
    [Delivered Sales],
    SAMEPERIODLASTYEAR(Date_Table[Date])
)
```

**YoY Revenue Growth %**

```dax
YoY Revenue Growth % =
DIVIDE(
    [Delivered Sales] - [Revenue Last Year],
    [Revenue Last Year]
)
```

**Revenue Previous Month**

```dax
Revenue Previous Month =
CALCULATE(
    [Delivered Sales],
    PREVIOUSMONTH(Date_Table[Date])
)
```

**MoM Revenue Growth %**

```dax
MoM Revenue Growth % =
DIVIDE(
    [Delivered Sales] - [Revenue Previous Month],
    [Revenue Previous Month]
)
```


### Row-Level Security (RLS)

Implemented two approaches to demonstrate data access control:

- **Static RLS** — City-level roles manually created through Power BI Manage Roles.
- **Dynamic RLS** — User mapping table with `USERPRINCIPALNAME()` to filter data based on the logged-in user's email.

---

## 📋 Key Findings

### 💰 Revenue & Profitability

- **Total Order Value: ₹311.15M** across all order statuses.
- **Delivered Sales: ₹206.14M** from successfully delivered orders.
- **Delivered Profit: ₹45.03M** with a delivered profit margin of **21.85%**.
- Electronics contributes approximately **85% of Delivered Sales**, making it the largest revenue-generating category.
- **544 loss-making orders (5.7%)** highlight opportunities to review pricing and discount strategies.

### 🏷️ Discount Impact

- Electronics profit margin declines substantially as discount levels increase.
  - 21–30% discount band → **6.09% margin**
  - Above 30% discount band → **8.76% margin**
- Higher discounts are associated with lower profit margins, particularly in Electronics.
- The findings suggest the need for better discount governance and profitability monitoring.

### 👥 Customer Behaviour

- **1,000 total customers** in the dataset.
- **331 active customers** and **216 at-risk customers**.
- App is the highest revenue-generating acquisition channel.
- UPI accounts for **34.56%** of orders, making it the most frequently used payment mode.

### 🚚 Delivery Performance

- Overall on-time delivery rate: **21.55%**.
- Amazon Logistics leads with **38.57% on-time delivery**.
- DTDC records the lowest on-time delivery rate at **5.82%**, with an average delay of **4.20 days**.
- Average customer rating across delivery partners: **3.36 / 5**.

### 📅 Seasonal & Time Intelligence

- Festive season (October–December) accounts for approximately **43.5% of annual orders**.
- Overall order revenue declined by **2.05% in 2024** compared with 2023.
- Delivered Sales declined by **1.45% YoY** in 2024.
- Monthly and cumulative sales trends provide additional visibility into business performance over time.

---

## 💡 Business Recommendations

The following recommendations are illustrative and demonstrate how the analysis could support business decisions if applied to real business data.

| Area | Recommendation |
|------|---------------|
| **Discount Governance** | Review Electronics discounts above 20%, where delivered profit margins fall considerably. |
| **Loss-Making Orders** | Conduct monthly reviews of loss-making orders to distinguish pricing issues from planned promotional activities. |
| **Fashion Returns** | Investigate the 18.20% return rate at product and reason level before changing the product assortment. |
| **Delivery Allocation** | Review delivery allocation to DTDC due to its comparatively low simulated on-time delivery performance. |
| **Customer Retention** | Target the 216 at-risk customers with personalised retention campaigns. |
| **Seasonal Planning** | Use festive-season demand patterns to plan inventory, promotions, and delivery capacity ahead of Q4. |

---

## ⚠️ Project Limitations

- The dataset is **synthetic**, generated for portfolio purposes only, and does not represent actual company transactions.
- The analysis covers 2023–2024; no 2022 baseline is available for comparison.
- Delivery partner statistics are simulated and do not represent real-world carrier performance.
- Business findings and recommendations are based on the assumptions and characteristics of the generated dataset.


---

## 👩‍💻 About

**Madhumitha Mathivanan**

Junior Data Engineer → Aspiring Data Analyst

- 🎓 M.Sc. Data Science — SASTRA University
- 💼 1+ year of experience in data validation, SQL, and reporting — DocIT SYRL India
- 🛠️ Skills — SQL Server, Power BI, Python (Pandas), Excel
- 🔗 [LinkedIn](https://www.linkedin.com/in/madhumithamathi07)

---

*RetailPulse 360 is an independent portfolio project created to demonstrate practical data analytics skills, including data preparation, SQL querying, dashboard development, and business interpretation.*
