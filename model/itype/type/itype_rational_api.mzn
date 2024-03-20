%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RATIONAL I-TYPE API
%
%	- Uses I-TYPE API
%		- OBJECTS
%			- itype
%
%	- Implements part of I-TYPE IMPLEMENTATION API
%		- OUTPUT
%			- iShow
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../../itype/itype_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

%
constraint
			assert(getCategory(itype) == ITYPE_CATEGORY_SINGLE_SORTED, "(1) implementation constraint - check i-type consistency of DZN files")
	/\		assert(isSingleSorted(itype), "(2) implementation constraint - check i-type consistency of DZN files")
	/\		assert(getSorts(itype)[1] == ITYPE_SORT_RATIONAL, "(3) implementation constraint - check i-type consistency of DZN files")
	
	/\		assert(getAggregation(itype) == ITYPE_AGGREGATION_PLUS <-> getPropagation(itype) == ITYPE_PROPAGATION_TIMES, "(4-1) implementation constraint - check consistency of DZN files")
	/\		assert(getAggregation(itype) == ITYPE_AGGREGATION_TIMES <-> getPropagation(itype) == ITYPE_PROPAGATION_PLUS, "(4-2) implementation constraint - check consistency of DZN files")
	/\		assert(getAggregation(itype) == ITYPE_AGGREGATION_MIN <-> getPropagation(itype) == ITYPE_PROPAGATION_MAX, "(4-3) implementation constraint - check consistency of DZN files")
	/\		assert(getAggregation(itype) == ITYPE_AGGREGATION_MAX <-> getPropagation(itype) == ITYPE_PROPAGATION_MIN, "(4-4) implementation constraint - check consistency of DZN files")

% 	/\		assert(getAggregation(itype) in {ITYPE_AGGREGATION_PLUS, ITYPE_AGGREGATION_TIMES}, "(4-5) implementation constraint - check consistency of DZN files")
	/\		assert(getAggregation(itype) in {ITYPE_AGGREGATION_PLUS, ITYPE_AGGREGATION_TIMES, ITYPE_AGGREGATION_MIN, ITYPE_AGGREGATION_MAX}, "(4-5) implementation constraint - check consistency of DZN files")

	/\		assert((getAggregation(itype) == ITYPE_AGGREGATION_TIMES /\ getPropagation(itype) == ITYPE_PROPAGATION_PLUS) -> isOptType(itype), "(5-1) implementation constraint - check consistency of DZN files")
	/\		assert((getAggregation(itype) == ITYPE_AGGREGATION_MIN /\ getPropagation(itype) == ITYPE_PROPAGATION_MAX) -> isOptType(itype), "(5-1) implementation constraint - check consistency of DZN files")
	/\		assert((getAggregation(itype) == ITYPE_AGGREGATION_MAX /\ getPropagation(itype) == ITYPE_PROPAGATION_MIN) -> isOptType(itype), "(5-1) implementation constraint - check consistency of DZN files")
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

% Getter for influence value symbol
function string: iShow(DEOPT_INFLUENCE: x)
	:: "iShow($x): returns string representation of non-virtual influence $x"
	=
	show(x.iblock[1]) ++ "/" ++ show(x.iblock[2])
	;
