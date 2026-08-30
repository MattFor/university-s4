CREATE DATABASE IF NOT EXISTS events;
USE events;

CREATE TABLE IF NOT EXISTS events(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

INSERT INTO events(name)
SELECT 'Turniej szachowy'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Turniej szachowy');

INSERT INTO events(name)
SELECT 'Wieczór planszówek'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Wieczór planszówek');

INSERT INTO events(name)
SELECT 'Maraton filmowy'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Maraton filmowy');

INSERT INTO events(name)
SELECT 'Konkurs pieczenia ciast'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Konkurs pieczenia ciast');

INSERT INTO events(name)
SELECT 'Turniej FIFA'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Turniej FIFA');

INSERT INTO events(name)
SELECT 'Quiz wiedzy ogólnej'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Quiz wiedzy ogólnej');

INSERT INTO events(name)
SELECT 'Bieg charytatywny'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Bieg charytatywny');

INSERT INTO events(name)
SELECT 'Piknik rodzinny'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Piknik rodzinny');

INSERT INTO events(name)
SELECT 'Pokaz talentów'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Pokaz talentów');

INSERT INTO events(name)
SELECT 'Nocne obserwacje gwiazd'
WHERE NOT EXISTS (SELECT 1 FROM events WHERE name='Nocne obserwacje gwiazd');

CREATE TABLE IF NOT EXISTS registrations(
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(event_id) REFERENCES events(id)
);

CREATE TABLE IF NOT EXISTS audit_logs(
    id INT AUTO_INCREMENT PRIMARY KEY,
    operation_type VARCHAR(30) NOT NULL,
    registration_id INT NOT NULL,
    event_id INT NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE DATABASE IF NOT EXISTS lab2;
USE lab2;

CREATE TABLE IF NOT EXISTS zadanie2 (
    komunikat VARCHAR(100)
);

INSERT INTO zadanie2 (komunikat)
SELECT 'Test 1'
WHERE NOT EXISTS (
    SELECT 1 FROM zadanie2 WHERE komunikat='Test 1'
);

INSERT INTO zadanie2 (komunikat)
SELECT 'Test 2'
WHERE NOT EXISTS (
    SELECT 1 FROM zadanie2 WHERE komunikat='Test 2'
);

INSERT INTO zadanie2 (komunikat)
SELECT 'REDACTED 155197'
WHERE NOT EXISTS (
    SELECT 1 FROM zadanie2 WHERE komunikat='REDACTED 155197'
);

USE events;

DROP TRIGGER IF EXISTS registration_after_insert;

DELIMITER $$

CREATE TRIGGER registration_after_insert
AFTER INSERT ON registrations
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs(operation_type, registration_id, event_id)
    VALUES('INSERT', NEW.id, NEW.event_id);
END$$

DELIMITER ;

GRANT ALL PRIVILEGES ON lab2.* TO 'user1'@'%';
GRANT ALL PRIVILEGES ON events.* TO 'user1'@'%';
FLUSH PRIVILEGES;
