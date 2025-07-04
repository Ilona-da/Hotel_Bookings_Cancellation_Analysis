/*
  This script performs initial exploratory data analysis.
*/

SELECT COUNT(*) 
FROM reservations_cleaned
WHERE booking_status = 'Canceled';
/* Around 1/3 of all reservations was canceled */

/* =====================================================
STEP 1: Time analysis
===================================================== */

/* Attempt to create arrival_date */
SELECT DATEFROMPARTS(arrival_year, arrival_month, arrival_day) AS arrival_date
FROM reservations_cleaned;

/* Check because of an error shown */
SELECT 
	DISTINCT arrival_year
	, arrival_month
	, arrival_day 
FROM reservations_cleaned
ORDER BY 
	arrival_year
	, arrival_month
	, arrival_day;

/* Turns out there was mistake in database (2018 wasn't a leap year, and so 29th Feb is invalid - 
the years should be shifted back two years) */
SELECT DISTINCT arrival_year - 2 AS corrected_arrival_year
FROM reservations_cleaned;

UPDATE reservations_cleaned
SET arrival_year = arrival_year - 2;

SELECT DISTINCT arrival_year
FROM reservations_cleaned;

ALTER TABLE reservations_cleaned
ADD arrival_date DATE;

UPDATE reservations_cleaned
SET arrival_date = DATEFROMPARTS(arrival_year, arrival_month, arrival_day);

/*  Check if table update worked */
SELECT TOP 10 * 
FROM reservations_cleaned;

/* When do we see the most arrivals? (Which years/mmonths/days/seasons were the most popular?) */
SELECT 
	arrival_year
	, arrival_month
	, COUNT(*) AS cnt_arrivals
FROM reservations_cleaned
GROUP BY arrival_year, arrival_month
ORDER BY arrival_year DESC;

SELECT 
	DATENAME(WEEKDAY, arrival_date) AS arrival_day_name
	, COUNT(*) AS cnt_arrivals
FROM reservations_cleaned
GROUP BY DATENAME(WEEKDAY, arrival_date)
ORDER BY cnt_arrivals DESC;

/* Additional column with arrival season */
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

SELECT arrival_season, COUNT(*) AS cnt_arrivals
FROM reservations_cleaned
GROUP BY arrival_season;

/* Average length of stay by month of arrival */
SELECT 
	arrival_month
	, AVG(no_of_week_nights + no_of_weekend_nights) AS avg_stay_days
FROM reservations_cleaned
GROUP BY arrival_month
ORDER BY arrival_month;

/* When do we see the most reservations? (Which days/months/years were the most popular?)
Add columns for booking date */

ALTER TABLE reservations_cleaned
ADD 
	booking_date DATE
	, booking_month INT 
	, booking_day INT
	, booking_year INT;

UPDATE reservations_cleaned
SET 
	booking_date = DATEADD(DAY, -lead_time_days, arrival_date)
	, booking_month = MONTH(booking_date)
	, booking_day = DAY(booking_date)
	, booking_year = YEAR(booking_date);

SELECT TOP 10 * FROM reservations_cleaned;

SELECT 
	booking_year
	, booking_month
	, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
GROUP BY booking_year, booking_month
ORDER BY cnt_reservations DESC;

SELECT 
	DATENAME(WEEKDAY, booking_date) AS booking_day_name
	, COUNT(*) AS cnt_bookings
FROM reservations_cleaned
GROUP BY DATENAME(WEEKDAY, booking_date)
ORDER BY cnt_bookings DESC;

/* Have people been booking further in advance from year to year? */
SELECT 
	booking_year 
	, AVG(lead_time_days) AS avg_lead_time_days
FROM reservations_cleaned
GROUP BY booking_year
ORDER BY booking_year;

/* Does the season/month affect the cancellation rate? */
SELECT
	arrival_month
	, COUNT(*) AS total
	, SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS canceled
	, CAST(SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS cancel_rate
FROM reservations_cleaned
GROUP BY arrival_month
ORDER BY cancel_rate DESC;

/*
Conclusions:
- The highest number of arrivals occurs in the second half of each year, with a noticeable increase in 2016 compared to the previous year. Arrivals peak on Fridays.
- In terms of seasonality, most arrivals happen in autumn and summer.
- The average length of stay is 2–3 days and remains relatively consistent throughout the year.
- Most bookings are made in the early months of the year, particularly on Mondays.
- Year by year, the average lead time (days between booking and arrival) is decreasing.
- The highest cancellation rates are observed during the summer holiday months
*/

/* =====================================================
STEP 2: Client's segments
===================================================== */

/* What customer segment generates the most income? */
SELECT 
	market_segment_type
	, CAST(SUM((no_of_week_nights + no_of_weekend_nights) * avg_price_per_room) AS DECIMAL(10, 2)) AS income
	, CAST(SUM((no_of_week_nights + no_of_weekend_nights) * avg_price_per_room) * 100.0 / 
		SUM(SUM((no_of_week_nights + no_of_weekend_nights) * avg_price_per_room)) OVER() AS DECIMAL(5,2)) AS income_pct
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY income DESC;

/*  What are the preferences of different customer segments in terms of room type and meal plan? */
SELECT type_of_meal_plan, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
GROUP BY type_of_meal_plan
ORDER BY cnt_reservations DESC;

SELECT 
	room_type_reserved
	, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
GROUP BY room_type_reserved
ORDER BY cnt_reservations DESC;

/* and together: */
SELECT 
	type_of_meal_plan 
	, room_type_reserved
	, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
GROUP BY type_of_meal_plan, room_type_reserved
ORDER BY cnt_reservations DESC;

/*
Conclusions:
- The Online market segment generates the highest total income among all segments.
- For most reservations, the meal plan was not important, as it was left unselected.
- The most common combination is Meal Plan 1 with Room_Type 1, suggesting a standard preference pattern across many bookings.
*/

/* =====================================================
STEP 3: Guest behaviour
===================================================== */

/* What is the average length of stay of guests? */
SELECT AVG(no_of_week_nights + no_of_weekend_nights) AS avg_stay_length
FROM reservations_cleaned;

/* How many guests are returning to the hotel? */
SELECT
	COUNT(CASE WHEN repeated_guest = 1 THEN 1 END) AS returning_guests
	, COUNT(*) AS total_guests
	, CAST(COUNT(CASE WHEN repeated_guest = 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS returning_guests_rate
FROM reservations_cleaned;

/* How many special requests are made by guests? */
SELECT 
	no_of_special_requests
	, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
WHERE no_of_special_requests != 0
GROUP BY no_of_special_requests;

/*
Conclusions:
- The average length of stay is 3 nights.
- Only about 3% of guests are returning customers.
- The vast majority of guests made only one special request.
*/

/* =====================================================
STEP 4: Revenues and prices
===================================================== */

/* What is the average room rate? */
SELECT 
	room_type_reserved
	, CAST(AVG(avg_price_per_room) AS DECIMAL(7, 2)) AS avg_room_rate
FROM reservations_cleaned
GROUP BY room_type_reserved
ORDER BY avg_room_rate DESC;

/* What are the price changes depending on the season and market segment? */
SELECT 
	market_segment_type
	, CAST(AVG(avg_price_per_room) AS DECIMAL(7, 2)) AS avg_room_rate
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY avg_room_rate DESC;

SELECT 
	arrival_season
	, CAST(AVG(avg_price_per_room) AS DECIMAL(7, 2)) AS avg_room_rate
FROM reservations_cleaned
GROUP BY arrival_season
ORDER BY avg_room_rate DESC;

/*
Conclusions:
- Room prices vary by room type, with Room_Type 6 having the highest average rate.
- Online and Aviation market segments tend to have higher average room prices compared to others, while the Complementary segment has the lowest.
- The most expensive seasons on average are Summer and Autumn, while Winter tends to be the cheapest.
*/

/* =====================================================
STEP 5: Resource management
===================================================== */

/* What is the demand for parking spaces? */
SELECT COUNT(*) AS cnt_parking_requested
FROM reservations_cleaned
WHERE required_car_parking_space = 1;

/* What are the trends in the number of adults and children in reservations? */
SELECT COUNT(*) AS cnt_no_children
FROM reservations_cleaned
WHERE no_of_children = 0;

/* What is the average number of children? */
SELECT AVG(no_of_children)
FROM reservations_cleaned
WHERE no_of_children > 0;

/*
Conclusions:
- About 3% of guests requested parking spaces.
- Most reservations were made for guests without children.
- For bookings including children, the average number of children per reservation is approximately 1.
*/

/* =====================================================
STEP 6: Lead time
===================================================== */

/* Average lead time across all reservations */
SELECT ROUND(AVG(lead_time_days), 1) AS avg_lead_time_days
FROM reservations_cleaned;

/* Average lead time by booking status */
SELECT 
	booking_status
	, COUNT(*) AS cnt_reservations
	, ROUND(AVG(lead_time_days), 1) AS avg_lead_time
FROM reservations_cleaned
GROUP BY booking_status
ORDER BY avg_lead_time DESC;

/* Lead time ranges and cancellation rates */
WITH lead_time_ranges AS (
	SELECT 
		*
		, CASE 
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
	lead_time_range
	, COUNT(*) AS total_reservations
	, SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS canceled_reservations
	, ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate
FROM lead_time_ranges
GROUP BY lead_time_range
ORDER BY cancellation_rate DESC;

/*
Conclusions:
- The average lead time is approximately 85 days.
- Canceled reservations had an average lead time nearly three times longer than those not canceled.
- Reservations booked more than 90 days in advance showed a significantly higher cancellation rate (around 56%).
*/

/* =====================================================
STEP 7: Operational analysis
===================================================== */

/* Average number of special requests per booking */
SELECT ROUND(AVG(no_of_special_requests), 2) AS avg_special_requests
FROM reservations_cleaned;

/* Special Requests vs Cancellations */
SELECT 
	no_of_special_requests
	, COUNT(*) AS cnt_reservations
	, SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cnt_cancellations
	, ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_cancellations
FROM reservations_cleaned
GROUP BY no_of_special_requests
ORDER BY no_of_special_requests;

/* Special requests vs average revenue (for completed reservations only) */
SELECT 
	no_of_special_requests
	, ROUND(AVG(avg_price_per_room * (no_of_week_nights + no_of_weekend_nights)), 2) AS avg_revenue
FROM reservations_cleaned
WHERE booking_status = 'Not Canceled'
GROUP BY no_of_special_requests
ORDER BY no_of_special_requests;

/* Average number of special requests by market segment and room type */
SELECT 
	market_segment_type
	, room_type_reserved
	, ROUND(AVG(no_of_special_requests), 2) AS avg_special_requests
FROM reservations_cleaned
GROUP BY market_segment_type, room_type_reserved
ORDER BY market_segment_type, room_type_reserved;

/* Number of bookings by market segment */
SELECT 
	market_segment_type
	, COUNT(*) AS cnt_reservations
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY cnt_reservations DESC;

/* Cancellations by market segment */
SELECT 
	market_segment_type
	, COUNT(*) AS cnt_reservations
	, SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cnt_cancellations
	, ROUND(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_cancellations
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY pct_cancellations DESC;

/* Market segment: average lead time and revenue (only non-cancelled) */
SELECT 
	market_segment_type
	, ROUND(AVG(lead_time_days), 1) AS avg_lead_time
	, ROUND(AVG(avg_price_per_room * (no_of_week_nights + no_of_weekend_nights)), 2) AS avg_revenue
FROM reservations_cleaned
WHERE booking_status = 'Not Canceled'
GROUP BY market_segment_type
ORDER BY avg_revenue DESC;

/* Market segment: average number of nights and special requests */
SELECT 
	market_segment_type
	, ROUND(AVG(no_of_week_nights + no_of_weekend_nights), 1) AS avg_nights
	, ROUND(AVG(no_of_special_requests), 1) AS avg_special_requests
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY avg_nights DESC;

/* =====================================================
STEP 8: Reservations and cancelations
===================================================== */

/* What is the cancellation rate? */
SELECT 
	COUNT(*) AS cnt_reservations
	, SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cnt_cancelations
	, CAST(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM reservations_cleaned;

/* more detailed time breakdown: */
SELECT 
	arrival_year
	, arrival_month
	, COUNT(*) AS cnt_reservations
	, SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) AS cnt_cancelations
	, CAST(100.0 * SUM(
		CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM reservations_cleaned
GROUP BY arrival_year, arrival_month
ORDER BY arrival_year, arrival_month;

/* Does lead time influence cancellation of a reservation? */
WITH lead_grouped AS (
	SELECT 
		CASE 
			WHEN lead_time_days < 7 THEN '0-6 days'
			WHEN lead_time_days < 30 THEN '7-29 days'
			WHEN lead_time_days < 90 THEN '30-89 days'
			ELSE '90+ days'
		END AS lead_time_range
		, booking_status
	FROM reservations_cleaned
)
SELECT 
	lead_time_range
	, COUNT(*) AS cnt_reservations
	, CAST(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM lead_grouped
GROUP BY lead_time_range
ORDER BY lead_time_range;

/* Market segment - some booking sources are less stable */
SELECT 
	market_segment_type
	, COUNT(*) AS cnt_reservations
	, CAST(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM reservations_cleaned
GROUP BY market_segment_type
ORDER BY pct_cancelations DESC;

/* Price and cancellation rate */
WITH price_grouped AS (
	SELECT 
		CASE 
			WHEN avg_price_per_room < 50 THEN '<50 EUR'
			WHEN avg_price_per_room < 100 THEN '50-99 EUR'
			ELSE '100+ EUR'
		END AS price_range
		, booking_status
	FROM reservations_cleaned
)
SELECT 
	price_range
	, COUNT(*) AS cnt_reservations
	, CAST(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM price_grouped
GROUP BY price_range
ORDER BY price_range;

/* Select three most expensive reservations per segment each year */
SELECT *
	FROM (
		SELECT 
			booking_id,
			arrival_year,
			market_segment_type,
			avg_price_per_room,
			ROW_NUMBER() OVER (PARTITION BY market_segment_type ORDER BY avg_price_per_room DESC) AS rn
		FROM reservations_cleaned
		) AS ranked
	WHERE rn <= 3;

/* Special requests - maybe more requests = fewer cancellations? */
SELECT 
	no_of_special_requests
	, COUNT(*) AS cnt_reservations
	, CAST(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM reservations_cleaned
GROUP BY no_of_special_requests
ORDER BY no_of_special_requests;

/* Returning Guests - Do loyal guests cancel less? */
SELECT 
	repeated_guest
	, COUNT(*) AS cnt_reservations
	, CAST(100.0 * SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5, 2)) AS pct_cancelations
FROM reservations_cleaned
GROUP BY repeated_guest;

/*
Conclusions:
- Around one third of bookings is cancelled.
- The longer lead time, the more cancellations.
- Cancellations happen more often in Online market segment, while Complementary has the lowest cancel rate.
- The more expensive room, the less cancellations.
- The more requests, the less cancellations.
- Loyal guests (who reserved room more than once) cancel much less.
*/

/* =====================================================
STEP 9: Feature engineering – segmentation bins + helper columns
===================================================== */

/* Length of stay (raw + range) */
ALTER TABLE reservations_cleaned 
ADD length_of_stay SMALLINT, length_of_stay_range VARCHAR(20);

UPDATE reservations_cleaned
SET length_of_stay = no_of_week_nights + no_of_weekend_nights;

UPDATE reservations_cleaned
SET length_of_stay_range = 
	CASE 
		WHEN length_of_stay <= 1 THEN '1 night'
		WHEN length_of_stay <= 3 THEN '2-3 nights'
		WHEN length_of_stay <= 6 THEN '4-6 nights'
		WHEN length_of_stay <= 10 THEN '7-10 nights'
		ELSE '11+ nights'
	END;

ALTER TABLE reservations_cleaned
ADD length_of_stay_range_sort TINYINT;

UPDATE reservations_cleaned
SET length_of_stay_range_sort = 
	CASE 
		WHEN length_of_stay <= 1 THEN 1
		WHEN length_of_stay <= 3 THEN 2
		WHEN length_of_stay <= 6 THEN 3
		WHEN length_of_stay <= 10 THEN 4
		ELSE 5
	END;

/* Lead time (range) */
ALTER TABLE reservations_cleaned 
ADD lead_time_range VARCHAR(20);

UPDATE reservations_cleaned
SET lead_time_range = 
	CASE 
		WHEN lead_time_days <= 7 THEN '0-7 days'
		WHEN lead_time_days <= 14 THEN '8-14 days'
		WHEN lead_time_days <= 30 THEN '15-30 days'
		WHEN lead_time_days <= 60 THEN '31-60 days'
		WHEN lead_time_days <= 90 THEN '61-90 days'
		WHEN lead_time_days <= 180 THEN '91-180 days'
		ELSE '180+ days'
	END;

ALTER TABLE reservations_cleaned
ADD lead_time_range_sort TINYINT;

UPDATE reservations_cleaned
SET lead_time_range_sort = 
	CASE 
		WHEN lead_time_days <= 7 THEN 1
		WHEN lead_time_days <= 14 THEN 2
		WHEN lead_time_days <= 30 THEN 3
		WHEN lead_time_days <= 60 THEN 4
		WHEN lead_time_days <= 90 THEN 5
		WHEN lead_time_days <= 180 THEN 6
		ELSE 7
	END;

/* Number of guests (sum + range) */
ALTER TABLE reservations_cleaned
ADD no_of_guests TINYINT, no_of_guests_range VARCHAR(20);

UPDATE reservations_cleaned
SET no_of_guests = no_of_adults + no_of_children;

UPDATE reservations_cleaned
SET no_of_guests_range =
	CASE 
		WHEN no_of_guests = 1 THEN '1'
		WHEN no_of_guests = 2 THEN '2'
		WHEN no_of_guests <= 5 THEN '3-5'
		WHEN no_of_guests <= 10 THEN '6-10'
		ELSE '10+'
	END;

ALTER TABLE reservations_cleaned
ADD no_of_guests_range_sort TINYINT;

UPDATE reservations_cleaned
SET no_of_guests_range_sort =
	CASE 
		WHEN no_of_guests = 1 THEN 1
		WHEN no_of_guests = 2 THEN 2
		WHEN no_of_guests <= 5 THEN 3
		WHEN no_of_guests <= 10 THEN 4
		ELSE 5
	END;

/* Price bins */
ALTER TABLE reservations_cleaned 
ADD avg_price_per_room_range VARCHAR(20);

UPDATE reservations_cleaned
SET avg_price_per_room_range = 
	CASE 
		WHEN avg_price_per_room >= 550 THEN '550+'
		ELSE CONCAT(
		CAST(FLOOR(avg_price_per_room / 25.0) * 25 AS VARCHAR),
        '-',
        CAST(FLOOR(avg_price_per_room / 25.0) * 25 + 25 AS VARCHAR)
		)
	END;

ALTER TABLE reservations_cleaned
ADD avg_price_per_room_range_sort TINYINT;

UPDATE reservations_cleaned
SET avg_price_per_room_range_sort =
	CASE 
		WHEN avg_price_per_room >= 550 THEN 99
		ELSE FLOOR(avg_price_per_room / 25.0)
	END;

/* Children status helper column */
ALTER TABLE reservations_cleaned 
ADD with_children BIT;

UPDATE reservations_cleaned
SET with_children = 
	CASE
		WHEN no_of_children = 0 THEN 0
		ELSE 1
	END;

/* Sorting helper columns for meal type and room type reserved */
ALTER TABLE reservations_cleaned
ADD type_of_meal_plan_sort TINYINT;

UPDATE reservations_cleaned
SET type_of_meal_plan_sort =
	CASE 
		WHEN type_of_meal_plan = 'Meal Plan 1' THEN 1
		WHEN type_of_meal_plan = 'Meal Plan 2' THEN 2
		WHEN type_of_meal_plan = 'Meal Plan 3' THEN 3
		ELSE 4
	END;

ALTER TABLE reservations_cleaned
ADD room_type_reserved_sort TINYINT;

UPDATE reservations_cleaned
SET room_type_reserved_sort =
	CASE 
		WHEN room_type_reserved = 'Room Type 1' THEN 1
		WHEN room_type_reserved = 'Room Type 2' THEN 2
		WHEN room_type_reserved = 'Room Type 3' THEN 3
		WHEN room_type_reserved = 'Room Type 4' THEN 4
		WHEN room_type_reserved = 'Room Type 5' THEN 5
		WHEN room_type_reserved = 'Room Type 6' THEN 6
		WHEN room_type_reserved = 'Room Type 7' THEN 7
	END;

