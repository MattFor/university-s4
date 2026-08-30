CREATE TABLE registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100),
    event_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER registration_after_insert
AFTER INSERT ON registrations
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs(message)
    VALUES (
        CONCAT('Uzytkownik ', NEW.username,
        ' zapisal sie na wydarzenie ',
        NEW.event_name)
    );
END//

DELIMITER ;
