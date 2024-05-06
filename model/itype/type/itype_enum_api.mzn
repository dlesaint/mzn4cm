%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ENUMERATED I-TYPE API
%
%	- Uses I-TYPE API
%		- OBJECTS
%			- itype
%
%	- Implements part of I-TYPE IMPLEMENTATION API
%		- OUTPUT
%			- iShow
%
%	- Declares
%		- I-TYPE DOMAIN ELEMENTS
%			- ENUMERATIONS
%				- I_DOMAIN
%			- ARRAYS
%				- I_
%		- BINARY INFLUENCE OPERATIONS
%			- ARRAYS
%				- I_AGGREGATE
%				- I_PROPAGATE



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../../itype/itype_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% I-TYPE DOMAIN ELEMENTS

% I-type domain enumeration
enum I_DOMAIN;

% I-type element symbols
array[I_DOMAIN] of string: I_;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

%
constraint
			assert(getCategory(itype) == ITYPE_CATEGORY_SINGLE_SORTED, "(1) implementation constraint - check i-type consistency of DZN files")
	/\	assert(isSingleSorted(itype), "(2) implementation constraint - check i-type consistency of DZN files")
	/\	assert(getSorts(itype)[1] == ITYPE_SORT_ENUM, "(3) implementation constraint - check i-type consistency of DZN files")
	/\	assert(getAggregation(itype) == ITYPE_AGGREGATION_ENUM <-> getPropagation(itype) == ITYPE_PROPAGATION_ENUM, "(4-1) implementation constraint - check consistency of DZN files")
	/\	assert(getAggregation(itype) in {ITYPE_AGGREGATION_ENUM, ITYPE_PROPAGATION_ENUM}, "(4-2) implementation constraint - check consistency of DZN files")
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

% Getter for influence value symbol
function string: iShow(array[IBLOCK_COMPONENT] of int: x)
	:: "iShow($x): returns string representation of non-virtual influence $x"
	=
	I_[to_enum(I_DOMAIN, x[1])]
	;
