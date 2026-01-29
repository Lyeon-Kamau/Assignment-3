-- Customers Table--

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles Table--

CREATE TABLE Vehicles (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    Make VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    LicensePlate VARCHAR(20) UNIQUE NOT NULL,
    DailyRate DECIMAL(10, 2) NOT NULL,
    Status ENUM('Available', 'Rented', 'Unavailable') DEFAULT 'Available',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rentals Table --
CREATE TABLE Rentals (
    RentalID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    VehicleID INT NOT NULL,
    RentalDate DATE NOT NULL,
    ReturnDate DATE,
    Status ENUM('Reserved', 'Active', 'Completed', 'Cancelled') DEFAULT 'Active',
    TotalCost DECIMAL(10, 2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);

-- CustomerPoints Table --
CREATE TABLE CustomerPoints (
    PointID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    TotalPoints DECIMAL(10, 2) DEFAULT 0.00,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    UNIQUE KEY (CustomerID)
);

-- PointsHistory Table --
CREATE TABLE PointsHistory (
    HistoryID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    RentalID INT NOT NULL,
    PointsAwarded DECIMAL(10, 2),
    AwardedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    DaysRemaining INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID)
);

DELIMITER $$

CREATE TRIGGER trg_award_loyalty_points
AFTER UPDATE ON Rentals
FOR EACH ROW
BEGIN
    DECLARE points_to_award DECIMAL(10, 2);
    DECLARE days_remaining INT;
    
    -- Only fire when status changes TO 'Completed' 
    IF NEW.Status = 'Completed' AND OLD.Status != 'Completed' THEN
        
        -- Calculate remaining days in current month
        SET days_remaining = DAY(LAST_DAY(CURDATE())) - DAY(CURDATE());
        
        -- Calculate points: remaining days / 8
        SET points_to_award = days_remaining / 8.0;
        
        -- Update customer points 
        INSERT INTO CustomerPoints (CustomerID, TotalPoints)
        VALUES (NEW.CustomerID, points_to_award)
        ON DUPLICATE KEY UPDATE 
            TotalPoints = TotalPoints + points_to_award,
            LastUpdated = CURRENT_TIMESTAMP;
        
        -- Record in audit trail
        INSERT INTO PointsHistory (CustomerID, RentalID, PointsAwarded, DaysRemaining)
        VALUES (NEW.CustomerID, NEW.RentalID, points_to_award, days_remaining);
            
    END IF;
END$$

DELIMITER ;



SELECT 
    CURDATE() AS TodayDate,
    DAY(LAST_DAY(CURDATE())) AS TotalDaysInJanuary,
    DAY(CURDATE()) AS CurrentDay,
    DAY(LAST_DAY(CURDATE())) - DAY(CURDATE()) AS DaysRemainingInMonth,
    (DAY(LAST_DAY(CURDATE())) - DAY(CURDATE())) / 8.0 AS PointsPerCompletion;

SELECT 
    c.CustomerID,
    c.CustomerName,
    cp.TotalPoints AS CurrentPoints,
    COUNT(r.RentalID) AS TotalRentals,
    SUM(CASE WHEN r.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedRentals,
    SUM(CASE WHEN r.Status = 'Active' THEN 1 ELSE 0 END) AS ActiveRentals
FROM Customers c
LEFT JOIN CustomerPoints cp ON c.CustomerID = cp.CustomerID
LEFT JOIN Rentals r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.CustomerName, cp.TotalPoints
ORDER BY c.CustomerID;


UPDATE Rentals
SET Status = 'Completed',
    ReturnDate = CURDATE()
WHERE RentalID = 1;


SELECT c.CustomerName, cp.TotalPoints, cp.LastUpdated
FROM Customers c
JOIN CustomerPoints cp ON c.CustomerID = cp.CustomerID
WHERE c.CustomerID = 1;

UPDATE Rentals
SET Status = 'Completed',
    ReturnDate = CURDATE()
WHERE RentalID = 2;

UPDATE Rentals
SET Status = 'Completed',
    ReturnDate = CURDATE()
WHERE RentalID = 3;

-- AFTER: View updated points
SELECT 
    c.CustomerID,
    c.CustomerName,
    cp.TotalPoints,
    cp.LastUpdated
FROM Customers c
LEFT JOIN CustomerPoints cp ON c.CustomerID = cp.CustomerID
ORDER BY cp.TotalPoints DESC;

-- View points history with calculations
SELECT 
    ph.HistoryID,
    c.CustomerName,
    r.RentalID,
    v.Make,
    v.Model,
    ph.PointsAwarded,
    ph.DaysRemaining,
    ph.AwardedDate,
    CONCAT(ph.DaysRemaining, ' days ÷ 8 = ', ROUND(ph.PointsAwarded, 2), ' points') AS Calculation
FROM PointsHistory ph
JOIN Customers c ON ph.CustomerID = c.CustomerID
JOIN Rentals r ON ph.RentalID = r.RentalID
JOIN Vehicles v ON r.VehicleID = v.VehicleID
ORDER BY ph.AwardedDate DESC;


Verify Trigger Only Fires on Status Change

sql
-- TEST: Update an already completed rental 
SELECT TotalPoints FROM CustomerPoints WHERE CustomerID = 4;

UPDATE Rentals
SET TotalCost = 500.00  
WHERE RentalID = 4;

SELECT TotalPoints FROM CustomerPoints WHERE CustomerID = 4;


SELECT TotalPoints FROM CustomerPoints WHERE CustomerID = 2;

UPDATE Rentals
SET TotalCost = 500.00  
WHERE RentalID = 9;

SELECT TotalPoints FROM CustomerPoints WHERE CustomerID = 2;  



sql
-- Comprehensive loyalty program dashboard
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Email,
    COALESCE(cp.TotalPoints, 0) AS LoyaltyPoints,
    COUNT(DISTINCT r.RentalID) AS TotalRentals,
    COUNT(DISTINCT CASE WHEN r.Status = 'Completed' THEN r.RentalID END) AS CompletedRentals,
    COUNT(DISTINCT CASE WHEN r.Status = 'Active' THEN r.RentalID END) AS ActiveRentals,
    COALESCE(SUM(CASE WHEN r.Status = 'Completed' THEN r.TotalCost END), 0) AS LifetimeRevenue,
    cp.LastUpdated AS LastPointsUpdate
FROM Customers c
LEFT JOIN CustomerPoints cp ON c.CustomerID = cp.CustomerID
LEFT JOIN Rentals r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Email, cp.TotalPoints, cp.LastUpdated
ORDER BY LoyaltyPoints DESC, LifetimeRevenue DESC;