# Hotel Cancellations Trends Analysis

## Project Overview
This portfolio project simulates a real-world business analytics scenario using hotel reservation data from Kaggle. The goal was to explore the reasons behind booking cancellations and uncover actionable insights that could help reduce them.

The full process included:

- Data preparation and cleaning using SQL
- Exploratory analysis to understand patterns in guest behavior
- Interactive dashboard creation in Power BI
- Final recommendations for operational improvements

## Data Preparation (SQL)

### Source & Initial Setup
The dataset was provided in CSV format. To handle import issues and validate raw input, I first created a staging table (reservations_staging).
Then I created a refined version (reservations_refined) where I applied proper data types, initial conversions, and consistency checks.
After identifying 217 low-quality or implausible records (e.g. bookings with zero adults or zero nights), I cloned the data into a new table called reservations_cleaned and removed those rows to ensure analytical quality.

### Cleaning & Transformation
Using SQL Server, I:
- Applied proper data types (TINYINT, BIT, DECIMAL, etc.)
- Cleaned and standardized categorical values
- Converted strings to numeric types where needed

The data surprisingly had no NULLs, which allowed for a smooth transition to the analysis phase.

This stage focused on:
- Practicing clean SQL coding habits
- Structuring the dataset for analysis and Power BI import

## Exploratory Data Analysis (SQL)
The EDA phase was organized into thematic steps to simulate a structured analytics workflow. Already at this stage, initial insights began to emerge - including patterns in seasonality, guest behavior, pricing, and cancellations. Each step focused on a specific area of the dataset to uncover trends, spot inconsistencies, and prepare the data for deeper analysis and visualization in Power BI:

- **Time analysis** - Created accurate arrival and booking dates, handled data inconsistencies, added weekday, month, and season labels to support time-based insights.

- **Customer segmentation** - Analyzed market segments, room types, and meal plans to understand booking patterns across different client groups.

- **Guest behavior** - Explored variables such as length of stay, return visits, and number of special requests.

- **Revenue and pricing** - Examined room rates across segments, seasons, and room types.

- **Operational metrics** - Looked into parking demand, guest's group size.

- **Lead time dynamics** - Segmented lead times into ranges and prepared cancellation risk indicators.

- **Operational risk factors** - Connected booking attributes with cancellation likelihood to identify risk areas.

- **Cancellation patterns** - Quantified cancellation rates over time and across segments, prices, and guest types.

- **Feature engineering** - Created bins and helper columns (e.g. price bands, stay length, guest count) to support flexible segmentation and clear visuals in Power BI.

## Dashboard & Final Insights (Power BI)
The cleaned dataset was used to build a six-page Power BI report:

- **OVERVIEW** - A high-level summary of bookings, cancellations, revenue loss, and recovery.

- **TIMELINE** - Time-based trends in arrivals, bookings, and cancellations.

- **GUESTS** - Guest segmentation, behavior patterns, and cancellation likelihood across groups.

- **SERVICES** - Preferences regarding room types, meal plans, and add-ons like special requests.

- **FINANCES** - Analysis of room pricing, revenue drivers, and financial impact of cancellations.

- **INSIGHTS** - Key insights with recommendations on how to possibly reduce cancellations and recover value.

The final page brings together all findings and translates them into clear operational suggestions, highlighting which guest profiles, booking conditions, and pricing strategies are most associated with cancellations and how they can be better managed.

## View interactive report: [LINK]

## Tools Used
- **Microsoft SQL Server** - Data cleaning and EDA
- **Power BI Desktop** - Dashboard creation & storytelling

## Repository Structure
- `data/` - folder containing raw dataset:
  - `raw_data.csv` - source data file
- `sql/` - folder containing SQL scripts:
  - `data_cleaning.sql` - SQL script for data cleaning
  - `exploratory_data_analysis.sql` - SQL queries for exploratory data analysis
- `powerbi/` - folder with Power BI dashboard file:
  - `report.pbix` - fully interactive report file
- `README.md` - project documentation

This project was conducted as part of my portfolio to demonstrate SQL data cleaning, exploratory analysis, and visualization skills.

