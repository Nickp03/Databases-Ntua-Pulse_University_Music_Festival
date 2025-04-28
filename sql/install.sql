-- DDL

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
    FOREIGN KEY (type_id) REFERENCES perf_type(type_id),
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

CREATE TABLE review_summary (-- Extra table to have per-performance reviews
  performance_id INT PRIMARY KEY, -- One-to-one relationship (primary and foreign keys are the same)
  total_reviews INT NOT NULL DEFAULT 0,
  avg_interpretation DECIMAL(4,2) NOT NULL DEFAULT 0,
  avg_sound_and_lighting DECIMAL(4,2) NOT NULL DEFAULT 0,
  avg_stage_presence DECIMAL(4,2) NOT NULL DEFAULT 0,
  avg_organization DECIMAL(4,2) NOT NULL DEFAULT 0,
  avg_overall_impression DECIMAL(4,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (performance_id) REFERENCES performance(performance_id) ON DELETE CASCADE
);

CREATE INDEX idx_review_perf ON review(performance_id);
CREATE INDEX idx_review_owner ON review(owner_id);
CREATE INDEX idx_review_perf_date ON review(performance_id, review_date);

-- Trigger to ensure that an owner can only review a performance once

DELIMITER $$
CREATE TRIGGER review_no_dup
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 
	FROM review
	WHERE performance_id=NEW.performance_id AND owner_id=NEW.owner_id
  ) 
  THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Duplicate review: an owner may only review each performance once';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER review_sum_before_insert
BEFORE INSERT ON review
FOR EACH ROW
BEGIN -- If no summary row exists yet for this performance, create it
  IF NOT EXISTS (
    SELECT 1 FROM review_summary
	WHERE performance_id = NEW.performance_id
  ) 
  THEN
    INSERT INTO review_summary(performance_id)
    VALUES (NEW.performance_id);
  END IF;
END$$

CREATE TRIGGER review_sum_after_insert
AFTER INSERT ON review
FOR EACH ROW
BEGIN
  UPDATE review_summary
  SET
       avg_interpretation     = (avg_interpretation*total_reviews + NEW.interpretation)/(total_reviews+1),
       avg_sound_and_lighting = (avg_sound_and_lighting*total_reviews + NEW.sound_and_lighting)/(total_reviews+1),
       avg_stage_presence     = (avg_stage_presence*total_reviews + NEW.stage_presence)/(total_reviews+1),
       avg_organization       = (avg_organization*total_reviews + NEW.organization)/(total_reviews+1),
       avg_overall_impression = (avg_overall_impression*total_reviews + NEW.overall_impression)/(total_reviews+1),
       total_reviews          = total_reviews + 1
  WHERE performance_id = NEW.performance_id;
END$$

CREATE TRIGGER review_sum_after_update
AFTER UPDATE ON review
FOR EACH ROW
BEGIN
  UPDATE review_summary
  SET
       avg_interpretation     = (avg_interpretation*total_reviews - OLD.interpretation + NEW.interpretation)/total_reviews,
       avg_sound_and_lighting = (avg_sound_and_lighting*total_reviews - OLD.sound_and_lighting + NEW.sound_and_lighting)/total_reviews,
       avg_stage_presence     = (avg_stage_presence*total_reviews - OLD.stage_presence + NEW.stage_presence)/total_reviews,
       avg_organization       = (avg_organization*total_reviews - OLD.organization + NEW.organization)/total_reviews,
       avg_overall_impression = (avg_overall_impression*total_reviews - OLD.overall_impression + NEW.overall_impression)/total_reviews
  WHERE performance_id = OLD.performance_id;
END$$


CREATE TRIGGER review_sum_after_delete
AFTER DELETE ON review
FOR EACH ROW
BEGIN
  IF (SELECT total_reviews FROM review_summary WHERE performance_id = OLD.performance_id) <= 1 THEN
      DELETE FROM review_summary WHERE performance_id = OLD.performance_id;
  ELSE
    UPDATE review_summary
	SET
         avg_interpretation     = (avg_interpretation*total_reviews - OLD.interpretation)/(total_reviews-1),
         avg_sound_and_lighting = (avg_sound_and_lighting*total_reviews - OLD.sound_and_lighting)/(total_reviews-1),
         avg_stage_presence     = (avg_stage_presence*total_reviews - OLD.stage_presence)/(total_reviews-1),
         avg_organization       = (avg_organization*total_reviews - OLD.organization)/(total_reviews-1),
         avg_overall_impression = (avg_overall_impression*total_reviews - OLD.overall_impression)/(total_reviews-1),
         total_reviews          = total_reviews - 1
	WHERE performance_id = OLD.performance_id;
  END IF;
END$$
DELIMITER ;