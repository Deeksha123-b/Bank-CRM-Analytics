Bank Customer Churn Analysis (SQL, Excel and Power BI)

An end-to-end analysis of a retail bank's customer data (10,000 customers across France, Germany and Spain) to understand who leaves, why they might leave, and what the bank can do about it. The project uses MySQL for analysis, Excel and Power BI for cleaning and visualisation, and ends with an interactive dashboard and retention recommendations.

Table of Contents
Project Overview
Dataset and Schema
Tools and Techniques
Project Structure
Objective Analysis
Subjective Analysis
Key Findings
Data Quality Issue Found
Recommendations
Dashboard
Limitations
How to Run
License
Project Overview

The bank wants to reduce customer churn and grow profitable segments. This project:

Measures overall and segment-level churn
Profiles customers by geography, gender, age, credit score, balance, tenure and product usage
Detects and corrects a data inconsistency in the active-member flag
Identifies customer groups with the highest churn risk
Delivers an interactive Power BI dashboard with slicers
Dataset and Schema

The database bank_churn_analysis has 7 tables. Five are lookup tables that contain only categorical labels and IDs.

Table	Description
bank_churn	Customer account data: credit score, balance, tenure, products, credit card, active status, exit status
customerinfo	Customer profile: ID, surname, age, estimated salary, geography, gender, bank joining date (Bank DOJ)
geography	Lookup: France, Germany, Spain
gender	Lookup: gender labels
exit_customer	Lookup: exit status and category
active_customer	Lookup: active-member status
credit_card	Lookup: credit card status

Key fields: CustomerId, CreditScore, Balance, Tenure, NumOfProducts, HasCrCard, IsActiveMember, EstimatedSalary, Exited, Age, Bank DOJ.

Tools and Techniques
MySQL: joins, subqueries (including correlated subqueries), CASE, RANK(), CONCAT(), LIKE, ALTER TABLE ... RENAME COLUMN, aggregation and date conversion
Excel and Power BI: data cleaning and validation, charts, conditional formatting, KPI cards, slicers
Statistics: correlation analysis and IQR-based outlier detection
Project Structure
bank-churn-analysis/
├── README.md
├── LICENSE
├── sql/
│   └── bank_churn_queries.sql
├── dashboard/
│   └── bank_churn_dashboard.pbix
├── report/
│   └── Bank_CRM_Report.docx
└── images/
    └── (charts and dashboard screenshots)

Adjust this layout to match your repository.

Objective Analysis
Topic	Approach
Account balance distribution by region	Total balance grouped by geography, shown as a donut chart
Top 5 customers by salary in the last quarter	SQL filter on quarter, sorted by estimated salary
Average products for credit card holders	AVG(NumOfProducts) where HasCrCard = 1
Churn rate by gender (most recent joining year)	Join bank_churn, customerinfo and gender, filtered on Bank DOJ
Credit score: exited vs retained	Average credit score by exit status
Salary and active accounts by gender	Average salary and active-customer percentage
Credit score segments and exit rate	CASE buckets with exit rate per bucket
Active customers with tenure over 5 years by region	Filtered join on tenure and IsActiveMember
Credit card impact on churn	Churn rate with and without a credit card
Most common product count among exited customers	Grouped count on NumOfProducts
Customer joining trend and seasonality	Month and year counts from Bank DOJ
Products vs balance for exited customers	Average balance by product count
Balance outliers among retained customers	Q1, Q3 and IQR thresholds
Table count and categorical-only tables	7 tables, 5 are lookup tables
Average income by gender and geography, ranked	RANK() over average salary
Average tenure of exited customers by age bracket	Brackets 18-30, 30-50, 50+
Correlation: salary vs balance, salary vs credit score	Scatter plots with trendlines, split by exit status
Churn ranking by credit score bucket	RANK() over churn counts
Credit card holders by age bucket	Compared to the average per bucket
Location ranking by churn and average balance	RANK() over churn count
CustomerID_Surname column	CONCAT()
Fetch ExitCategory without a JOIN	Correlated subquery
Missing values	Checked and handled in Excel and Power BI
Surnames ending in "on" with active status	LIKE '%on' and a subquery
Data discrepancy in IsActiveMember and Exited	See Data Quality Issue Found
Subjective Analysis
Long-term vs new customer behaviour
Product affinity and cross-selling
Geographic market trends
Risk management by demographic segment
Customer tenure value forecasting
Marketing campaign effectiveness
Customer exit reasons
Predictors of churn (Tenure, NumOfProducts, IsActiveMember, EstimatedSalary)
SQL-based customer segmentation
Conditional formatting for churn risk and credit card rewards
Churn rate per year and overall
Dashboard with KPIs and slicers
Approach when no questions are given
Renaming HasCrCard to Has_creditcard
Key Findings

Churn overview

Overall churn rate: 20.37% (2,037 exited customers out of 10,000).
By joining year: 19.27% (2016), 22.35% (2017), 20.21% (2018), 19.86% (2019). These are churn rates by joining year, not by the year customers left.

Who is more likely to leave

Segment	Churn rate
Age 50 and above	~45.45%
Age 30-50	~18.37%
Age 18-30	~7.56%
Female customers	~25.07%
Male customers	~16.46%
Germany	~32.44%
France	~16.15%
Spain	~16.67%
Credit score below 580	22.02% (highest score segment)

Other observations

France has the highest total account balance and the most active customers with tenure over 5 years.
Germany has the highest average balance (~120K) but also the highest churn and lowest activity, so a high balance does not mean loyalty.
Credit card ownership has almost no effect on churn (20.18% with a card vs 20.81% without).
Customers with fewer products tend to have lower churn than those with more products. Single-product customers are the most common group among exited customers.
Salary shows essentially no correlation with balance or credit score.
Long-term and new customers look very similar in balance, products, activity and churn (~20%), so tenure alone does not indicate loyalty.
Customer acquisition is seasonal, with spikes in September, November and December each year.
Data Quality Issue Found

735 customers have Exited = 1 but IsActiveMember = 1, which is impossible: 36% of exited customers and 7.35% of all records.

IsActiveMember (as given)	Exited = 0	Exited = 1
0 (inactive)	3,547	1,302
1 (active)	4,416	735

Since Exited is treated as correct, a new column IsActiveMember_Corrected sets IsActiveMember = 0 for every exited customer. Active members drop from 5,151 (51.5%) to 4,416 (44.2%). Use the original flag for predictive modelling and the corrected flag for reporting current activity.

Tenure only takes values 3 to 7 and is inconsistent with Bank DOJ (for example a 2019 joiner with 7 years of tenure). It was used as provided, and the source system should be audited.

Recommendations
Prioritise Germany for retention work, since it combines high balances with the highest churn.
Focus on customers aged 50 and above with accessible service and personalised support.
Investigate the experience of female customers, who churn at a higher rate.
Engage single-product and inactive customers with relevant offers, and monitor churn by product count as cross-selling grows.
Do not rely on balance, salary or credit score alone to judge loyalty or risk.
Time marketing campaigns around seasonal acquisition peaks and review weaker months.
Collect better data: exit dates, exit reasons, campaign records, reward participation, transactions and product names.
Build a multi-variable churn model (for example logistic regression or random forest) to measure the real importance of each predictor.
Dashboard

The Power BI dashboard has three pages:

Executive Overview: total, active, exited and retained customers, churn rate, average balance and average credit score
Customer and Churn Analysis: churn by geography, gender, age group and activity
Product and Customer Behaviour: churn by number of products and credit card ownership

Slicers filter the report by geography, gender, age group, and tenure or product count.

Limitations
Churn analysis shows associations, not causes.
The dataset has no exit dates, so true year-by-year churn cannot be calculated.
There is no campaign, reward-programme or external economic data, so marketing and reward effectiveness and regional economic effects cannot be measured directly.
Specific product combinations are not available, only the number of products per customer.
Customer value is based on balance and activity, not revenue or cost, so a full profit-based lifetime value cannot be calculated.
How to Run
Install MySQL and create the bank_churn_analysis database from your source tables.
Run the queries in sql/bank_churn_queries.sql using MySQL Workbench or the command line.
Open the .pbix file in Power BI Desktop to explore the dashboard and slicers.
The last query renames a column (ALTER TABLE bank_churn RENAME COLUMN HasCrCard TO Has_creditcard;). Run it on a copy if you want to keep the original schema, and update earlier queries if you run it first.
