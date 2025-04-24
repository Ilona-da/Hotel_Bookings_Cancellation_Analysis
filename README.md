# Hotel Reservations Analysis (SQL + Power BI)

## Project Overview

This project focuses on data preparation, exploratory data analysis (EDA), and visualization based on a hotel reservations dataset sourced from Kaggle. The goal is to simulate a real-world business analysis scenario, starting with raw data and moving through structured cleaning and insights generation using SQL and Power BI.


## Data Preparation (SQL)

### 1. Data Source & Initial Challenges

The original data was provided in CSV format. During the import process into SQL Server, I encountered some issues, which led me to create a **staging table** (`reservations_staging`) for raw data ingestion. This allowed me to check, debug and control the data more effectively before shaping it into a refined, analysis-ready format.

### 2. Cleaning & Transformation

I created a new table (`reservations_refined`) and populated it using SQL `INSERT` and `UPDATE` operations, ensuring:
- Consistent data types (`TINYINT`, `BIT`, `DECIMAL`, etc.)
- Basic trimming and conversion of categorical and boolean values
- Casting strings to numeric formats where needed

Surprisingly, the dataset contained **no NULL values** or obvious dirty data - making the cleaning process fairly light in this case.

This phase focused on:
- Practicing good SQL structure
- Making the dataset easier to query and analyze in the next steps
- Preparing it for smooth integration with Power BI


## Next Steps

This project will now move into two major phases:

- **Exploratory Data Analysis (EDA)** — directly in SQL (e.g. using window functions, aggregations, and filtering)
- **Data Visualization** — using Power BI to create interactive dashboards and extract business insights