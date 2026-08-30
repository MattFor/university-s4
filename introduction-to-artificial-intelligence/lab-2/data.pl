write_list([]).
write_list([H|T]):-print(H),nl,write_list(T).

dziel(E, [G|O], [G|L1], L2) :- G =< E, dziel(E,O,L1,L2).
dziel(E, [G|O], L1, [G|L2]) :- G > E, dziel(E,O,L1,L2).
dziel(_, [], [], []).

silnia(0, 1).
silnia(N, X):- N>0,N1 is N-1,silnia(N1,X1),X is N*X1.

maximum([X],X).
maximum([H|T],X):-maximum(T,MaxT),X is max(H,MaxT).

minimum([X],X).
minimum([H|T],X):-minimum(T,MinT),X is min(H,MinT).

suma([],0).
suma([H|T],S):-suma(T,ST),S is ST+H.

show_perm(L):-permutation(L, X), write(X), nl, fail.

czytaj_all :-write('Podaj plik: '),read(Plik),see(Plik),czyt,seen,nl,write('Skonczone!').
czyt:-read(X), X \== end_of_file, assertz(imie(X)), czyt.
czyt.