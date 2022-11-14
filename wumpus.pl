:-dynamic position/2.
:-dynamic safe/2.
:-dynamic dangerous/2.
:-dynamic no_wumpus/2.
:-dynamic no_pit/2. 
:-dynamic temp/2.
:-dynamic diagnol/2.
:-dynamic adjacent/2.
:-dynamic call_adj/2.
:-dynamic temp_breeze/2.
:-dynamic temp_pp/2.
:-dynamic temp_stench/2.
:-dynamic temp_pw/2.

position(3,0).
no_wumpus(3,0).
no_pit(3,0).
safe(X,Y) :- no_wumpus(X,Y), no_pit(X,Y). 
call_adj(Z,W) :- retractall(adjacent(X,Y)),(((X is Z+1, Y is W);(X is Z-1, Y is W);
                                        (X is Z, Y is W+1);(X is Z, Y is W-1)), 
                                        (Y >= 0, Y < 4, X >=0, X < 4)), assert(adjacent(X,Y)).


check_breeze(X,Y) :- retractall(temp_breeze(S,T)),call_adj(X,Y),adjacent(A,B),breeze(A,B),asserta(temp_breeze(A,B)).
check_pp(X,Y) :- retractall(temp_pp(S,T)),check_breeze(X,Y),temp_breeze(A,B),call_adj(A,B),adjacent(Z,W),pos_pit(Z,W),not((Z is X, W is Y)),assert(temp_pp(Z,W)),!.
pit(X,Y) :- check_pp(X,Y), temp_pp(Z,W),safe(Z,W).

check_stench(X,Y) :- retractall(temp_stench(S,T)),call_adj(X,Y),adjacent(A,B),stench(A,B),asserta(temp_stench(A,B)).
check_pw(X,Y) :- retractall(temp_pw(S,T)),check_stench(X,Y),temp_stench(A,B),call_adj(A,B),adjacent(Z,W),pos_wum(Z,W),not((Z is X, W is Y)),assert(temp_pw(Z,W)),!.
wumpus(X,Y) :- check_pw(X,Y), temp_pw(Z,W),safe(Z,W).

dangerous(X,Y) :- wumpus(X,Y);pit(X,Y).

 

% move by teleporting the agent to space(X,Y)
% assuming that the position is safe
move(X,Y) :- retractall(position(A,B)), assert(position(X,Y)).
% detect takes two boolean parameters
% true true means to create a stench and a breeze 
detect(true,true) :- position(X,Y), asserta(stench(X,Y)),asserta(breeze(X,Y)).
detect(true, true) :- position(A,B), call_adj(A,B).
detect(true, true) :- adjacent(X,Y), not(safe(X,Y)), asserta(pos_pit(X,Y)), asserta(pos_wum(X,Y)). 
% true false create a stench at the position
detect(true, false) :- position(X,Y), asserta(stench(X,Y)), asserta(no_breeze(X,Y)).
detect(true, false) :- position(A,B), call_adj(A,B).
detect(true, false) :- adjacent(X,Y), not(safe(X,Y)), asserta(pos_wum(X,Y)),asserta(no_pit(X,Y)). 
% false true create a breeze at the position
detect(false, true) :- position(X,Y), asserta(no_stench(X,Y)), asserta(breeze(X,Y)).
detect(false, true) :- position(A,B), call_adj(A,B).
detect(false, true) :- adjacent(X,Y), not(safe(X,Y)), asserta(pos_pit(X,Y)),asserta(no_wumpus(X,Y)). 
% false false means that the position is absolutely safe 
detect(false, false) :- position(X,Y), asserta(no_stench(X,Y)), asserta(no_breeze(X,Y)).
detect(false, false) :- adjacent(X,Y), asserta(no_wumpus(X,Y)), asserta(no_pit(X,Y)).