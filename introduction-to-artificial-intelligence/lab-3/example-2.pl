:-dynamic fakt/1.
fakt(a).
fakt(g).
fakt(c).
regula(e):- fakt(a), fakt(c), assert(fakt(e)).
regula(a):- fakt(f), fakt(b), assert(fakt(a)).
regula(f):- fakt(a), fakt(g), fakt(b), assert(fakt(f)).
regula(b):- fakt(c), assert(fakt(b)).
regula(d):- fakt(e), fakt(g), fakt(f), assert(fakt(d)).
regula(c):- fakt(a), fakt(g), assert(fakt(c)).
sprawdz(a):- fakt(a) ; not(fakt(a)), regula(a).
sprawdz(b):- fakt(b) ; not(fakt(b)), regula(b).
sprawdz(c):- fakt(c) ; not(fakt(c)), regula(c).
sprawdz(d):- fakt(d) ; not(fakt(d)), regula(d).
sprawdz(e):- fakt(e) ; not(fakt(e)), regula(e).
sprawdz(f):- fakt(f) ; not(fakt(f)), regula(f).
sprawdz(g):- fakt(g) ; not(fakt(g)), regula(g).
