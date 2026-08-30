SET SERVEROUTPUT ON;

-- 1. Czytelnik z najmniejszą liczbą wypożyczeń
DECLARE
    v_min_liczba NUMBER;
    v_ile        NUMBER;
    v_nazwisko   CZYTELNIK.NAZWISKO%TYPE;
    v_imie       CZYTELNIK.IMIE%TYPE;

    e_wielu_czytelnikow EXCEPTION;
BEGIN
    -- Minimalna liczba wypożyczeń, licząc także czytelników bez wypożyczeń
    SELECT MIN(ile)
    INTO v_min_liczba
    FROM (SELECT c.id_czyt, COUNT(w.id_wyp) AS ile
          FROM czytelnik c
                   LEFT JOIN wypozyczenia w ON c.id_czyt = w.id_czyt
          GROUP BY c.id_czyt);

    -- Sprawdzenie, czy jest więcej niż jeden czytelnik z takim minimum
    SELECT COUNT(*)
    INTO v_ile
    FROM (SELECT c.id_czyt
          FROM czytelnik c
                   LEFT JOIN wypozyczenia w ON c.id_czyt = w.id_czyt
          GROUP BY c.id_czyt
          HAVING COUNT(w.id_wyp) = v_min_liczba);

    IF v_ile > 1 THEN
        RAISE e_wielu_czytelnikow;
    END IF;

    -- Pobranie danych jedynego czytelnika
    SELECT c.nazwisko, c.imie
    INTO v_nazwisko, v_imie
    FROM czytelnik c
             LEFT JOIN wypozyczenia w ON c.id_czyt = w.id_czyt
    GROUP BY c.id_czyt, c.nazwisko, c.imie
    HAVING COUNT(w.id_wyp) = v_min_liczba;

    DBMS_OUTPUT.PUT_LINE('Czytelnik z najmniejszą liczbą wypożyczeń: ' || v_nazwisko || ' ' || v_imie);

EXCEPTION
    WHEN e_wielu_czytelnikow THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: więcej niż jeden czytelnik ma najmniejszą liczbę wypożyczeń.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 2. Gatunek najdroższej książki
DECLARE
    v_max_cena KSIAZKA.CENA%TYPE;
    v_ile      NUMBER;
    v_gatunek  GATUNEK.G_NAZWA%TYPE;
    v_tytul    KSIAZKA.TYTUL%TYPE;

    e_wiele_ksiazek EXCEPTION;
BEGIN
    SELECT MAX(cena)
    INTO v_max_cena
    FROM ksiazka;

    SELECT COUNT(*)
    INTO v_ile
    FROM ksiazka
    WHERE cena = v_max_cena;

    IF v_ile > 1 THEN
        RAISE e_wiele_ksiazek;
    END IF;

    SELECT g.g_nazwa, k.tytul
    INTO v_gatunek, v_tytul
    FROM ksiazka k
             JOIN gatunek g ON k.id_gat = g.id_gat
    WHERE k.cena = v_max_cena;

    DBMS_OUTPUT.PUT_LINE('Najdroższa książka:');
    DBMS_OUTPUT.PUT_LINE('Gatunek: ' || v_gatunek);
    DBMS_OUTPUT.PUT_LINE('Tytuł: ' || v_tytul);
    DBMS_OUTPUT.PUT_LINE('Cena: ' || v_max_cena);

EXCEPTION
    WHEN e_wiele_ksiazek THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: więcej niż jedna książka ma najwyższą cenę.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/


-- 3. Tabela logów
CREATE TABLE AUTOR_LOG
(
    ID_AUT        NUMBER(4),
    NAZWISKO      VARCHAR2(30),
    IMIE          VARCHAR2(30),
    KRAJ          VARCHAR2(30),
    LOG_OPERATION VARCHAR2(10)
);

CREATE OR REPLACE TRIGGER TRG_AUTOR_INSERT
    AFTER INSERT
    ON AUTOR
    FOR EACH ROW
BEGIN
    INSERT INTO AUTOR_LOG (ID_AUT, NAZWISKO, IMIE, KRAJ, LOG_OPERATION)
    VALUES (:NEW.ID_AUT, :NEW.NAZWISKO, :NEW.IMIE, :NEW.KRAJ, 'INSERT');
END;
/

CREATE OR REPLACE TRIGGER TRG_AUTOR_UPDATE
    AFTER UPDATE
    ON AUTOR
    FOR EACH ROW
BEGIN
    INSERT INTO AUTOR_LOG (ID_AUT, NAZWISKO, IMIE, KRAJ, LOG_OPERATION)
    VALUES (:NEW.ID_AUT, :NEW.NAZWISKO, :NEW.IMIE, :NEW.KRAJ, 'UPDATE');
END;
/

CREATE OR REPLACE TRIGGER TRG_AUTOR_DELETE
    AFTER DELETE
    ON AUTOR
    FOR EACH ROW
BEGIN
    INSERT INTO AUTOR_LOG (ID_AUT, NAZWISKO, IMIE, KRAJ, LOG_OPERATION)
    VALUES (:OLD.ID_AUT, :OLD.NAZWISKO, :OLD.IMIE, :OLD.KRAJ, 'DELETE');
END;
/

-- 4. Trigger blokujący wstawienie nazwiska Dorian
CREATE OR REPLACE TRIGGER TRG_AUTOR_BI_DORIAN
    BEFORE INSERT
    ON AUTOR
    FOR EACH ROW
BEGIN
    IF UPPER(:NEW.NAZWISKO) = 'DORIAN' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie można wstawić autora o nazwisku Dorian.');
    END IF;
END;
/

-- 5. Zwiększanie cen książek o 5%, od najtańszych, z przerwaniem po przekroczeniu 300 zł
DECLARE
    CURSOR c_ksiazki IS
        SELECT id_ks, tytul, cena
        FROM ksiazka
        ORDER BY cena ASC
            FOR UPDATE OF cena;
    v_nowa_cena NUMBER;
BEGIN
    FOR r IN c_ksiazki
        LOOP
            v_nowa_cena := ROUND(r.cena * 1.05, 2);

            IF v_nowa_cena > 300 THEN
                DBMS_OUTPUT.PUT_LINE('Przerwano na książce: ' || r.tytul || ', cena po podwyżce = ' || v_nowa_cena);
                EXIT;
            END IF;

            UPDATE ksiazka
            SET cena = v_nowa_cena
            WHERE CURRENT OF c_ksiazki;

            DBMS_OUTPUT.PUT_LINE('Zmieniono: ' || r.tytul || ' -> ' || v_nowa_cena);
        END LOOP;

    COMMIT;
END;
/
