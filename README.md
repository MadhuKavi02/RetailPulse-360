# 🛒 RetailPulse 360 — E-Commerce Intelligence System

> **End-to-end portfolio analytics project simulating an Indian e-commerce business using Python, SQL Server, and Power BI.**

---

## 📌 Project Overview

RetailPulse 360 is a complete Data Analyst portfolio project built around a fictional Indian e-commerce retailer — **KartZone India** — operating across six cities with four product categories.

The core business question driving this project:

> *"The business is generating strong revenue — but why is profit not growing at the same pace? Where is the money leaking?"*

The project answers this question through a full analytics workflow — from raw messy data to validated SQL analysis to an interactive six-page Power BI dashboard.

---

## 🛠️ Technology Stack

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, NumPy) | Data generation, cleaning, validation, feature engineering |
| **SQL Server** | Structured business analysis — 15 analytical queries |
| **Power BI Desktop** | Interactive six-page dashboard with advanced DAX |

---

## 📁 Project Structure

```
RetailPulse360/
│
├── 📂 data/
│   ├── raw/                    # Original generated CSV files with intentional quality issues
│   └── clean/                  # Validated analytical tables loaded into SQL Server
│
├── 📂 python/
│   ├── 01_data_generation.py   # Dataset generation with controlled quality issues
│   └── 02_data_cleaning.py     # Cleaning, validation, and feature engineering
│
├── 📂 sql/
│   └── retailpulse_queries.sql # 15 business SQL queries
│
├── 📂 powerbi/
│   └── RetailPulse360.pbix     # Power BI report file
│
├── 📂 docs/
│   └── RetailPulse360_Documentation.docx  # Full project documentation
│
└── README.md
```

---

## 📊 Dataset Summary

| Table | Rows | Description |
|-------|------|-------------|
| Customers | 1,000 | Customer profiles, segments, acquisition channels, activity |
| Products | 800 | Product catalogue, pricing, categories, ratings, stock |
| Orders | 9,598 | Order-level revenue, profit, discounts, status |
| Deliveries | 9,598 | Delivery partner, timing, cost, failure, ratings |

**Coverage:** Six cities — Mumbai, Delhi, Chennai, Bangalore, Hyderabad, Pune
**Period:** 2023 – 2024
**Categories:** Electronics, Fashion, Home & Kitchen, Beauty

---

## 🔄 End-to-End Pipeline

```
Raw CSVs
    ↓
Python — Data Cleaning & Feature Engineering
    ↓
SQL Server — Business Analysis (15 Queries)
    ↓
Power BI — Interactive Dashboard (6 Pages)
    ↓
Findings & Recommendations
```

---

## 🐍 Phase 1 — Python: Data Cleaning & Feature Engineering

### Data Quality Issues Handled
- Blank and duplicate rows
- Mixed capitalisation and spelling variations in categorical fields
- Mixed date formats and parsing issues
- Currency strings and numeric conversion problems
- Invalid numeric ranges (ratings outside 1–5 scale)
- Logical inconsistencies between status fields and flag columns
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
- `Partner_Reliability_Score` — Partner-level on-time rate × 100

---

## 🗄️ Phase 2 — SQL Server: Business Analysis

15 business queries written around real analytical questions.

| No. | Business Question | Technique |
|-----|-------------------|-----------|
| Q1 | Overall revenue, profit, margin, return and cancellation rates | SUM, COUNT, percentage calculations |
| Q2 | Monthly revenue and profit trend across years | GROUP BY, date functions |
| Q3 | Month-over-month revenue growth | LAG(), window functions |
| Q4 | Category performance — revenue, profit, return rate | GROUP BY, KPI calculations |
| Q5 | Top 10 most profitable products | TOP, JOIN, aggregation |
| Q6 | Products causing the highest losses | HAVING, DENSE_RANK(), CTE |
| Q7 | How discounts affect margins and loss orders | CASE WHEN, CTE, segmentation |
| Q8 | Revenue contribution by customer segment | JOIN, GROUP BY, window functions |
| Q9 | City-wise revenue and profit margin | RANK(), GROUP BY |
| Q10 | Payment mode cancellation and order value | GROUP BY, percentage calculations |
| Q11 | Best and worst delivery partner performance | CTE, RANK(), KPI benchmarking |
| Q12 | Festive vs non-festive season comparison | CASE WHEN, aggregation |
| Q13 | When did business cross 50% of annual revenue? | Running total, SUM() OVER, LAG() |
| Q14 | Customers at risk of churn | DATEDIFF, CTE, behaviour analysis |
| Q15 | Product category risk classification | Multi-condition CASE WHEN |

---

## 📈 Phase 3 — Power BI Dashboard

Six-page interactive report with slicers, KPI cards, drill-through, and advanced DAX measures.

### Report Pages

| Page | Focus | Key Visuals |
|------|-------|-------------|
| **Executive Summary** | Business overview | KPI cards, monthly trend, city revenue, category split |
| **Discount Impact** | Discount vs profitability | Scatter plot, profit margin matrix, loss order KPIs |
| **Customer Intelligence** | Customer behaviour | Segment revenue, acquisition channel, top customers |
| **Delivery Operations** | Partner performance | Matrix with conditional formatting, delay trend |
| **Time Intelligence** | Period comparison | YTD, YoY, MoM measures, cumulative trend |
| **Category Detail** | Drill-through analysis | Dynamic title, category KPIs, top 10 products |

### Advanced DAX Measures Used

```
// Year over Year Growth
YoY Growth % =
VAR CurrentYear = SUM(Orders[Revenue])
VAR LastYear = CALCULATE(SUM(Orders[Revenue]), SAMEPERIODLASTYEAR('Date'[Date]))
RETURN DIVIDE(CurrentYear - LastYear, LastYear)

// Month over Month Growth
MoM Growth % =
VAR CurrentMonth = SUM(Orders[Revenue])
VAR PrevMonth = CALCULATE(SUM(Orders[Revenue]), DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PrevMonth, PrevMonth)

// Dynamic Drill-Through Title
Category Title = "Category Analysis — " & SELECTEDVALUE(Products[Category], "All Categories")

// Product Revenue Rank
Product Rank = RANKX(ALL(Products[Product_Name]), [Total Revenue], , DESC, DENSE)

// Discount Category Classification
Discount Category =
SWITCH(TRUE(),
    Orders[Discount_Pct] > 30, "Above 30% — Loss Risk",
    Orders[Discount_Pct] > 20, "20–30% — Low Margin",
    Orders[Discount_Pct] > 10, "10–20% — Healthy",
    "Below 10% — Profitable"
)
```

### Row Level Security
- **Static RLS** — City-level roles manually created in Manage Roles
- **Dynamic RLS** — User mapping table with `USERPRINCIPALNAME()` function for automatic filtering based on login email

---

## 📋 Key Findings

### 💰 Revenue & Profitability
- **Total Revenue: ₹311.15M** | **Total Profit: ₹67.03M** | **Profit Margin: 21.54%**
- Electronics drives **84.7% of total revenue** but has the lowest category margin at **17.65%**
- **544 loss-making orders (5.7%)** — concentrated in high-discount Electronics transactions

### 🏷️ Discount Impact
- Electronics profit margin drops sharply beyond 20% discount
  - 21–30% discount band → **5.36% margin**
  - Above 30% discount → **6.68% margin**
- Discounts above 20% on Electronics are strongly associated with negative or near-zero profit

### 👥 Customer Behaviour
- **331 active customers** | **216 at-risk customers**
- App is the highest revenue-generating acquisition channel
- UPI dominates payment mode at **34.56%** of orders

### 🚚 Delivery Performance
- Overall on-time delivery rate: **21.55%**
- Amazon Logistics leads at **38.57% on-time**
- DTDC is the lowest performer at **5.82% on-time** with average delay of **4.20 days**
- Average customer rating across all partners: **3.36 / 5**

### 📅 Seasonal Patterns
- Festive season (Oct–Dec) accounts for **43.5% of annual orders**
- 2024 revenue declined **-2.05% YoY** vs 2023

---

## 💡 Business Recommendations

| Area | Recommendation |
|------|---------------|
| **Discount Governance** | Cap Electronics discounts at 20% — above this threshold margins collapse |
| **Loss Order Review** | Implement monthly review of loss-making orders to separate pricing errors from planned promotions |
| **Fashion Returns** | Investigate 18.20% return rate at product and reason level before changing assortment |
| **Delivery Allocation** | Review DTDC allocation — 5.82% on-time rate is critically low |
| **Customer Retention** | Target 216 at-risk customers with personalised retention campaigns |
| **Seasonal Planning** | Use festive season pattern to plan inventory, promotions, and delivery capacity ahead of Q4 |

---

## ⚠️ Limitations

- Dataset is **synthetic** — generated for portfolio purposes only, not real company data
- No 2022 baseline available — 2023 YoY comparison is not possible
- Profit calculation does not include marketing overhead, warehouse labour, or return-processing costs
- Delivery partner statistics are simulated — do not represent real carrier performance
- Scope is descriptive and diagnostic analytics — predictive modelling is outside current scope

---

## 📂 How to Use This Project

**1. Python — Data Generation and Cleaning**
```bash
pip install pandas numpy
python python/01_data_generation.py
python python/02_data_cleaning.py
```

**2. SQL Server — Load and Query**
- Load the cleaned CSV files from `data/clean/` into SQL Server
- Run queries from `sql/retailpulse_queries.sql`

**3. Power BI — Open Report**
- Open `powerbi/RetailPulse360.pbix` in Power BI Desktop
- Refresh data connection pointing to your SQL Server instance

---

## 👩‍💻 About

**Madhumitha Mathivanan**
Junior Data Engineer → Aspiring Data Analyst

- 🎓 M.Sc Data Science — SASTRA University
- 💼 1+ year experience in data validation and SQL — DocIT SYRL India
- 🛠️ Skills — SQL Server, Power BI, Python (Pandas), Excel

---

## 📄 Documentation

Full project documentation including data architecture, feature engineering details, SQL design principles, and analytical findings is available in `docs/RetailPulse360_Documentation.docx`

---

*RetailPulse 360 — Built to demonstrate end-to-end data analytics capability*
*September 2026*
