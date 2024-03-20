%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RANGE API
%
%	- Declares
%		-	isRange
%		-	isProperRange
%		-	rank (par)
%		-	rank (var)
%		-	value (par)
%		-	value (var)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RANGES

% Checks whether input set $V is a range $V=min($V)..max($V)
function bool: isRange(set of $$V: V) :: "isRange($V): checks whether $V=min($V)..max($V)";

% Checks whether input set $V is a proper range $V=1..|$V|
function bool: isProperRange(set of $$V: V) :: "isProperRange($V): checks whether $V=1..|$V|";

% Rank of v in range V
function int: rank(set of $$V: V, $$V: v) :: "rank($V,$v): rank of value $v in range $V (par)";

% Rank of x in range V
function var int: rank(set of $$V: V, var $$V: x) :: "rank($V,$x): rank of value $x in range $V (var)";

% r-th value of range V
function $$V: value(set of $$V: V, int: k) :: "value($V,$k): value ranked by $k in range $V";

% functional constraint yielding $x-th element of range $V
% constraint violated iff $V is not a range or $x is not in 1..|$V|
function var $$V: value(set of $$V: V, var int: x) :: "functional constraint value($V,$x): value ranked by $x in range $V (element constraint on range)"
