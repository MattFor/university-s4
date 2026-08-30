SET SERVEROUTPUT ON

DECLARE
    TYPE t_author_rec IS RECORD (
            id_aut   autor.id_aut%TYPE,
            nazwisko autor.nazwisko%TYPE,
            imie     autor.imie%TYPE,
            kraj     autor.kraj%TYPE
    );
    r t_author_rec;
    CURSOR c_auth IS
    SELECT
        id_aut,
        nazwisko,
        imie,
        kraj
    FROM
        autor;

BEGIN
    OPEN c_auth;
    LOOP
        FETCH c_auth INTO
            r.id_aut,
            r.nazwisko,
            r.imie,
            r.kraj;

        EXIT WHEN c_auth%notfound;
        dbms_output.put_line('ID:'
                             || r.id_aut
                             || ' | '
                             || r.imie
                             || ' '
                             || r.nazwisko
                             || ' | '
                             || r.kraj);

    END LOOP;

    CLOSE c_auth;
END;
/

SET SERVEROUTPUT ON

DECLARE
    r_autor autor%rowtype;
    CURSOR c_auth IS
    SELECT
        *
    FROM
        autor;

BEGIN
    OPEN c_auth;
    LOOP
        FETCH c_auth INTO r_autor;
        EXIT WHEN c_auth%notfound;
        dbms_output.put_line(r_autor.id_aut
                             || ' '
                             || r_autor.imie
                             || ' '
                             || r_autor.nazwisko
                             || ' '
                             || r_autor.kraj);

    END LOOP;

    CLOSE c_auth;
END;
/

SET SERVEROUTPUT ON

BEGIN
    FOR r IN (
        SELECT
            *
        FROM
            autor
    ) LOOP
        dbms_output.put_line(r.id_aut
                             || ' | '
                             || r.imie
                             || ' '
                             || r.nazwisko
                             || ' | '
                             || r.kraj);
    END LOOP;
END;
/

SET SERVEROUTPUT ON

BEGIN
    FOR r IN (
        SELECT
            imie,
            nazwisko,
            miasto
        FROM
            czytelnik
        ORDER BY
            nazwisko DESC
    ) LOOP
        dbms_output.put_line(r.imie
                             || ' *******'
                             || upper(r.nazwisko)
                             || ' ********'
                             || initcap(r.miasto));
    END LOOP;
END;
/

SET SERVEROUTPUT ON

BEGIN
    FOR r IN (
        SELECT
            c.imie,
            c.nazwisko,
            to_char(w.data_wyp, 'DD')                                               AS dzien,
            upper(rtrim(to_char(w.data_wyp, 'MONTH', 'NLS_DATE_LANGUAGE=ENGLISH'))) AS miesiac,
            k.tytul,
            lower(f.f_nazwa)                                                        AS format_ksiazki
        FROM
                 wypozyczenia w
            JOIN czytelnik c ON w.id_czyt = c.id_czyt
            JOIN ksiazka   k ON w.id_ks = k.id_ks
            JOIN format    f ON k.id_for = f.id_for
        ORDER BY
            c.nazwisko,
            c.imie,
            w.data_wyp
    ) LOOP
        dbms_output.put_line(r.imie
                             || ' '
                             || r.nazwisko
                             || ' '
                             || r.dzien
                             || ' '
                             || r.miesiac
                             || ' '
                             || r.tytul
                             || ' '
                             || r.format_ksiazki);
    END LOOP;
END;
/

SET SERVEROUTPUT ON

DECLARE
    p_min_price NUMBER := 30;
    CURSOR c_books (
        p_price NUMBER
    ) IS
    SELECT
        k.tytul,
        a.nazwisko AS autor,
        w.w_nazwa  AS wydawnictwo,
        wy.data_zwr,
        k.cena
    FROM
             wypozyczenia wy
        JOIN ksiazka     k ON wy.id_ks = k.id_ks
        JOIN autor       a ON k.id_aut = a.id_aut
        JOIN wydawnictwo w ON k.id_wyd = w.id_wyd
    WHERE
            k.cena >= p_price
        AND wy.data_zwr >= trunc(sysdate)
    ORDER BY
        k.cena DESC; -- Najdroższe jako pierwsze

    rec         c_books%rowtype;
BEGIN
    OPEN c_books(p_min_price);
    LOOP
        FETCH c_books INTO rec;
        EXIT WHEN c_books%notfound
        OR c_books%rowcount > 3;
        dbms_output.put_line('Tytul: '
                             || rec.tytul
                             || ' | Autor: '
                             || rec.autor
                             || ' | Wyd: '
                             || rec.wydawnictwo
                             || ' | Data zwr: '
                             || to_char(rec.data_zwr, 'YYYY-MM-DD')
                             || ' | Cena: '
                             || rec.cena);

    END LOOP;

    CLOSE c_books;
END;
/

SET SERVEROUTPUT ON

DECLARE
    CURSOR c_format IS
    SELECT
        f.f_nazwa,
        COUNT(k.id_ks) AS liczba
    FROM
        format  f
        LEFT JOIN ksiazka k ON f.id_for = k.id_for
    GROUP BY
        f.f_nazwa
    ORDER BY
        f.f_nazwa;

    v_name  VARCHAR2(100);
    v_count NUMBER;
BEGIN
    OPEN c_format;
    LOOP
        FETCH c_format INTO
            v_name,
            v_count;
        EXIT WHEN c_format%notfound;
        dbms_output.put_line('Format: '
                             || v_name
                             || ' | Liczba ksiazek: '
                             || nvl(v_count, 0));

    END LOOP;

    CLOSE c_format;
END;
/

SET SERVEROUTPUT ON

DECLARE
    p_format VARCHAR2(30) := 'EBOOK';
    CURSOR c_fmt (
        p_name VARCHAR2
    ) IS
    SELECT
        COUNT(k.id_ks) AS liczba
    FROM
        format  f
        LEFT JOIN ksiazka k ON f.id_for = k.id_for
    WHERE
        f.f_nazwa = p_name;

    v_count  NUMBER;
BEGIN
    OPEN c_fmt(p_format);
    FETCH c_fmt INTO v_count;
    IF c_fmt%notfound THEN
        dbms_output.put_line('Brak formatu o nazwie ' || p_format);
    ELSE
        dbms_output.put_line('Format: '
                             || p_format
                             || ' | Liczba ksiazek: '
                             || nvl(v_count, 0));
    END IF;

    CLOSE c_fmt;
END;
/

SET SERVEROUTPUT ON

DECLARE
    CURSOR c_upd IS
    SELECT
        k.id_ks,
        k.cena,
        w.w_nazwa
    FROM
             ksiazka k
        JOIN wydawnictwo w ON k.id_wyd = w.id_wyd
    FOR UPDATE OF k.cena;
    rec         c_upd%rowtype;
    v_new_price NUMBER;
BEGIN
    OPEN c_upd;
    LOOP
        FETCH c_upd INTO rec;
        EXIT WHEN c_upd%notfound;
        IF rec.w_nazwa = 'Litera' THEN
            v_new_price := round(rec.cena * 1.10, 2);
        ELSE
            v_new_price := round(rec.cena * 1.05, 2);
        END IF;

        UPDATE ksiazka
        SET
            cena = v_new_price
        WHERE
            CURRENT OF c_upd;

        dbms_output.put_line('ID_KS='
                             || rec.id_ks
                             || ' | Stara='
                             || rec.cena
                             || ' -> Nowa='
                             || v_new_price
                             || ' (wyd: '
                             || rec.w_nazwa
                             || ')');

    END LOOP;

    CLOSE c_upd;
    COMMIT;
END;
/

SET SERVEROUTPUT ON

DECLARE
    CURSOR c_ids IS
    SELECT
        k.id_ks,
        k.cena,
        w.w_nazwa
    FROM
             ksiazka k
        JOIN wydawnictwo w ON k.id_wyd = w.id_wyd;

    rec         c_ids%rowtype;
    v_new_price NUMBER;
BEGIN
    OPEN c_ids;
    LOOP
        FETCH c_ids INTO rec;
        EXIT WHEN c_ids%notfound;
        IF rec.w_nazwa = 'Litera' THEN
            UPDATE ksiazka
            SET
                cena = round(cena * 1.10, 2)
            WHERE
                id_ks = rec.id_ks
            RETURNING cena INTO v_new_price;

        ELSE
            UPDATE ksiazka
            SET
                cena = round(cena * 1.05, 2)
            WHERE
                id_ks = rec.id_ks
            RETURNING cena INTO v_new_price;

        END IF;

        dbms_output.put_line('ID_KS='
                             || rec.id_ks
                             || ' | Stara='
                             || rec.cena
                             || ' -> Nowa='
                             || v_new_price
                             || ' (wyd: '
                             || rec.w_nazwa
                             || ')');

    END LOOP;

    CLOSE c_ids;
    COMMIT;
END;
/
