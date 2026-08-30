SET SERVEROUTPUT ON;


-- TASKS 1
SELECT CONCAT(C.IMIE, CONCAT(' ', C.NAZWISKO)) AS "Dane czytelnika",
       COUNT(DISTINCT ID_GAT)                  AS "Liczba Wypożyczonych Gatunków"
FROM CZYTELNIK C
         JOIN WYPOZYCZENIA W ON W.ID_CZYT = C.ID_CZYT
         JOIN KSIAZKA K ON K.ID_KS = W.ID_KS
GROUP BY C.IMIE, C.NAZWISKO
ORDER BY "Liczba Wypożyczonych Gatunków" DESC;

SELECT COUNT(*)
FROM KSIAZKA
WHERE ID_WYD IN (SELECT ID_WYD FROM KSIAZKA WHERE DATA_WYD IN (SELECT MIN(DATA_WYD) FROM KSIAZKA));

SELECT COUNT(WY.ID_KS) ILE, F_NAZWA
FROM KSIAZKA K
         JOIN FORMAT F ON F.ID_FOR = K.ID_FOR
         JOIN WYPOZYCZENIA WY ON WY.ID_KS = K.ID_KS
WHERE DATA_WYP > ADD_MONTHS(SYSDATE, -3)
GROUP BY F_NAZWA
ORDER BY ILE DESC FETCH FIRST ROW ONLY;

SELECT COUNT(WY.ID_KS) ILE, F_NAZWA
FROM KSIAZKA K
         JOIN FORMAT F ON F.ID_FOR = K.ID_FOR
         JOIN WYPOZYCZENIA WY ON WY.ID_KS = K.ID_KS
WHERE DATA_WYP > ADD_MONTHS(SYSDATE, -3)
GROUP BY F_NAZWA
HAVING COUNT(WY.ID_KS) IN (SELECT MAX(COUNT(WY.ID_KS))
                           FROM KSIAZKA K
                                    JOIN FORMAT F ON F.ID_FOR = K.ID_FOR
                                    JOIN WYPOZYCZENIA WY ON WY.ID_KS = K.ID_KS
                           WHERE DATA_WYP > ADD_MONTHS(SYSDATE, -3)
                           GROUP BY F_NAZWA);

SELECT G.G_NAZWA AS RODZAJ, COUNT(K.ID_KS) AS LICZBA_KSIAZEK, SUM(K.CENA) AS SUMA_CEN
FROM GATUNEK G
         LEFT JOIN KSIAZKA K ON K.ID_GAT = G.ID_GAT
GROUP BY G.G_NAZWA
ORDER BY G.G_NAZWA;

SELECT G.G_NAZWA, COUNT(W.ID_WYP) AS ILOSC_WYPOZYCZEN
FROM GATUNEK G
         LEFT JOIN KSIAZKA K ON K.ID_GAT = G.ID_GAT
         LEFT JOIN WYPOZYCZENIA W ON W.ID_KS = K.ID_KS
GROUP BY G.G_NAZWA
HAVING COUNT(W.ID_WYP) > (SELECT AVG(CNT)
                          FROM (SELECT COUNT(W2.ID_WYP) AS CNT
                                FROM GATUNEK G2
                                         LEFT JOIN KSIAZKA K2 ON K2.ID_GAT = G2.ID_GAT
                                         LEFT JOIN WYPOZYCZENIA W2 ON W2.ID_KS = K2.ID_KS
                                GROUP BY G2.ID_GAT));

SELECT DISTINCT A.*
FROM AUTOR A
         JOIN KSIAZKA K ON K.ID_AUT = A.ID_AUT
WHERE K.ID_GAT IN (SELECT ID_GAT
                   FROM KSIAZKA
                   WHERE L_STRON = (SELECT MIN(L_STRON) FROM KSIAZKA));

CREATE OR REPLACE FUNCTION FACTORIAL(N IN PLS_INTEGER) RETURN NUMBER IS
    RESULT NUMBER := 1;
BEGIN
    IF N < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Silnia nie jest zdefiniowana dla n < 0');
    END IF;
    FOR I IN 2 .. GREATEST(N, 1)
        LOOP
            RESULT := RESULT * I;
        END LOOP;
    RETURN RESULT;
END;
/
SELECT FACTORIAL(5)
FROM DUAL;

DECLARE
    TYPE STUDENT_REC IS RECORD
                        (
                            ID       NUMBER,
                            NAZWISKO VARCHAR2(50),
                            MIASTO   VARCHAR2(50),
                            TELEFON  VARCHAR2(20)
                        );
    STUDENT STUDENT_REC;
BEGIN
    STUDENT.ID := 1;
    STUDENT.NAZWISKO := 'Kowalski';
    STUDENT.MIASTO := 'Kraków';
    STUDENT.TELEFON := '123456789';
    DBMS_OUTPUT.PUT_LINE('ID:' || STUDENT.ID || ', Nazwisko:' || STUDENT.NAZWISKO || ', Miasto:' || STUDENT.MIASTO ||
                         ', Telefon:' || STUDENT.TELEFON);
END;
/

CREATE OR REPLACE FUNCTION GCD(A IN PLS_INTEGER, B IN PLS_INTEGER) RETURN PLS_INTEGER IS
    AA  PLS_INTEGER := ABS(A);
    BB  PLS_INTEGER := ABS(B);
    TMP PLS_INTEGER;
BEGIN
    IF AA = 0 THEN
        RETURN BB;
    ELSIF BB = 0 THEN
        RETURN AA;
    END IF;
    WHILE BB != 0
        LOOP
            TMP := MOD(AA, BB);
            AA := BB;
            BB := TMP;
        END LOOP;
    RETURN AA;
END;
/

SELECT GCD(54, 24)
FROM DUAL;

DECLARE
    N   PLS_INTEGER := 10;
    A   NUMBER      := 0;
    B   NUMBER      := 1;
    TMP NUMBER;
BEGIN
    IF N <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak elementów (n <= 0).');
        RETURN;
    END IF;
    IF N >= 1 THEN DBMS_OUTPUT.PUT(A); END IF;
    FOR I IN 2 .. N
        LOOP
            DBMS_OUTPUT.PUT(', ' || B);
            TMP := A + B;
            A := B;
            B := TMP;
        END LOOP;
    DBMS_OUTPUT.NEW_LINE;
END;
/

-- TASKS 2
DECLARE
    TYPE T_AUTHOR_REC IS RECORD
                         (
                             ID_AUT   AUTOR.ID_AUT%TYPE,
                             NAZWISKO AUTOR.NAZWISKO%TYPE,
                             IMIE     AUTOR.IMIE%TYPE,
                             KRAJ     AUTOR.KRAJ%TYPE
                         );
    R T_AUTHOR_REC;
    CURSOR C_AUTH IS
        SELECT ID_AUT,
               NAZWISKO,
               IMIE,
               KRAJ
        FROM AUTOR;

BEGIN
    OPEN C_AUTH;
    LOOP
        FETCH C_AUTH INTO
            R.ID_AUT,
            R.NAZWISKO,
            R.IMIE,
            R.KRAJ;

        EXIT WHEN C_AUTH%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID:' || R.ID_AUT || ' | ' || R.IMIE || ' ' || R.NAZWISKO || ' | ' || R.KRAJ);
    END LOOP;

    CLOSE C_AUTH;
END;
/

DECLARE
    R_AUTOR AUTOR%ROWTYPE;
    CURSOR C_AUTH IS
        SELECT *
        FROM AUTOR;

BEGIN
    OPEN C_AUTH;
    LOOP
        FETCH C_AUTH INTO R_AUTOR;
        EXIT WHEN C_AUTH%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(R_AUTOR.ID_AUT || ' ' || R_AUTOR.IMIE || ' ' || R_AUTOR.NAZWISKO || ' ' || R_AUTOR.KRAJ);

    END LOOP;

    CLOSE C_AUTH;
END;
/

BEGIN
    FOR R IN (
        SELECT *
        FROM AUTOR
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(R.ID_AUT || ' | ' || R.IMIE || ' ' || R.NAZWISKO || ' | ' || R.KRAJ);
        END LOOP;
END;
/

BEGIN
    FOR R IN (
        SELECT IMIE,
               NAZWISKO,
               MIASTO
        FROM CZYTELNIK
        ORDER BY NAZWISKO DESC
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(R.IMIE || ' *******' || UPPER(R.NAZWISKO) || ' ********' || INITCAP(R.MIASTO));
        END LOOP;
END;
/

BEGIN
    FOR R IN (
        SELECT C.IMIE,
               C.NAZWISKO,
               TO_CHAR(W.DATA_WYP, 'DD')                                               AS DZIEN,
               UPPER(RTRIM(TO_CHAR(W.DATA_WYP, 'MONTH', 'NLS_DATE_LANGUAGE=ENGLISH'))) AS MIESIAC,
               K.TYTUL,
               LOWER(F.F_NAZWA)                                                        AS FORMAT_KSIAZKI
        FROM WYPOZYCZENIA W
                 JOIN CZYTELNIK C ON W.ID_CZYT = C.ID_CZYT
                 JOIN KSIAZKA K ON W.ID_KS = K.ID_KS
                 JOIN FORMAT F ON K.ID_FOR = F.ID_FOR
        ORDER BY C.NAZWISKO,
                 C.IMIE,
                 W.DATA_WYP
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(R.IMIE || ' ' || R.NAZWISKO || ' ' || R.DZIEN || ' ' || R.MIESIAC || ' ' || R.TYTUL ||
                                 ' ' || R.FORMAT_KSIAZKI);
        END LOOP;
END;
/

DECLARE
    P_MIN_PRICE NUMBER := 30;
    CURSOR C_BOOKS (
        P_PRICE NUMBER
        ) IS
        SELECT K.TYTUL,
               A.NAZWISKO AS AUTOR,
               W.W_NAZWA  AS WYDAWNICTWO,
               WY.DATA_ZWR,
               K.CENA
        FROM WYPOZYCZENIA WY
                 JOIN KSIAZKA K ON WY.ID_KS = K.ID_KS
                 JOIN AUTOR A ON K.ID_AUT = A.ID_AUT
                 JOIN WYDAWNICTWO W ON K.ID_WYD = W.ID_WYD
        WHERE K.CENA >= P_PRICE
          AND WY.DATA_ZWR >= TRUNC(SYSDATE)
        ORDER BY K.CENA DESC; -- Najdroższe jako pierwsze

    REC         C_BOOKS%ROWTYPE;
BEGIN
    OPEN C_BOOKS(P_MIN_PRICE);
    LOOP
        FETCH C_BOOKS INTO REC;
        EXIT WHEN C_BOOKS%NOTFOUND OR C_BOOKS%ROWCOUNT > 3;
        DBMS_OUTPUT.PUT_LINE('Tytul: ' || REC.TYTUL || ' | Autor: ' || REC.AUTOR || ' | Wyd: ' || REC.WYDAWNICTWO ||
                             ' | Data zwr: ' || TO_CHAR(REC.DATA_ZWR, 'YYYY-MM-DD') || ' | Cena: ' || REC.CENA);

    END LOOP;

    CLOSE C_BOOKS;
END;
/

DECLARE
    CURSOR C_FORMAT IS
        SELECT F.F_NAZWA,
               COUNT(K.ID_KS) AS LICZBA
        FROM FORMAT F
                 LEFT JOIN KSIAZKA K ON F.ID_FOR = K.ID_FOR
        GROUP BY F.F_NAZWA
        ORDER BY F.F_NAZWA;
    V_NAME  VARCHAR2(100);
    V_COUNT NUMBER;
BEGIN
    OPEN C_FORMAT;
    LOOP
        FETCH C_FORMAT INTO
            V_NAME,
            V_COUNT;
        EXIT WHEN C_FORMAT%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Format: ' || V_NAME || ' | Liczba ksiazek: ' || NVL(V_COUNT, 0));

    END LOOP;

    CLOSE C_FORMAT;
END;
/

DECLARE
    P_FORMAT VARCHAR2(30) := 'EBOOK';
    CURSOR C_FMT (
        P_NAME VARCHAR2
        ) IS
        SELECT COUNT(K.ID_KS) AS LICZBA
        FROM FORMAT F
                 LEFT JOIN KSIAZKA K ON F.ID_FOR = K.ID_FOR
        WHERE F.F_NAZWA = P_NAME;
    V_COUNT  NUMBER;
BEGIN
    OPEN C_FMT(P_FORMAT);
    FETCH C_FMT INTO V_COUNT;
    IF C_FMT%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak formatu o nazwie ' || P_FORMAT);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Format: ' || P_FORMAT || ' | Liczba ksiazek: ' || NVL(V_COUNT, 0));
    END IF;

    CLOSE C_FMT;
END;
/

DECLARE
    CURSOR C_UPD IS
        SELECT K.ID_KS,
               K.CENA,
               W.W_NAZWA
        FROM KSIAZKA K
                 JOIN WYDAWNICTWO W ON K.ID_WYD = W.ID_WYD
            FOR UPDATE OF K.CENA;
    REC         C_UPD%ROWTYPE;
    V_NEW_PRICE NUMBER;
BEGIN
    OPEN C_UPD;
    LOOP
        FETCH C_UPD INTO REC;
        EXIT WHEN C_UPD%NOTFOUND;
        IF REC.W_NAZWA = 'Litera' THEN
            V_NEW_PRICE := ROUND(REC.CENA * 1.10, 2);
        ELSE
            V_NEW_PRICE := ROUND(REC.CENA * 1.05, 2);
        END IF;

        UPDATE KSIAZKA
        SET CENA = V_NEW_PRICE
        WHERE
            CURRENT OF C_UPD;

        DBMS_OUTPUT.PUT_LINE('ID_KS=' || REC.ID_KS || ' | Stara=' || REC.CENA || ' -> Nowa=' || V_NEW_PRICE ||
                             ' (wyd: ' || REC.W_NAZWA || ')');

    END LOOP;

    CLOSE C_UPD;
    COMMIT;
END;
/

DECLARE
    CURSOR C_IDS IS
        SELECT K.ID_KS,
               K.CENA,
               W.W_NAZWA
        FROM KSIAZKA K
                 JOIN WYDAWNICTWO W ON K.ID_WYD = W.ID_WYD;
    REC         C_IDS%ROWTYPE;
    V_NEW_PRICE NUMBER;
BEGIN
    OPEN C_IDS;
    LOOP
        FETCH C_IDS INTO REC;
        EXIT WHEN C_IDS%NOTFOUND;
        IF REC.W_NAZWA = 'Litera' THEN
            UPDATE KSIAZKA
            SET CENA = ROUND(CENA * 1.10, 2)
            WHERE ID_KS = REC.ID_KS
            RETURNING CENA INTO V_NEW_PRICE;

        ELSE
            UPDATE KSIAZKA
            SET CENA = ROUND(CENA * 1.05, 2)
            WHERE ID_KS = REC.ID_KS
            RETURNING CENA INTO V_NEW_PRICE;

        END IF;

        DBMS_OUTPUT.PUT_LINE('ID_KS=' || REC.ID_KS || ' | Stara=' || REC.CENA || ' -> Nowa=' || V_NEW_PRICE ||
                             ' (wyd: ' || REC.W_NAZWA || ')');

    END LOOP;

    CLOSE C_IDS;
    COMMIT;
END;
/


-- TASKS 3
-- 1. Czytelnik z najmniejszą liczbą wypożyczeń
DECLARE
    V_MIN_LICZBA NUMBER;
    V_ILE        NUMBER;
    V_NAZWISKO   CZYTELNIK.NAZWISKO%TYPE;
    V_IMIE       CZYTELNIK.IMIE%TYPE;

    E_WIELU_CZYTELNIKOW EXCEPTION;
BEGIN
    -- Minimalna liczba wypożyczeń, licząc także czytelników bez wypożyczeń
    SELECT MIN(ILE)
    INTO V_MIN_LICZBA
    FROM (SELECT C.ID_CZYT, COUNT(W.ID_WYP) AS ILE
          FROM CZYTELNIK C
                   LEFT JOIN WYPOZYCZENIA W ON C.ID_CZYT = W.ID_CZYT
          GROUP BY C.ID_CZYT);

    -- Sprawdzenie, czy jest więcej niż jeden czytelnik z takim minimum
    SELECT COUNT(*)
    INTO V_ILE
    FROM (SELECT C.ID_CZYT
          FROM CZYTELNIK C
                   LEFT JOIN WYPOZYCZENIA W ON C.ID_CZYT = W.ID_CZYT
          GROUP BY C.ID_CZYT
          HAVING COUNT(W.ID_WYP) = V_MIN_LICZBA);

    IF V_ILE > 1 THEN
        RAISE E_WIELU_CZYTELNIKOW;
    END IF;

    -- Pobranie danych jedynego czytelnika
    SELECT C.NAZWISKO, C.IMIE
    INTO V_NAZWISKO, V_IMIE
    FROM CZYTELNIK C
             LEFT JOIN WYPOZYCZENIA W ON C.ID_CZYT = W.ID_CZYT
    GROUP BY C.ID_CZYT, C.NAZWISKO, C.IMIE
    HAVING COUNT(W.ID_WYP) = V_MIN_LICZBA;

    DBMS_OUTPUT.PUT_LINE('Czytelnik z najmniejszą liczbą wypożyczeń: ' || V_NAZWISKO || ' ' || V_IMIE);

EXCEPTION
    WHEN E_WIELU_CZYTELNIKOW THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: więcej niż jeden czytelnik ma najmniejszą liczbę wypożyczeń.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 2. Gatunek najdroższej książki
DECLARE
    V_MAX_CENA KSIAZKA.CENA%TYPE;
    V_ILE      NUMBER;
    V_GATUNEK  GATUNEK.G_NAZWA%TYPE;
    V_TYTUL    KSIAZKA.TYTUL%TYPE;

    E_WIELE_KSIAZEK EXCEPTION;
BEGIN
    SELECT MAX(CENA)
    INTO V_MAX_CENA
    FROM KSIAZKA;

    SELECT COUNT(*)
    INTO V_ILE
    FROM KSIAZKA
    WHERE CENA = V_MAX_CENA;

    IF V_ILE > 1 THEN
        RAISE E_WIELE_KSIAZEK;
    END IF;

    SELECT G.G_NAZWA, K.TYTUL
    INTO V_GATUNEK, V_TYTUL
    FROM KSIAZKA K
             JOIN GATUNEK G ON K.ID_GAT = G.ID_GAT
    WHERE K.CENA = V_MAX_CENA;

    DBMS_OUTPUT.PUT_LINE('Najdroższa książka:');
    DBMS_OUTPUT.PUT_LINE('Gatunek: ' || V_GATUNEK);
    DBMS_OUTPUT.PUT_LINE('Tytuł: ' || V_TYTUL);
    DBMS_OUTPUT.PUT_LINE('Cena: ' || V_MAX_CENA);

EXCEPTION
    WHEN E_WIELE_KSIAZEK THEN
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
    CURSOR C_KSIAZKI IS
        SELECT ID_KS, TYTUL, CENA
        FROM KSIAZKA
        ORDER BY CENA ASC FOR UPDATE OF CENA;
    V_NOWA_CENA NUMBER;
BEGIN
    FOR R IN C_KSIAZKI
        LOOP
            V_NOWA_CENA := ROUND(R.CENA * 1.05, 2);

            IF V_NOWA_CENA > 300 THEN
                DBMS_OUTPUT.PUT_LINE('Przerwano na książce: ' || R.TYTUL || ', cena po podwyżce = ' || V_NOWA_CENA);
                EXIT;
            END IF;

            UPDATE KSIAZKA
            SET CENA = V_NOWA_CENA
            WHERE CURRENT OF C_KSIAZKI;

            DBMS_OUTPUT.PUT_LINE('Zmieniono: ' || R.TYTUL || ' -> ' || V_NOWA_CENA);
        END LOOP;

    COMMIT;
END;
/


-- TASKS 4
-- 1. Funkcja --- suma cen książek danego gatunku
CREATE OR REPLACE FUNCTION FN_SUMA_CEN_GATUNKU(
    P_ID_GAT IN NUMBER
) RETURN NUMBER IS
    V_SUMA NUMBER;
BEGIN
    SELECT NVL(SUM(CENA), 0)
    INTO V_SUMA
    FROM KSIAZKA
    WHERE ID_GAT = P_ID_GAT;

    RETURN V_SUMA;
END;
/

-- 2. Funkcja --- cena netto książki przy podatku 8%
CREATE OR REPLACE FUNCTION FN_CENA_NETTO(
    P_ID_KS IN NUMBER
) RETURN NUMBER IS
    V_CENA_BRUTTO KSIAZKA.CENA%TYPE;
BEGIN
    SELECT CENA
    INTO V_CENA_BRUTTO
    FROM KSIAZKA
    WHERE ID_KS = P_ID_KS;

    RETURN ROUND(V_CENA_BRUTTO / 1.08, 2);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono książki o podanym ID.');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Podane ID wskazuje na więcej niż jedną książkę.');
END;
/

-- 3. Procedura --- zmiana ceny książki zależnie od ceny bieżącej
CREATE OR REPLACE PROCEDURE PR_ZMIEN_CENE(
    P_ID_KS IN NUMBER
)
    IS
BEGIN
    UPDATE KSIAZKA
    SET CENA = ROUND(
            CASE
                WHEN CENA >= 25 THEN CENA * 1.10
                ELSE CENA * 1.15
                END,
            2
               )
    WHERE ID_KS = P_ID_KS;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono książki o podanym ID.');
    END IF;
END;
/


-- 4. Procedura --- wydawnictwo, które wydało najstarszą książkę
CREATE OR REPLACE PROCEDURE PR_NAJSTARSZA_KSIAZKA
    IS
    V_MIN_DATA   KSIAZKA.DATA_WYD%TYPE;
    V_LICZBA_WYD NUMBER;
    V_W_NAZWA    WYDAWNICTWO.W_NAZWA%TYPE;
    V_TYTUL      KSIAZKA.TYTUL%TYPE;
    V_NAZWISKO   AUTOR.NAZWISKO%TYPE;
BEGIN
    SELECT MIN(DATA_WYD)
    INTO V_MIN_DATA
    FROM KSIAZKA;

    SELECT COUNT(DISTINCT ID_WYD)
    INTO V_LICZBA_WYD
    FROM KSIAZKA
    WHERE DATA_WYD = V_MIN_DATA;

    IF V_LICZBA_WYD > 1 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Najstarszą książkę wydało więcej niż jedno wydawnictwo.');
    END IF;

    SELECT W.W_NAZWA, K.TYTUL, A.NAZWISKO
    INTO V_W_NAZWA, V_TYTUL, V_NAZWISKO
    FROM KSIAZKA K
             JOIN WYDAWNICTWO W ON W.ID_WYD = K.ID_WYD
             JOIN AUTOR A ON A.ID_AUT = K.ID_AUT
    WHERE K.DATA_WYD = V_MIN_DATA FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('Wydawnictwo: ' || V_W_NAZWA);
    DBMS_OUTPUT.PUT_LINE('Tytuł: ' || V_TYTUL);
    DBMS_OUTPUT.PUT_LINE('Autor: ' || V_NAZWISKO);

EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak książek w bazie.');
END;
/


-- 5. Pakiet --- funkcja + procedura
CREATE OR REPLACE PACKAGE PKG_BIBLIOTEKA AS
    FUNCTION FN_LICZBA_FORMATOW_AUTORA(
        P_NAZWISKO IN VARCHAR2,
        P_IMIE IN VARCHAR2
    ) RETURN NUMBER;

    PROCEDURE PR_KSIAZKI_I_CZYTELNICY_NAJMNIEJ_WYDAWNICTWA;
END PKG_BIBLIOTEKA;
/

CREATE OR REPLACE PACKAGE BODY PKG_BIBLIOTEKA AS

    FUNCTION FN_LICZBA_FORMATOW_AUTORA(
        P_NAZWISKO IN VARCHAR2,
        P_IMIE IN VARCHAR2
    ) RETURN NUMBER IS
        V_LICZBA NUMBER;
    BEGIN
        SELECT COUNT(DISTINCT K.ID_FOR)
        INTO V_LICZBA
        FROM KSIAZKA K
                 JOIN AUTOR A ON A.ID_AUT = K.ID_AUT
        WHERE UPPER(A.NAZWISKO) = UPPER(P_NAZWISKO)
          AND UPPER(A.IMIE) = UPPER(P_IMIE);

        RETURN V_LICZBA;
    END FN_LICZBA_FORMATOW_AUTORA;


    PROCEDURE PR_KSIAZKI_I_CZYTELNICY_NAJMNIEJ_WYDAWNICTWA
        IS
        V_ID_WYD WYDAWNICTWO.ID_WYD%TYPE;
    BEGIN
        SELECT ID_WYD
        INTO V_ID_WYD
        FROM (SELECT ID_WYD
              FROM KSIAZKA
              GROUP BY ID_WYD
              ORDER BY COUNT(*) ASC, ID_WYD)
        WHERE ROWNUM = 1;

        FOR R IN (
            SELECT DISTINCT K.TYTUL, C.NAZWISKO
            FROM KSIAZKA K
                     JOIN WYPOZYCZENIA W ON W.ID_KS = K.ID_KS
                     JOIN CZYTELNIK C ON C.ID_CZYT = W.ID_CZYT
            WHERE K.ID_WYD = V_ID_WYD
            ORDER BY K.TYTUL, C.NAZWISKO
            )
            LOOP
                DBMS_OUTPUT.PUT_LINE(R.TYTUL || ' | ' || R.NAZWISKO);
            END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak książek w bazie.');
    END PR_KSIAZKI_I_CZYTELNICY_NAJMNIEJ_WYDAWNICTWA;

END PKG_BIBLIOTEKA;
/
SET SERVEROUTPUT ON;

-- 1. Funkcja --- suma cen książek danego gatunku
CREATE OR REPLACE FUNCTION FN_SUMA_CEN_GATUNKU(
    P_ID_GAT IN NUMBER
) RETURN NUMBER IS
    V_SUMA NUMBER;
BEGIN
    SELECT NVL(SUM(CENA), 0)
    INTO V_SUMA
    FROM KSIAZKA
    WHERE ID_GAT = P_ID_GAT;

    RETURN V_SUMA;
END;
/

-- 2. Funkcja --- cena netto książki przy podatku 8%
CREATE OR REPLACE FUNCTION FN_CENA_NETTO(
    P_ID_KS IN NUMBER
) RETURN NUMBER IS
    V_CENA_BRUTTO KSIAZKA.CENA%TYPE;
BEGIN
    SELECT CENA
    INTO V_CENA_BRUTTO
    FROM KSIAZKA
    WHERE ID_KS = P_ID_KS;

    RETURN ROUND(V_CENA_BRUTTO / 1.08, 2);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono książki o podanym ID.');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Podane ID wskazuje na więcej niż jedną książkę.');
END;
/

-- 3. Procedura --- zmiana ceny książki zależnie od ceny bieżącej
CREATE OR REPLACE PROCEDURE PR_ZMIEN_CENE(
    P_ID_KS IN NUMBER
)
    IS
BEGIN
    UPDATE KSIAZKA
    SET CENA = ROUND(
            CASE
                WHEN CENA >= 25 THEN CENA * 1.10
                ELSE CENA * 1.15
                END,
            2
               )
    WHERE ID_KS = P_ID_KS;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono książki o podanym ID.');
    END IF;
END;
/


-- 4. Procedura --- wydawnictwo, które wydało najstarszą książkę
CREATE OR REPLACE PROCEDURE PR_NAJSTARSZA_KSIAZKA
    IS
    V_MIN_DATA   KSIAZKA.DATA_WYD%TYPE;
    V_LICZBA_WYD NUMBER;
    V_W_NAZWA    WYDAWNICTWO.W_NAZWA%TYPE;
    V_TYTUL      KSIAZKA.TYTUL%TYPE;
    V_NAZWISKO   AUTOR.NAZWISKO%TYPE;
BEGIN
    SELECT MIN(DATA_WYD)
    INTO V_MIN_DATA
    FROM KSIAZKA;

    SELECT COUNT(DISTINCT ID_WYD)
    INTO V_LICZBA_WYD
    FROM KSIAZKA
    WHERE DATA_WYD = V_MIN_DATA;

    IF V_LICZBA_WYD > 1 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Najstarszą książkę wydało więcej niż jedno wydawnictwo.');
    END IF;

    SELECT W.W_NAZWA, K.TYTUL, A.NAZWISKO
    INTO V_W_NAZWA, V_TYTUL, V_NAZWISKO
    FROM KSIAZKA K
             JOIN WYDAWNICTWO W ON W.ID_WYD = K.ID_WYD
             JOIN AUTOR A ON A.ID_AUT = K.ID_AUT
    WHERE K.DATA_WYD = V_MIN_DATA FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('Wydawnictwo: ' || V_W_NAZWA);
    DBMS_OUTPUT.PUT_LINE('Tytuł: ' || V_TYTUL);
    DBMS_OUTPUT.PUT_LINE('Autor: ' || V_NAZWISKO);

EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak książek w bazie.');
END;
/


-- 5. Pakiet --- funkcja + procedura
CREATE OR REPLACE PACKAGE PKG_BIBLIOTEKA AS
    FUNCTION FN_LICZBA_FORMATOW_AUTORA(
        P_NAZWISKO IN VARCHAR2,
        P_IMIE IN VARCHAR2
    ) RETURN NUMBER;

    PROCEDURE PR_KSIAZKI_I_CZYTELNICY_NAJMNIEJ_WYDAWNICTWA;
END PKG_BIBLIOTEKA;
/

CREATE OR REPLACE PACKAGE BODY PKG_BIBLIOTEKA AS

    FUNCTION FN_LICZBA_FORMATOW_AUTORA(
        P_NAZWISKO IN VARCHAR2,
        P_IMIE IN VARCHAR2
    ) RETURN NUMBER IS
        V_LICZBA NUMBER;
    BEGIN
        SELECT COUNT(DISTINCT K.ID_FOR)
        INTO V_LICZBA
        FROM KSIAZKA K
                 JOIN AUTOR A ON A.ID_AUT = K.ID_AUT
        WHERE UPPER(A.NAZWISKO) = UPPER(P_NAZWISKO)
          AND UPPER(A.IMIE) = UPPER(P_IMIE);

        RETURN V_LICZBA;
    END FN_LICZBA_FORMATOW_AUTORA;


    PROCEDURE PR_KSIAZKI_I_CZYTELNICY_NAJMNIEJ_WYDAWNICTWA
        IS
        V_ID_WYD WYDAWNICTWO.ID_WYD%TYPE;
    BEGIN
        SELECT ID_WYD
        INTO V_ID_WYD
        FROM (SELECT ID_WYD
              FROM KSIAZKA
              GROUP BY ID_WYD
              ORDER BY COUNT(*) ASC, ID_WYD)
        WHERE ROWNUM = 1;

        FOR R IN (
            SELECT DISTINCT K.TYTUL, C.NAZWISKO
            FROM KSIAZKA K
                     JOIN WYPOZYCZENIA W ON W.ID_KS = K.ID_KS
                     JOIN CZYTELNIK C ON C.ID_CZYT = W.ID_CZYT
            WHERE K.ID_WYD = V_ID_WYD
            ORDER BY K.TYTUL, C.NAZWISKO
            )
            LOOP
                DBMS_OUTPUT.PUT_LINE(R.TYTUL || ' | ' || R.NAZWISKO);
            END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak książek w bazie.');
    END PR_KSIAZKI_I_CZYTELNICY_NAJMNIEJ_WYDAWNICTWA;

END PKG_BIBLIOTEKA;
/
