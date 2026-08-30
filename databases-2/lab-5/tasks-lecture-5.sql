SET SERVEROUTPUT ON;

-- 1. Zdefiniuj kursor zawierający imiona i nazwiska czytelników, którzy w 2024 roku pożyczali książki. Wykorzystaj polecenie FETCH.
DECLARE
    CURSOR CUR IS SELECT IMIE, NAZWISKO, DATA_WYP
                  FROM WYPOZYCZENIA W
                           JOIN CZYTELNIK C ON C.ID_CZYT = W.ID_CZYT
                  WHERE DATA_WYP >= TO_DATE('2024-01-01', 'YYYY-MM-DD')
                    AND DATA_ZWR <= TO_DATE('2024-12-31', 'YYYY-MM-DD');
    V_IMIE     CZYTELNIK.IMIE%TYPE;
    V_NAZWISKO CZYTELNIK.NAZWISKO%TYPE;
    V_DATA_WYP WYPOZYCZENIA.DATA_WYP%TYPE;
BEGIN
    OPEN CUR;

    LOOP
        FETCH CUR INTO V_IMIE, V_NAZWISKO, V_DATA_WYP;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(V_IMIE || ' ' || V_NAZWISKO || ' ' || TO_CHAR(V_DATA_WYP, 'YYYY-MM-DD'));
    END LOOP;

    CLOSE CUR;
END;
/

-- 2. Napisz procedurę, w której zostanie wybrany tytuł najdroższej książki, który wraz z ceną wypisz na ekranie.
-- Wprowadź obsługę błędów, jeśli więcej niż jedna książka posiada najwyższą cenę.
CREATE OR REPLACE PROCEDURE WYBIERZ_NAJDROZSZE_KSIAZKE IS
    V_TYTUL_KS KSIAZKA.TYTUL%TYPE;
    V_CENA_KS  KSIAZKA.CENA%TYPE;
BEGIN
    SELECT MAX(CENA) INTO V_CENA_KS FROM KSIAZKA;

    SELECT TYTUL INTO V_TYTUL_KS FROM KSIAZKA WHERE CENA = V_CENA_KS;

    DBMS_OUTPUT.PUT_LINE('Najdrozsza ksiazka to ' || V_TYTUL_KS || ' o cenie ' || V_CENA_KS);
EXCEPTION
    WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Wystapilo wiele ksiazek o najwyzszej cenie');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak ksiazek');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- 3. Napisz procedurę zwiększającą ceny książek o 5%, zaczynając od książek najtańszych.
--    Zmiany należy przerwać, jeśli w jakimś momencie suma przekroczy 400 zł.
CREATE OR REPLACE PROCEDURE ZWIEKSZ_CENY_KSIAZEK IS
    V_SUMA NUMBER := 0;
BEGIN
    FOR REC IN (SELECT ID_KSIAZKI, CENA FROM KSIAZKA ORDER BY CENA)
        LOOP
            V_SUMA := V_SUMA + REC.CENA;

            EXIT WHEN V_SUMA > 400;

            UPDATE KSIAZKA SET CENA = CENA * 1.05 WHERE ID_KSIAZKI = REC.ID_KSIAZKI;
        END LOOP;
END;
/

-- 4. Napisz procedurę, która zmodyfikuje cenę danej książki w zależności od jej ceny bieżącej.
-- cena > 100       +10%
-- 50 < cena <= 100 +15%
-- cena <= 50       +20%
CREATE OR REPLACE PROCEDURE ZMIEN_CENY_KSIAZKI IS
BEGIN
    FOR REC IN (SELECT ID_KS, CENA FROM KSIAZKA)
        LOOP
            IF REC.CENA > 100 THEN
                UPDATE KSIAZKA SET CENA = REC.CENA * 1.1 WHERE ID_KS = REC.ID_KS;
            ELSIF REC.CENA <= 100 AND REC.CENA > 50 THEN
                UPDATE KSIAZKA SET CENA = REC.CENA * 1.15 WHERE ID_KS = REC.ID_KS;
            ELSE
                UPDATE KSIAZKA SET CENA = REC.CENA * 1.2 WHERE ID_KS = REC.ID_KS;
            END IF;
        END LOOP;
END;
/

-- 5. Napisz funkcję, która dla podanego parametru (nazwa wydawnictwa – parametr),
--    zwróci liczbę książek wydanych przez to wydawnictwo.
CREATE OR REPLACE FUNCTION LICZBA_KSIAZEK_WYDAWNICTWA(W_NAZWA_WYDAWNICTWA IN VARCHAR2) RETURN NUMBER IS
    V_LICZBA NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_LICZBA
    FROM KSIAZKA K
             JOIN WYDAWNICTWO W ON K.ID_WYD = W.ID_WYD
    WHERE W.W_NAZWA = W_NAZWA_WYDAWNICTWA;

    RETURN V_LICZBA;
END;
/

-- 6. Napisz funkcję sparametryzowaną (parametry: nazwisko i imię autora),
-- która dla podanego nazwiska i imienia autora, zwróci liczbę gatunków literackich napisanych przez niego książek.
CREATE OR REPLACE FUNCTION LICZBA_GATUNKOW(NAZWISKO_AUTORA VARCHAR2, IMIE_AUTORA VARCHAR2) RETURN NUMBER IS
    V_ID_AUT     NUMBER;
    V_LICZBA_GAT NUMBER;
BEGIN
    SELECT ID_AUT INTO V_ID_AUT FROM AUTOR WHERE NAZWISKO = NAZWISKO_AUTORA AND IMIE = IMIE_AUTORA;

    SELECT COUNT(DISTINCT ID_GAT)
    INTO V_LICZBA_GAT
    FROM KSIAZKA
    WHERE ID_AUT = V_ID_AUT;

    RETURN V_LICZBA_GAT;
END;
/

-- 7. Napisz funkcję, która dla wybranego gatunku (parametr id) obliczy sumaryczną cenę wszystkich książek tego gatunku.
CREATE OR REPLACE FUNCTION SUMARYCZNA_CENA_KSIAZEK_GATUNKU(I_ID_GAT IN NUMBER) RETURN NUMBER IS
    V_SUMA NUMBER := 0;
BEGIN
    FOR REC IN (SELECT CENA FROM KSIAZKA WHERE ID_GAT = I_ID_GAT)
        LOOP
            V_SUMA := V_SUMA + REC.CENA;
        END LOOP;

    RETURN V_SUMA;
END;
/

-- 8. Napisz funkcję sparametryzowaną (parametry: nazwisko i imię autora),
--    która dla podanego nazwiska autora zwróci liczbę formatów napisanych przez niego książek.
CREATE OR REPLACE FUNCTION LICZBA_FORMATOW_KSIAZEK_AUTORA(I_IMIE IN VARCHAR2, I_NAZWISKO IN VARCHAR2) RETURN NUMBER IS
    V_LICZBA NUMBER;
BEGIN
    SELECT COUNT(DISTINCT ID_FOR)
    INTO V_LICZBA
    FROM KSIAZKA
             NATURAL JOIN AUTOR
    WHERE IMIE = I_IMIE
      AND NAZWISKO = I_NAZWISKO;

    RETURN V_LICZBA;
END;
/

-- 9. Napisz procedurę, która obniży cenę wszystkich książek danego wydawnictwa (nazwa przekazana przez parametr)
-- o podany procent (wartość przekazana przez parametr, domyślna wartość: 5%).
-- Dodaj obsługę błędu w przypadku podania wydawnictwa spoza bazy
CREATE OR REPLACE PROCEDURE OBNIZUJ_CENY_KSIAZEK_WYDAWNICTWA(I_NAZWA_WYDAWNICTWA IN VARCHAR2,
                                                             I_PROCENT_OBNIESZENIA IN NUMBER DEFAULT 5) IS
    V_CENA_KSIAZKA NUMBER;
BEGIN
    FOR REC IN (SELECT CENA
                FROM KSIAZKA
                WHERE ID_WYD = (SELECT ID_WYD FROM WYDAWNICTWO WHERE W_NAZWA = I_NAZWA_WYDAWNICTWA))
        LOOP

        END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Wydawnictwo nie istnieje');
END;

-- 10. Napisz procedurę wypozycz_ksiazke, która zmienia status książki na 'WYPOŻYCZONA'.
-- Jeśli książka o danym ID już ma taki status, procedura powinna zgłosić błąd.
CREATE OR REPLACE PROCEDURE WYPOZYCZ_KSIAZKE(
    I_ID_KS IN NUMBER
) IS
    KS_JUZ_WYPOZYCZONA EXCEPTION;
    V_STATUS KSIAZKA.WYPOZYCZONA%TYPE;
BEGIN
    SELECT WYPOZYCZONA INTO V_STATUS FROM KSIAZKA WHERE ID_KS = I_ID_KS;

    IF V_STATUS = 'WYPOŻYCZONA' THEN
        RAISE KS_JUZ_WYPOZYCZONA;
    END IF;

    UPDATE KSIAZKA SET WYPOZYCZONA = 'WYPOŻYCZONA' WHERE ID_KS = I_ID_KS;

EXCEPTION
    WHEN KS_JUZ_WYPOZYCZONA THEN DBMS_OUTPUT.PUT_LINE('Ksiazka o tym ID juz jest wypozyczona');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono ksiazki');
END;
/

-- 11. Napisz pakiet zarzadzanie_biblioteka, który zawiera funkcję zliczającą książki oraz procedurę dodawania nowej pozycji.
CREATE OR REPLACE PACKAGE ZARZADZANIE_BIBLIOTEKA IS
    FUNCTION LICZBA_KSIAZEK RETURN NUMBER;
    PROCEDURE DODAJ_KSIAZKE(
        P_ID_KS IN NUMBER,
        P_TYTUL IN VARCHAR2,
        P_CENA IN NUMBER,
        P_ID_AUT IN NUMBER,
        P_ID_GAT IN NUMBER
    );
END ZARZADZANIE_BIBLIOTEKA;
/

CREATE OR REPLACE PACKAGE BODY ZARZADZANIE_BIBLIOTEKA IS

    FUNCTION LICZBA_KSIAZEK RETURN NUMBER IS
        V_LICZBA NUMBER;
    BEGIN
        SELECT COUNT(*) INTO V_LICZBA FROM KSIAZKA;

        RETURN V_LICZBA;
    END;

    PROCEDURE DODAJ_KSIAZKE(
        P_ID_KS IN NUMBER,
        P_TYTUL IN VARCHAR2,
        P_CENA IN NUMBER,
        P_ID_AUT IN NUMBER,
        P_ID_GAT IN NUMBER
    ) IS
    BEGIN
        INSERT INTO KSIAZKA(ID_KS, TYTUL, CENA, ID_AUT, ID_GAT)
        VALUES (P_ID_KS, P_TYTUL, P_CENA, P_ID_AUT, P_ID_GAT);
    END;

END ZARZADZANIE_BIBLIOTEKA;
/
