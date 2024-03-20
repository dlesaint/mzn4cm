%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RANGE API IMPLEMENTATION
%
%	- Declares
%		-	isRange
%		-	isProperRange
%		-	rank (par)
%		-	rank (var)
%		-	value (par)
%		-	value (var)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../ranges/ranges_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RANGES

%
function bool: isRange(set of $$V: V)
	:: "isRange($V): checks whether $V=min($V)..max($V)"
	=
		V == min(V)..max(V)
	;

%
function bool: isProperRange(set of $$V: V)
	:: "isProperRange($V): checks whether $V=1..|$V|"
	=
		V == 1..card(V)
	;

%
function int: rank(set of $$V: V, $$V: v)
	:: "rank($V,$v): rank of value $v in range $V (par)"
	=
	let {
		% V is a range
		bool: precond1 = assert(isRange(V), show(V) ++ " is not a range");
		% v in V
		bool: precond2 = assert(v in V, show(v) ++ " is not in " ++ show(V));
	} in
		v - min(V) + 1
	;

% Rank of x in range V
function var int: rank(set of $$V: V, var $$V: x)
	:: "rank($V,$x): rank of value $x in range $V (var)"
	=
	let {
		% V is a range
		bool: precond1 = assert(isRange(V), show(V) ++ " is not a range");
		% x in V
		constraint x in V;
	} in
		x - min(V) + 1
	;

%
function $$V: value(set of $$V: V, int: k)
	:: "value($V,$k): value ranked by $k in range $V"
	=
	let {
		% V is a range
		bool: precond1 = assert(isRange(V), show(V) ++ " is not a range");
		% 1<=k<=|V|
		bool: precond2 = assert(k in 1..card(V), show(k) ++ " is not in " ++ show(1..card(V)));
	} in
		min(V) + k - 1
	;

%
function var $$V: value(set of $$V: V, var int: x)
	:: "functional constraint value($V,$x): value ranked by $x in range $V (element constraint on range)"
	=
	let {
		% V is a range
		bool: precond1 = assert(isRange(V), show(V) ++ " is not a range");
		% 1<=x<=|V|
		constraint x in 1..card(V);
	} in
		min(V) + x - 1
	;



