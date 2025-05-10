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
	continent VARCHAR(100) NOT NULL,
    location_image BLOB NULL DEFAULT NULL
)ENGINE=InnoDB;

DROP TABLE IF EXISTS festival;
CREATE TABLE festival (
	festival_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	year INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	location_id INT NOT NULL,
    festival_image BLOB NULL DEFAULT NULL
	CONSTRAINT chk_festival_dates CHECK (start_date <= end_date),
    CONSTRAINT chk_year CHECK (year=YEAR(start_date)),
	FOREIGN KEY (location_id) REFERENCES location(location_id)
)ENGINE=InnoDB;

DROP TABLE IF EXISTS stage;
CREATE TABLE stage (
    stage_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_capacity INT NOT NULL,
    equipment TEXT,
    stage_image BLOB NULL DEFAULT NULL
)ENGINE=InnoDB;

DROP TABLE IF EXISTS event;
CREATE TABLE event (
	event_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	festival_id INT NOT NULL,
	stage_id INT NOT NULL,
  event_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  CONSTRAINT chk_event_time CHECK (start_time < end_time),
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
    staff_image BLOB NULL DEFAULT NULL
	CONSTRAINT check_age CHECK (age > 0),
    FOREIGN KEY (role_id) REFERENCES staff_role(role_id),
	FOREIGN KEY (level_id) REFERENCES experience_level(level_id)
)ENGINE=InnoDB;

DROP TABLE IF EXISTS staff_schedule;
CREATE TABLE staff_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    event_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES staff_role(role_id)
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
    genre_id INT NOT NULL, 
    subgenre_id INT NOT NULL,
    website VARCHAR(77),
    instagram VARCHAR(30),
    artist_image BLOB NULL DEFAULT NULL,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY (subgenre_id) REFERENCES subgenre(subgenre_id)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS band (
    band_id INT PRIMARY KEY AUTO_INCREMENT,
    band_name VARCHAR(100) NOT NULL UNIQUE,
    date_of_creation DATE,
    website VARCHAR(255),
    instagram VARCHAR(30),
    genre_id INT NOT NULL, 
    subgenre_id INT NOT NULL,
    band_image BLOB NULL DEFAULT NULL,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY (subgenre_id) REFERENCES subgenre(subgenre_id)
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
    perf_time TIME NOT NULL,
    duration INT NOT NULL,
    kind_id INT NOT NULL,
    type_id INT NOT NULL,
    artist_id INT,
    band_id INT,
    event_id INT NOT NULL,
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
    phone_number VARCHAR(14) NOT NULL,-- +YY KK XX XX XX XX 
    method_of_purchase VARCHAR(12),
    payment_info VARCHAR(19), -- 16 digit card info + CVC --KANTO NOT NULL
    total_charge DECIMAL(6,2) DEFAULT 0,
    owner_image BLOB NULL DEFAULT NULL,
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
    ticket_image BLOB NULL DEFAULT NULL,
    CONSTRAINT no_double_tickets_per_event UNIQUE (owner_id,event_id), -- one ticket/event per owner
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
    buyer_image BLOB NULL DEFAULT NULL
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
CREATE INDEX perf_time ON performance(perf_time);

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
		WHERE event_id=NEW.event_id AND perf_time<NEW.perf_time + INTERVAL NEW.duration MINUTE 
			AND NEW.perf_time<perf_time + INTERVAL duration MINUTE) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Performance overlaps another in the same event';
	END IF;
-- Enforce a 5-30 minute break
	SELECT MAX(perf_time + INTERVAL duration MINUTE)
    INTO previous_end
    FROM performance
    WHERE event_id=NEW.event_id;
    IF previous_end IS NOT NULL THEN
		SET gap=TIMESTAMPDIFF(MINUTE,previous_end,NEW.perf_time);
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

DELIMITER $$
CREATE TRIGGER check_vip_ticket_limit
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
  DECLARE v_stage_id INT;
  DECLARE v_capacity INT;
  DECLARE v_vip_count INT;

  IF NEW.event_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Ticket must reference an event.';
  END IF;
  
	IF NEW.ticket_category = 'VIP' THEN
      SELECT stage_id
      INTO v_stage_id
      FROM event
      WHERE event_id = NEW.event_id;

      SELECT max_capacity
      INTO v_capacity
      FROM stage
      WHERE stage_id = v_stage_id;

      SELECT COUNT(*)
      INTO v_vip_count
      FROM ticket
      WHERE event_id = NEW.event_id
        AND ticket_category = 'VIP';

      IF (v_vip_count + 1) > FLOOR(v_capacity / 10) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot issue more VIP tickets: capacity exceeded.';
      END IF;
	END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_stage_event_conflict
BEFORE INSERT ON event
FOR EACH ROW
BEGIN
    DECLARE conflict_count INT;

    SELECT COUNT(*)
    INTO conflict_count
    FROM event
    WHERE stage_id = NEW.stage_id
      AND event_date = NEW.event_date
      AND (
            (NEW.start_time BETWEEN start_time AND end_time) OR
            (NEW.end_time BETWEEN start_time AND end_time) OR
            (start_time BETWEEN NEW.start_time AND NEW.end_time)
          );

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Η σκηνή είναι ήδη δεσμευμένη για άλλη παράσταση εκείνη την ώρα.';
    END IF;
END $$

DELIMITER ;

-- this trigger charges the owner the first time a ticket is bought
DELIMITER //
CREATE TRIGGER bill_owner_once_ticket_is_bought
AFTER INSERT ON ticket
FOR EACH ROW
BEGIN
   UPDATE owner
   SET total_charge=total_charge+NEW.cost
   WHERE owner_id=NEW.owner_id;
END//
DELIMITER ;

-- this trigger checks the following:
-- if the event is sold out
-- if the event is old 
DELIMITER // 
CREATE TRIGGER check_for_valid_demand
BEFORE INSERT ON buyer_queue
FOR EACH ROW
BEGIN
	DECLARE tic_event_id INT;
    DECLARE tic_category VARCHAR(13);
	DECLARE events_capacity INT;
    DECLARE max_capacity_now INT;
    DECLARE today DATE;
    DECLARE festivals_date DATE;
    DECLARE current_festival_id INT;
    
    IF (NEW.ticket_id IS NULL) THEN -- if event and ticket category where specified
    
		SELECT COUNT(*) INTO events_capacity FROM ticket
		WHERE event_id=NEW.event_id;
        
		-- check if the event is old
        -- no need to check if ticket is specified because it wouldn't be inserted in seller queue 
        -- and therefore would not be available for purchase
        
		SET today=CURDATE();
        
        SELECT festival_id
		INTO current_festival_id
		FROM event
		WHERE event_id=NEW.event_id;
    
		SELECT start_date
		INTO festivals_date
		FROM festival
		WHERE festival_id=current_festival_id;
        
		IF (today>festivals_date) THEN
			SET @msg = 'This event has passed therefore tickets for it are not sold';
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
		END IF;	
		SELECT max_capacity
		INTO max_capacity_now 
		FROM stage
		WHERE stage_id=(
			SELECT stage_id 
			FROM event 
			WHERE event_id=NEW.event_id);
            
		IF events_capacity<max_capacity_now THEN 
			SET @msg = 'Tickets for this event are still available, therefore resell queue for this event is not activated';
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
		END IF;
        
	ELSE  -- if ticket was spacified
		SELECT event_id,ticket_category
        INTO tic_event_id,tic_category
        FROM ticket
        WHERE ticket_id=NEW.ticket_id;
        
        SELECT COUNT(*) INTO events_capacity FROM ticket
		WHERE event_id=tic_event_id;
			
		SELECT max_capacity
		INTO max_capacity_now 
		FROM stage
		WHERE stage_id=(
			SELECT stage_id 
			FROM event 
			WHERE event_id=tic_event_id);
            
		IF events_capacity<max_capacity_now THEN 
			SET @msg = 'Tickets for this event are still available, therefore resell queue for this event is not activated';
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
		END IF;
	
	END IF;
END//

DELIMITER ;

-- check if the event is sold out or if the requested event has passed
delimiter //
CREATE TRIGGER are_tickets_available
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN

	DECLARE events_capacity INT;
    DECLARE max_capacity_now INT;

	SELECT COUNT(*) INTO events_capacity FROM ticket
		WHERE event_id=NEW.event_id;
			
	SELECT max_capacity
	INTO max_capacity_now 
	FROM stage
	WHERE stage_id=(
		SELECT stage_id 
		FROM event 
		WHERE event_id=NEW.event_id);
    
    IF (events_capacity=max_capacity_now) THEN
		SET @msg = 'There are not any tickets available';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        
	END IF;
END//

delimiter ;

-- check if event is old 
delimiter //
CREATE TRIGGER time_of_event
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN

	DECLARE events_date DATE;
    DECLARE today DATE;
    
    SET today=NEW.purchase_date;
	
	SELECT event_date
	INTO events_date
	FROM event
	WHERE event_id=NEW.event_id;
    
    IF (today>events_date) THEN
		SET @msg = 'This event has passed';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
        
	END IF;
END//
delimiter ;

-- AUTOSELL
-- INSERT BUYER
DELIMITER $$
-- DROP TRIGGER IF EXISTS search_for_item;-- FIND MATCH 
CREATE TRIGGER search_for_item_once_its_desired
BEFORE INSERT ON buyer_queue
FOR EACH ROW
BEGIN
  DECLARE match_resell_id INT;
  DECLARE match_ticket_id BIGINT(13);
  DECLARE buyer_exists INT;
  DECLARE updated_first_name VARCHAR(20);
  DECLARE updated_last_name VARCHAR(20);
  DECLARE updated_age INT;
  DECLARE updated_phone_number VARCHAR(13);
  DECLARE updated_method_of_purchase VARCHAR(12);
  DECLARE updated_payment_info VARCHAR(19);
  DECLARE is_being_sold BIGINT(13);
  DECLARE new_charge DECIMAL(6,2);
  DECLARE previous_owner INT;
  
  SELECT ticket_id
  INTO is_being_sold
  FROM seller_queue
  WHERE ticket_id=NEW.ticket_id
  LIMIT 1;
  
  IF (is_being_sold IS NULL AND (NEW.event_id IS NULL AND NEW.ticket_category IS NULL))THEN
		SET @msg = 'Can not buy ticket that is not available';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  
   -- GET THE CHARACTERISTICS FOR THE NEW OWNER
   SELECT first_name, last_name, age, phone_number,method_of_purchase, payment_info
    INTO updated_first_name,updated_last_name,updated_age,updated_phone_number,updated_method_of_purchase,updated_payment_info 
    FROM buyer
    WHERE buyer_id = NEW.buyer_id;
    
  -- FIND MATCHING SELLER  
  SELECT resell_id,ticket_id
	INTO match_resell_id,match_ticket_id
    FROM seller_queue  
    WHERE ((ticket_id=NEW.ticket_id OR (event_id=NEW.event_id AND ticket_category=NEW.ticket_category)) AND sold=0)
	ORDER BY interest_datetime
	LIMIT 1;
  
    IF match_resell_id IS NOT NULL THEN -- IF MATCH WAS FOUND 
    
    SELECT owner_id
    INTO buyer_exists
    FROM owner
    WHERE first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number
    LIMIT 1; -- to ensure no error in thrown
    
    IF buyer_exists IS NULL THEN 
    
    -- INSERT BUYER IF NECESSARY AND BILL THEM
    SELECT cost -- buyer doesnt already exist therefore they have not purchased anything yet
		INTO new_charge
		FROM ticket
		WHERE ticket_id=match_ticket_id;
    
    INSERT INTO owner(first_name,last_name,age,phone_number,method_of_purchase,payment_info,total_charge)
    VALUES (updated_first_name,updated_last_name,updated_age,updated_phone_number,updated_method_of_purchase,updated_payment_info,new_charge);
    
    ELSE 
		
        SELECT cost -- buyer exists so they have purchased something
        INTO new_charge
        FROM ticket
        WHERE ticket_id=match_ticket_id;
        
		UPDATE owner
        SET total_charge=total_charge+ new_charge 
        WHERE first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number
		LIMIT 1;
        
    END IF ;
    
     -- REFUND OLD OWNER
	SELECT owner_id 
    INTO previous_owner
    FROM ticket
    WHERE ticket_id=match_ticket_id; 
    
	UPDATE owner
    SET total_charge=total_charge-new_charge
    WHERE owner_id=previous_owner;
    
    UPDATE ticket
    SET owner_id=(
		SELECT owner_id 
        FROM owner 
        WHERE (first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number)
		),
        method_of_purchase=(
		SELECT method_of_purchase
        FROM owner 
        WHERE (first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number)
		),
        purchase_date=NOW()
	WHERE ticket_id=match_ticket_id;

	DELETE FROM seller_queue -- delete sold item
	WHERE resell_id=match_resell_id;  
    
    SET NEW.sold=TRUE;
   ELSE
	    UPDATE buyer
		SET number_of_desired_tickets=number_of_desired_tickets+1
		WHERE buyer_id=NEW.buyer_id;
   END IF;
END$$

DELIMITER ;

-- INSERT SELLER
DELIMITER $$
-- DROP TRIGGER IF EXISTS search_for_item_once_its_supplied;-- FIND MATCH 
CREATE TRIGGER search_for_item_once_its_supplied
BEFORE INSERT ON seller_queue
FOR EACH ROW
BEGIN
  DECLARE match_resell_id INT;
  DECLARE match_buyer_id INT;
  DECLARE match_ticket_id INT;
  DECLARE updated_first_name VARCHAR(20);
  DECLARE updated_last_name VARCHAR(20);
  DECLARE updated_age INT;
  DECLARE updated_phone_number VARCHAR(13);
  DECLARE updated_method_of_purchase VARCHAR(12);
  DECLARE updated_payment_info VARCHAR(19);
  DECLARE buyer_exists INT;
  DECLARE is_activated BOOLEAN;
  DECLARE new_charge DECIMAL(6,2);
  DECLARE previous_owner INT;
  
  SELECT activated 
  INTO is_activated
  FROM ticket
  WHERE ticket_id=NEW.ticket_id;
  
  IF is_activated=1 THEN
		SET @msg = 'Can not resell activated ticket ';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  
  SELECT resell_id,buyer_id
	INTO match_resell_id,match_buyer_id
    FROM buyer_queue  
    WHERE ((ticket_id=NEW.ticket_id OR (event_id=NEW.event_id AND ticket_category=NEW.ticket_category)) AND sold=0)
	ORDER BY interest_datetime
	LIMIT 1;


    IF match_resell_id IS NOT NULL THEN -- IF MATCH IS FOUND

	SELECT first_name, last_name, age, phone_number,method_of_purchase, payment_info
		INTO updated_first_name,updated_last_name,updated_age,updated_phone_number,updated_method_of_purchase,updated_payment_info
		FROM buyer
		WHERE buyer_id = match_buyer_id;
        
	SELECT owner_id
		INTO buyer_exists
		FROM owner
		WHERE first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number
		LIMIT 1; -- to ensure no error in throw
        
	IF buyer_exists IS NULL THEN 
    
    -- INSERT BUYER IS NECESSARY AND BILL THEM
    SELECT cost -- buyer doesnt already exist therefore they have not purchased anything yet
		INTO new_charge
		FROM ticket
		WHERE ticket_id=match_ticket_id;
    
    INSERT INTO owner(first_name,last_name,age,phone_number,method_of_purchase,payment_info,total_charge)
    VALUES (updated_first_name,updated_last_name,updated_age,updated_phone_number,updated_method_of_purchase,updated_payment_info,new_charge);
    
    ELSE 
		
        SELECT cost -- buyer exists so they have purchased something
        INTO new_charge
        FROM ticket
        WHERE ticket_id=NEW.ticket_id;
        
		UPDATE owner
        SET total_charge=total_charge+ new_charge 
        WHERE first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number
		LIMIT 1;
        
    END IF ;
    
	-- REFUND OLD OWNER
    
    SELECT owner_id 
    INTO previous_owner
    FROM ticket
    WHERE ticket_id=NEW.ticket_id;
    
    UPDATE owner
    SET total_charge=total_charge-new_charge
    WHERE owner_id=previous_owner;
    
   UPDATE ticket
    SET owner_id=(
		SELECT owner_id 
        FROM owner 
        WHERE (first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number)
		),
        method_of_purchase=(
		SELECT method_of_purchase
        FROM owner 
        WHERE (first_name=updated_first_name AND last_name=updated_last_name AND phone_number=updated_phone_number)
		),
        purchase_date=NOW()
	WHERE ticket_id=NEW.ticket_id;
    
        
     DELETE FROM buyer_queue -- delete satisfied buyer
     WHERE resell_id=match_resell_id ;

	SET NEW.sold=1; 
    
	UPDATE buyer
	SET number_of_desired_tickets=number_of_desired_tickets-1
	WHERE buyer_id=match_buyer_id;
    
    END IF;
    
END$$

DELIMITER ;

-- DATA INSERTION PROCEDURE
-- This procedure ensures that the data inserted will be correct and therefore no other checks are necessary

DELIMITER //
CREATE PROCEDURE insert_into_seller_queue (IN seller_owner_id INT, IN for_sale_ticket_id BIGINT(13) unsigned)
BEGIN
	DECLARE tickets_owner INT;
	DECLARE sell_event_id INT;
    DECLARE sell_ticket_category VARCHAR(13); 
    DECLARE tickets_for_event INT;
    DECLARE max_capacity_now INT;
    DECLARE current_stage_id int;
    DECLARE today DATE;
    DECLARE festivals_date DATE;
    DECLARE current_festival_id INT;
    
    SET today=CURDATE();
    
    -- check if owner and ticket pair valid
	SELECT owner_id
    INTO tickets_owner
    FROM ticket
    WHERE ticket_id=for_sale_ticket_id;
    
    IF ( tickets_owner<> seller_owner_id) THEN
		SET @msg = 'This ticket does not belong to this seller';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
	ELSE 
		-- get the rest of the information and check if reselling is possible for this event
		SELECT event_id, ticket_category
		INTO sell_event_id,sell_ticket_category
		FROM ticket
		WHERE ticket_id=for_sale_ticket_id;
        
        -- check if the ticket is old
        SELECT festival_id
		INTO current_festival_id
		FROM event
		WHERE event_id=sell_event_id;
    
		SELECT start_date
		INTO festivals_date
		FROM festival
		WHERE festival_id=current_festival_id;
        
		IF (today>festivals_date) THEN
			SET @msg = 'This event has passed therefore the tickets can not be sold';
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
		END IF;
        
        -- check if the event is sold out
        SELECT COUNT(*) INTO tickets_for_event FROM ticket
        WHERE event_id=sell_event_id;
        
        SET current_stage_id=
			(SELECT stage_id 
            FROM event 
            WHERE event_id=sell_event_id);
            
        SELECT max_capacity
        INTO max_capacity_now 
        FROM stage
        WHERE stage_id=current_stage_id;
        
        IF tickets_for_event< max_capacity_now THEN 
			SET @msg = 'Tickets for this event are still available, therefore resell queue for this event is not activated';
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
		ELSE
			-- finish the insert
			INSERT INTO seller_queue(seller_id,ticket_id,event_id,ticket_category)
			VALUES(seller_owner_id,for_sale_ticket_id,sell_event_id,sell_ticket_category);
        END IF;
	END IF;
END//

DELIMITER ;

-- the following events clear up the queues
delimiter | 
CREATE EVENT clear_owners_buyers
ON SCHEDULE EVERY 5 MINUTE
COMMENT 'Clear all unnecessary owners and buyers'
DO
BEGIN
    DELETE FROM owner WHERE owner_id NOT IN (SELECT owner_id FROM ticket);
    DELETE FROM buyer WHERE number_of_desired_tickets=0;
END|

delimiter ;

delimiter |

CREATE EVENT clear_queues
ON SCHEDULE EVERY 5 MINUTE
COMMENT 'Clear all sold items from buyer and seller queue'
DO
BEGIN
    DELETE FROM buyer_queue WHERE sold=1;
    DELETE FROM seller_queue WHERE sold=1;
END |

delimiter ;

DELIMITER $$

CREATE PROCEDURE assign_security_to_event(IN in_event_id INT)
BEGIN
  DECLARE security_role_id INT;
  DECLARE required_security INT DEFAULT 0;
  DECLARE current_security INT DEFAULT 0;
  DECLARE missing_security INT DEFAULT 0;
  DECLARE available_staff_id INT;
  DECLARE stage_id_val INT;

  SELECT role_id INTO security_role_id
  FROM staff_role
  WHERE role_name = 'security';

  SELECT stage_id INTO stage_id_val
  FROM event
  WHERE event_id = in_event_id;

  SELECT CEIL(s.max_capacity * 0.05) INTO required_security
  FROM stage s
  WHERE s.stage_id = stage_id_val;

  SELECT COUNT(*) INTO current_security
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.event_id = in_event_id AND s.role_id = security_role_id;

  SET missing_security = required_security - current_security;

  WHILE missing_security > 0 DO
    SELECT s.staff_id INTO available_staff_id
    FROM staff s
    WHERE s.role_id = security_role_id
      AND s.staff_id NOT IN (
        SELECT ss.staff_id
        FROM staff_schedule ss
        JOIN event e2 ON ss.event_id = e2.event_id
        JOIN event e1 ON e1.event_id = in_event_id
        WHERE e2.event_date = e1.event_date
      )
    LIMIT 1;

    IF available_staff_id IS NOT NULL THEN

      INSERT INTO staff_schedule (staff_id, event_id, role_id)
      VALUES (available_staff_id, in_event_id, security_role_id);

      SET missing_security = missing_security - 1;
    ELSE
      SET missing_security = 0;
    END IF;
  END WHILE;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE assign_support_to_event(IN in_event_id INT)
BEGIN
  DECLARE support_role_id INT;
  DECLARE required_support INT DEFAULT 0;
  DECLARE current_support INT DEFAULT 0;
  DECLARE missing_support INT DEFAULT 0;
  DECLARE available_staff_id INT;
  DECLARE stage_id_val INT;

  SELECT role_id INTO support_role_id
  FROM staff_role
  WHERE role_name = 'support';

  SELECT stage_id INTO stage_id_val
  FROM event
  WHERE event_id = in_event_id;

  SELECT CEIL(s.max_capacity * 0.02) INTO required_support
  FROM stage s
  WHERE s.stage_id = stage_id_val;

  SELECT COUNT(*) INTO current_support
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.event_id = in_event_id AND s.role_id = support_role_id;

  SET missing_support = required_support - current_support;

  WHILE missing_support > 0 DO
    SELECT s.staff_id INTO available_staff_id
    FROM staff s
    WHERE s.role_id = support_role_id
      AND s.staff_id NOT IN (
        SELECT ss.staff_id
        FROM staff_schedule ss
        JOIN event e2 ON ss.event_id = e2.event_id
        JOIN event e1 ON e1.event_id = in_event_id
        WHERE e2.event_date = e1.event_date
      )
    LIMIT 1;

    IF available_staff_id IS NOT NULL THEN
      INSERT INTO staff_schedule (staff_id, event_id, role_id)
      VALUES (available_staff_id, in_event_id, support_role_id);

      SET missing_support = missing_support - 1;
    ELSE
      SET missing_support = 0;
    END IF;
  END WHILE;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE assign_tech_to_event(IN in_event_id INT)
BEGIN
  DECLARE tech_role_id INT;
  DECLARE current_tech INT DEFAULT 0;
  DECLARE available_staff_id INT;

  
  SELECT role_id INTO tech_role_id
  FROM staff_role
  WHERE role_name = 'technician';

  SELECT COUNT(*) INTO current_tech
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.event_id = in_event_id AND s.role_id = tech_role_id;

  IF current_tech = 0 THEN
    SELECT s.staff_id INTO available_staff_id
    FROM staff s
    WHERE s.role_id = tech_role_id
      AND s.staff_id NOT IN (
        SELECT ss.staff_id
        FROM staff_schedule ss
        JOIN event e2 ON ss.event_id = e2.event_id
        JOIN event e1 ON e1.event_id = in_event_id
        WHERE e2.event_date = e1.event_date
      )
    LIMIT 1;

    IF available_staff_id IS NOT NULL THEN
      INSERT INTO staff_schedule (staff_id, event_id, role_id)
      VALUES (available_staff_id, in_event_id, tech_role_id);
    END IF;
  END IF;
END$$

DELIMITER ;


DELIMITER //

CREATE TRIGGER trigger_check_staff_on_event
AFTER INSERT ON event
FOR EACH ROW
BEGIN
  CALL assign_security_to_event(NEW.event_id);
  CALL assign_support_to_event(NEW.event_id);
  CALL assign_tech_to_event(NEW.event_id);
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER correct_event_date
BEFORE INSERT ON event
FOR EACH ROW
BEGIN
	DECLARE festival_start_date DATE;
    DECLARE festival_end_date DATE;
    
    SELECT start_date,end_date
    INTO festival_start_date,festival_end_date
    FROM festival
    WHERE (festival_id=new.festival_id);
    
    IF(festival_start_date>new.event_date or festival_end_date<new.event_date) THEN 
		SET @msg = 'Invalid event date';
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER correct_performance_time
BEFORE INSERT ON performance
FOR EACH ROW
BEGIN
	DECLARE event_start_time TIME;
    DECLARE event_end_time TIME;
    
    SELECT start_time,end_time
    INTO event_start_time,event_end_time
    FROM event
    WHERE (event_id=new.event_id);
    
    IF(event_start_time>new.perf_time or event_end_time<DATE_ADD(new.perf_time, INTERVAL new.duration MINUTE) or event_end_time<=new.perf_time) THEN 
		SET @msg = 'Invalid performance time or performance duration';
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
	END IF;
END //
DELIMITER ;