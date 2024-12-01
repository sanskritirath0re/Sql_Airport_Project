create database airport_db;
use airport_db;
select * from airports2 limit 5;
SELECT COUNT(*) AS row_count FROM airports2;
show tables;

## Problem Statement 1 : 

-- The objective is to calculate the total number of passengers for each pair of origin and destination airports.

SELECT 
    Origin_airport,
    Destination_airport,
    SUM(Passengers) AS Total_Passengers
FROM
    airports2
GROUP BY Origin_airport , Destination_airport
ORDER BY Origin_airport , Destination_airport;

-- This analysis will provide insights into travel patterns between specific airport pairs,
-- helping to identify the most frequented routes and enhance strategic planning for airline operations.


## Problem Statement 2 : 

-- Here the goal is to calculate the average seat utilization for each flight by dividing the  number of passengers by the total number of seats available. 

SELECT 
    Origin_airport, 
    Destination_airport, 
    AVG(CAST(Passengers AS FLOAT) / NULLIF(Seats, 0)) * 100 AS Average_Seat_Utilization
FROM 
    airports2
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Average_Seat_Utilization DESC;

-- The results will be sorted in descending order based on utilization percentage.
-- This analysis will help identify flights with the highest and lowest seat occupancy, 
-- providing valuable insights for optimizing flight capacity and enhancing operational efficiency.

## Problem Statement 3 :
 
-- The aim is to determine the top 5 origin and destination airport pairs that have the highest total passenger volume. 

SELECT 
    Origin_airport, 
    Destination_airport, 
    SUM(Passengers) AS Total_Passengers
FROM 
    airports2
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Total_Passengers DESC
LIMIT 5;

-- This analysis will reveal the most frequented travel routes, allowing airlines to optimize resource allocation 
-- and enhance service offerings based on passenger demand trends

## Problem Statement 4 :

-- The objective is to calculate the total number of flights and passengers departing from each origin city. 

SELECT 
    Origin_city, 
    COUNT(Flights) AS Total_Flights, 
    SUM(Passengers) AS Total_Passengers
FROM 
    airports2
GROUP BY 
    Origin_city
ORDER BY 
    Origin_city;

-- This analysis will provide insights into the activity levels at various origin cities, 
-- helping to identify key hubs and inform strategic decisions regarding flight operations and capacity management.

## Problem Statement 5 : 

-- The aim is to calculate the total distance flown by flights originating from each airport.
 
SELECT 
    Origin_airport, 
    SUM(Distance) AS Total_Distance
FROM 
    airports2
GROUP BY 
    Origin_airport
ORDER BY 
    Origin_airport;

-- This analysis will offer insights into the overall travel patterns and operational reach of each airport, 
-- helping to evaluate their significance in the network and inform future route planning decisions.

## Problem Statement 6 :

-- The objective is to group flights by month and year using the Fly_date column to calculate the number of flights,
-- total passengers, and average distance traveled per month. 

SELECT 
    YEAR(Fly_date) AS Year, 
    MONTH(Fly_date) AS Month, 
    COUNT(Flights) AS Total_Flights, 
    SUM(Passengers) AS Total_Passengers, 
    AVG(Distance) AS Avg_Distance
FROM 
    airports2
GROUP BY 
    YEAR(Fly_date), 
    MONTH(Fly_date)
ORDER BY 
    Year, 
    Month;

-- This analysis will provide a clearer understanding of seasonal trends and operational performance over time, 
-- enabling better strategic planning for airline operations.

## Problem Statement 7 : 

-- The goal is to calculate the passenger-to-seats ratio for each origin and destination route
-- and filter the results to display only those routes where this ratio is less than 0.5. 

SELECT 
    Origin_airport, 
    Destination_airport, 
    SUM(Passengers) AS Total_Passengers, 
    SUM(Seats) AS Total_Seats, 
    (SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0)) AS Passenger_to_Seats_Ratio
FROM 
    airports2
GROUP BY 
    Origin_airport, 
    Destination_airport
HAVING 
    (SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0)) < 0.5
ORDER BY 
    Passenger_to_Seats_Ratio;

-- This analysis will help identify underutilized routes, enabling airlines to make informed decisions about capacity management and potential route adjustments.

## Problem Statement 8 : 

-- The aim is to determine the top 3 origin airports with the highest frequency of flights. 

SELECT 
    Origin_airport, 
    COUNT(Flights) AS Total_Flights
FROM 
    airports2
GROUP BY 
    Origin_airport
ORDER BY 
    Total_Flights DESC
LIMIT 3;

-- This analysis will highlight the most active airports in terms of flight operations, 
-- providing valuable insights for airlines and stakeholders to optimize scheduling and improve service offerings at these critical locations.

## Problem Statement 9 :
-- The objective is to identify the cities (excluding Bend, OR) that sends the most flights and passengers to Bend, OR. 
SELECT 
    Origin_city, 
    COUNT(Flights) AS Total_Flights, 
    SUM(Passengers) AS Total_Passengers
FROM 
    airports2
WHERE 
    Destination_city = 'Bend, OR' AND 
    Origin_city <> 'Bend, OR'
GROUP BY 
    Origin_city
ORDER BY 
    Total_Flights DESC, 
    Total_Passengers DESC
LIMIT 3;

-- This analysis will reveal key contributors to passenger traffic at Bend, OR, 
-- helping airlines and travel authorities understand demand patterns and enhance connectivity from popular originating cities.

## Problem Statement 10 : 
-- The aim is to identify the longest flight route in terms of distance traveled, including both the origin and destination airports. 
SELECT 
    Origin_airport, 
    Destination_airport, 
    MAX(Distance) AS Longest_Distance
FROM 
    airports2
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Longest_Distance DESC
LIMIT 1;
-- This analysis will provide insights into the most extensive travel connections,
-- helping airlines assess operational challenges and opportunities for long-haul service planning.











