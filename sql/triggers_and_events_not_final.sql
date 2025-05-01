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

	DECLARE festivals_date DATE;
    DECLARE current_festival_id INT;
    DECLARE today DATE;
    
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