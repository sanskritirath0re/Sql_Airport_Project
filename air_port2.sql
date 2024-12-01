-- challenging problem statements

## Probleem Statement 1 : 
use airport_db;
-- The objective is to determine the most and least busy months by flight count across multiple years. 
SELECT 
    YEAR(Fly_date) AS Year,
    MONTH(Fly_date) AS Month,
    COUNT(Flights) AS Total_Flights
FROM
    airports2
GROUP BY MONTH(Fly_date) , YEAR(Fly_date)
ORDER BY Total_Flights DESC;

-- To get both the most and least busy months as per the year, you can run the above query 

-- below query will give you the "Most Busy" & "Least Busy" Month at Once in result

WITH Monthly_Flights AS (
    SELECT 
        MONTH(Fly_date) AS Month, 
        COUNT(Flights) AS Total_Flights
    FROM 
        airports2
    GROUP BY 
        MONTH(Fly_date)
)

SELECT 
    Month, 
    Total_Flights,
    CASE 
        WHEN Total_Flights = (SELECT MAX(Total_Flights) FROM Monthly_Flights) THEN 'Most Busy'
        WHEN Total_Flights = (SELECT MIN(Total_Flights) FROM Monthly_Flights) THEN 'Least Busy'
        ELSE NULL
    END AS Month_Status
FROM 
    Monthly_Flights
WHERE 
    Total_Flights = (SELECT MAX(Total_Flights) FROM Monthly_Flights) 
    OR Total_Flights = (SELECT MIN(Total_Flights) FROM Monthly_Flights);

-- This analysis will provide insights into seasonal trends in air travel,
-- helping airlines and stakeholders understand peak and off-peak periods for better operational planning and resource allocation.



## Problem Statement 2 : 

-- The aim is to calculate the year-over-year percentage growth in the total number of passengers for each origin and destination airport pair.
WITH Passenger_Summary AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date) AS Year, 
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports2
    GROUP BY 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date)
),

Passenger_Growth AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        Year, 
        Total_Passengers,
        LAG(Total_Passengers) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY Year) AS Previous_Year_Passengers
    FROM 
        Passenger_Summary
)

SELECT 
    Origin_airport, 
    Destination_airport, 
    Year, 
    Total_Passengers, 
    CASE 
        WHEN Previous_Year_Passengers IS NOT NULL THEN 
            ((Total_Passengers - Previous_Year_Passengers) * 100.0 / NULLIF(Previous_Year_Passengers, 0))
        ELSE NULL 
    END AS Growth_Percentage
FROM 
    Passenger_Growth
ORDER BY 
    Origin_airport, 
    Destination_airport, 
    Year;

-- This analysis will help identify trends in passenger traffic over time,
-- providing valuable insights for airlines to make informed decisions about route development 
-- and capacity management based on demand fluctuations.



## Problem Statement 3 : 


-- The objective is to identify routes (from origin to destination) that have demonstrated consistent year-over-year growth in the number of flights. 

WITH Flight_Summary AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date) AS Year, 
        COUNT(Flights) AS Total_Flights
    FROM 
        airports2
    GROUP BY 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date)
),

Flight_Growth AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        Year, 
        Total_Flights,
        LAG(Total_Flights) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY Year) AS Previous_Year_Flights
    FROM 
        Flight_Summary
),

Growth_Rates AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        Year, 
        Total_Flights,
        CASE 
            WHEN Previous_Year_Flights IS NOT NULL AND Previous_Year_Flights > 0 THEN 
                ((Total_Flights - Previous_Year_Flights) * 100.0 / Previous_Year_Flights)
            ELSE NULL 
        END AS Growth_Rate,
        CASE 
            WHEN Previous_Year_Flights IS NOT NULL AND Total_Flights > Previous_Year_Flights THEN 1
            ELSE 0 
        END AS Growth_Indicator
    FROM 
        Flight_Growth
)

-- Final query to identify routes with consistent growth and their growth rate
SELECT 
    Origin_airport, 
    Destination_airport,
    MIN(Growth_Rate) AS Minimum_Growth_Rate,
    MAX(Growth_Rate) AS Maximum_Growth_Rate
FROM 
    Growth_Rates
WHERE 
    Growth_Indicator = 1
GROUP BY 
    Origin_airport, 
    Destination_airport
HAVING 
    MIN(Growth_Indicator) = 1
ORDER BY 
    Origin_airport, 
    Destination_airport;

-- This analysis will help airlines understand which routes have not only grown consistently but also the magnitude of that growth in terms of percentage.
-- This analysis will highlight successful routes, providing insights for airlines to strengthen their operational strategies 
-- and consider potential expansions based on sustained demand trends.


## Problem Statement 4 :

 -- The aim is to determine the top 3 origin airports with the highest weighted passenger-to-seats utilization ratio, 
 -- sidering the total number of flights for weighting.
 
WITH Utilization_Ratio AS (
    -- Step 1: Calculate the passenger-to-seats ratio for each flight
    SELECT 
        Origin_airport, 
        SUM(Passengers) AS Total_Passengers, 
        SUM(Seats) AS Total_Seats, 
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) * 1.0 / SUM(Seats) AS Passenger_Seat_Ratio
    FROM 
        airports2
    GROUP BY 
        Origin_airport
),

Weighted_Utilization AS (
    -- Step 2: Calculate the weighted utilization by flights for each origin airport
    SELECT 
        Origin_airport, 
        Total_Passengers, 
        Total_Seats, 
        Total_Flights,
        Passenger_Seat_Ratio, 
        -- Weight the passenger-to-seat ratio by the total number of flights
        (Passenger_Seat_Ratio * Total_Flights) / SUM(Total_Flights) OVER () AS Weighted_Utilization
    FROM 
        Utilization_Ratio
)

-- Step 3: Select the top 3 airports by weighted utilization
SELECT 
    Origin_airport, 
    Total_Passengers, 
    Total_Seats, 
    Total_Flights, 
    Weighted_Utilization
FROM 
    Weighted_Utilization
ORDER BY 
    Weighted_Utilization DESC
LIMIT 3;

-- analysis will highlight the top 3 origin airports that not only have good passenger-to-seat ratios 
-- but also perform well when the total number of flights is considered. It gives a more balanced view of operational efficiency by considering both the ratio and flight volume.


## Problem Statement 5 : 

-- The objective is to identify the peak traffic month for each origin city based on the highest number of passengers, 
-- including any ties where multiple months have the same passenger count. 

WITH Monthly_Passenger_Count AS (
    SELECT 
        Origin_city,
        YEAR(Fly_date) AS Year,
        MONTH(Fly_date) AS Month,
        SUM(Passengers) AS Total_Passengers  -- Handling NULLs and non-integer values
    FROM 
        airports2
    GROUP BY 
        Origin_city, 
        YEAR(Fly_date), 
        MONTH(Fly_date)
),

Max_Passengers_Per_City AS (
    SELECT 
        Origin_city, 
        MAX(Total_Passengers) AS Peak_Passengers
    FROM 
        Monthly_Passenger_Count
    GROUP BY 
        Origin_city
)

SELECT 
    mpc.Origin_city, 
    mpc.Year, 
    mpc.Month, 
    mpc.Total_Passengers
FROM 
    Monthly_Passenger_Count mpc
JOIN 
    Max_Passengers_Per_City mp ON mpc.Origin_city = mp.Origin_city 
                               AND mpc.Total_Passengers = mp.Peak_Passengers
ORDER BY 
    mpc.Origin_city, 
    mpc.Year, 
    mpc.Month;
    
-- This analysis will help reveal seasonal travel patterns specific to each city,
-- enabling airlines to tailor their services and marketing strategies to meet demand effectively.



## Problem Statement 6 : 

-- The aim is to identify the routes (origin-destination pairs) that have experienced the largest decline in passenger numbers year-over-year. 

WITH Yearly_Passenger_Count AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        YEAR(Fly_date) AS Year,
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports2
    GROUP BY 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date)
),

Yearly_Decline AS (
    SELECT 
        y1.Origin_airport,
        y1.Destination_airport,
        y1.Year AS Year1,
        y1.Total_Passengers AS Passengers_Year1,
        y2.Year AS Year2,
        y2.Total_Passengers AS Passengers_Year2,
        -- Calculate percentage decline: (New - Old) / Old * 100
        ((y2.Total_Passengers - y1.Total_Passengers) / NULLIF(y1.Total_Passengers, 0)) * 100 AS Percentage_Change
    FROM 
        Yearly_Passenger_Count y1
    JOIN 
        Yearly_Passenger_Count y2
        ON y1.Origin_airport = y2.Origin_airport
        AND y1.Destination_airport = y2.Destination_airport
        AND y2.Year = y1.Year + 1 -- Join consecutive years
)

SELECT 
    Origin_airport,
    Destination_airport,
    Year1,
    Year2,
    Passengers_Year1,
    Passengers_Year2,
    Percentage_Change
FROM 
    Yearly_Decline
WHERE 
    Percentage_Change < 0 -- Only declining routes
ORDER BY 
    Percentage_Change ASC -- Largest decline first
LIMIT 5;

-- This analysis will help airlines pinpoint routes facing reduced demand,
-- allowing for strategic adjustments in operations, marketing, and service offerings to address the decline effectively.


## Problem Statement 7 : 

-- The objective is to list all origin and destination airports that had at least 10 flights
-- but maintained an average seat utilization (passengers/seats) of less than 50%.

WITH Flight_Stats AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) AS Total_Passengers,
        SUM(Seats) AS Total_Seats,
        -- Calculate average seat utilization as (Total Passengers / Total Seats)
        (SUM(Passengers) / NULLIF(SUM(Seats), 0)) AS Avg_Seat_Utilization
    FROM 
        airports2
    GROUP BY 
        Origin_airport, Destination_airport
)

SELECT 
    Origin_airport,
    Destination_airport,
    Total_Flights,
    Total_Passengers,
    Total_Seats,
    ROUND(Avg_Seat_Utilization * 100, 2) AS Avg_Seat_Utilization_Percentage
FROM 
    Flight_Stats
WHERE 
    Total_Flights >= 10 -- At least 10 flights
    AND Avg_Seat_Utilization < 0.5 -- Less than 50% seat utilization
ORDER BY 
    Avg_Seat_Utilization_Percentage ASC;
 
-- This analysis will highlight underperforming routes, allowing airlines to reassess their capacity management strategies
-- and make informed decisions regarding potential service adjustments to optimize seat utilization and improve profitability 


## Problem Statement 8 : 

-- The aim is to calculate the average flight distance for each unique city-to-city pair (origin and destination) 
-- and identify the routes with the longest average distance. 

WITH Distance_Stats AS (
    SELECT 
        Origin_city,
        Destination_city,
        AVG(Distance) AS Avg_Flight_Distance
    FROM 
        airports2
    GROUP BY 
        Origin_city, 
        Destination_city
)

SELECT 
    Origin_city,
    Destination_city,
    ROUND(Avg_Flight_Distance, 2) AS Avg_Flight_Distance
FROM 
    Distance_Stats
ORDER BY 
    Avg_Flight_Distance DESC;  -- Sort by average distance in descending order

-- This analysis will provide insights into long-haul travel patterns,
-- helping airlines assess operational considerations
-- and potential market opportunities for extended routes.


## Problem Statement 9 : 

-- The objective is to calculate the total number of flights and passengers for each year, 
-- along with the percentage growth in both flights and passengers compared to the previous year. 

WITH Yearly_Summary AS (
    SELECT 
        SUBSTR(Fly_date, 7, 4) AS Year,  -- Extracting year from the Fly_date string
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports2
    GROUP BY 
        SUBSTR(Fly_date, 7, 4)
),

Yearly_Growth AS (
    SELECT 
        Year,
        Total_Flights,
        Total_Passengers,
        LAG(Total_Flights) OVER (ORDER BY Year) AS Prev_Flights,
        LAG(Total_Passengers) OVER (ORDER BY Year) AS Prev_Passengers
    FROM 
        Yearly_Summary
)

SELECT 
    Year,
    Total_Flights,
    Total_Passengers,
    ROUND(((Total_Flights - Prev_Flights) / NULLIF(Prev_Flights, 0) * 100), 2) AS Flight_Growth_Percentage,
    ROUND(((Total_Passengers - Prev_Passengers) / NULLIF(Prev_Passengers, 0) * 100), 2) AS Passenger_Growth_Percentage
FROM 
    Yearly_Growth
ORDER BY 
    Year;

    
-- This analysis will provide a comprehensive overview of annual trends in air travel,
-- enabling airlines and stakeholders to assess growth patterns and 
-- make informed strategic decisions for future operations.

## Problem Statement 10 : 

-- The aim is to identify the top 3 busiest routes (origin-destination pairs) based on the total distance flown,
--  weighted by the number of flights. 

WITH Route_Distance AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        SUM(Distance) AS Total_Distance,
        SUM(Flights) AS Total_Flights
    FROM 
        airports2
    GROUP BY 
        Origin_airport, 
        Destination_airport
),

Weighted_Routes AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        Total_Distance,
        Total_Flights,
        Total_Distance * Total_Flights AS Weighted_Distance
    FROM 
        Route_Distance
)

SELECT 
    Origin_airport,
    Destination_airport,
    Total_Distance,
    Total_Flights,
    Weighted_Distance
FROM 
    Weighted_Routes
ORDER BY 
    Weighted_Distance DESC
LIMIT 3;  -- To get the top 3 busiest routes

-- This analysis will highlight the most significant routes in terms of distance and operational activity, 
-- providing valuable insights for airlines to optimize their scheduling and resource allocation strategies.







