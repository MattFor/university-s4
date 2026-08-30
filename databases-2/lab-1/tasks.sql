select concat(c.imie, concat(' ', c.nazwisko)) as "Dane czytelnika", count(distinct id_gat) as "Liczba Wypożyczonych Gatunków"
from czytelnik c join wypozyczenia w
on w.id_czyt=c.id_czyt join ksiazka k on k.id_ks=w.id_ks group by c.imie, c.nazwisko order by "Liczba Wypożyczonych Gatunków" desc;

select count (*) from ksiazka where id_wyd in (select id_wyd from ksiazka where data_wyd in(select min(data_wyd) from ksiazka));

select count(wy.id_ks) ile, f_nazwa
from ksiazka k join format f
on f.id_for=k.id_for join wypozyczenia wy on wy.id_ks=k.id_ks
where data_wyp>add_months(sysdate, -3)
group by f_nazwa 
order by ile desc
fetch first row only;

select count(wy.id_ks) ile, f_nazwa
from ksiazka k join format f
on f.id_for=k.id_for join wypozyczenia wy on wy.id_ks=k.id_ks
where data_wyp>add_months(sysdate, -3)
group by f_nazwa
having count(wy.id_ks) in (select max(count(wy.id_ks))
from ksiazka k join format f
on f.id_for=k.id_for join wypozyczenia wy on wy.id_ks=k.id_ks
where data_wyp>add_months(sysdate, -3)
group by f_nazwa);

SELECT g.g_nazwa AS rodzaj, COUNT(k.id_ks) AS liczba_ksiazek, SUM(k.cena) AS suma_cen
FROM gatunek g
LEFT JOIN ksiazka k ON k.id_gat = g.id_gat
GROUP BY g.g_nazwa
ORDER BY g.g_nazwa;

SELECT g.g_nazwa, COUNT(w.id_wyp) AS ilosc_wypozyczen
FROM gatunek g
LEFT JOIN ksiazka k ON k.id_gat = g.id_gat
LEFT JOIN wypozyczenia w ON w.id_ks = k.id_ks
GROUP BY g.g_nazwa
HAVING COUNT(w.id_wyp) > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(w2.id_wyp) AS cnt
        FROM gatunek g2
        LEFT JOIN ksiazka k2 ON k2.id_gat = g2.id_gat
        LEFT JOIN wypozyczenia w2 ON w2.id_ks = k2.id_ks
        GROUP BY g2.id_gat
      )
);

SELECT DISTINCT a.*
FROM autor a
JOIN ksiazka k ON k.id_aut = a.id_aut
WHERE k.id_gat IN (
  SELECT id_gat
  FROM ksiazka
  WHERE l_stron = (SELECT MIN(l_stron) FROM ksiazka)
);

CREATE OR REPLACE FUNCTION factorial(n IN PLS_INTEGER) RETURN NUMBER IS
  result NUMBER := 1;
BEGIN
  IF n < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Silnia nie jest zdefiniowana dla n < 0');
  END IF;
  FOR i IN 2 .. GREATEST(n,1) LOOP
    result := result * i;
  END LOOP;
  RETURN result;
END;
/
SELECT factorial(5) FROM dual;

DECLARE
  TYPE student_rec IS RECORD (
    id      NUMBER,
    nazwisko VARCHAR2(50),
    miasto   VARCHAR2(50),
    telefon  VARCHAR2(20)
  );
  student student_rec;
BEGIN
  student.id := 1;
  student.nazwisko := 'Kowalski';
  student.miasto := 'Kraków';
  student.telefon := '123456789';
  DBMS_OUTPUT.PUT_LINE('ID:' || student.id || ', Nazwisko:' || student.nazwisko || ', Miasto:' || student.miasto || ', Telefon:' || student.telefon);
END;
/

CREATE OR REPLACE FUNCTION gcd(a IN PLS_INTEGER, b IN PLS_INTEGER) RETURN PLS_INTEGER IS
  aa PLS_INTEGER := ABS(a);
  bb PLS_INTEGER := ABS(b);
  tmp PLS_INTEGER;
BEGIN
  IF aa = 0 THEN
    RETURN bb;
  ELSIF bb = 0 THEN
    RETURN aa;
  END IF;
  WHILE bb != 0 LOOP
    tmp := MOD(aa, bb);
    aa := bb;
    bb := tmp;
  END LOOP;
  RETURN aa;
END;
/

SELECT gcd(54, 24) FROM dual;

DECLARE
  n PLS_INTEGER := 10;
  a NUMBER := 0;
  b NUMBER := 1;
  tmp NUMBER;
BEGIN
  IF n <= 0 THEN
    DBMS_OUTPUT.PUT_LINE('Brak elementów (n <= 0).');
    RETURN;
  END IF;
  IF n >= 1 THEN DBMS_OUTPUT.PUT(a); END IF;
  FOR i IN 2 .. n LOOP
    DBMS_OUTPUT.PUT(', ' || b);
    tmp := a + b;
    a := b;
    b := tmp;
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
END;
/
