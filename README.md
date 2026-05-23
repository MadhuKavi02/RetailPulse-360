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

## Project Structure
