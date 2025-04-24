-- Create empty table with proper data types
CREATE TABLE reservations_refined (
    booking_id NVARCHAR(20) PRIMARY KEY,
    no_of_adults TINYINT,
    no_of_children TINYINT,
    no_of_weekend_nights TINYINT,
    no_of_week_nights TINYINT,
    type_of_meal_plan NVARCHAR(20),
    required_car_parking_space BIT,
    room_type_reserved NVARCHAR(20),
    lead_time_days SMALLINT,
    arrival_year SMALLINT,
    arrival_month TINYINT,
    arrival_day TINYINT,
    market_segment_type NVARCHAR(20),
    repeated_guest BIT,
    no_of_previous_cancellations TINYINT,
    no_of_previous_booking_not_canceled TINYINT,
    avg_price_per_room DECIMAL(10,2),
    no_of_special_requests TINYINT,
    booking_status NVARCHAR(20)
);

-- Insert data from staging table with initial cleaning and data type conversion
INSERT INTO reservations_refined
SELECT
    booking_id,
    TRY_CAST(no_of_adults AS TINYINT),
    TRY_CAST(no_of_children AS TINYINT),
    TRY_CAST(no_of_weekend_nights AS TINYINT),
    TRY_CAST(no_of_week_nights AS TINYINT),
    type_of_meal_plan,
    CASE LTRIM(RTRIM(required_car_parking_space)) WHEN '1' THEN 1 WHEN '0' THEN 0 ELSE NULL END,
    room_type_reserved,
    TRY_CAST(lead_time_days AS SMALLINT),
    TRY_CAST(arrival_year AS SMALLINT),
    TRY_CAST(arrival_month AS TINYINT),
    TRY_CAST(arrival_date AS TINYINT),
    market_segment_type,
    CASE LTRIM(RTRIM(repeated_guest)) WHEN '1' THEN 1 WHEN '0' THEN 0 ELSE NULL END,
    TRY_CAST(no_of_previous_cancellations AS TINYINT),
    TRY_CAST(no_of_previous_bookings_not_canceled AS TINYINT),
    TRY_CAST(avg_price_per_room AS DECIMAL(10,2)),
    TRY_CAST(no_of_special_requests AS TINYINT),
    booking_status
FROM reservations_staging;

-- Check for NULL values
SELECT
  COUNT(*) AS total_records,
  SUM(CASE WHEN booking_id                   IS NULL THEN 1 ELSE 0 END) AS null_booking_id,
  SUM(CASE WHEN no_of_adults                 IS NULL THEN 1 ELSE 0 END) AS null_adults,
  SUM(CASE WHEN no_of_children               IS NULL THEN 1 ELSE 0 END) AS null_children,
  SUM(CASE WHEN no_of_weekend_nights         IS NULL THEN 1 ELSE 0 END) AS null_weekend_nights,
  SUM(CASE WHEN no_of_week_nights            IS NULL THEN 1 ELSE 0 END) AS null_week_nights,
  SUM(CASE WHEN type_of_meal_plan            IS NULL THEN 1 ELSE 0 END) AS null_meal_plan,
  SUM(CASE WHEN required_car_parking_space   IS NULL THEN 1 ELSE 0 END) AS null_parking,
  SUM(CASE WHEN room_type_reserved           IS NULL THEN 1 ELSE 0 END) AS null_room_type,
  SUM(CASE WHEN lead_time_days               IS NULL THEN 1 ELSE 0 END) AS null_lead_time,
  SUM(CASE WHEN arrival_year                 IS NULL THEN 1 ELSE 0 END) AS null_arrival_year,
  SUM(CASE WHEN arrival_month                IS NULL THEN 1 ELSE 0 END) AS null_arrival_month,
  SUM(CASE WHEN arrival_day                  IS NULL THEN 1 ELSE 0 END) AS null_arrival_day,
  SUM(CASE WHEN market_segment_type          IS NULL THEN 1 ELSE 0 END) AS null_market_segment,
  SUM(CASE WHEN repeated_guest               IS NULL THEN 1 ELSE 0 END) AS null_repeated_guest,
  SUM(CASE WHEN no_of_previous_cancellations IS NULL THEN 1 ELSE 0 END) AS null_prev_cancellations,
  SUM(CASE WHEN no_of_previous_booking_not_canceled IS NULL THEN 1 ELSE 0 END) AS null_prev_not_canceled,
  SUM(CASE WHEN avg_price_per_room           IS NULL THEN 1 ELSE 0 END) AS null_avg_price,
  SUM(CASE WHEN no_of_special_requests       IS NULL THEN 1 ELSE 0 END) AS null_special_requests,
  SUM(CASE WHEN booking_status               IS NULL THEN 1 ELSE 0 END) AS null_booking_status
FROM reservations_refined;

-- Checking booking_id uniqness before setting primary key
SELECT COUNT(DISTINCT booking_id) AS distinct_bookings, COUNT(*) AS total_bookings
FROM reservations_refined;