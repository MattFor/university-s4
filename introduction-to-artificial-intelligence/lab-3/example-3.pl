:-dynamic fakt/1.
fakt(a).
fakt(g).
fakt(c).
regula(e):- sprawdz(a), sprawdz(c).
regula(a):- sprawdz(f), sprawdz(b).
regula(f):- sprawdz(a), sprawdz(g), sprawdz(b).
regula(b):- sprawdz(c).
regula(d):- sprawdz(e), sprawdz(g), sprawdz(f).
regula(c):- sprawdz(a), sprawdz(g).
sprawdz(a):-fakt(a) ; regula(a).
sprawdz(b):-fakt(b) ; regula(b).
sprawdz(c):-fakt(c) ; regula(c).
sprawdz(d):-fakt(d) ; regula(d).
sprawdz(e):-fakt(e) ; regula(e).
sprawdz(f):-fakt(f) ; regula(f).
sprawdz(g):-fakt(g) ; regula(g).
