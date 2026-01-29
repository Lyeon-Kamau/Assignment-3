-- Insert Customers
INSERT INTO Customers (CustomerName, Email, Phone, Address) VALUES
('Faith Jepkemoi', 'Faith.J@email.com', '555-0101', '123 Main St, Boston, MA'),
('Lyeon Kamau', 'LyeonK@email.com', '555-0102', '456 Oak Ave, Seattle, WA'),
('Melvis Mwenda', 'Melvis.M@email.com', '555-0103', '789 Pine Rd, Miami, FL'),
('David Kim', 'dkim@email.com', '555-0104', '321 Elm St, Austin, TX'),
('Jessica Brown', 'jbrown@email.com', '555-0105', '654 Maple Dr, Denver, CO'),
('Robert Taylor', 'rtaylor@email.com', '555-0106', '987 Cedar Ln, Portland, OR'),
('Amanda White', 'awhite@email.com', '555-0107', '246 Birch St, Chicago, IL');

-- Insert Vehicles
INSERT INTO Vehicles (Make, Model, Year, LicensePlate, DailyRate, Status) VALUES
('Toyota', 'Camry', 2023, 'ABC-1234', 45.00, 'Available'),
('Honda', 'Civic', 2023, 'XYZ-5678', 40.00, 'Available'),
('Tesla', 'Model 3', 2024, 'EV-9012', 85.00, 'Available'),
('Ford', 'Explorer', 2023, 'SUV-3456', 65.00, 'Available'),
('Chevrolet', 'Malibu', 2022, 'CHV-7890', 42.00, 'Available'),
('BMW', '3 Series', 2024, 'BMW-1111', 95.00, 'Available'),
('Mercedes', 'C-Class', 2023, 'MBZ-2222', 100.00, 'Available'),
('Nissan', 'Altima', 2023, 'NIS-3333', 43.00, 'Available');

-- Insert Rentals with various statuses
INSERT INTO Rentals (CustomerID, VehicleID, RentalDate, ReturnDate, Status, TotalCost) VALUES
-- Active rentals (ready to be completed for testing)
(1, 1, '2026-01-15', '2026-01-20', 'Active', 225.00),
(2, 2, '2026-01-18', '2026-01-22', 'Active', 160.00),
(3, 3, '2026-01-10', '2026-01-25', 'Active', 1275.00),
(6, 5, '2026-01-20', '2026-01-27', 'Active', 294.00),
(7, 8, '2026-01-23', '2026-01-28', 'Active', 215.00),

-- Already completed rentals (from earlier in the month)
(4, 4, '2026-01-05', '2026-01-12', 'Completed', 455.00),
(5, 5, '2026-01-08', '2026-01-14', 'Completed', 252.00),
(1, 6, '2026-01-01', '2026-01-03', 'Completed', 190.00),

-- Current active rentals (still ongoing)
(2, 4, '2026-01-26', '2026-02-02', 'Active', 455.00),
(3, 1, '2026-01-27', '2026-01-29', 'Active', 90.00),

-- Reserved for future
(4, 3, '2026-02-01', '2026-02-05', 'Reserved', 340.00),
(5, 7, '2026-02-03', '2026-02-08', 'Reserved', 500.00),

-- Cancelled rental
(6, 2, '2026-01-12', NULL, 'Cancelled', 0.00);

-- Initialize CustomerPoints for all customers
INSERT INTO CustomerPoints (CustomerID, TotalPoints)
SELECT CustomerID, 0.00
FROM Customers;