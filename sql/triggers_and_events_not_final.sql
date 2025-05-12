DELIMITER // --forced to do a stored procedure due to trigger issues

CREATE PROCEDURE repeated_performer_timing_issue(
    IN perf_time TIME ,
    IN duration INT,
    IN kind_id INT ,
    IN type_id INT,
    IN artist_id INT,
    IN band_id INT,
    IN event_id INT 
)
BEGIN
    DECLARE artist_count INT;
    DECLARE band_count INT;

    SELECT COUNT(DISTINCT festival.year) INTO artist_count
    FROM performance
    JOIN event ON event.performance_id = performance.performance_id
    JOIN festival ON festival.event_id = event.event_id
    WHERE performance.artist_id = artist_id
      AND festival.year IN (
          YEAR(CURDATE()) - 3,
          YEAR(CURDATE()) - 2,
          YEAR(CURDATE()) - 1
      );

    SELECT COUNT(DISTINCT festival.year) INTO band_count
    FROM performance
    JOIN event ON event.performance_id = performance.performance_id
    JOIN festival ON festival.event_id = event.event_id
    WHERE performance.band_id = new.band_id
      AND festival.year IN (
          YEAR(CURDATE()) - 3,
          YEAR(CURDATE()) - 2,
          YEAR(CURDATE()) - 1
      );

    IF artist_count = 3 OR band_count=3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This artist has been playing for 3 continuous years';
    
    ELSE
        INSERT INTO performance (perf_time,duration,kind_id,type_id,artist_id,band_id,event_id)
        VALUES (perf_time,duration,kind_id,type_id,artist_id,band_id,event_id);
    END IF;
END //

DELIMITER ;
-- NEED TO CHANGE PYTHON TO USE THIS TO INSERT ON PERFORMANCE