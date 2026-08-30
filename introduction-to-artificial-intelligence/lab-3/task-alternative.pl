
pietra :-
    L0 = [0,1,2,3,4,5,6],
    select(J, L0, L1),
    select(F, L1, L2),
    select(S, L2, L3),
    select(A, L3, L4),
    select(Z, L4, L5),
    select(R, L5, L6),
    select(M, L6, []),
    Z < J,
S < J,
S < Z,
R < Z,
M < F,
A < Z,
M < J,
M < Z,
Z > F,
S < R,
S < A,
R < J,
S < M,
F < J,
R > M,
M < A,
F < R,
A > R,
A < J,
A > F,
S < F,
    pietro(Jz, J),
    pietro(Fz, F),
    pietro(Sz, S),
    pietro(Az, A),
    pietro(Zz, Z),
    pietro(Rz, R),
    pietro(Mz, M),
    assert(info(jarek, J, Jz)),
    assert(info(franek, F, Fz)),
    assert(info(stefan, S, Sz)),
    assert(info(albert, A, Az)),
    assert(info(szymon, Z, Zz)),
    assert(info(robert, R, Rz)),
    assert(info(marcin, M, Mz)).


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
nie_ma(albert, pies).
nie_ma(albert, rybka).
nie_ma(albert, wąż).
nie_ma(franek, kanarek).
nie_ma(franek, papuga).
nie_ma(franek, pies).
nie_ma(franek, rybka).
nie_ma(jarek, chomik).
nie_ma(jarek, kot).
nie_ma(jarek, papuga).
nie_ma(jarek, pies).
nie_ma(jarek, rybka).
nie_ma(jarek, wąż).
nie_ma(marcin, chomik).
nie_ma(marcin, kanarek).
nie_ma(marcin, kot).
nie_ma(marcin, papuga).
nie_ma(marcin, rybka).
nie_ma(marcin, wąż).
nie_ma(robert, chomik).
nie_ma(robert, kanarek).
nie_ma(robert, kot).
nie_ma(robert, pies).
nie_ma(robert, rybka).
nie_ma(robert, wąż).
nie_ma(stefan, kanarek).
nie_ma(stefan, papuga).
nie_ma(stefan, pies).
nie_ma(stefan, rybka).
nie_ma(stefan, wąż).
nie_ma(szymon, kot).
nie_ma(szymon, papuga).
nie_ma(szymon, pies).
nie_ma(szymon, wąż).
pietro(chomik, 0).
pietro(kanarek, 6).
pietro(kot, 4).
pietro(papuga, 3).
pietro(pies, 1).
pietro(rybka, 5).
pietro(wąż, 2).
