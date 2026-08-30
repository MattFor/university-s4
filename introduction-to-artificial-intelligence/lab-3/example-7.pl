:-dynamic fakt/1.
:-dynamic inuse/1.
:-dynamic asked/1.
fakt(a).
fakt(g).
fakt(c).
regula(e):- not(inuse(e)), assert(inuse(e)), (sprawdz(a), sprawdz(c), assert(fakt(e)), retract(inuse(e))) ;
            (retract(inuse(e)), fail).
regula(a):- not(inuse(a)), assert(inuse(a)), (sprawdz(f), sprawdz(b), assert(fakt(a)), retract(inuse(a))) ;
            (retract(inuse(a)), fail).
regula(f):- not(inuse(f)), assert(inuse(f)), (sprawdz(a), sprawdz(g), sprawdz(b), assert(fakt(f)),
            retract(inuse(f))) ; (retract(inuse(f)), fail).
regula(b):- not(inuse(b)), assert(inuse(b)), (sprawdz(c), assert(fakt(b)), retract(inuse(b))) ;
            (retract(inuse(b)), fail).
regula(d):- not(inuse(d)), assert(inuse(d)), (sprawdz(e), sprawdz(g), sprawdz(f), assert(fakt(d)),
            retract(inuse(d))) ; (retract(inuse(d)), fail).
regula(c):- not(inuse(c)), assert(inuse(c)), (sprawdz(a), sprawdz(g), assert(fakt(c)), retract(inuse(c))) ;
            (retract(inuse(c)), fail).
sprawdz(a):- fakt(a) ; not(fakt(a)), regula(a); not(fakt(a)), zapytaj(a), assert(fakt(a)).
sprawdz(b):- fakt(b) ; not(fakt(b)), regula(b); not(fakt(b)), zapytaj(b), assert(fakt(b)).
sprawdz(c):- fakt(c) ; not(fakt(c)), regula(c); not(fakt(c)), zapytaj(c), assert(fakt(c)).
sprawdz(d):- fakt(d) ; not(fakt(d)), regula(d); not(fakt(d)), zapytaj(d), assert(fakt(d)).
sprawdz(e):- fakt(e) ; not(fakt(e)), regula(e); not(fakt(e)), zapytaj(e), assert(fakt(e)).
sprawdz(f):- fakt(f) ; not(fakt(f)), regula(f); not(fakt(f)), zapytaj(f), assert(fakt(f)).
sprawdz(g):- fakt(g) ; not(fakt(g)), regula(g); not(fakt(g)), zapytaj(g), assert(fakt(g)).
zapytaj(X):- not(asked(X)), assert(asked(X)), nl, write('czy '), write(X), write(' jest prawdziwe?[t/n] '),                      nl, read(Odp), Odp='t'.
reset:- retractall(fakt(_)), retractall(asked(_)).
dodaj(X):- not(fakt(X)), assert(fakt(X)).
wypisz_fakty:- not(fakt(_)), write('Nie ma znanych faktow!'), nl, !.
wypisz_fakty:- fakt(X), write(X), write(' '), fail.
wypisz_fakty.
wnioskuj_w_przod:- nl, write('Fakty znane przed wnioskowaniem: '), nl, wypisz_fakty, fail.
wnioskuj_w_przod:- sprawdz(_), fail.
wnioskuj_w_przod:- nl, write('Fakty znane po wnioskowaniu: '), nl, wypisz_fakty.
wnioskuj_w_tyl(_):- nl, write('Fakty znane przed wnioskowaniem: '), nl, wypisz_fakty, fail.
wnioskuj_w_tyl(X):- sprawdz(X), nl, write(X), write(' dowiedzione'), nl, 
                    write('Fakty znane po wnioskowaniu: '), nl,
wypisz_fakty, !.
wnioskuj_w_tyl(X):- nl, write(X), write(' nie zostalo dowiedzione'), nl, 
                    write('Fakty znane po wnioskowaniu: '), nl,
wypisz_fakty.
powitanie:- write('Witaj!'),nl, nl.
