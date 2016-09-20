% CSCI 305, Lab 4
% Bradley White
% April 24, 2016

% The following is a weighted graph with 9 nodes
% Each edge is given as (A,B,weight), with weight > 0.

edge(1,2,1.6).
edge(1,3,1.5).
edge(1,4,2.2).
edge(1,6,5.2).
edge(2,3,1.4).
edge(2,5,2.1).
edge(2,9,5.1).
edge(3,4,1.4).
edge(3,5,1.3).
edge(4,5,1.3).
edge(4,7,1.2).
edge(4,8,3.0).
edge(5,6,1.6).
edge(5,7,1.7).
edge(6,7,1.8).
edge(6,8,2.2).
edge(6,9,1.7).
edge(7,8,1.6).
edge(8,9,1.8).

% Find the shortest path between two nodes
shortest(A,B,Path,Length):-
	% setof collects all possible paths and sorts them
	setof([P,L],path(A,B,P,L),Set),
	% No path found
	Set = [_|_],
	% Find the minimal weighted path
	minimal(Set,[Path,Length]).

% Find the minimal weighted path from all possible paths
minimal([H|T],M):-
	min(T,H,M).
% If the list is empty the shortest path has been found
min([],M,M).
% Compare the length of the first and second paths remaining in the list, keep the shortest
min([[P,L]|T],[_,M],Min):-
	L < M, !, min(T,[P,L],Min).
min([_|T],M,Min) :-
	min(T,M,Min).

% Find a path from A to B through Path with weight Len
path(A,B,Path,Len):-
	travel(A,B,[A],Q,Len),
	reverse(Q,Path).

% If there is a direct connection use it
travel(A,B,P,[B|P],L):-
	connected(A,B,L).

% If a transitive relation exists between nodes, find it
travel(A,B,Visited,Path,L):-
	connected(A,C,D),
	% Make sure C doesn't equal B
	C \== B,
	% Make sure C hasn't been visited to avoid endless cycles
	\+member(C,Visited),
	% Continue searching for a path
	travel(C,B,[C|Visited],Path,L1),
	% Update the length of the path
	L is D+L1.

% Disjunction to stop infinite loops, when building connections
connected(X,Y,L):- edge(X,Y,L) ; edge(Y,X,L).
