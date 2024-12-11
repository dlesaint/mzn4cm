%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BOOLEAN I-TYPE OPERATIONS
%
% - Implements I-TYPE IMPLEMENTATION API
%		- PAR/VAR I-TYPE RELATIONS 
%			- iEquals (par)
%			- iEquals (var)
%		- PAR/VAR BINARY I-TYPE OPERATIONS
%			-	iAggregate (par)
%			-	iAggregate (var)
%			-	iPropagate (par)
%			-	iPropagate (var)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../itype/itype_imp_api.mzn";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: iEquals(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
	=
	assert(false, "bug: unexpected function call (equality should be identity - see _buildAlgebra() - and so pre-checked)", false)
	;
	
%
function var bool: iEquals(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)"
	=
	assert(false, "bug: unexpected function call (equality should be identity - see _buildAlgebra() - and so pre-checked)", false)
	;
%% BINARY AGGREGATION
%
function array[IBLOCK_COMPONENT] of int: iAggregate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
    ::  "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
    =
    if getAggregation(itype) == ITYPE_BOOL_OR
    then [max(x[1],y[1])]
    elseif getAggregation(itype) == ITYPE_BOOL_AND
    then [x[1]*y[1]]
    else assert(false, "bug - incomplete implementation", [])
	endif
;
%
function array[IBLOCK_COMPONENT] of var int: iAggregate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)"
	=
	if 		getAggregation(itype) == ITYPE_BOOL_OR
	then	[max(x[1], y[1])]
	elseif	getAggregation(itype) == ITYPE_BOOL_AND
	then	%[x[1] * y[1]]
		assert(false,"test",[])
	else	assert(false, "bug - incomplete implementation", [])
	endif
;


%% BINARY PROPAGATION
%
function array[IBLOCK_COMPONENT] of int: iPropagate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	if 		getPropagation(itype) == ITYPE_BOOL_OR
	then	[max(x[1], y[1])]
	elseif	getPropagation(itype) == ITYPE_BOOL_AND
	then	[x[1] * y[1]]
	else	assert(false, "bug - incomplete implementation", [])
	endif
;

%
function array[IBLOCK_COMPONENT] of var int: iPropagate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)"
	=
	if 		getPropagation(itype) == ITYPE_BOOL_OR
	then	[max(x[1], y[1])]
	elseif	getPropagation(itype) == ITYPE_BOOL_AND
	then	[x[1] * y[1]]
	else	assert(false, "bug - incomplete implementation", [])
	endif
;