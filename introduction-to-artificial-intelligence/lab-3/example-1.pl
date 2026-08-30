:-dynamic fakt/1.
fakt(a).
fakt(g).
fakt(c).
regula(e):- fakt(a), fakt(c).
regula(a):- fakt(f), fakt(b).
regula(f):- fakt(a), fakt(g), fakt(b).
regula(b):- fakt(c).
regula(d):- fakt(e), fakt(g), fakt(f).
regula(c):- fakt(a), fakt(g).
sprawdz(a):- fakt(a) ; not(fakt(a)), regula(a).
sprawdz(b):- fakt(b) ; not(fakt(b)), regula(b).
sprawdz(c):- fakt(c) ; not(fakt(c)), regula(c).
sprawdz(d):- fakt(d) ; not(fakt(d)), regula(d).
sprawdz(e):- fakt(e) ; not(fakt(e)), regula(e).
sprawdz(f):- fakt(f) ; not(fakt(f)), regula(f).
sprawdz(g):- fakt(g) ; not(fakt(g)), regula(g).
