CREATE DATABASE IF NOT EXISTS eventsdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eventsdb;

CREATE TABLE IF NOT EXISTS registrations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    event_id TINYINT UNSIGNED NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registration_id BIGINT UNSIGNED NOT NULL,
    username VARCHAR(100) NOT NULL,
    event_id TINYINT UNSIGNED NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    action VARCHAR(32) NOT NULL,
    processed TINYINT(1) NOT NULL DEFAULT 0,
    processed_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_processed (processed),
    INDEX idx_event_id (event_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER registration_after_insert
AFTER INSERT ON registrations
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        registration_id,
        username,
        event_id,
        event_name,
        action,
        processed
    )
    VALUES (
        NEW.id,
        NEW.username,
        NEW.event_id,
        NEW.event_name,
        'INSERT',
        0
    );
END$$

DELIMITER ;
