%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% I-TYPE OUTPUT
%
% - Implements part of I-TYPE API
%		- OUTPUT
%			- showInfluence
%			- displayITypeHeader
%			- displayITypeSignature
%			- displayITypeDomains
%			- displayITypeBlockType
%			- displayITypeAlgebra
%			-	displayITypeProperties
%			-	displayITypeElements
%			- displayITypePropagationOperation
%			- displayITypeAggregationOperation
%
%	- Implements part of ALGEBRA IMPLEMENTATION API
%		- OUTPUT
%			- showNonVirtualElement
%
%	- Uses I-TYPE IMPLEMENTATION API
%		- PAR/VAR BINARY I-TYPE OPERATIONS
%			-	iAggregate (par)
%			-	iPropagate (par)
%		- OUTPUT
%			- iShow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../itype/itype_api.mzn";
include "./../algebra/algebra_imp_api.mzn";

include "./../itype/itype.mzn";
include "./../itype/itype_imp_api.mzn";
include "./../utils/utils_string.mzn"; % map2string



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function string: showNonVirtualElement(DEOPT_A_ELEMENT: x)
	=
	iShow(x.value) % GLOBAL
% 	iShow((iblock: x.value)) % GLOBAL
	;

%
function string: showInfluence(INFLUENCE: x)
	=
	if	isVirtualInfluence(x)
	then	"<>" % TODO on all components
	else	iShow(deopt(x.iblock))
% 	else	iShow((iblock: deopt(x.iblock)))
	endif
	;

%
function array[int] of string: displayITypeHeader(ITYPE: it)
	=
		["****** I-TYPE ***********"]
	++	["\n"]
	++	["Category:\t\t" ++ show(getCategory(it))]
	++	["\n"]
	++	["Many-sorted:\t\t" ++ show(not(isSingleSorted(it)))]
	++	["\n"]
	++	["Poly-sorted:\t\t" ++ show(isPolySort(it))]
	++	["\n"]
	++	["Option-type:\t\t" ++ show(isOptType(it))]
	++	["\n"]
	++	["Equality is identity:\t" ++ show(isEqualityIdentityOverIType(it))]
	++	["\n"]
;

%
function array[int] of string: displayITypeSignature(ITYPE: it)
	=
		["****** I-TYPE SIGNATURE ***********"]
	++	["\n"]
	++	["Number of sorts:\t" ++ show(getNumberOfSorts(it))]
	++	["\n"]
	++	["Tuple of sorts:\t\t" ++ show(getSorts(it))]
	++	["\n"]
	++	["Aggregation:\t\t" ++ show(getAggregation(it))]
	++	["\n"]
	++	["Propagation:\t\t" ++ show(getPropagation(it))]
	++	["\n"]
;

%
function array[int] of string: displayITypeDomains(ITYPE: it)
	=
		["****** I-TYPE DOMAINS ***********"]
	++	["\n"]
	++	["Tuple of sorts:\t\t" ++ show(getSorts(it))]
	++	["\n"]
	++	["Tuple of domains:\t" ++ show(getDomainsCardinalities(it))]
	++	["\n"]
;

%
function array[int] of string: displayITypeBlockType(ITYPE: it)
	=
		["****** I-TYPE BLOCK TYPE ***********"]
	++	["\n"]
	++	["Block length:\t\t" ++ show(getBlockTypeLength(it))]
	++	["\n"]
	++	["Array of sorts:\t\t" ++ show(getBlockTypeSorts(it))]
	++	["\n"]
	++	["Array of sizes:\t\t" ++ show(getBlockTypeSizes(it))]
	++	["\n"]
;

%
function array[int] of string: displayITypeAlgebra(ITYPE: it)
	=
		["****** I-TYPE ALGEBRA ***********"]
	++	["\n"]
	++	["Aggregation:\t\t" ++ show(getAlgebraicAggregation(it))]
	++	["\n"]
	++	["Propagation:\t\t" ++ show(getAlgebraicPropagation(it))]
	++	["\n"]
	++	displayITypeProperties(it)
	++	displayITypeElements(it)
;

%
function array[int] of string: displayITypeProperties(ITYPE: it) =
	let {
		array[int] of string: rows = map2string([getAggregation(it), getPropagation(it)]);
		array[int] of string: cols = map2string(set2array(ALGEBRAIC_PROPERTY));
		array[int, int] of string: names = array2d(ITYPE_OPERATION_CLASS, ALGEBRAIC_PROPERTY, [show(checkProperty(getAlgebra(it), i, j)) | i in ALGEBRAIC_OPERATION, j in ALGEBRAIC_PROPERTY]);
	} in
		[show2d_indexed(rows, cols, names)]
	++	["\n"]
;

%
function array[int] of string: displayITypeElements(ITYPE: it) =
	let {
		array[int] of string: rows = map2string([getAggregation(it), getPropagation(it)]);
		array[int] of string: cols = map2string(set2array(ALGEBRAIC_ELEMENT));
		array[int, int] of string: names = array2d(ITYPE_OPERATION_CLASS, ALGEBRAIC_ELEMENT, [showAlgebraElement(getElement(getAlgebra(it), i, j)) | i in ALGEBRAIC_OPERATION, j in ALGEBRAIC_ELEMENT]);
	} in
		[show2d_indexed(rows, cols, names)]
	++	["\n"]
;

%
function array[int] of string: displayITypeAggregationOperation(ITYPE: it)
	=
		["Aggregation:\t\t" ++ show(getAggregation(it))]
		%TODO show tables of enum operations
% % 	++	["\n"]
% 	++
% 		if hasNoBuiltInSort(it) /\ isSingleSorted(it)
% 		then
% 			let {
% 				array[int] of string: rows = array1d(IBLOCK_COMPONENT, [showInfluence((iblock:[i])) | i in IBLOCK_COMPONENT]);
% 				array[int] of string: cols = array1d(IBLOCK_COMPONENT, [showInfluence((iblock: [i])) | i in IBLOCK_COMPONENT]);
% 				array[int, int] of string: names = array2d(IBLOCK_COMPONENT, IBLOCK_COMPONENT, [showInfluence(iAggregate((iblock: [i]),(iblock: [j]))) | i,j in IBLOCK_COMPONENT]);
% 			} in
% 				[show2d_indexed(rows, cols, names)]
% 		else
% 			[""]
% 		endif
	++	["\n"]
	;

%
function array[int] of string: displayITypePropagationOperation(ITYPE: it)
	=
		["Propagation:\t\t" ++ show(getPropagation(it))]
		%TODO show tables of enum operations
% 	++	["\n"]
% 	++
% 		if hasNoBuiltInSort(it) /\ isSingleSorted(it)
% 		then
% 			let {
% 				array[int] of string: rows = array1d(IBLOCK_COMPONENT, [showInfluence((iblock:[i])) | i in IBLOCK_COMPONENT]);
% 				array[int] of string: cols = array1d(IBLOCK_COMPONENT, [showInfluence((iblock:[i])) | i in IBLOCK_COMPONENT]);
% 				array[int, int] of string: names = array2d(IBLOCK_COMPONENT, IBLOCK_COMPONENT, [showInfluence((iblock:iPropagate([i],[j]))) | i,j in IBLOCK_COMPONENT]);
% 			} in
% 				[show2d_indexed(rows, cols, names)]
% 		else
% 			[""]
% 		endif
	++	["\n"]
	;

