-- Sample data for Pulse Music Festival
USE pulse_festival;

INSERT INTO locations (address, city, country) VALUES
('123 Music Lane', 'Athens', 'Greece'),
('456 Festival Ave', 'Thessaloniki', 'Greece');

INSERT INTO festivals (year, start_date, end_date, location_id) VALUES
(2025, '2025-06-15', '2025-06-18', 1),
(2026, '2026-07-20', '2026-07-23', 2);