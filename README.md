# E---Commerce-Sales-Analysis

E-Commerce Sales Analysis
1. Project Overview
This is an end-to-end data analytics project analysing an e-commerce dataset to understand sales performance, profitability drivers, discount impact, customer behaviour, and delivery trends.
The project covers data cleaning, SQL analysis, Python exploratory data analysis (EDA), and dashboard creation in Power BI.

### 2. Business Problem
The business generated $2.30M in revenue over four years but achieved only a 12% profit margin, which is lower than the industry benchmark of 15–25%.

Key questions addressed:
Which products and categories are loss-making?
Do discounts increase sales or reduce profit?
Which customers generate the most value?
Which regions and segments perform best?
Are delivery delays impacting performance?
Why is revenue high but margin low?

### 3. Dataset Information
Source: Kaggle (Superstore-style dataset)
Period: 2014–2017
Records: 9,993 order lines
Orders: 5,009
Customers: 793
Geography: United States (4 regions, 49 states)

Main columns include:
Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Segment, Region, Category, Sub-Category, Sales, Quantity, Discount, Profit.

### 4. Tools Used
- Excel (Power Query) for data cleaning 
- PostgreSQL for SQL analysis
- Python (Pandas, NumPy) for data manipulation
- Matplotlib and Seaborn for visualisation
- Power BI for dashboard development

### 5. Analysis Process

### Step 1 – Data Collection
- The dataset was downloaded from Kaggle.

### Step 2 – Data Cleaning
- Removed duplicates and fixed inconsistent values
- Corrected data types for dates, numbers, and text columns
- tables : customers, orders, order_details, and products.

### Step 3 – SQL Analysis
- Loaded cleaned tables into PostgreSQL
- Wrote **28 SQL queries** across 6 sections to answer business questions:
  - Overall KPIs - total sales, profit, margin, loss
  - Geography - region, city, state-wise performance
  - Category & product - profit vs loss by sub-category
  - Discount analysis - bucket-wise impact on profit
  - Customer analysis - top customers, Pareto (80/20), lifetime value
  - Shipping - late deliveries, avg delivery time per ship mode
- Used advanced SQL: CTEs, Window Functions, CASE WHEN, Subqueries

### Step 4 – Python EDA
- Loaded all 4 CSVs and merged into one DataFrame using left joins
- Checked for nulls, duplicates, and data types
- **Feature engineering** - created new columns:
  - shipping_delay - days between order and ship date
  - loss - loss amount for unprofitable orders
  - margin - profit as % of sales per row
  - discount_bucket - discount grouped into tiers
  - month_year, month_name, year - for time series analysis
- Performed full EDA:
  - Univariate: Sales and profit distributions
  - Bivariate: Sales vs profit, discount vs profit scatter plots
  - Category & sub-category profitability charts
  - Monthly and yearly trend analysis
  - Correlation heatmap across all numeric variables

### Step 5 – Power BI Dashboard
- Built an interactive dashboard to visualise all findings
- Added slicers for **Year** and **Category** so stakeholders can filter dynamically
- Designed visuals based on the business questions answered in SQL and Python
  
## 6. Key Insights

- Tables sub-category is the largest loss contributor, losing approximately $17.7K.
- Discounts above 20% consistently lead to negative margins.
- Technology has the highest margin (around 17%), while Furniture has only 2.5% margin despite similar revenue.
- Top 20% of customers contribute around 80% of total revenue.
- Q4 sales naturally increase every year, but heavy discounting during peak demand reduces profitability.
- West region leads in both revenue and total profit.
- Some high-revenue customers generate zero or negative profit.
- Discount and profit have a strong negative relationship.

## 7. Business Recommendations

- Cap discounts at 20% and require approval for higher discounts.
- Reprice or restructure the Tables sub-category.
- Focus on growing the Technology product mix.
- Audit high-revenue but low-profit customers.
- Reduce unnecessary discounting during peak Q4 demand.
- Monitor late deliveries and proactively manage customer experience.

### 8. Project Structure

ecomm-analysis/

ecomm_queries.sql/

e-commerce_eds.ipynb/

Power BI dashboard file/

README.md/

### 9. How to Run

SQL:
Open the SQL file in PostgreSQL and run queries section by section.

Python:
Place all CSV files in the same folder as the notebook and run all cells in Jupyter Notebook.

Power BI:
Open the .pbix file and use filters to explore the dashboard.
