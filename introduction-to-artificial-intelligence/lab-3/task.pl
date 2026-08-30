czlowiek(albert).
czlowiek(franek).
czlowiek(jarek).
czlowiek(marcin).
czlowiek(robert).
czlowiek(stefan).
czlowiek(szymon).

moze_miec(X, Y) :- czlowiek(X), not(nie_ma(X, Y)).

nie_ma(albert, chomik).
nie_ma(albert, kanarek).
nie_ma(albert, kot).
nie_ma(albert, papuga).
nie_ma(albert, pies).
nie_ma(albert, 'wąż').
nie_ma(franek, chomik).
nie_ma(franek, kanarek).
nie_ma(franek, pies).
nie_ma(franek, 'wąż').
nie_ma(jarek, papuga).
nie_ma(jarek, rybka).
nie_ma(jarek, 'wąż').
nie_ma(marcin, chomik).
nie_ma(marcin, kanarek).
nie_ma(marcin, kot).
nie_ma(marcin, papuga).
nie_ma(marcin, rybka).
nie_ma(marcin, 'wąż').
nie_ma(robert, chomik).
nie_ma(robert, kanarek).
nie_ma(robert, kot).
nie_ma(robert, papuga).
nie_ma(robert, pies).
nie_ma(robert, rybka).
nie_ma(stefan, kanarek).
nie_ma(stefan, kot).
nie_ma(stefan, papuga).
nie_ma(stefan, pies).
nie_ma(stefan, rybka).
nie_ma(stefan, 'wąż').
nie_ma(szymon, chomik).
nie_ma(szymon, kanarek).
nie_ma(szymon, kot).
nie_ma(szymon, pies).

% Mapowanie zwierzak -> numer pietro(Zwierze, Numer).
pietro(chomik, 5).
pietro(kanarek, 1).
pietro(kot, 6).
pietro(papuga, 4).
pietro(pies, 0).
pietro(rybka, 2).
pietro('wąż', 3).

% Znajduje permutację 0..6 spełniającą wszystkie warunki i wypisuje wynik
solve :-
    L0 = [0,1,2,3,4,5,6],
    select(J, L0, L1),
    select(F, L1, L2),
    select(S, L2, L3),
    select(A, L3, L4),
    select(Z, L4, L5),
    select(R, L5, L6),
    select(M, L6, []),

    % warunki z treści
    F > R,
    J < S,
    S > Z,
    A < F,
    Z > A,
    S > M,
    J < A,
    Z < F,
    M < F,
    R > A,
    Z > M,
    A > M,
    R < Z,
    J > M,
    F > S,
    J < R,
    R > M,
    S > R,
    A < S,
    J < F,
    Z > J,

    % Dopasowanie numer -> zwierze
    pietro(Jz, J),
    pietro(Fz, F),
    pietro(Sz, S),
    pietro(Az, A),
    pietro(Zz, Z),
    pietro(Rz, R),
    pietro(Mz, M),

    moze_miec(jarek, Jz),
    moze_miec(franek, Fz),
    moze_miec(stefan, Sz),
    moze_miec(albert, Az),
    moze_miec(szymon, Zz),
    moze_miec(robert, Rz),
    moze_miec(marcin, Mz),

    format('Jarek ~w ~w~n', [J, Jz]),
    format('Franek ~w ~w~n', [F, Fz]),
    format('Stefan ~w ~w~n', [S, Sz]),
    format('Albert ~w ~w~n', [A, Az]),
    format('Szymon ~w ~w~n', [Z, Zz]),
    format('Robert ~w ~w~n', [R, Rz]),
    format('Marcin ~w ~w~n', [M, Mz]).