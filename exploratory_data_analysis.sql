-- EXPLORATORY DATA ANALYSIS
SELECT count(*) 
FROM reservations_refined
WHERE booking_status = 'Canceled';
-- Around 1/3 of all reservations was cancelled

SELECT * FROM reservations_cleaned

-- 1) TIME ANALYSIS

-- Attempt to create arrival_date
SELECT *, CAST(CONCAT(arrival_year, '-', arrival_month, '-', arrival_day) AS DATE) AS arrival_date
FROM reservations_cleaned;

-- Check because of an error shown
SELECT DISTINCT arrival_year, arrival_month, arrival_day FROM reservations_cleaned
ORDER BY arrival_year, arrival_month, arrival_day;

-- Turns out there was mistake in database (2018 wasn't a leap year, and so 29th Feb is invalid - the years should be shifted back two years)
SELECT *, arrival_year - 2 AS corrected_arrival_year
FROM reservations_cleaned;

UPDATE reservations_cleaned
SET arrival_year = arrival_year - 2;

SELECT DISTINCT arrival_year
FROM reservations_cleaned;

ALTER TABLE reservations_cleaned
ADD arrival_date DATE;

UPDATE reservations_cleaned
SET arrival_date = CAST(CONCAT(arrival_year, '-', arrival_month, '-', arrival_day) AS DATE);

-- Check if table update worked
SELECT TOP 10 * FROM reservations_cleaned;

-- When do we see the most arrivals? (Which years/mmonths/days/seasons were the most popular?)
SELECT arrival_month, arrival_year, COUNT(*) AS cnt_arrivals
FROM reservations_cleaned
GROUP BY arrival_year, arrival_month
ORDER BY arrival_year DESC

SELECT 
  DATENAME(WEEKDAY, arrival_date) AS arrival_day_name,
  COUNT(*) AS cnt_arrivals
FROM reservations_cleaned
GROUP BY DATENAME(WEEKDAY, arrival_date)
ORDER BY cnt_arrivals DESC;

ALTER TABLE reservations_cleaned 
ADD arrival_season VARCHAR(10);

UPDATE reservations_cleaned
SET arrival_season = 
  CASE 
    WHEN arrival_month IN (12, 1, 2) THEN 'Winter'
    WHEN arrival_month IN (3, 4, 5) THEN 'Spring'
    WHEN arrival_month IN (6, 7, 8) THEN 'Summer'
    WHEN arrival_month IN (9, 10, 11) THEN 'Autumn'
  END;

SELECT arrival_season, COUNT(*)
FROM reservations_cleaned
GROUP BY arrival_season;

-- Average length of stay by month of arrival
SELECT 
  arrival_month,
  AVG(no_of_week_nights + no_of_weekend_nights) AS avg_stay
FROM reservations_cleaned
GROUP BY arrival_month
ORDER BY arrival_month;

-- When do we see the most reservations? (Which days/months/years were the most popular?)
-- Add additional columns for booking date
ALTER TABLE reservations_cleaned
ADD booking_date DATE, 
	booking_month INT, 
	booking_day INT, 
	booking_year INT;

UPDATE reservations_cleaned
SET booking_date = DATEADD(DAY,-lead_time_days, arrival_date),
	booking_month = MONTH(booking_date),
	booking_day = DAY(booking_date),
	booking_year = YEAR(booking_date);

SELECT TOP 10 * FROM reservations_cleaned;

SELECT booking_month, booking_year, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
GROUP BY booking_month, booking_year
ORDER BY cnt_reservations DESC, booking_year DESC;

SELECT 
  DATENAME(WEEKDAY, booking_date) AS booking_day_name,
  COUNT(*) AS cnt_bookings
FROM reservations_cleaned
GROUP BY DATENAME(WEEKDAY, booking_date)
ORDER BY cnt_bookings DESC;

-- Have people been booking further in advance from year to year?
SELECT 
  booking_year, 
  AVG(lead_time_days) AS avg_lead_time
FROM reservations_cleaned
GROUP BY booking_year
ORDER BY booking_year;

-- Does the season/month affect the cancellation rate?
SELECT
  arrival_month,
  COUNT(*) AS total,
  SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS canceled,
  100 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS cancel_rate
FROM reservations_cleaned
GROUP BY arrival_month
ORDER BY cancel_rate DESC;

-- Conclusions:
-- The highest number of arrivals occurs in the second half of each year, with a noticeable increase in 2016 compared to the previous year. Arrivals peak on Fridays.
-- In terms of seasonality, most arrivals happen in autumn and summer.
-- The average length of stay is 2–3 days and remains relatively consistent throughout the year.
-- Most bookings are made in the early months of the year, particularly on Mondays.
-- Year by year, the average lead time (days between booking and arrival) is decreasing.
-- The highest cancellation rates are observed during the summer holiday months

-- 2) CLIENT'S SEGMENTS

-- What customer segment generates the most income?
SELECT market_segment_type, SUM((no_of_week_nights + no_of_weekend_nights) * avg_price_per_room) AS income
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY income DESC;

-- What are the preferences of different customer segments in terms of room type and meal plan?
SELECT type_of_meal_plan, COUNT(*) AS cnt_of_reservations
FROM reservations_cleaned
GROUP BY type_of_meal_plan
ORDER BY cnt_of_reservations DESC;

SELECT room_type_reserved, COUNT(*) AS cnt_of_reservations
FROM reservations_cleaned
GROUP BY room_type_reserved
ORDER BY cnt_of_reservations DESC;

-- and together:
SELECT type_of_meal_plan, room_type_reserved, COUNT(*) AS cnt_of_reservations
FROM reservations_cleaned
GROUP BY type_of_meal_plan, room_type_reserved
ORDER BY cnt_of_reservations DESC;

-- Conclusions:
-- The Online market segment generates the highest total income among all segments.
-- For most reservations, the meal plan was not important, as it was left unselected.
-- The most common combination is Meal Plan 1 with Room_Type 1, suggesting a standard preference pattern across many bookings.

-- 3) GUESTS BEHAVIOUR

-- What is the average length of stay of guests?
SELECT AVG(no_of_week_nights + no_of_weekend_nights) AS avg_stay_nights
FROM reservations_cleaned;

-- How many guests are returning to the hotel?
WITH totals AS (
  SELECT 
    COUNT(*) AS total_guests,
    SUM(CASE WHEN repeated_guest = 1 THEN 1 ELSE 0 END) AS returning_guests
  FROM reservations_cleaned
)
SELECT 
  returning_guests,
  total_guests,
  CAST(returning_guests AS FLOAT) / total_guests * 100 AS returning_guests_percentage
FROM totals;

-- What (or rather how many) special requests are most often made by guests?
SELECT COUNT(*), no_of_special_requests
FROM reservations_cleaned
WHERE no_of_special_requests <> 0
GROUP BY no_of_special_requests;

-- Conclusions:
-- The average length of stay is 3 nights.
-- Only about 3% of guests are returning customers.
-- The vast majority of guests made only one special request.

-- 4) REVENUES AND PRICES

-- What is the average room rate?
SELECT room_type_reserved, AVG(avg_price_per_room) AS avg_price_per_room
FROM reservations_cleaned
GROUP BY room_type_reserved
ORDER BY avg_price_per_room DESC;

-- What are the price changes depending on the season and market segment?
SELECT market_segment_type, AVG(avg_price_per_room) AS avg_price_per_room
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY avg_price_per_room DESC;

SELECT arrival_season, AVG(avg_price_per_room) AS avg_price_per_room
FROM reservations_cleaned
GROUP BY arrival_season
ORDER BY avg_price_per_room DESC;

-- Conclusions:
-- Room prices vary by room type, with Room_Type 6 having the highest average rate.
-- Online and Aviation market segments tend to have higher average room prices compared to others, while the Complementary segment has the lowest.
-- The most expensive seasons on average are Summer and Autumn, while Winter tends to be the cheapest.

-- 5) RESOURCE MANAGEMENT

-- What is the demand for parking spaces?
SELECT COUNT(*)
FROM reservations_cleaned
WHERE required_car_parking_space = 1;

-- What are the trends in the number of adults and children in reservations?
SELECT COUNT(*)
FROM reservations_cleaned
WHERE no_of_children = 0;

-- What is the average number of children?
SELECT AVG(no_of_children)
FROM reservations_cleaned
WHERE no_of_children > 0;

-- Conclusions:
-- About 3% of guests requested parking spaces.
-- Most reservations were made for guests without children.
-- For bookings including children, the average number of children per reservation is approximately 1.

-- 6) LEAD TIME

-- Average lead time across all reservations
SELECT 
  ROUND(AVG(lead_time_days), 1) AS avg_lead_time_days
FROM reservations_cleaned;

-- Average lead time by booking status
SELECT 
  booking_status,
  COUNT(*) AS cnt_of_reservations,
  ROUND(AVG(lead_time_days), 1) AS avg_lead_time
FROM reservations_cleaned
GROUP BY booking_status
ORDER BY avg_lead_time DESC;

-- Lead time ranges and cancellation rates
WITH lead_time_ranges AS (
  SELECT *,
    CASE 
      WHEN lead_time_days <= 7 THEN '0–7 days'
      WHEN lead_time_days <= 14 THEN '8–14 days'
      WHEN lead_time_days <= 30 THEN '15–30 days'
      WHEN lead_time_days <= 60 THEN '31–60 days'
      WHEN lead_time_days <= 90 THEN '61–90 days'
      ELSE '90+ days'
    END AS lead_time_range
  FROM reservations_cleaned
)
SELECT 
  lead_time_range,
  COUNT(*) AS total_reservations,
  SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS canceled_reservations,
  ROUND(100 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate
FROM lead_time_ranges
GROUP BY lead_time_range
ORDER BY cancellation_rate DESC;

-- Conclusions:
-- The average lead time is approximately 85 days.
-- Canceled reservations had an average lead time nearly three times longer than those not canceled.
-- Reservations booked more than 90 days in advance showed a significantly higher cancellation rate (around 56%).