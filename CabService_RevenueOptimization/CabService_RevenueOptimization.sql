CREATE DATABASE CabServiceDB;
USE CabServiceDB;

CREATE TABLE Drivers (
    driver_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    location_zone VARCHAR(50) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    availability BOOLEAN NOT NULL
);

CREATE TABLE Services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_type VARCHAR(50) NOT NULL,
    base_fare DECIMAL(10,2) NOT NULL,
    per_mile_charge DECIMAL(10,2) NOT NULL
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT,
    service_id INT,
    location_zone VARCHAR(50) NOT NULL,
    fare DECIMAL(10,2) NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted BOOLEAN NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

CREATE TABLE Driver_Acceptance (
    driver_id INT,
    service_id INT,
    total_requests INT NOT NULL,
    total_accepts INT NOT NULL,
    acceptance_rate DECIMAL(5,2) GENERATED ALWAYS AS ((total_accepts / total_requests) * 100) STORED,
    PRIMARY KEY (driver_id, service_id),
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);


/* Identify Highest-Paying Service Type Per Zone */
SELECT location_zone, s.service_type, AVG(b.fare) AS avg_revenue
FROM Bookings b
JOIN Services s ON b.service_id = s.service_id
GROUP BY location_zone, s.service_type
ORDER BY avg_revenue DESC;

/* Determine Peak Demand Hours for Each Zone */
SELECT location_zone, HOUR(booking_time) AS peak_hour, COUNT(*) AS total_bookings
FROM Bookings
GROUP BY location_zone, peak_hour
ORDER BY total_bookings DESC;

/* Identify Drivers With Highest Acceptance Rates */
SELECT d.name, s.service_type, da.acceptance_rate
FROM Driver_Acceptance da
JOIN Drivers d ON da.driver_id = d.driver_id
JOIN Services s ON da.service_id = s.service_id
ORDER BY acceptance_rate DESC;

/* Suggested Incentives for Underserved Services */
SELECT d.name, s.service_type, 
       CASE 
           WHEN da.acceptance_rate < 50 THEN 'Incentive Recommended'
           ELSE 'No Incentive Needed'
       END AS incentive_suggestion
FROM Driver_Acceptance da
JOIN Drivers d ON da.driver_id = d.driver_id
JOIN Services s ON da.service_id = s.service_id;

/* Computation of Total Revenue per Service Type */
SELECT s.service_type, SUM(b.fare) AS total_revenue
FROM Bookings b
JOIN Services s ON b.service_id = s.service_id
GROUP BY s.service_type;

/* Identification of top earning drivers */
SELECT d.name, SUM(b.fare) AS total_earnings
FROM Bookings b
JOIN Drivers d ON b.driver_id = d.driver_id
GROUP BY d.name
ORDER BY total_earnings DESC;

/* Average Customer Rating per Driver */
SELECT d.name, AVG(b.rating) AS avg_rating
FROM Bookings b
JOIN Drivers d ON b.driver_id = d.driver_id
GROUP BY d.name
ORDER BY avg_rating DESC;

/* Service Demand per Zone */
SELECT location_zone, s.service_type, COUNT(*) AS service_count
FROM Bookings b
JOIN Services s ON b.service_id = s.service_id
GROUP BY location_zone, s.service_type
ORDER BY service_count DESC;

/* Drivers With Lowest Acceptance Rates */
SELECT d.name, s.service_type, da.acceptance_rate
FROM Driver_Acceptance da
JOIN Drivers d ON da.driver_id = d.driver_id
JOIN Services s ON da.service_id = s.service_id
ORDER BY acceptance_rate ASC
LIMIT 10;

/* Revenue Per Mile for Each Service */
SELECT s.service_type, (SUM(b.fare) / COUNT(*)) AS revenue_per_mile
FROM Bookings b
JOIN Services s ON b.service_id = s.service_id
GROUP BY s.service_type;

/* Stored Procedure for Demand-Supply Gaps */
DELIMITER $$

CREATE PROCEDURE Identify_Demand_Supply_Gap()
BEGIN
    SELECT location_zone, COUNT(*) AS total_bookings,
           (SELECT COUNT(*) FROM Drivers d WHERE d.location_zone = b.location_zone AND d.availability = TRUE) AS available_drivers
    FROM Bookings b
    GROUP BY location_zone
    HAVING total_bookings > available_drivers;
END $$

DELIMITER ;

CALL Identify_Demand_Supply_Gap();

/* Triggers for Real-Time Availability Updates */
DELIMITER //

CREATE TRIGGER update_driver_availability_on_accept
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.accepted = TRUE THEN
        UPDATE Drivers
        SET availability = FALSE
        WHERE driver_id = NEW.driver_id;
    END IF;
END;

//

DELIMITER ;

/* Trigger to Restore Availability When a Booking is Completed. This trigger will mark the driver as available (TRUE) again after the trip is completed. */

DELIMITER //

CREATE TRIGGER restore_driver_availability
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF OLD.accepted = TRUE AND NEW.accepted = FALSE THEN
        UPDATE Drivers
        SET availability = TRUE
        WHERE driver_id = NEW.driver_id;
    END IF;
END;

//

DELIMITER ;

/* View: Driver Performance Summary */
CREATE VIEW Driver_Performance AS
SELECT d.driver_id, d.name, d.location_zone, d.vehicle_type,
       COUNT(b.booking_id) AS total_bookings,
       AVG(b.rating) AS avg_rating,
       SUM(b.fare) AS total_earnings
FROM Drivers d
LEFT JOIN Bookings b ON d.driver_id = b.driver_id
GROUP BY d.driver_id, d.name, d.location_zone, d.vehicle_type;

/* View: Service Demand Analysis */
 CREATE VIEW Service_Demand AS
SELECT b.location_zone, s.service_type, COUNT(b.booking_id) AS total_bookings
FROM Bookings b
JOIN Services s ON b.service_id = s.service_id
GROUP BY b.location_zone, s.service_type;

/* View: Highest-Paid Drivers */
CREATE VIEW Highest_Paid_Drivers AS
SELECT d.driver_id, d.name, SUM(b.fare) AS total_earnings
FROM Drivers d
JOIN Bookings b ON d.driver_id = b.driver_id
GROUP BY d.driver_id, d.name
ORDER BY total_earnings DESC;

/* View: Driver Acceptance Performance */
CREATE VIEW Driver_Acceptance_Performance AS
SELECT d.name, s.service_type, da.total_requests, da.total_accepts, da.acceptance_rate
FROM Driver_Acceptance da
JOIN Drivers d ON da.driver_id = d.driver_id
JOIN Services s ON da.service_id = s.service_id;

/* Calling Views */
SELECT * FROM Driver_Performance;
SELECT * FROM Service_Demand;
SELECT * FROM Highest_Paid_Drivers;
SELECT * FROM Driver_Acceptance_Performance;

