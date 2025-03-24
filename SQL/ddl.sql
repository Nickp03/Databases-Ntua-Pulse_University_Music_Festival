-- Database schema for Pulse Music Festival
CREATE DATABASE IF NOT EXISTS pulse_festival;
USE pulse_festival;

CREATE TABLE IF NOT EXISTS locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS festivals (
    festival_id INT AUTO_INCREMENT PRIMARY KEY,
    year YEAR NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
); hvgadsahfhad