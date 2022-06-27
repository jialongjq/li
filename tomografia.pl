% A matrix which contains zeroes and ones gets "x-rayed" vertically and
% horizontally, giving the total number of ones in each row and column.
% The problem is to reconstruct the contents of the matrix from this
% information. Sample run:
%
%	?- p.
%	    0 0 7 1 6 3 4 5 2 7 0 0
%	 0                         
%	 0                         
%	 8      * * * * * * * *    
%	 2      *             *    
%	 6      *   * * * *   *    
%	 4      *   *     *   *    
%	 5      *   *   * *   *    
%	 3      *   *         *    
%	 7      *   * * * * * *    
%	 0                         
%	 0                         
%	

:- use_module(library(clpfd)).

ejemplo1( [0,0,8,2,6,4,5,3,7,0,0], [0,0,7,1,6,3,4,5,2,7,0,0] ).
ejemplo2( [10,4,8,5,6], [5,3,4,0,5,0,5,2,2,0,1,5,1] ).
ejemplo3( [11,5,4], [3,2,3,1,1,1,1,2,3,2,1] ).


p:-	ejemplo1(RowSums,ColSums),
	length(RowSums,NumRows),
	length(ColSums,NumCols),
	NVars is NumRows*NumCols,
	listVars(NVars,L),  % generate a list of Prolog vars (their names do not matter)

%1: Dominio:
    L ins 0..1,
    
%2: Constraints:
    
	matrixByRows(L,NumCols,MatrixByRows),
	transpose(MatrixByRows, MatrixByColumns),
	declareConstraints(MatrixByRows, RowSums, MatrixByColumns, ColSums),

%3: Labeling:

    label(L),
    
    
	pretty_print(RowSums,ColSums,MatrixByRows), !.


pretty_print(_,ColSums,_):- write('     '), member(S,ColSums), writef('%2r ',[S]), fail.
pretty_print(RowSums,_,M):- nl,nth1(N,M,Row), nth1(N,RowSums,S), nl, writef('%3r   ',[S]), member(B,Row), wbit(B), fail.
pretty_print(_,_,_):- nl.
wbit(1):- write('*  '),!.
wbit(0):- write('   '),!.

listVars(NVars, L):- length(L, NVars).

removeElements(0, L, [], L).
removeElements(N, [X|L], [X|Removed], Resultante):- N1 is N-1, removeElements(N1, L, Removed, Resultante), !.

matrixByRows([], _, []).
matrixByRows(L, NumCols, [Fila|Filas]):- removeElements(NumCols, L, Fila, Resto), matrixByRows(Resto, NumCols, Filas), !.

declareConstraints([], [], [], []).

declareConstraints([Row|Rows], [RowSum|RowSums], [], []):- 
    exprSuma(Row, ExprRow),
    ExprRow #= RowSum,
    declareConstraints(Rows, RowSums, [], []).
    
declareConstraints([], [], [Column|Columns], [ColSum|ColSums]):- 
    exprSuma(Column, ExprColumn),
    ExprColumn #= ColSum,
    declareConstraints([], [], Columns, ColSums).


declareConstraints([Row|Rows], [RowSum|RowSums], [Column|Columns], [ColSum|ColSums]):-
    exprSuma(Row, ExprRow),
    ExprRow #= RowSum,
    exprSuma(Column, ExprColumn),
    ExprColumn #= ColSum,
    declareConstraints(Rows, RowSums, Columns, ColSums).
    

exprSuma( [X],  X ):- !.
exprSuma( [X|Vars], X+Expr ):- exprSuma( Vars, Expr).

