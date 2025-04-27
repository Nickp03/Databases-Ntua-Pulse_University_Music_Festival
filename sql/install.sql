--DDL

DROP DATABASE IF EXISTS pulse_festival;
CREATE DATABASE pulse_festival;
USE pulse_festival;

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

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
	staff_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(100) NOT NULL,
	age INT NOT NULL,
	role ENUM('τεχνικό', 'ασφάλειας', 'βοηθητικό') NOT NULL,
	experience ENUM('ειδικευόμενος', 'αρχάριος', 'μέσος', 'έμπειρος', 'πολύ έμπειρος') NOT NULL,
	CHECK (age > 0)
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

CREATE TABLE IF NOT EXISTS performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    type_of_performance ENUM ('warm up','support', 'headline', 'Special guest', 'Closing'),
    perf_time TIME,
    performance_type ENUM ('solo','band'),
    artist_id INT,
    band_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id),
    FOREIGN KEY (band_id) REFERENCES band(band_id)
);

CREATE TABLE  IF NOT EXISTS ticket (
	ticket_id BIGINT(13) PRIMARY KEY, 
    ticket_category ENUM('general_entry','VIP','backstage'),
    purchase_date DATETIME DEFAULT NOW(),
    cost DECIMAL(4,2),
    method_of_purchase ENUM ('debit','credit','bank_account','pay-pal'),
    activated BOOLEAN DEFAULT FALSE,
    performance_id INT,
    CONSTRAINT check_ticket CHECK (length(ticket_id)=13),
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id) ON DELETE CASCADE
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