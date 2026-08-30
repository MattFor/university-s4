mezczyzna(adam).
mezczyzna(stefan).
mezczyzna(staszek).
mezczyzna(marek).
kobieta(ala).
kobieta(alina).
kobieta(maria).
kobieta(ania).
rodzice(stefan, staszek, maria).
rodzice(ala, staszek, maria).
rodzice(ania, marek, alina).
siostra(X,Y) :- rodzice(X,A,_),rodzice(Y,A,_) ; rodzice(X,_,B),rodzice(Y,_,B) , kobieta(X).