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

include "./../../itype/itype_imp_api.mzn";

include "./../../itype/type/itype_bool_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: iEquals(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
	=
	assert(false, "bug: unexpected function call", false)
	;
	
%
function var bool: iEquals(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)"
	=
	assert(false, "bug: unexpected function call", false)
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR BINARY I-TYPE OPERATIONS

%% BINARY AGGREGATION
%
function DEOPT_INFLUENCE: iAggregate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
	=
	if 		getAggregation(itype) == ITYPE_AGGREGATION_OR
	then	(iblock: [max(x.iblock[1], y.iblock[1])])
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_AND
	then	(iblock: [x.iblock[1] * y.iblock[1]])
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;

%
function var DEOPT_INFLUENCE: iAggregate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)"
	=
	if 		getAggregation(itype) == ITYPE_AGGREGATION_OR
	then	(iblock: [max(x.iblock[1], y.iblock[1])])
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_AND
	then	(iblock: [x.iblock[1] * y.iblock[1]])
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;


%% BINARY PROPAGATION
%
function DEOPT_INFLUENCE: iPropagate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	if 		getPropagation(itype) == ITYPE_PROPAGATION_OR
	then	(iblock: [max(x.iblock[1], y.iblock[1])])
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_AND
	then	(iblock: [x.iblock[1] * y.iblock[1]])
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;

%
function var DEOPT_INFLUENCE: iPropagate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)"
	=
	if 		getPropagation(itype) == ITYPE_PROPAGATION_OR
	then	(iblock: [max(x.iblock[1], y.iblock[1])])
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_AND
	then	(iblock: [x.iblock[1] * y.iblock[1]])
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;