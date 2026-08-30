:-dynamic fakt/1.
:-dynamic inuse/1.
fakt(a).
fakt(g).
fakt(c).
regula(e):- not(inuse(e)), assert(inuse(e)), sprawdz(a), sprawdz(c), retract(inuse(e)).
regula(a):- not(inuse(a)), assert(inuse(a)), sprawdz(f), sprawdz(b), retract(inuse(a)).
regula(f):- not(inuse(f)), assert(inuse(f)), sprawdz(a), sprawdz(g), sprawdz(b), retract(inuse(f)).
regula(b):- not(inuse(b)), assert(inuse(b)), sprawdz(c), retract(inuse(b)).
regula(d):- not(inuse(d)), assert(inuse(d)), sprawdz(e), sprawdz(g), sprawdz(f), retract(inuse(d)).
regula(c):- not(inuse(c)), assert(inuse(c)), sprawdz(a), sprawdz(g), retract(inuse(c)).
sprawdz(a):- fakt(a) ; not(fakt(a)), regula(a).
sprawdz(b):- fakt(b) ; not(fakt(b)), regula(b).
sprawdz(c):- fakt(c) ; not(fakt(c)), regula(c).
sprawdz(d):- fakt(d) ; not(fakt(d)), regula(d).
sprawdz(e):- fakt(e) ; not(fakt(e)), regula(e).
sprawdz(f):- fakt(f) ; not(fakt(f)), regula(f).
sprawdz(g):- fakt(g) ; not(fakt(g)), regula(g).
