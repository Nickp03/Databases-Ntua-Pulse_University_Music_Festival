-- DDL

DROP DATABASE IF EXISTS pulse_university;
CREATE DATABASE pulse_university;
USE pulse_university;
SET global event_scheduler=ON;

DROP TABLE IF EXISTS location;
CREATE TABLE location (
	location_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	address VARCHAR(255) NOT NULL,
	latitude DECIMAL(10,8) NOT NULL,
	longitude DECIMAL(11,8) NOT NULL,
	city VARCHAR(100) NOT NULL,
	country VARCHAR(100) NOT NULL,
	continent VARCHAR(100) NOT NULL
)ENGINE=InnoDB;

DROP TABLE IF EXISTS festival;
CREATE TABLE festival (
	festival_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	year INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	location_id INT NOT NULL,
	CONSTRAINT chk_festival_dates CHECK (start_date <= end_date),
	FOREIGN KEY (location_id) REFERENCES location(location_id)
)ENGINE=InnoDB;

DROP TABLE IF EXISTS stage;
CREATE TABLE stage (
    stage_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_capacity INT NOT NULL,
    equipment TEXT
)ENGINE=InnoDB;

DROP TABLE IF EXISTS event;
CREATE TABLE event (
	event_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	festival_id INT NOT NULL,
	stage_id INT NOT NULL,
	FOREIGN KEY (festival_id) REFERENCES festival(festival_id),
	FOREIGN KEY (stage_id) REFERENCES stage(stage_id)
)ENGINE=InnoDB;

DROP TABLE IF EXISTS staff_role;
CREATE TABLE staff_role (
  role_id   INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL UNIQUE
)ENGINE=InnoDB;

DROP TABLE IF EXISTS experience_level;
CREATE TABLE experience_level (
  level_id   INT AUTO_INCREMENT PRIMARY KEY,
  level_name VARCHAR(50) NOT NULL UNIQUE
)ENGINE=InnoDB;

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
)ENGINE=InnoDB;

DROP TABLE IF EXISTS stage_staff;
CREATE TABLE stage_staff (
	stage_id INT NOT NULL,
	staff_id INT NOT NULL,
	PRIMARY KEY (stage_id, staff_id),
	FOREIGN KEY (stage_id) REFERENCES stage(stage_id),
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
)ENGINE=InnoDB;

CREATE TABLE genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
)ENGINE=InnoDB;

CREATE TABLE subgenre (
    subgenre_id INT AUTO_INCREMENT PRIMARY KEY,
    subgenre_name VARCHAR(50) NOT NULL UNIQUE,
    genre_id INT NOT NULL,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
)ENGINE=InnoDB;

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
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS band (
    band_id INT PRIMARY KEY AUTO_INCREMENT,
    band_name VARCHAR(100) NOT NULL UNIQUE,
    date_of_creation DATE,
    website VARCHAR(255),
    instagram VARCHAR(30),
    genre VARCHAR(50),
    subgenre VARCHAR(50)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS artist_band(-- many to many relationship=>linking table
	artist_id INT,
    band_id INT,
    PRIMARY KEY (band_id, artist_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id),
    FOREIGN KEY (band_id) REFERENCES band(band_id)
)ENGINE=InnoDB;

CREATE TABLE perf_kind (
  kind_id INT AUTO_INCREMENT PRIMARY KEY,
  kind_name VARCHAR(50) NOT NULL UNIQUE
)ENGINE=InnoDB;

CREATE TABLE perf_type (
  type_id INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL UNIQUE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    perf_datetime DATETIME NOT NULL,
    duration INT NOT NULL,
    kind_id INT NOT NULL,
    type_id INT NOT NULL,
    artist_id INT,
    band_id INT,
    event_id INT,
    CONSTRAINT check_duration CHECK (duration BETWEEN 1 AND 180),
    CONSTRAINT check_artist_or_band CHECK ((artist_id IS NOT NULL AND band_id IS NULL) OR (artist_id IS NULL AND band_id IS NOT NULL)),
    FOREIGN KEY (kind_id) REFERENCES perf_kind(kind_id),
    FOREIGN KEY (type_id) REFERENCES perf_type(type_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id),
    FOREIGN KEY (band_id) REFERENCES band(band_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payment_method (
  pm_id INT AUTO_INCREMENT PRIMARY KEY,
  pm_name VARCHAR(12) NOT NULL UNIQUE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS owner (
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    phone_number VARCHAR(13) NOT NULL,-- +YY KK XX XX XX XX 
    method_of_purchase VARCHAR(12),
    payment_info VARCHAR(19), -- 16 digit card info + CVC --KANTO NOT NULL
    total_charge DECIMAL(6,2) DEFAULT 0,
    CONSTRAINT check_age CHECK (age >= 18),
    CONSTRAINT critical_info UNIQUE (first_name,last_name,phone_number),
    FOREIGN KEY (method_of_purchase) REFERENCES payment_method(pm_name)
)AUTO_INCREMENT=1, ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ticket_category (
  cat_id INT AUTO_INCREMENT PRIMARY KEY,
  cat_name VARCHAR(50) NOT NULL UNIQUE
)ENGINE=InnoDB;

CREATE TABLE  IF NOT EXISTS ticket (
	ticket_id BIGINT(13) UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
    ticket_category VARCHAR(13),
    purchase_date DATETIME DEFAULT NOW(),
    cost DECIMAL(6,2),
    method_of_purchase VARCHAR(12),
    activated BOOLEAN DEFAULT FALSE,
    event_id INT NOT NULL,
    owner_id INT NOT NULL,
    CONSTRAINT no_double_tickets_per_event UNIQUE (owner_id,event_id), -- one ticket/performance per owner
    CONSTRAINT distict_categories CHECK( ticket_category= 'general_entry' OR ticket_category='VIP' OR ticket_category='backstage'),
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_category) REFERENCES ticket_category(cat_name),
    FOREIGN KEY (method_of_purchase) REFERENCES payment_method(pm_name)
    )AUTO_INCREMENT = 1000000000000, ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS buyer (
    buyer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT,
	phone_number VARCHAR(13),-- +YY KK XX XX XX XX
    method_of_purchase VARCHAR(12),
    payment_info VARCHAR(19) ,-- ΚΑΝΤΟ NOT NULL,
    number_of_desired_tickets INT DEFAULT 0,
    CONSTRAINT check_age CHECK (age >= 18),
    FOREIGN KEY (method_of_purchase) REFERENCES payment_method(pm_name)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS seller_queue(
	resell_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL, 
	interest_datetime DATETIME DEFAULT NOW(),
	ticket_id BIGINT(13) UNSIGNED UNIQUE NOT NULL , 
    event_id INT NOT NULL, 
    ticket_category VARCHAR(13) NOT NULL,
    sold BOOLEAN DEFAULT FALSE,
    CONSTRAINT distict_categories CHECK( ticket_category= 'general_entry' OR ticket_category='VIP' OR ticket_category='backstage'),
    FOREIGN KEY (seller_id) REFERENCES owner(owner_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_category) REFERENCES ticket_category(cat_name)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS buyer_queue(
	resell_id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
	interest_datetime DATETIME DEFAULT NOW(),
	ticket_id BIGINT(13) UNSIGNED DEFAULT NULL,
    event_id INT DEFAULT NULL,
    ticket_category VARCHAR(13) DEFAULT NULL,
    sold BOOLEAN DEFAULT FALSE,
    CONSTRAINT distict_categories CHECK( ticket_category= 'general_entry' OR ticket_category='VIP' OR ticket_category='backstage'),
    CONSTRAINT check_characteristics CHECK (
    (ticket_id IS NOT NULL AND (event_id IS NULL AND ticket_category IS NULL)) OR
    (ticket_id IS NULL AND (event_id IS NOT NULL AND ticket_category IS NOT NULL))),
    FOREIGN KEY (buyer_id) REFERENCES buyer(buyer_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_category) REFERENCES ticket_category(cat_name)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT(13) UNSIGNED,
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
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE review_summary (-- Extra table to have per-performance reviews
    performance_id INT PRIMARY KEY, -- One-to-one relationship (primary and foreign keys are the same)
    total_reviews INT NOT NULL DEFAULT 0,
    avg_interpretation DECIMAL(4,2) NOT NULL DEFAULT 0,
    avg_sound_and_lighting DECIMAL(4,2) NOT NULL DEFAULT 0,
    avg_stage_presence DECIMAL(4,2) NOT NULL DEFAULT 0,
    avg_organization DECIMAL(4,2) NOT NULL DEFAULT 0,
    avg_overall_impression DECIMAL(4,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id) ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE INDEX review_perf ON review(performance_id);
CREATE INDEX review_ticket ON review(ticket_id);
CREATE INDEX review_perf_date ON review(performance_id, review_date);
CREATE INDEX perf_datetime ON performance(perf_datetime);

-- Trigger to ensure that an owner/ticket can only review a performance once

DELIMITER $$
CREATE TRIGGER review_no_dup
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
	  FROM review
	  WHERE performance_id=NEW.performance_id AND ticket_id=NEW.ticket_id
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
    SELECT 1
    FROM review_summary
    WHERE performance_id = NEW.performance_id
  ) 
  THEN
    INSERT INTO review_summary(performance_id) VALUES (NEW.performance_id);
  END IF;
END$$

CREATE TRIGGER review_sum_after_insert
AFTER INSERT ON review
FOR EACH ROW
BEGIN
  UPDATE review_summary
  SET
      avg_interpretation = (avg_interpretation*total_reviews + NEW.interpretation)/(total_reviews+1),
      avg_sound_and_lighting = (avg_sound_and_lighting*total_reviews + NEW.sound_and_lighting)/(total_reviews+1),
      avg_stage_presence = (avg_stage_presence*total_reviews + NEW.stage_presence)/(total_reviews+1),
      avg_organization = (avg_organization*total_reviews + NEW.organization)/(total_reviews+1),
      avg_overall_impression = (avg_overall_impression*total_reviews + NEW.overall_impression)/(total_reviews+1),
      total_reviews = total_reviews + 1
  WHERE performance_id = NEW.performance_id;
END$$

CREATE TRIGGER review_sum_after_update
AFTER UPDATE ON review
FOR EACH ROW
BEGIN
  UPDATE review_summary
  SET
      avg_interpretation = (avg_interpretation*total_reviews - OLD.interpretation + NEW.interpretation)/total_reviews,
      avg_sound_and_lighting = (avg_sound_and_lighting*total_reviews - OLD.sound_and_lighting + NEW.sound_and_lighting)/total_reviews,
      avg_stage_presence = (avg_stage_presence*total_reviews - OLD.stage_presence + NEW.stage_presence)/total_reviews,
      avg_organization = (avg_organization*total_reviews - OLD.organization + NEW.organization)/total_reviews,
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
        avg_interpretation = (avg_interpretation*total_reviews - OLD.interpretation)/(total_reviews-1),
        avg_sound_and_lighting = (avg_sound_and_lighting*total_reviews - OLD.sound_and_lighting)/(total_reviews-1),
        avg_stage_presence = (avg_stage_presence*total_reviews - OLD.stage_presence)/(total_reviews-1),
        avg_organization = (avg_organization*total_reviews - OLD.organization)/(total_reviews-1),
        avg_overall_impression = (avg_overall_impression*total_reviews - OLD.overall_impression)/(total_reviews-1),
        total_reviews = total_reviews - 1
	  WHERE performance_id = OLD.performance_id;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER scheduling
BEFORE INSERT ON performance
FOR EACH ROW
BEGIN
	DECLARE previous_end DATETIME;
    DECLARE next_start DATETIME;
    DECLARE gap INT;
-- No overlaps
	IF EXISTS(
		SELECT 1
		FROM performance
		WHERE event_id=NEW.event_id AND perf_datetime<NEW.perf_datetime + INTERVAL NEW.duration MINUTE 
			AND NEW.perf_datetime<perf_datetime + INTERVAL duration MINUTE) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Performance overlaps another in the same event';
	END IF;
-- Enforce a 5-30 minute break
	SELECT MAX(perf_datetime + INTERVAL duration MINUTE)
    INTO previous_end
    FROM performance
    WHERE event_id=NEW.event_id;
    IF previous_end IS NOT NULL THEN
		SET gap=TIMESTAMPDIFF(MINUTE,previous_end,NEW.perf_datetime);
        IF gap<5 OR gap>30 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes';
		END IF;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER no_cancel_performance
BEFORE DELETE ON performance
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Δεν επιτρέπεται η ακύρωση εμφάνισης';
END$$

CREATE TRIGGER no_cancel_festival
BEFORE DELETE ON festival
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Δεν επιτρέπεται η ακύρωση φεστιβάλ';
END$$
DELIMITER ;