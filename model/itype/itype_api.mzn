%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% I-TYPE API
%
%	- Uses ALGEBRA API
%		- ENUMERATIONS
%			- ALGEBRAIC_PROPERTY
%			- ALGEBRAIC_ELEMENT
%		- CLASSES
%			- E_ALGEBRA
%
%	- Defines
%		- ENUMERATIONS
%			- ITYPE_CATEGORY
%			- ITYPE_SORT
%			- ITYPE_OPERATION_CLASS
%			- ITYPE_OPERATION
%		- CLASSES
%			- ITYPE_SIGNATURE
%			- ITYPE_DOMAINS
%			- IBLOCK_TYPE
%			- ITYPE_ALGEBRA
%			- ITYPE
%			- INFLUENCE
%			- DEOPT_INFLUENCE
%		- TYPES
%			- IBLOCK_COMPONENT
%
%	- Declares
%		- OBJECTS
%			- itype
%		- ASSERTIONS
%			- assertIType
%			- assertITypeSignature
%			- assertITypeStructure
%			- assertITypeAlgebra
%		- GETTERS/CHECKERS
% 			- isBuiltInSort
% 			- isAggregationOperation
% 			- isPropagationOperation
% 			- getCategory
% 			- getNumberOfSorts
% 			- getSorts
% 			- getAggregation
% 			- getPropagation
% 			- getDomainsCardinalities
% 			- getBlockTypeLength
% 			- getBlockTypeSorts
% 			- getBlockTypeSizes
% 			- getAlgebra
% 			- getAlgebraicAggregation
% 			- getAlgebraicPropagation
% 			- isSingleSorted
% 			- hasNoBuiltInSort
% 			- isPolySort
% 			- isOptType
% 			- isEqualityIdentityOverIType
%		- PAR/VAR I-TYPE ELEMENTS 
%			- getNullInfluence (par)
%			- isNullInfluenceVirtual (par)
%			- isNullInfluence (par)
%			- isNullInfluence (var)
%			- isVirtualInfluence (par)
%			- isVirtualInfluence (var)
%		- PAR/VAR I-TYPE RELATIONS 
%			- equals (par)
%			- equals (var)
%   - PAR/VAR I-TYPE OPERATIONS
%			- aggregate (par)
%			- propagate (par)
%			- aggregate (var)
%			- propagate (var)
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../algebra/algebra_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES

% I-type categories
enum ITYPE_CATEGORY = {
	ITYPE_CATEGORY_SINGLE_SORTED,
	ITYPE_CATEGORY_MANY_SORTED_PRODUCT,
	ITYPE_CATEGORY_MANY_SORTED_NUMERIC,
	};

% I-type sorts
enum ITYPE_SORT = {
	ITYPE_SORT_ENUM,
	ITYPE_SORT_BOOL,
	ITYPE_SORT_RATIONAL,
% 	ITYPE_SORT_SCALE,
% 	ITYPE_SORT_RANGE,
	};

% Class of i-type operations
enum ITYPE_OPERATION_CLASS = {ITYPE_AGGREGATION, ITYPE_PROPAGATION};

% I-type operations
enum ITYPE_OPERATION = {
	ITYPE_AGGREGATION_ENUM,
	ITYPE_AGGREGATION_AND,
	ITYPE_AGGREGATION_OR,
	ITYPE_AGGREGATION_PLUS,
	ITYPE_AGGREGATION_TIMES,
	ITYPE_AGGREGATION_MIN,
	ITYPE_AGGREGATION_MAX,
% 	ITYPE_AGGREGATION_MEAN,
	ITYPE_PROPAGATION_ENUM,
	ITYPE_PROPAGATION_AND,
	ITYPE_PROPAGATION_OR,
	ITYPE_PROPAGATION_PLUS,
	ITYPE_PROPAGATION_TIMES,
	ITYPE_PROPAGATION_MIN,
	ITYPE_PROPAGATION_MAX,
% 	ITYPE_PROPAGATION_MEAN,
	};
	
% Proper range of sorts
set of int: SORT;

% Class for i-type signatures
type ITYPE_SIGNATURE = record(
	% the category of the i-type
	ITYPE_CATEGORY: category,
	% the tuple of sorts of the i-type
	array[SORT] of ITYPE_SORT: sorts,
	% the operations of the i-type
	array[ITYPE_OPERATION_CLASS] of ITYPE_OPERATION: operations,
);

% Class for i-type domains
type ITYPE_DOMAINS = record(
	% the cardinality of the domain associated with each sort:
	%		- set to <> if the domain is a built-in type
	% 		- otherwise, set to the cardinality of the corresponding user-defined enumeration or range
	array[SORT] of opt int: cardinalities,
);

% Proper range of i-block components
set of int: IBLOCK_COMPONENT;

% Class for i-block types
type IBLOCK_TYPE = record(
	array[IBLOCK_COMPONENT] of ITYPE_SORT: sorts,
	array[IBLOCK_COMPONENT] of opt int: sizes,
);

% Class for i-type algebraic structures
type ITYPE_ALGEBRA = record(
	% the algebraic properties of the i-type operations
	array[ITYPE_OPERATION_CLASS, ALGEBRAIC_PROPERTY] of bool: properties,
	% the algebraic elements of the i-type operations
	INFLUENCE: aggregation_absorbing,
	INFLUENCE: aggregation_neutral,
	INFLUENCE: propagation_absorbing,
	INFLUENCE: propagation_neutral,
);

% Class for i-types
type ITYPE = record(
	% the signature of the i-type
	ITYPE_SIGNATURE: signature,
	% the domains for the sorts of the i-type
	ITYPE_DOMAINS: domains,
	% the type of iblock to encode values (ie. influences) of the i-type
	IBLOCK_TYPE: iblock_type,
	% the 1-to-1 mapping between the i-type operations and their algebraic counterparts
	array[ITYPE_OPERATION_CLASS] of ALGEBRAIC_OPERATION: algebraic_operations,
	% the e-algebra mapping to the i-type
	E_ALGEBRA: ealgebra,
	);

% Class of influence objects (aka. i-objects)
type INFLUENCE = record(
	array[IBLOCK_COMPONENT] of opt int: iblock,
);

% Class of non-virtual i-objects
type DEOPT_INFLUENCE = record(
	% the array of non-optional integers encoding the influence value of the non-virtual i-object
	array[IBLOCK_COMPONENT] of int: iblock,
);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA

% The (single) i-type built using i-domain from instance data (see itype_domain_imp_api.mzn)
ITYPE: itype;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

%
function bool: assertIType(ITYPE: it) :: "function assertIType($it): asserts consistency of i-type $it";

% Checks consistency of i-type signature
function bool: assertITypeSignature(ITYPE: it)	:: "function assertITypeSignature($it): asserts signature consistency of i-type $it";
		
% Checks consistency of i-type structure
function bool: assertITypeStructure(ITYPE: it)	:: "function assertITypeStructure($it): asserts structure consistency of i-type $it";

% Checks consistency of i-type algebra
function bool: assertITypeAlgebra(ITYPE: it)	:: "function assertIType($it): asserts algebraic properties of i-type $it";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHECKERS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GETTERS / CHECKERS

%
function bool: isBuiltInSort(ITYPE_SORT: sort)	:: "function isBuiltInSort($sort): checks whether sort $sort is built on built-in domain (bool or int) or not (enum or range (set of ints))";

%
function bool: isAggregationOperation(ITYPE_OPERATION: op) :: "function isAggregationOperation($op): checks whether i-type operation $op is an aggregation operation or not";

%
function bool: isPropagationOperation(ITYPE_OPERATION: op)	:: "function isPropagationOperation($op): checks whether i-type operation $op is a propagation operation or not";

%
function ITYPE_CATEGORY: getCategory(ITYPE: it) :: "function getCategory($it): returns the category of i-type $it";

%
function int: getNumberOfSorts(ITYPE: it)	:: "function getNumberOfSorts($it): returns the number of sorts of i-type $it";

%
function array[SORT] of ITYPE_SORT: getSorts(ITYPE: it) :: "function getSorts($it): returns the tuple of sorts of i-type $it";

%
function ITYPE_OPERATION: getAggregation(ITYPE: it)	:: "function getAggregation($it): returns the aggregation operation of i-type $it";

%
function ITYPE_OPERATION: getPropagation(ITYPE: it)	:: "function getPropagation($it): returns the propagation operation of i-type $it";

%
function array[SORT] of opt int: getDomainsCardinalities(ITYPE: it)	:: "function getDomainsCardinalities($it): returns the tuple of domain cardinalities of i-type $it";

%
function int: getBlockTypeLength(ITYPE: it)	:: "function getBlockTypeLength($it): returns the length of the i-block type for i-type $it";

%
function array[IBLOCK_COMPONENT] of ITYPE_SORT: getBlockTypeSorts(ITYPE: it)	:: "function getBlockTypeSorts($it): returns the tuple of sorts of the i-block type for i-type $it";

%
function array[IBLOCK_COMPONENT] of opt int: getBlockTypeSizes(ITYPE: it)	:: "function getBlockTypeSizes($it): returns the tuple of sizes of the i-block type for i-type $it";

%
function E_ALGEBRA: getAlgebra(ITYPE: it)	:: "function getAlgebra($it): returns the algebra of i-type $it";

%
function ALGEBRAIC_OPERATION: getAlgebraicAggregation(ITYPE: it)	:: "function getAlgebraicAggregation($it): returns the algebraic aggregation operation of i-type $it";

%
function ALGEBRAIC_OPERATION: getAlgebraicPropagation(ITYPE: it)	:: "function getAlgebraicPropagation($it): returns the algebraic propagation operation of i-type $it";

%
function bool: isSingleSorted(ITYPE: it)	:: "function isSingleSorted($it): checks whether i-type $it is single-sorted or many-sorted";

%
function bool: hasNoBuiltInSort(ITYPE: it)	:: "function hasNoBuiltInSort($it): checks whether i-type $it has a non built-in sort";

%
function bool: isPolySort(ITYPE: it) :: "function isPolySort($it): checks whether i-type $it has different sorts";

%
function bool: isOptType(ITYPE: it)	:: "function isOptType($it): checks whether i-type $it is an opt type, ie. its null element is virtual";

%
function bool: isEqualityIdentityOverIType(ITYPE: it)	:: "function isEqualityIdentityOverIType($it): checks whether equality is identity over i-type $it";
	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE ELEMENTS 

%
function INFLUENCE: getNullInfluence(ITYPE: it) :: "getNullInfluence($it): returns the null influence over i-type $it - (par)";

%
function var INFLUENCE: getNullInfluence(ITYPE: it) :: "getNullInfluence($it): returns the null influence over i-type $it - (var)";

%
function var bool: isNullInfluenceVirtual(ITYPE: it) :: "isNullInfluenceVirtual($it): checks whether the null influence over i-type $it is virtual";

%
function bool: isNullInfluence(INFLUENCE: x) :: "isNullInfluence($x): checks whether $x is the null influence over i-type of $x - (par)";
	
%
function var bool: isNullInfluence(var INFLUENCE: x) :: "isNullInfluence($x): checks whether $x is the null influence over i-type of $x - (var)";

%
function bool: isVirtualInfluence(INFLUENCE: x) :: "isVirtualInfluence($x): checks whether $x is equal to the virtual influence over i-type of $x (par)";

%
function var bool: isVirtualInfluence(var INFLUENCE: x) 	:: "isVirtualInfluence($x): checks whether $x is equal to the virtual influence over i-type of $x (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: equals(INFLUENCE: x, INFLUENCE: y) :: "equals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)";

%
function var bool: equals(var INFLUENCE: x, var INFLUENCE: y) :: "equals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE OPERATIONS 

%
function INFLUENCE: aggregate(INFLUENCE: x, INFLUENCE: y) :: "aggregate($x,$y): aggregate $x with $y over i-type of $x - (par)";

%
function INFLUENCE: propagate(INFLUENCE: x, INFLUENCE: y) :: "propagate($x,$y): propagate $x with $y over i-type of $x - (par)";

%
function var INFLUENCE: aggregate(var INFLUENCE: x, var INFLUENCE: y) :: "aggregate($x,$y): aggregate $x with $y over i-type of $x - (var)";

%
function var INFLUENCE: propagate(var INFLUENCE: x, var INFLUENCE: y) :: "propagate($x,$y): propagate $x with $y over i-type of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT 

%
function string: showInfluence(INFLUENCE: x);

%
function array[int] of string: displayITypeHeader(ITYPE: it);

%
function array[int] of string: displayITypeSignature(ITYPE: it);

%
function array[int] of string: displayITypeDomains(ITYPE: it);

%
function array[int] of string: displayITypeBlockType(ITYPE: it);

%
function array[int] of string: displayITypeAlgebra(ITYPE: it);

%
function array[int] of string: displayITypeProperties(ITYPE: it);

%
function array[int] of string: displayITypeElements(ITYPE: it);

%
function array[int] of string: displayITypeAggregationOperation(ITYPE: it);

%
function array[int] of string: displayITypePropagationOperation(ITYPE: it);