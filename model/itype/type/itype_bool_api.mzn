%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BOOLEAN I-TYPE API
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
	/\		assert(getSorts(itype)[1] == ITYPE_SORT_BOOL, "(3) implementation constraint - check i-type consistency of DZN files")
	/\		assert(getAggregation(itype) == ITYPE_AGGREGATION_OR <-> getPropagation(itype) == ITYPE_PROPAGATION_AND, "(4-1) implementation constraint - check consistency of DZN files")
	/\		assert(getAggregation(itype) == ITYPE_AGGREGATION_AND <-> getPropagation(itype) == ITYPE_PROPAGATION_OR, "(4-2) implementation constraint - check consistency of DZN files")
	/\		assert(getAggregation(itype) in {ITYPE_AGGREGATION_OR, ITYPE_AGGREGATION_AND}, "(4-3) implementation constraint - check consistency of DZN files")
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

% Getter for influence value symbol
function string: iShow(DEOPT_INFLUENCE: x)
	:: "iShow($x): returns string representation of non-virtual influence $x"
	=
	show(if x.iblock[1]==1 then show(true) else show(false) endif)
	;
