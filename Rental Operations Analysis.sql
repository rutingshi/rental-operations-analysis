-- Rental Operations Analysis
-- Dataset: Sakila Sample Database

USE Sakila;

-- 1. Staff Rental Workload
SELECT 
	staff_id, 
	COUNT(*) AS total_rentals
FROM rental
GROUP BY staff_id
ORDER BY total_rentals DESC;

-- 2. Hourly Rental Activity
SELECT 
	HOUR(rental_date) AS rental_hour,
    COUNT(*) AS rental_count
FROM rental
GROUP BY rental_hour
ORDER BY rental_hour ASC;

-- 3. Staff Rental Workload by Hour
SELECT
    staff_id,
    HOUR(rental_date) AS rental_hour,
    COUNT(*) AS rental_count
FROM rental
GROUP BY staff_id, HOUR(rental_date)
ORDER BY rental_hour, staff_id;

-- 4. Rental Duration Distribution
SELECT
    DATEDIFF(return_date, rental_date) AS rental_days,
    COUNT(*) AS rental_count
FROM rental
WHERE return_date IS NOT NULL
GROUP BY rental_days
ORDER BY rental_days ASC;

-- 5. Potential Data Anomalies and Duplicate Records
-- 5-1.Check for Duplicate Rental Records
SELECT 
	customer_id, 
	inventory_id, 
	rental_date, 
	COUNT(*) AS duplicate_count
FROM rental
GROUP BY customer_id, inventory_id, rental_date
HAVING COUNT(*) > 1;

-- 5-2.Check for Invalid Rental and Return Dates
SELECT
    rental_id, 
	customer_id, 
	staff_id, 
	rental_date, 
	return_date
FROM rental
WHERE return_date < rental_date;

-- 5-3.Check for Overlapping Rental Periods for the Same Inventory Item
-- Treat NULL return dates as open rental periods ending at NOW().
SELECT 
	r1.rental_id AS rental_1, 
	r1.rental_date AS rental_date_1, 
	r1.return_date AS return_date_1, 
	r1.inventory_id,
	r2.rental_id AS rental_2, 
	r2.rental_date AS rental_date_2, 
	r2.return_date AS return_date_2
FROM rental r1 
JOIN rental r2
	ON r1.inventory_id=r2.inventory_id 
	AND r1.rental_id < r2.rental_id 
WHERE r1.rental_date < COALESCE(r2.return_date, NOW())
AND r2.rental_date < COALESCE(r1.return_date, NOW());