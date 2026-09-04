# pizza-delivery-analytics
End-to-end analytics project: Excel cleaning, SQL analysis, and Power BI dashboard for pizza delivery data

# Pizza Delivery Performance Analytics

An end-to-end data analytics project analyzing delivery delays across 1,004 orders 
from 5 pizza chains in 84 U.S. cities — from raw data cleaning through SQL-based 
business analysis to an interactive Power BI dashboard.

## Project Overview

This project investigates why pizza deliveries get delayed, using a full analytics 
pipeline: Excel (cleaning) → Python/Jupyter (exploration) → PostgreSQL (business 
analysis via SQL) → Power BI (interactive dashboard).

## Tools & Tech Stack

- **Data Cleaning:** Excel
- **Data Processing:** Python (pandas, openpyxl), Jupyter Notebook
- **Database:** PostgreSQL, pgAdmin, SQLAlchemy, psycopg2
- **Visualization:** Power BI Desktop (Import mode), DAX
- **Version Control:** Git, GitHub

## Data

The dataset (`data/pizza_data_cleaned.xlsx`) contains 1,004 pizza delivery orders 
with 25 columns covering order details, delivery logistics, and timing across 
5 restaurant chains (Domino's, Papa John's, Little Caesars, Pizza Hut, Marco's Pizza).

### Data Cleaning
Three data quality issues were identified and fixed:
1. Inconsistent apostrophe encoding in "Marco's Pizza" (splitting it into two entries)
2. A mismatched restaurant/payment-method row (Domino's paired with a Pizza Hut-only 
   loyalty payment)
3. 12 rows where the `Is Delayed` flag contradicted the actual `Delay (min)` value

## Key Findings

- **Distance is the strongest delay predictor** (0.60 correlation) — delay rate 
  jumps from under 1% (0-3km) to 100% (9-12km), with a sharp threshold around 6-9km.
- **Traffic level matters enormously** — High traffic orders are delayed 50% of the 
  time vs. 1.8% in Low traffic.
- **Domino's has the highest overall delay rate (28.9%)** — but the root cause is 
  specific: unusually high *inconsistency* (variance) in Medium-traffic conditions, 
  not a general operational problem.
- **The delivery time estimation system appears systematically miscalibrated** — 
  every single order in the dataset misses its estimated time by at least 9 minutes.
- **8 PM is the sharpest delay spike** within the dinner rush window (94% of all 
  orders occur 6-9 PM).
- **Pizza complexity/toppings have no meaningful effect on delay** once distance 
  is controlled for.

## Dashboard

![Dashboard Screenshot]
<img width="393" height="540" alt="pizza_sales_dashbord_screenshot" src="https://github.com/user-attachments/assets/4ef6b2d2-20d3-4c5c-9215-66cad5122e11" />


The Power BI dashboard includes:
- KPI summary (delay rate, total orders, avg delay, % over 10min)
- Delay rate by distance bucket and traffic level
- Restaurant comparison and a Restaurant × Traffic Level matrix
- Hourly and monthly delay trends
- Top delay-prone cities (filtered for reliable sample size)
- Product mix (pizza type × size) treemap
- Interactive slicers (restaurant, traffic level, month, distance)


## How to Run

1. Load `data/pizza_data_cleaned.xlsx` into PostgreSQL (or use the notebook to 
   push it via SQLAlchemy)
2. Run queries in `sql/queries.sql` using pgAdmin or any PostgreSQL client
3. Open `powerbi/pizza_dashboard.pbix` in Power BI Desktop and connect it to 
   your local PostgreSQL database

## Author

Sakshee Kanawade —  [linkedin.com/in/sakshee-kanawade-2b3aba416](https://www.linkedin.com/in/sakshee-kanawade-2b3aba416/)

Email: saksheekanawade@gmail.com

