:-dynamic fakt/1.
:-dynamic inuse/1.
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
sprawdz(a):- fakt(a) ; not(fakt(a)), regula(a).
sprawdz(b):- fakt(b) ; not(fakt(b)), regula(b).
sprawdz(c):- fakt(c) ; not(fakt(c)), regula(c).
sprawdz(d):- fakt(d) ; not(fakt(d)), regula(d).
sprawdz(e):- fakt(e) ; not(fakt(e)), regula(e).
sprawdz(f):- fakt(f) ; not(fakt(f)), regula(f).
sprawdz(g):- fakt(g) ; not(fakt(g)), regula(g).
