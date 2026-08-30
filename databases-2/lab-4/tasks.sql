SET SERVEROUTPUT ON;

-- 1. Funkcja --- suma cen książek danego gatunku
CREATE OR REPLACE FUNCTION fn_suma_cen_gatunku(
    p_id_gat IN NUMBER
) RETURN NUMBER IS
    v_suma NUMBER;
BEGIN
    SELECT NVL(SUM(cena), 0)
    INTO v_suma
    FROM ksiazka
    WHERE id_gat = p_id_gat;

    RETURN v_suma;
END;
/

-- 2. Funkcja --- cena netto książki przy podatku 8%
CREATE OR REPLACE FUNCTION fn_cena_netto(
    p_id_ks IN NUMBER
) RETURN NUMBER IS
    v_cena_brutto ksiazka.cena%TYPE;
BEGIN
    SELECT cena
    INTO v_cena_brutto
    FROM ksiazka
    WHERE id_ks = p_id_ks;

    RETURN ROUND(v_cena_brutto / 1.08, 2);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono książki o podanym ID.');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Podane ID wskazuje na więcej niż jedną książkę.');
END;
/

-- 3. Procedura --- zmiana ceny książki zależnie od ceny bieżącej
CREATE OR REPLACE PROCEDURE pr_zmien_cene(
    p_id_ks IN NUMBER
)
    IS
BEGIN
    UPDATE ksiazka
    SET cena = ROUND(
            CASE
                WHEN cena >= 25 THEN cena * 1.10
                ELSE cena * 1.15
                END,
            2
               )
    WHERE id_ks = p_id_ks;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono książki o podanym ID.');
    END IF;
END;
/


-- 4. Procedura --- wydawnictwo, które wydało najstarszą książkę
CREATE OR REPLACE PROCEDURE pr_najstarsza_ksiazka
    IS
    v_min_data   ksiazka.data_wyd%TYPE;
    v_liczba_wyd NUMBER;
    v_w_nazwa    wydawnictwo.w_nazwa%TYPE;
    v_tytul      ksiazka.tytul%TYPE;
    v_nazwisko   autor.nazwisko%TYPE;
BEGIN
    SELECT MIN(data_wyd)
    INTO v_min_data
    FROM ksiazka;

    SELECT COUNT(DISTINCT id_wyd)
    INTO v_liczba_wyd
    FROM ksiazka
    WHERE data_wyd = v_min_data;

    IF v_liczba_wyd > 1 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Najstarszą książkę wydało więcej niż jedno wydawnictwo.');
    END IF;

    SELECT w.w_nazwa, k.tytul, a.nazwisko
    INTO v_w_nazwa, v_tytul, v_nazwisko
    FROM ksiazka k
             JOIN wydawnictwo w ON w.id_wyd = k.id_wyd
             JOIN autor a ON a.id_aut = k.id_aut
    WHERE k.data_wyd = v_min_data FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('Wydawnictwo: ' || v_w_nazwa);
    DBMS_OUTPUT.PUT_LINE('Tytuł: ' || v_tytul);
    DBMS_OUTPUT.PUT_LINE('Autor: ' || v_nazwisko);

EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak książek w bazie.');
END;
/


-- 5. Pakiet --- funkcja + procedura
CREATE OR REPLACE PACKAGE pkg_biblioteka AS
    FUNCTION fn_liczba_formatow_autora(
        p_nazwisko IN VARCHAR2,
        p_imie IN VARCHAR2
    ) RETURN NUMBER;

    PROCEDURE pr_ksiazki_i_czytelnicy_najmniej_wydawnictwa;
END pkg_biblioteka;
/

CREATE OR REPLACE PACKAGE BODY pkg_biblioteka AS

    FUNCTION fn_liczba_formatow_autora(
        p_nazwisko IN VARCHAR2,
        p_imie IN VARCHAR2
    ) RETURN NUMBER IS
        v_liczba NUMBER;
    BEGIN
        SELECT COUNT(DISTINCT k.id_for)
        INTO v_liczba
        FROM ksiazka k
                 JOIN autor a ON a.id_aut = k.id_aut
        WHERE UPPER(a.nazwisko) = UPPER(p_nazwisko)
          AND UPPER(a.imie) = UPPER(p_imie);

        RETURN v_liczba;
    END fn_liczba_formatow_autora;


    PROCEDURE pr_ksiazki_i_czytelnicy_najmniej_wydawnictwa
        IS
        v_id_wyd wydaWnictwo.id_wyd%TYPE;
    BEGIN
        SELECT id_wyd
        INTO v_id_wyd
        FROM (SELECT id_wyd
              FROM ksiazka
              GROUP BY id_wyd
              ORDER BY COUNT(*) ASC, id_wyd)
        WHERE ROWNUM = 1;

        FOR r IN (
            SELECT DISTINCT k.tytul, c.nazwisko
            FROM ksiazka k
                     JOIN wypozyczenia w ON w.id_ks = k.id_ks
                     JOIN czytelnik c ON c.id_czyt = w.id_czyt
            WHERE k.id_wyd = v_id_wyd
            ORDER BY k.tytul, c.nazwisko
            )
            LOOP
                DBMS_OUTPUT.PUT_LINE(r.tytul || ' | ' || r.nazwisko);
            END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Brak książek w bazie.');
    END pr_ksiazki_i_czytelnicy_najmniej_wydawnictwa;

END pkg_biblioteka;
/
