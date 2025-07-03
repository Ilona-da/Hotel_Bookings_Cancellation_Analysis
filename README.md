# Hotel Cancellations Trends Analysis (SQL + Power BI)

## Project Overview
This project focuses on data preparation, exploratory data analysis (EDA), and visualization based on a hotel reservations dataset sourced from Kaggle. The goal is to simulate a real-world business analysis scenario, starting with raw data and moving through structured cleaning and insights generation using SQL and Power BI.

The analysis process went through several stages: from data mining, through identifying the reasons for bookings cancellation, to drawing operational conclusions and proposing specific actions to prevent those cancellations. 

## Data Preparation (SQL)

### Data Source & Initial Challenges
The original data was provided in CSV format. During the import process into SQL Server, I encountered some issues, which led me to create a **staging table** (`reservations_staging`) for raw data ingestion. This allowed me to check, debug and control the data more effectively before shaping it into a refined, analysis-ready format.

### Cleaning & Transformation
I created a new table (`reservations_refined`) and populated it using SQL `INSERT` and `UPDATE` operations, ensuring:
- Consistent data types (`TINYINT`, `BIT`, `DECIMAL`, etc.)
- Basic trimming and conversion of categorical and boolean values
- Casting strings to numeric formats where needed

Surprisingly, the dataset contained **no NULL values** or obvious dirty data - making the cleaning process fairly light in this case.

This phase focused on:
- Practicing good SQL structure
- Making the dataset easier to query and analyze in the next steps
- Preparing it for smooth integration with Power BI

## Exploratory Data Analysis (SQL)
The EDA phase was organized into thematic steps to simulate a structured analytics workflow. Already at this stage, initial insights began to emerge - including patterns in seasonality, guest behavior, pricing, and cancellations. Each step focused on a specific area of the dataset to uncover trends, spot inconsistencies, and prepare the data for deeper analysis and visualization in Power BI:

- **Time analysis** - Created accurate arrival and booking dates, handled data inconsistencies, added weekday, month, and season labels to support time-based insights.

- **Customer segmentation** - Analyzed market segments, room types, and meal plans to understand booking patterns across different client groups.

- **Guest behavior** - Explored variables such as length of stay, return visits, and number of special requests.

- **Revenue and pricing** - Examined room rates across segments, seasons, and room types.

- **Operational metrics** - Looked into parking demand, family size, and guest composition.

- **Lead time dynamics** - Segmented lead times into ranges and prepared cancellation risk indicators.

- **Operational risk factors** - Connected booking attributes with cancellation likelihood to identify risk areas.

- **Cancellation patterns** - Quantified cancellation rates over time and across segments, prices, and guest types.

- **Feature engineering** - Created bins and helper columns (e.g. price bands, stay length, guest count) to support flexible segmentation and clear visuals in Power BI.

## Dashboard & Final Insights (Power BI)
The refined dataset was connected to Power BI to create a clear, interactive dashboard structured into six thematic pages:

- **OVERVIEW** - A high-level summary of bookings, cancellations, revenue loss, and recovery.

- **TIMELINE** - Time-based trends in arrivals, bookings, and cancellations.

- **GUESTS** - Guest segmentation, behavior patterns, and cancellation likelihood across groups.

- **SERVICES** - Preferences regarding room types, meal plans, and add-ons like parking or special requests.

- **FINANCES** - Analysis of room pricing, revenue drivers, and financial impact of cancellations.

- **INSIGHTS** - key insights with recommendations on how to possibly reduce cancellations and recover value.

The final page brings together all findings and translates them into clear operational suggestions, highlighting which guest profiles, booking conditions, and pricing strategies are most associated with cancellations and how they can be better managed.

## Tools Used
- **Microsoft SQL Server** - Data cleaning and EDA
- **Power BI** (Desktop version) - Data visualization and dashboard creation

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

