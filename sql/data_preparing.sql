/*
  This script imports raw data, performs initial data cleaning, 
  checks for duplicates, missing and suspicious values, and creates a refined table.
  Later used for exploratory data analysis (EDA).
*/

USE hotel_reservations;

/* =====================================================
STEP 1: Create Refined Table and Import Data
===================================================== */

/* Create empty table with proper data types */
CREATE TABLE reservations_refined (
  booking_id NVARCHAR(20) PRIMARY KEY
  , no_of_adults TINYINT
  , no_of_children TINYINT
  , no_of_weekend_nights TINYINT
  , no_of_week_nights TINYINT
  , type_of_meal_plan NVARCHAR(20)
  , required_car_parking_space BIT
  , room_type_reserved NVARCHAR(20)
  , lead_time_days SMALLINT
  , arrival_year SMALLINT
  , arrival_month TINYINT
  , arrival_day TINYINT
  , market_segment_type NVARCHAR(20)
  , repeated_guest BIT
  , no_of_previous_cancellations TINYINT
  , no_of_previous_booking_not_canceled TINYINT
  , avg_price_per_room DECIMAL(10,2)
  , no_of_special_requests TINYINT
  , booking_status NVARCHAR(20)
);

/* Insert data from staging table with initial cleaning and data type conversion*/
INSERT INTO reservations_refined
SELECT
  booking_id
  , TRY_CAST(no_of_adults AS TINYINT)
  , TRY_CAST(no_of_children AS TINYINT)
  , TRY_CAST(no_of_weekend_nights AS TINYINT)
  , TRY_CAST(no_of_week_nights AS TINYINT)
  , type_of_meal_plan
  , CASE LTRIM(RTRIM(required_car_parking_space)) WHEN '1' THEN 1 WHEN '0' THEN 0 ELSE NULL END
  , room_type_reserved
  , TRY_CAST(lead_time_days AS SMALLINT)
  , TRY_CAST(arrival_year AS SMALLINT)
  , TRY_CAST(arrival_month AS TINYINT)
  /* Rename arrival_date to arrival_day when inserting into refined table */
  , TRY_CAST(arrival_date AS TINYINT)
  , market_segment_type
  , CASE LTRIM(RTRIM(repeated_guest)) WHEN '1' THEN 1 WHEN '0' THEN 0 ELSE NULL END
  , TRY_CAST(no_of_previous_cancellations AS TINYINT)
  , TRY_CAST(no_of_previous_booking_not_canceled AS TINYINT)
  , TRY_CAST(avg_price_per_room AS DECIMAL(10,2))
  , TRY_CAST(no_of_special_requests AS TINYINT)
  , booking_status
FROM reservations_staging;

/* Check booking_id uniqness before setting primary key */
SELECT 
  COUNT(DISTINCT booking_id) AS distinct_bookings
  , COUNT(*) AS total_bookings
FROM reservations_refined;

/* =====================================================
STEP 2: Data Cleaning
===================================================== */

/* Check for empty values */
SELECT
  COUNT(*) AS total_records
  , SUM(CASE WHEN booking_id                   IS NULL THEN 1 ELSE 0 END) AS null_booking_id
  , SUM(CASE WHEN no_of_adults                 IS NULL THEN 1 ELSE 0 END) AS null_adults
  , SUM(CASE WHEN no_of_children               IS NULL THEN 1 ELSE 0 END) AS null_children
  , SUM(CASE WHEN no_of_weekend_nights         IS NULL THEN 1 ELSE 0 END) AS null_weekend_nights
  , SUM(CASE WHEN no_of_week_nights            IS NULL THEN 1 ELSE 0 END) AS null_week_nights
  , SUM(CASE WHEN type_of_meal_plan            IS NULL THEN 1 ELSE 0 END) AS null_meal_plan
  , SUM(CASE WHEN required_car_parking_space   IS NULL THEN 1 ELSE 0 END) AS null_parking
  , SUM(CASE WHEN room_type_reserved           IS NULL THEN 1 ELSE 0 END) AS null_room_type
  , SUM(CASE WHEN lead_time_days               IS NULL THEN 1 ELSE 0 END) AS null_lead_time
  , SUM(CASE WHEN arrival_year                 IS NULL THEN 1 ELSE 0 END) AS null_arrival_year
  , SUM(CASE WHEN arrival_month                IS NULL THEN 1 ELSE 0 END) AS null_arrival_month
  , SUM(CASE WHEN arrival_day                  IS NULL THEN 1 ELSE 0 END) AS null_arrival_day
  , SUM(CASE WHEN market_segment_type          IS NULL THEN 1 ELSE 0 END) AS null_market_segment
  , SUM(CASE WHEN repeated_guest               IS NULL THEN 1 ELSE 0 END) AS null_repeated_guest
  , SUM(CASE WHEN no_of_previous_cancellations IS NULL THEN 1 ELSE 0 END) AS null_prev_cancellations
  , SUM(CASE WHEN no_of_previous_booking_not_canceled IS NULL THEN 1 ELSE 0 END) AS null_prev_not_canceled
  , SUM(CASE WHEN avg_price_per_room           IS NULL THEN 1 ELSE 0 END) AS null_avg_price
  , SUM(CASE WHEN no_of_special_requests       IS NULL THEN 1 ELSE 0 END) AS null_special_requests
  , SUM(CASE WHEN booking_status               IS NULL THEN 1 ELSE 0 END) AS null_booking_status
FROM reservations_refined;

SELECT COUNT(*) FROM reservations_refined;

/* Check for duplicates */
SELECT booking_id, COUNT(*) AS cnt
FROM reservations_refined
GROUP BY booking_id
HAVING COUNT(*) > 1;

/* Check for extreme values */
SELECT 
  MIN(no_of_adults) AS min_adults, MAX(no_of_adults) AS max_adults
  , MIN(no_of_children) AS min_children, MAX(no_of_children) AS max_children
  , MIN(no_of_weekend_nights) AS min_weekend_nights, MAX(no_of_weekend_nights) AS max_weekend_nights
  , MIN(lead_time_days) AS min_lead_time_d, MAX(lead_time_days) AS max_lead_time_d
  , MIN(arrival_month) AS min_arrival_m, MAX(arrival_month) AS max_arrival_m
  , MIN(arrival_year) AS min_arrival_y, MAX(arrival_year) AS max_arrival_y
  , MIN(arrival_day) AS min_arrival_d, MAX(arrival_day) AS max_arrival_d
  , MIN(no_of_previous_cancellations) AS min_of_cancel, MAX(no_of_previous_cancellations) AS max_of_cancel
  , MIN(no_of_previous_booking_not_canceled) AS min_of_no_cancel, MAX(no_of_previous_booking_not_canceled) AS max_of_no_cancel
  , MIN(avg_price_per_room) AS min_avg_price, MAX(avg_price_per_room) AS max_avg_price
  , MIN(no_of_special_requests) AS min_special_req, MAX(no_of_special_requests) AS max_special_req
  , MIN(no_of_week_nights) AS min_week_nights, MAX(no_of_week_nights) AS max_week_nights
FROM reservations_refined;

/* Check for suspicious or implausible values */
SELECT 
  SUM(CASE WHEN no_of_adults = 0 THEN 1 ELSE 0 END) AS cnt_zero_adults
  , SUM(CASE WHEN no_of_children > 0 AND no_of_adults = 0 THEN 1 ELSE 0 END) AS cnt_children_without_adults
  , SUM(CASE WHEN no_of_week_nights = 0 AND no_of_weekend_nights = 0 THEN 1 ELSE 0 END) AS cnt_zero_total_nights
  , SUM(CASE WHEN avg_price_per_room = 0 THEN 1 ELSE 0 END) AS cnt_zero_price
  , SUM(CASE WHEN lead_time_days > 365 THEN 1 ELSE 0 END) AS cnt_long_lead_time_days
FROM reservations_refined;

/* Check how many records to remove (139 and 78 rows) */
SELECT * 
FROM reservations_refined 
WHERE no_of_adults = 0;

SELECT * 
FROM reservations_refined 
WHERE no_of_week_nights = 0 AND no_of_weekend_nights = 0;

/* Check for market segment (around 65% of rows are Complementary market segment, the rest is Online) 
> those records will stay */
SELECT * 
FROM reservations_refined 
WHERE avg_price_per_room = 0;

/* Check booking status for rows with very long lead time (95% is canceled) */
SELECT COUNT(*)
FROM reservations_refined
WHERE lead_time_days > 365 AND booking_status = 'Canceled';

/* Create table copy to save data before deleting records */
SELECT * 
INTO reservations_cleaned 
FROM reservations_refined;

/* Check once again how many records to remove */
SELECT COUNT(*) AS to_be_removed
FROM reservations_cleaned
WHERE 
  no_of_adults = 0
  OR (no_of_week_nights = 0 AND no_of_weekend_nights = 0);

/* Remove chosen records */
DELETE FROM reservations_cleaned
WHERE 
  no_of_adults = 0
  OR (no_of_week_nights = 0 AND no_of_weekend_nights = 0);

/* Review full cleaned table */
SELECT * 
FROM reservations_cleaned;

/* Standarize the data (only for debugging, consider limiting columns in production) */
SELECT * FROM reservations_cleaned;
SELECT DISTINCT type_of_meal_plan FROM reservations_cleaned;
SELECT DISTINCT room_type_reserved FROM reservations_cleaned;
SELECT DISTINCT market_segment_type FROM reservations_cleaned;
SELECT DISTINCT booking_status FROM reservations_cleaned;

UPDATE reservations_cleaned
SET 
  room_type_reserved = REPLACE(room_type_reserved, '_', ' ')
  , booking_status = REPLACE(booking_status, '_', ' ');

/* Create column with arrival_data */
SELECT
  *
  , CAST(CONCAT(arrival_year, '-', arrival_month, '-', arrival_day) AS DATE) AS arrival_date
  , DATEADD(DAY, -lead_time, CAST(CONCAT(arrival_year, '-', arrival_month, '-', arrival_day) AS DATE)) AS booking_date
FROM hotel_reservations;

