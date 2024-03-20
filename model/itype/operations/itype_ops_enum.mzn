%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ENUMERATION I-TYPE OPERATIONS
%
%	- Uses ENUMERATION I-TYPE API
%		- ENUMERATION
%			- I_DOMAIN
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

include "./../../itype/type/itype_enum_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BINARY INFLUENCE OPERATIONS

% Influence aggregation matrix
array[I_DOMAIN, I_DOMAIN] of I_DOMAIN: I_AGGREGATE;

% Influence propagation matrix
array[I_DOMAIN, I_DOMAIN] of I_DOMAIN: I_PROPAGATE;



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
	(iblock: [I_AGGREGATE[to_enum(I_DOMAIN, x.iblock[min(index_set(x.iblock))]), to_enum(I_DOMAIN, y.iblock[min(index_set(y.iblock))])]])
;
	
%
function var DEOPT_INFLUENCE: iAggregate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)"
	=
	(iblock: [I_AGGREGATE[to_enum(I_DOMAIN, x.iblock[min(index_set(x.iblock))]), to_enum(I_DOMAIN, y.iblock[min(index_set(y.iblock))])]])
;
	

%% BINARY PROPAGATION
%
function DEOPT_INFLUENCE: iPropagate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	(iblock: [I_PROPAGATE[to_enum(I_DOMAIN, x.iblock[min(index_set(x.iblock))]), to_enum(I_DOMAIN, y.iblock[min(index_set(y.iblock))])]])
;
	
%
function var DEOPT_INFLUENCE: iPropagate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)"
	=
	(iblock: [I_PROPAGATE[to_enum(I_DOMAIN, x.iblock[min(index_set(x.iblock))]), to_enum(I_DOMAIN, y.iblock[min(index_set(y.iblock))])]])
;
	

