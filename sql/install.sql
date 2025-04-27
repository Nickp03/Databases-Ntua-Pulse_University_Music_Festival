--DDL

DROP DATABASE IF EXISTS pulse_university;
CREATE DATABASE pulse_university;
USE pulse_university;

DROP TABLE IF EXISTS location;
CREATE TABLE location (
	location_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	address VARCHAR(255) NOT NULL,
	latitude DECIMAL(10,8) NOT NULL,
	longitude DECIMAL(11,8) NOT NULL,
	city VARCHAR(100) NOT NULL,
	country VARCHAR(100) NOT NULL,
	continent VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS festival;
CREATE TABLE festival (
	festival_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	year INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	location_id INT NOT NULL,
	CONSTRAINT chk_festival_dates CHECK (start_date <= end_date),
	FOREIGN KEY (location_id) REFERENCES location(location_id)
);

DROP TABLE IF EXISTS stage;
CREATE TABLE stage (
    stage_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_capacity INT NOT NULL,
    equipment TEXT
);

DROP TABLE IF EXISTS event;
CREATE TABLE event (
	event_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	festival_id INT NOT NULL,
	stage_id INT NOT NULL,
	FOREIGN KEY (festival_id) REFERENCES festival(festival_id),
	FOREIGN KEY (stage_id) REFERENCES stage(stage_id)
);

DROP TABLE IF EXISTS staff_role;
CREATE TABLE staff_role (
  role_id   INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS experience_level;
CREATE TABLE experience_level (
  level_id   INT AUTO_INCREMENT PRIMARY KEY,
  level_name VARCHAR(50) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
	staff_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(100) NOT NULL,
	age INT NOT NULL,
	role_id INT NOT NULL,
    level_id INT NOT NULL,
	CONSTRAINT check_age CHECK (age > 0),
    FOREIGN KEY (role_id) REFERENCES staff_role(role_id),
	FOREIGN KEY (level_id) REFERENCES experience_level(level_id)
);

DROP TABLE IF EXISTS stage_staff;
CREATE TABLE stage_staff (
	stage_id INT NOT NULL,
	staff_id INT NOT NULL,
	PRIMARY KEY (stage_id, staff_id),
	FOREIGN KEY (stage_id) REFERENCES stage(stage_id),
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS artist(
	artist_id INT PRIMARY KEY AUTO_INCREMENT,
    artist_name VARCHAR(20),
    artist_lastname VARCHAR(20),
    stage_name VARCHAR(20) NOT NULL UNIQUE,
    DOB DATE,
    genre VARCHAR (10), 
    subgenre VARCHAR (20),
    website VARCHAR(77),
    instagram VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS band (
    band_id INT PRIMARY KEY AUTO_INCREMENT,
    band_name VARCHAR(100) NOT NULL UNIQUE,
    date_of_creation DATE,
    website VARCHAR(255),
    instagram VARCHAR(30),
    genre VARCHAR(50),
    subgenre VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS artist_band(-- many to many relationship=>linking table
	artist_id INT,
    band_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id),
    FOREIGN KEY (band_id) REFERENCES band(band_id)
);

CREATE TABLE perf_kind (
  kind_id   INT AUTO_INCREMENT PRIMARY KEY,
  kind_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE perf_type (
  type_id   INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    perf_time TIME,
    kind_id INT NOT NULL,
    type_id INT NOT NULL,
    artist_id INT,
    band_id INT,
    FOREIGN KEY (kind_id) REFERENCES perf_kind(kind_id),
    FOREIGN KEY (artist_id) REFERENCES perf_type(type_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id),
    FOREIGN KEY (band_id) REFERENCES band(band_id)
);

CREATE TABLE ticket_category (
  cat_id   INT AUTO_INCREMENT PRIMARY KEY,
  cat_name VARCHAR(50)    NOT NULL UNIQUE
);

CREATE TABLE payment_method (
  pm_id   INT AUTO_INCREMENT PRIMARY KEY,
  pm_name VARCHAR(50)    NOT NULL UNIQUE
);

CREATE TABLE  IF NOT EXISTS ticket (
	ticket_id BIGINT(13) PRIMARY KEY,
    purchase_date DATETIME DEFAULT NOW(),
    cost DECIMAL(4,2),
    activated BOOLEAN DEFAULT FALSE,
    performance_id INT,
    cat_id INT NOT NULL,
    pm_id INT NOT NULL,
    CONSTRAINT check_ticket CHECK (length(ticket_id)=13),
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id) ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES ticket_category(cat_id),
    FOREIGN KEY (pm_id) REFERENCES payment_method(pm_id)
);

CREATE TABLE IF NOT EXISTS owner (
    owner_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT,
    phone_number VARCHAR(20),
    CONSTRAINT check_age CHECK (age >= 18)
);

CREATE TABLE IF NOT EXISTS buyer (
    buyer_id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_name VARCHAR(100) NOT NULL,
    date_of_interest DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit', 'paypal', 'debit', 'bank account') NOT NULL,
    ticket_id BIGINT(13),
    performance_id INT,
    category ENUM('general', 'VIP', 'backstage'),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
);

CREATE TABLE IF NOT EXISTS resell_queue(
	resell_id INT PRIMARY KEY,
	queue_type ENUM('Supply','Demand'),
    buyer_id INT,
    seller_id INT,
	interest_datetime DATETIME DEFAULT NOW(),
	ticket_id BIGINT(13), -- NULL for buyer
    event_id INT,
    ticket_category ENUM('general_entry','VIP','backstage'),
    CONSTRAINT check_valid CHECK ( (queue_type='Supply' AND buyer_id IS NULL AND seller_id IS NOT NULL) OR (queue_type='DEMAND' AND buyer_id IS NOT NULL AND seller_id IS NULL)),
    FOREIGN KEY (buyer_id) REFERENCES buyer(buyer_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT,
    interpretation TINYINT,
    sound_and_lighting TINYINT,
    stage_presence TINYINT,
    organization TINYINT,
    overall_impression TINYINT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    performance_id INT,
    CONSTRAINT check_inter CHECK (interpretation BETWEEN 1 AND 5),
    CONSTRAINT check_sound CHECK (sound_and_lighting BETWEEN 1 AND 5),
    CONSTRAINT check_pres CHECK (stage_presence BETWEEN 1 AND 5),
    CONSTRAINT check_org CHECK (organization BETWEEN 1 AND 5),
    CONSTRAINT check_overall CHECK (overall_impression BETWEEN 1 AND 5),
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id) ON DELETE CASCADE
);