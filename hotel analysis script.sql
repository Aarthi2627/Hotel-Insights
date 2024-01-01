USE theap44a_hotel;

SELECT * FROM hotel2018;
SELECT * FROM hotel2019;
SELECT * FROM hotel2020;

-- 1. What market segment are major contributors of the revenue per year? 

-- To Combine three tables into a single data table
SELECT 
    year,
    market_segment,
    total_revenue

FROM (

-- To find whch market segment in hotel2018 are major contributors of the revenue 

    SELECT 
        '2018' AS year,
        market_segment,
        SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)) AS total_revenue
    FROM 
        hotel2018
    GROUP BY 
        year, market_segment

    UNION ALL

-- To find whch market segment in hotel2019 are major contributors of the revenue 

    SELECT 
        '2019' AS year,
        market_segment,
        SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)) AS total_revenue
    FROM 
        hotel2019
    GROUP BY 
        year, market_segment

    UNION ALL

-- To find whch market segment in hotel2020 are major contributors of the revenue 

    SELECT 
        '2020' AS year,
        market_segment,
        SUM(daily_room_rate * (stays_in_weekend_nights + stays_in_week_nights)) AS total_revenue
    FROM 
        hotel2020
    GROUP BY 
        year, market_segment
) AS combined_data
ORDER BY 
    year, total_revenue DESC;


-- 2. When is the hotel at maximum occupancy?

SELECT
	CONCAT(arrival_date_year, '-', arrival_date_month) AS yearmonth,
    COUNT(*) AS total_bookings,
    
-- To calculate the occupancy percentage 
    
    100 * COUNT(*) / (SELECT COUNT(*) 
    FROM (
        SELECT arrival_date_year, arrival_date_month FROM hotel2018
        UNION ALL
        SELECT arrival_date_year, arrival_date_month FROM hotel2019
        UNION ALL
        SELECT arrival_date_year, arrival_date_month FROM hotel2020
    ) AS combined_data) AS occupancy_percentage
FROM (
    SELECT arrival_date_year, arrival_date_month FROM hotel2018
    UNION ALL
    SELECT arrival_date_year, arrival_date_month FROM hotel2019
    UNION ALL
    SELECT arrival_date_year, arrival_date_month FROM hotel2020
) AS combined_data
GROUP BY
    arrival_date_year, arrival_date_month
ORDER BY
    occupancy_percentage DESC;



-- 3. When are people cancelling the most?

SELECT
    arrival_date_year AS Year,
    arrival_date_month AS Month,
    COUNT(*) AS Cancellations
FROM
    (
        SELECT * FROM hotel2018
        UNION ALL
        SELECT * FROM hotel2019
        UNION ALL
        SELECT * FROM hotel2020
    ) AS CombinedData
WHERE
    is_canceled = 1 
GROUP BY
    Year,
    Month
ORDER BY
    Year, Month;



-- 4. Are families with kids more likely to cancel the hotel booking?

SELECT
    SUM(CASE 
        WHEN adults >= 1 AND (children + babies) >= 1 THEN 1 
        ELSE 0 
    END) AS total_family_bookings,
    SUM(CASE 
        WHEN adults >= 1 AND (children + babies) >= 1 AND is_canceled = 1 THEN 1 
        ELSE 0 
    END) AS canceled_family_bookings,
    SUM(CASE 
        WHEN adults = 1 AND (children + babies) = 0 THEN 1 
        ELSE 0 
    END) AS total_adult_bookings,
    SUM(CASE 
        WHEN adults = 1 AND (children + babies) = 0 AND is_canceled = 1 THEN 1 
        ELSE 0 
    END) AS canceled_adult_bookings,
    (SUM(CASE 
        WHEN adults >= 1 AND (children + babies) >= 1 AND is_canceled = 1 THEN 1 
        ELSE 0 
    END) / SUM(CASE 
        WHEN adults >= 1 AND (children + babies) >= 1 THEN 1 
        ELSE 0 
    END)) AS cancellation_rate_family,
    (SUM(CASE 
        WHEN adults = 1 AND (children + babies) = 0 AND is_canceled = 1 THEN 1 
        ELSE 0 
    END) / SUM(CASE 
        WHEN adults = 1 AND (children + babies) = 0 THEN 1 
        ELSE 0 
    END)) AS cancellation_rate_adult
FROM
    (
    SELECT adults, children, babies, is_canceled FROM hotel2018
    UNION ALL
    SELECT adults, children, babies, is_canceled FROM hotel2019
    UNION ALL
    SELECT adults, children, babies, is_canceled FROM hotel2020
    ) AS combined_data;
    
    
    
-- 5. Is hotel revenue increasing year on year?

SELECT
   hotel2018.arrival_date_year AS year, 
   sum(hotel2018.adr * (hotel2018.stays_in_weekend_nights + hotel2018.stays_in_week_nights) + 
     (meal_cost.cost *(hotel2018.adults + hotel2018. children + hotel2018.babies) * 
     (hotel2018.stays_in_weekend_nights + hotel2018.stays_in_week_nights)) *
     (1 - market_segment.discount))
     AS total_revenue
 FROM hotel2018
 inner join market_segment on hotel2018.market_segment = market_segment.market_segment
 inner join meal_cost on hotel2018.meal = meal_cost.meal
 UNION ALL 
 SELECT
   hotel2019.arrival_date_year, 
   sum(hotel2019.adr * (hotel2019.stays_in_weekend_nights + hotel2019.stays_in_week_nights) + 
     (meal_cost.cost *(hotel2019.adults + hotel2019. children + hotel2019.babies) * 
     (hotel2019.stays_in_weekend_nights + hotel2019.stays_in_week_nights)) *
     (1 - market_segment.discount))
     AS total_revenue
 FROM hotel2019
 inner join market_segment on hotel2019.market_segment = market_segment.market_segment
 inner join meal_cost on hotel2019.meal = meal_cost.meal
 UNION ALL
 SELECT
   hotel2020.arrival_date_year, 
   sum(hotel2020.daily_room_rate * (hotel2020.stays_in_weekend_nights + hotel2020.stays_in_week_nights) + 
     (meal_cost.cost *(hotel2020.adults + hotel2020. children + hotel2020.babies) * 
     (hotel2020.stays_in_weekend_nights + hotel2020.stays_in_week_nights)) *
     (1 - market_segment.discount))
     AS total_revenue
 FROM hotel2020
 inner join market_segment on hotel2020.market_segment = market_segment.market_segment
 inner join meal_cost on hotel2020.meal = meal_cost.meal;