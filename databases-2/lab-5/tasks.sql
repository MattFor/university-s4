DECLARE
	CURSOR ksiazka IS SELECT imie, nazwisko, count(id_wyp) FROM ksiazki 

	vimie 		ksiazki.imie%TYPE
	vnazwisko	ksiazki.nazwisko%TYPE

BEGIN
	OPEN ksiazka;

	LOOP
		FETCH ksiazka INTO vimie, vnazwisko
		EXIT WHEN ksiazka%NOTFOUND
		DBMS_OUTPUT.PUT_LINE('Imie: ' || vimie || ' ' || 'Nazwisko: ' || vnazwisko || );
	END LOOP;

	CLOSE ksiazka;
END;
/


DECLARE
  CURSOR ksiazka IS 
    SELECT k.imie, k.nazwisko, COUNT(w.id_wyp)
    FROM klienci k
    JOIN wypozyczenia w ON k.id_kli = w.id_kli
    GROUP BY k.imie, k.nazwisko;

  vimie       klienci.imie%TYPE;
  vnazwisko   klienci.nazwisko%TYPE;
  vliczba     NUMBER;

BEGIN
	OPEN ksiazka;

	LOOP
		FETCH ksiazka INTO vimie, vnazwisko, vliczba;
		EXIT WHEN ksiazka%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE('Imie: ' || vimie || ' Nazwisko: ' || vnazwisko || ' Liczba wypozyczen: ' || vliczba);
	END LOOP;
	
	CLOSE ksiazka;
END;
/


BEGIN
	FOR rec IN (
		SELECT k.imie, k.nazwisko, COUNT(w.id_wyp) liczba
		FROM klienci k
		JOIN wypozyczenia w ON k.id_kli = w.id_kli
		GROUP BY k.imie, k.nazwisko
	)
	LOOP
		DBMS_OUTPUT.PUT_LINE(rec.imie || ' ' || rec.nazwisko || ' -> ' || rec.liczba);
	END LOOP;
END;
/
