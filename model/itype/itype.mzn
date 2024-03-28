%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% I-TYPE API IMPLEMENTATION
%
%	- Implements part of I-TYPE API
%		- RANGES
%			- SORT
%			- IBLOCK_COMPONENT
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
%
%	- Implements part of ALGEBRA IMPLEMENTATION API
%		- PAR/VAR ALGEBRAIC RELATIONS 
%			- equals (par)
%			- equals (var)
%   - PAR/VAR ALGEBRAIC OPERATIONS
%			- operation1 (par)
%			- operation2 (par)
%			- operation1 (var)
%			- operation2 (var)
%
%	- Uses I-TYPE IMPLEMENTATION API
%		-	BULIT-IN TYPE
%			-	itype_nr_sorts
%		- OBJECTS
%			- itype_signature
%			- itype_domains
%			- itype_algebra
%		- PAR/VAR ALGEBRAIC RELATIONS 
%			- iEquals (par)
%			- iEquals (var)
%		- PAR/VAR BINARY INFLUENCE OPERATIONS
%			-	iAggregate (par)
%			-	iPropagate (par)
%			-	iAggregate (var)
%			-	iPropagate (var)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../algebra/algebra_imp_api.mzn";
include "./../itype/itype_api.mzn";

include "./../itype/itype_imp_api.mzn";
include "./../ranges/ranges_api.mzn";
include "./../ranges/ranges.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA BUILD

% Proper range of sorts
SORT = _buildSortRange(itype_nr_sorts);

% Number of components in i-blocks
int: _nr_iblock_components = _buildNrIBlockComponents(itype_signature);

% Range of i-block components
IBLOCK_COMPONENT = _buildBlockComponentRange(_nr_iblock_components);

% I-block type of the i-type
IBLOCK_TYPE: _iblock_type = _buildIBlockType(IBLOCK_COMPONENT, itype_signature, itype_domains);

% Algebraic operations map of the i-type
array[ITYPE_OPERATION_CLASS] of ALGEBRAIC_OPERATION: _algebraic_operations = _buildAlgebraicOperationsMap(itype_domains);

% Algebra of the i-type
ALGEBRA: _algebra = _buildAlgebra(itype_signature, _iblock_type, itype_algebra);

% E-algebra of the i-type
E_ALGEBRA: _ealgebra = _buildITypeEalgebra(_algebra, _algebraic_operations, itype_algebra);

% I-type
itype = (signature: itype_signature, domains: itype_domains, iblock_type: _iblock_type, algebraic_operations: _algebraic_operations, ealgebra: _ealgebra);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

% Checks consistency of i-type
function bool: assertIType(ITYPE: it)
	:: "function assertIType($it): asserts consistency of i-type $it"
	=
			assertITypeSignature(it)
	/\		assertITypeStructure(it)
	/\		assertITypeAlgebra(it)
;
		
% Checks consistency of i-type signature
function bool: assertITypeSignature(ITYPE: it)
	:: "function assertITypeSignature($it): asserts signature consistency of i-type $it"
	=
			assert(getNumberOfSorts(it) > 0, "(1-1) at least one sort must be specified")
	/\		assert(isProperRange(index_set(getSorts(it))), "(1-2) index set of sorts must be a proper range")
% 	/\		assert(isSingleSorted(it) <-> getCategory(it) == getSorts(it)[1], "(2-1) if the i-type is single-sorted then its sort must be set to its category")
	/\		assert(isAggregationOperation(getAggregation(it)), "(3-1) one aggregation operation must be selected")
	/\		assert(isPropagationOperation(getPropagation(it)), "(3-2) one propagation operation must be selected")
;
		
% Checks consistency of i-type structure
function bool: assertITypeStructure(ITYPE: it)
	:: "function assertITypeStructure($it): asserts structure consistency of i-type $it"
	=
			assert(length(getDomainsCardinalities(it)) > 0, "(1-1) at least one subcategory must be specified")
	/\		assert(isProperRange(index_set(getDomainsCardinalities(it))), "(1-2) index set of domain cardinalities must be a proper range")
	/\		assert(index_set(getSorts(it)) == index_set(getDomainsCardinalities(it)), "(2-1) index sets for sorts and cardinalities must agree")
			%TODO extend for ranges
	/\		assert(forall(i in index_set(getSorts(it)) where isBuiltInSort(getSorts(it)[i]))(absent(getDomainsCardinalities(it)[i])), "(3-1) domain cardinalities must be set consistently with signature sorts according to specification")
	/\		assert(forall(i in index_set(getSorts(it)) where not(isBuiltInSort(getSorts(it)[i])))((getDomainsCardinalities(it)[i] default 1) > 0), "(3-2) domain cardinality must be >0 for non buil-int types")
			%TODO could optionally do type checking per component ...
;

% Checks consistency of i-type algebra
function bool: assertITypeAlgebra(ITYPE: it)
	:: "function assertIType($it): asserts algebraic properties of i-type $it"
	=
	%	consistency of e-algebra
	assertAlgebra(getAlgebra(it)) /\
			
	%% COMMUTATIVE MONOID FOR AGGREGATION
	% associativity of aggregation
	assert(isAssociative(getAlgebra(it), getAlgebraicAggregation(it)), "aggregation must be associative") /\

	% existence of neutral element for aggregation
	assert(hasNeutralElement(getAlgebra(it), getAlgebraicAggregation(it)), "aggregation must have neutral element") /\
	
	% commutativity of aggregation
	assert(isCommutative(getAlgebra(it), getAlgebraicAggregation(it)), "aggregation must be commutative") /\

	%% COMMUTATIVE SEMI-GROUP FOR PROPAGATION
	% associativity of propagation
	assert(isAssociative(getAlgebra(it), getAlgebraicPropagation(it)), "propagation must be associative") /\
	
	% commutativity of propagation
	assert(isCommutative(getAlgebra(it), getAlgebraicPropagation(it)), "propagation must be commutative") /\

	%% COMMUTATIVE MONOID FOR PROPAGATION (!! TODO could be dropped and only required using dedicated feature)
	% TODO assert existence of neutral element for propagation if required based on feature => define this feature
	assert(hasNeutralElement(getAlgebra(it), getAlgebraicPropagation(it)), "propagation must have neutral element") /\

	%% COMMUTATIVE SEMI-RING
	% !! DISTRIBUTIVITY OF PROPAGATION OVER AGGREGATION IS ASSUMED - could be checked on enums
			
	% EXISTENCE OF NULL ELEMENT, IE. BOTH NEUTRAL FOR AGGREGATION AND ABSORBING FOR PROPAGATION 		
	% existence of absorbing element for propagation
	assert(hasAbsorbingElement(getAlgebra(it), getAlgebraicPropagation(it)), "propagation must have absorbing element") /\
	
	% neutral element for aggregation must be absorbing element for propagation
	assert(equals(_toInfluence(it, getNeutralElement(getAlgebra(it), getAlgebraicAggregation(it))), _toInfluence(it, getAbsorbingElement(getAlgebra(it), getAlgebraicPropagation(it)))), "existence of *null* element: neutral element for aggregation must be absorbing for propagation") /\
			
	%% VIRTUALITY OF NULL ELEMENT
	% virtuality of neutral element for aggregation (and due to above assertion, virtuality of absorbant for propagation) if optionality
% 	assert(isOptType(it), "bug: 1") /\
% 	assert(false, "bug: 2\t" ++ show(getAlgebraicAggregation(it))) /\
% 	assert(false, "bug: 2-1\t" ++ show(getNeutralElement(getAlgebra(it), getAlgebraicAggregation(it)))) /\
% 	assert(false, "bug: 3\t" ++ show(_toInfluence(it, getNeutralElement(getAlgebra(it), getAlgebraicAggregation(it))))) /\
% 	assert(false, "bug: 4\t" ++ show(isVirtualInfluence(_toInfluence(it, getNeutralElement(getAlgebra(it), getAlgebraicAggregation(it)))))) /\
	assert(isOptType(it) <-> isVirtualInfluence(_toInfluence(it, getNeutralElement(getAlgebra(it), getAlgebraicAggregation(it)))), "bug: the null element should be virtual if i-type is an option type")
			
	% TODO could assert other optional properties using dedicated features such as invertibility to achieve ring or field structures 
;
	
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GETTERS / CHECKERS

%%%%%%%
%
function bool: isBuiltInSort(ITYPE_SORT: sort)
	:: "function isBuiltInSort($sort): checks whether sort $sort is built on built-in domain (bool or int) or not (enum or range (set of ints))"
	=
	sort in {
		ITYPE_SORT_BOOL, % TODO extend
	}
;

%
function bool: isAggregationOperation(ITYPE_OPERATION: op)
	:: "function isAggregationOperation($op): checks whether i-type operation $op is an aggregation operation or not"
	=
	op in {
		ITYPE_AGGREGATION_ENUM,
		ITYPE_AGGREGATION_AND,
		ITYPE_AGGREGATION_OR,
		ITYPE_AGGREGATION_PLUS,
		ITYPE_AGGREGATION_TIMES,
		ITYPE_AGGREGATION_MIN,
		ITYPE_AGGREGATION_MAX,
	% 	ITYPE_AGGREGATION_MEAN,
		}
;

%
function bool: isPropagationOperation(ITYPE_OPERATION: op)
	:: "function isPropagationOperation($op): checks whether i-type operation $op is a propagation operation or not"
	=
	op in {
		ITYPE_PROPAGATION_ENUM,
		ITYPE_PROPAGATION_AND,
		ITYPE_PROPAGATION_OR,
		ITYPE_PROPAGATION_PLUS,
		ITYPE_PROPAGATION_TIMES,
		ITYPE_PROPAGATION_MIN,
		ITYPE_PROPAGATION_MAX,
	% 	ITYPE_PROPAGATION_MEAN,
	}
;


%%%%%%%
%
function ITYPE_CATEGORY: getCategory(ITYPE: it)
	:: "function getCategory($it): returns the category of i-type $it"
	=
	it.signature.category
;

%
function int: getNumberOfSorts(ITYPE: it)
	:: "function getNumberOfSorts($it): returns the number of sorts of i-type $it"
	=
	length(it.signature.sorts)
;

%
function array[SORT] of ITYPE_SORT: getSorts(ITYPE: it)
	:: "function getSorts($it): returns the tuple of sorts of i-type $it"
	=
	it.signature.sorts
;

%
function ITYPE_OPERATION: getAggregation(ITYPE: it)
	:: "function getAggregation($it): returns the aggregation operation of i-type $it"
	=
	it.signature.operations[ITYPE_AGGREGATION]
;

%
function ITYPE_OPERATION: getPropagation(ITYPE: it)
	:: "function getPropagation($it): returns the propagation operation of i-type $it"
	=
	it.signature.operations[ITYPE_PROPAGATION]
;

%
function array[SORT] of opt int: getDomainsCardinalities(ITYPE: it)
	:: "function getDomainsCardinalities($it): returns the tuple of domain cardinalities of i-type $it"
	=
	it.domains.cardinalities
;

%
function int: getBlockTypeLength(ITYPE: it)
	:: "function getBlockTypeLength($it): returns the length of the i-block type for i-type $it"
	=
	length(it.iblock_type.sorts)
;

%
function array[IBLOCK_COMPONENT] of ITYPE_SORT: getBlockTypeSorts(ITYPE: it)
	:: "function getBlockTypeSorts($it): returns the tuple of sorts of the i-block type for i-type $it"
	=
	it.iblock_type.sorts
;

%
function array[IBLOCK_COMPONENT] of opt int: getBlockTypeSizes(ITYPE: it)
	:: "function getBlockTypeSizes($it): returns the tuple of sizes of the i-block type for i-type $it"
	=
	it.iblock_type.sizes
;

%
function E_ALGEBRA: getAlgebra(ITYPE: it)
	:: "function getAlgebra($it): returns the algebra of i-type $it"
	=
	it.ealgebra
;

%
function ALGEBRAIC_OPERATION: getAlgebraicAggregation(ITYPE: it)
	:: "function getAlgebraicAggregation($it): returns the algebraic aggregation operation of i-type $it"
	=
	it.algebraic_operations[ITYPE_AGGREGATION]
;

%
function ALGEBRAIC_OPERATION: getAlgebraicPropagation(ITYPE: it)
	:: "function getAlgebraicPropagation($it): returns the algebraic propagation operation of i-type $it"
	=
	it.algebraic_operations[ITYPE_PROPAGATION]
;

%
function bool: isSingleSorted(ITYPE: it)
	:: "function isSingleSorted($it): checks whether i-type $it is single-sorted or many-sorted"
	=
	getNumberOfSorts(it) == 1
;

%
function bool: hasNoBuiltInSort(ITYPE: it)
	:: "function hasNoBuiltInSort($it): checks whether i-type $it has no built-in sort"
	=
	forall(i in index_set(getSorts(it)))(not(isBuiltInSort(getSorts(it)[i])))
;

%
function bool: isPolySort(ITYPE: it)
	:: "function isPolySort($it): checks whether i-type $it has different sorts"
	=
	exists(i,j in index_set(getSorts(it)) where i<j)(getSorts(it)[i] != getSorts(it)[j])
;

%
function bool: isOptType(ITYPE: it)
	:: "function isOptType($it): checks whether i-type $it is an opt type, ie. its null element is virtual"
	=
	isOptAlgebra(getAlgebra(it))
;

%
function bool: isEqualityIdentityOverIType(ITYPE: it)
	:: "function isEqualityIdentityOverIType($it): checks whether equality is identity over i-type $it"
	=
	isEqualityIdentity(getAlgebra(it))
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE ELEMENTS 

%
function INFLUENCE: getNullInfluence(ITYPE: it)
	:: "getNullInfluence($it): returns the null influence over i-type $it - (par)"
	=
	_toInfluence(it, getNeutralElement(getAlgebra(it), getAlgebraicAggregation(it)))
;

%
function bool: isNullInfluenceVirtual(ITYPE: it)
	:: "isNullInfluenceVirtual($it): checks whether the null influence over i-type $it is virtual"
	=
	isVirtualElement(_toAlgebra(it, getNullInfluence(it)))
;


%%%%%%%

%
function bool: isNullInfluence(INFLUENCE: x)
	:: "isNullInfluence($x): checks whether $x is the null influence over i-type of $x - (par)"
	=
	let {
		bool: precond1 = _typeCheckInfluence(x);
	} in
		equals(x, getNullInfluence(itype)) % GLOBAL
;
	
%
function var bool: isNullInfluence(var INFLUENCE: x)
	:: "isNullInfluence($x): checks whether $x is the null influence over i-type of $x - (var)"
	=
	let {
		constraint _typeCheckInfluence(x);
	} in
		equals(x, getNullInfluence(itype)) % GLOBAL
;

%
function bool: isVirtualInfluence(INFLUENCE: x)
	:: "isVirtualInfluence($x): checks whether $x is the virtual influence over i-type of $x (par)"
	=
	let {
		bool: precond1 = _typeCheckInfluence(x);
	} in
	isVirtualElement(_toAlgebra(itype, x)) % GLOBAL
;

%
function var bool: isVirtualInfluence(var INFLUENCE: x)
	:: "isVirtualInfluence($x): checks whether $x is the virtual influence over i-type of $x (var)"
	=
	let {
		constraint _typeCheckInfluence(x);
	} in
	isVirtualElement(_toAlgebra(itype, x)) % GLOBAL
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: equals(INFLUENCE: x, INFLUENCE: y)
	:: "equals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
	=
	let {
		bool: precond1 = _typeCheckInfluence(x, y);
	} in
		if	(isVirtualInfluence(x) \/ isVirtualInfluence(y)) \/ isEqualityIdentityOverIType(itype) % GLOBAL
		then	x.iblock == y.iblock % TODO true <-> both arrays have the same optionality??
		else	iEquals((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock)))
		endif
	;

%
function var bool: equals(var INFLUENCE: x, var INFLUENCE: y)
	:: "equals($x,$y): checks whether equality relation holds between $x and $y over i-type $x.itype - (var)"
	=
	let {
		constraint _typeCheckInfluence(x, y);
	} in
		if	(isVirtualInfluence(x) \/ isVirtualInfluence(y)) \/ isEqualityIdentityOverIType(itype) % GLOBAL
		then	x.iblock == y.iblock % TODO true <-> both arrays have the same optionality??
		else	iEquals((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock)))
		endif
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE OPERATIONS 

%
function INFLUENCE: aggregate(INFLUENCE: x, INFLUENCE: y)
	:: "aggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
	=
	let {
		bool: precond1 = _typeCheckInfluence(x, y);
	} in
		if 		isNullInfluence(x) % hence neutral for aggregation
		then y
		elseif	isNullInfluence(y)
		then x
		else		% neither x or y null, thus none of them virtual 
					iAggregate((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock)))
		endif
	;

%
function INFLUENCE: propagate(INFLUENCE: x, INFLUENCE: y)
	:: "propagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	let {
		bool: precond1 = _typeCheckInfluence(x, y);
	} in
		if 		isNullInfluence(x) % hence absorbing for propagation
		then x
		elseif	isNullInfluence(y)
		then y
		else		% neither x or y null, thus none of them virtual 
					iPropagate((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock)))
		endif
	;

%
function var INFLUENCE: aggregate(var INFLUENCE: x, var INFLUENCE: y)
	:: "aggregate($x,$y): aggregate $x with $y over i-type of $x - (var)"
	=
	let {
		constraint _typeCheckInfluence(x, y);
		var INFLUENCE: z;
		constraint isNullInfluence(x) -> z == y; % null neutral for aggregation
		constraint isNullInfluence(y) -> z == x; % null neutral for aggregation
		constraint not(isNullInfluence(x) \/ isNullInfluence(y)) -> z == iAggregate((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock))) % TODO dangerous
	} in
		z
	;

%
function var INFLUENCE: propagate(var INFLUENCE: x, var INFLUENCE: y)
	:: "propagate($x,$y): propagate $x with $y over i-type of $x - (var)"
	=
	let {
		constraint _typeCheckInfluence(x, y);
		var INFLUENCE: z;
		constraint isNullInfluence(x) -> z == x; % null absorbing for propagation
		constraint isNullInfluence(y) -> z == y; % null absorbing for propagation
% 		constraint not(isNullInfluence(x) \/ isNullInfluence(y)) -> z == (iblock: iPropagate((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock))).iblock)
		constraint not(isNullInfluence(x) \/ isNullInfluence(y)) -> z == iPropagate((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock)));
		constraint z == iPropagate((iblock: deopt(x.iblock)), (iblock: deopt(y.iblock)));
	} in
		z %:: defines_var(z)
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC RELATIONS 

%
function bool: equality(A_ELEMENT: x, A_ELEMENT: y)
	:: "equality($x,$y): checks whether equality relation holds between $x and $y over algebra of $x - (par)"
	=
	equals(_toInfluence(itype, x), _toInfluence(itype, y)) % GLOBAL
	;

%
function var bool: equality(var A_ELEMENT: x, var A_ELEMENT: y)
	:: "equality($x,$y): checks whether equality relation holds between $x and $y over algebra of $x - (var)"
	=
	equals(_toInfluence(itype, x), _toInfluence(itype, y)) % GLOBAL
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC OPERATIONS 

%
function A_ELEMENT: operation1(A_ELEMENT: x, A_ELEMENT: y)
	:: "operation1($x,$y): $x AND $y over algebra of $x - (par)"
	=
	if	getAlgebraicAggregation(itype) == ALGEBRAIC_OPERATION_1 % could be avoided
	then	_toAlgebra(itype, aggregate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	else	_toAlgebra(itype, propagate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	endif
	;

%
function A_ELEMENT: operation2(A_ELEMENT: x, A_ELEMENT: y)
	:: "operation2($x,$y): $x OR $y over algebra of $x - (par)"
	=
	if	getAlgebraicAggregation(itype) == ALGEBRAIC_OPERATION_2 % could be avoided
	then	_toAlgebra(itype, aggregate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	else	_toAlgebra(itype, propagate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	endif
	;

%
function var A_ELEMENT: operation1(var A_ELEMENT: x, var A_ELEMENT: y)
	:: "operation1($x,$y): $x AND $y over algebra of $x - (var)"
	=
	if	getAlgebraicAggregation(itype) == ALGEBRAIC_OPERATION_1 % could be avoided
	then	_toAlgebra(itype, aggregate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	else	_toAlgebra(itype, propagate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	endif
	;
	
%
function var A_ELEMENT: operation2(var A_ELEMENT: x, var A_ELEMENT: y)
	:: "operation2($x,$y): $x OR $y over algebra of $x - (var)"
	=
	if	getAlgebraicAggregation(itype) == ALGEBRAIC_OPERATION_2 % could be avoided
	then	_toAlgebra(itype, aggregate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	else	_toAlgebra(itype, propagate(_toInfluence(itype, x), _toInfluence(itype, y))) % GLOBAL
	endif
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE BUILD

%%%%%%%
% Build range of sorts
function set of int: _buildSortRange(int: itype_nr_sorts)
	=
	let {
		bool: precond1 = assert(itype_nr_sorts > 0, "(1) the number of sorts must be >0");
	} in
	1..itype_nr_sorts
	;

%%%%%%%
% Build number of encoding components for array of sorts
function int: _buildNrIBlockComponents(ITYPE_SIGNATURE: signature)
	=
	let {
		bool: precond1 = assert(length(signature.sorts) > 0, "(1) i-type must include at least one sort");
	} in
	_buildNrIBlockComponents(signature.sorts)
	;

% Build number of encoding components for array of sorts
function int: _buildNrIBlockComponents(array[int] of ITYPE_SORT: sorts)
	=
	let {
		bool: precond1 = assert(length(sorts) > 0, "(1) bug - at least one sort");
		int: minS = min(index_set(sorts));
		int: maxS = max(index_set(sorts));
	} in
	if length(sorts) == 1
	then	_buildNrIBlockComponent(sorts[minS])
	else	_buildNrIBlockComponent(sorts[minS]) + _buildNrIBlockComponents(sorts[minS<..maxS])
	endif
	;

% Build number of encoding components for sort
function int: _buildNrIBlockComponent(ITYPE_SORT: sort)
	=
	if 		sort == ITYPE_SORT_ENUM
	then		1
	elseif	sort == ITYPE_SORT_BOOL
	then		1
	elseif	sort == ITYPE_SORT_RATIONAL
	then		2
	else		assert(false, "bug - incomplete implementation", 0)
	endif
	;

%%%%%%%
% Build range of encoding components for array of sorts
function set of int: _buildBlockComponentRange(int: nr_iblock_components)
	=
	let {
		bool: precond1 = assert(nr_iblock_components > 0, "(1) bug - the number of i-block components must be >0");
	} in
	1..nr_iblock_components
	;

%%%%%%%
% Build i-block type from i-type signature and domains
function IBLOCK_TYPE: _buildIBlockType(set of int: IBLOCK_COMPONENT, ITYPE_SIGNATURE: signature, ITYPE_DOMAINS: domains)
	=
	let {
		bool: precond1 = assert(isProperRange(IBLOCK_COMPONENT), "(1) IBLOCK_COMPONENT must be a proper range");
		array[int] of ITYPE_SORT: sorts = _buildIBlockTypeSorts(signature.sorts, domains.cardinalities);
		array[int] of opt int: sizes = _buildIBlockTypeSizes(signature.sorts, domains.cardinalities);
		bool: precond2 = assert(index_sets_agree(sorts, IBLOCK_COMPONENT), "(2) index set of i-block sorts must be IBLOCK_COMPONENT");
		bool: precond3 = assert(index_sets_agree(sizes, IBLOCK_COMPONENT), "(3) index set of i-block sizes must be IBLOCK_COMPONENT");
	} in
		(sorts: sorts, sizes: sizes)
	;

% Build array of sorts for i-block type from i-type signature's array of sorts and i-type domains' array of cardinalities
function array[int] of ITYPE_SORT: _buildIBlockTypeSorts(array[int] of ITYPE_SORT: sorts, array[int] of opt int: cardinalities)
	=
	let {
		bool: precond1 = assert(index_sets_agree(sorts, cardinalities), "(1) index sets of i-type sorts and domain cardinalities must agree");
		int: minS = min(index_set(sorts));
		int: maxS = max(index_set(sorts));
	} in
	if length(sorts) == 1
	then	_buildIBlockTypeSort(sorts[minS], cardinalities[minS])
	else	_buildIBlockTypeSort(sorts[minS], cardinalities[minS]) ++ _buildIBlockTypeSorts(sorts[minS<..maxS], cardinalities[minS<..maxS])
	endif
	;

% Build array of sorts from sort and domain cardinality
function array[int] of ITYPE_SORT: _buildIBlockTypeSort(ITYPE_SORT: sort, opt int: cardinality)
	=
	if 		sort == ITYPE_SORT_ENUM
	then		[sort]
	elseif	sort == ITYPE_SORT_BOOL
	then		[sort]
	elseif	sort == ITYPE_SORT_RATIONAL
	then		[sort, sort]
	else		assert(false, "bug - incomplete implementation", [])
	endif
	;

% Build array of sizes for i-block type from i-type signature's array of sorts and i-type domains' array of cardinalities
function array[int] of opt int: _buildIBlockTypeSizes(array[int] of ITYPE_SORT: sorts, array[int] of opt int: cardinalities)
	=
	let {
		bool: precond1 = assert(index_sets_agree(sorts, cardinalities), "(1) index sets of i-type sorts and domain cardinalities must agree");
		int: minS = min(index_set(sorts));
		int: maxS = max(index_set(sorts));
	} in
	if length(sorts) == 1
	then	_buildIBlockTypeSizes(sorts[minS], cardinalities[minS])
	else	_buildIBlockTypeSizes(sorts[minS], cardinalities[minS]) ++ _buildIBlockTypeSizes(sorts[minS<..maxS], cardinalities[minS<..maxS])
	endif
	;

% Build array of sizes from sort and domain cardinality
function array[int] of opt int: _buildIBlockTypeSizes(ITYPE_SORT: sort, opt int: cardinality)
	=
	if 		sort == ITYPE_SORT_ENUM
	then		[deopt(cardinality)]
	elseif	sort == ITYPE_SORT_BOOL
	then		[<>]
	elseif	sort == ITYPE_SORT_RATIONAL
	then		[<>, <>]
	else		assert(false, "bug - incomplete implementation", [])
	endif
	;

%%%%%%%
% Build 1-to-1 mapping between the i-type operations and their algebraic counterparts
function array[ITYPE_OPERATION_CLASS] of ALGEBRAIC_OPERATION: _buildAlgebraicOperationsMap(ITYPE_DOMAINS: domains)
	=
	array1d(ITYPE_OPERATION_CLASS, to_enum(ALGEBRAIC_OPERATION, [ITYPE_AGGREGATION, ITYPE_PROPAGATION]))
	;

%%%%%%%
% Build algebra for i-type
function ALGEBRA: _buildAlgebra(ITYPE_SIGNATURE: signature, IBLOCK_TYPE: iblock_type, ITYPE_ALGEBRA: itype_algebra)
	=
	let {
		array[int] of opt int: 	dimensions = iblock_type.sizes;
		bool: is_option_type = _setOptionType(itype_algebra);
% 		bool: precond1 = assert(false, show(if is_option_type then "TRUE" else "FALSE" endif));
		bool: equality_as_identity = _setEquality(signature);
	} in
		(dimensions: dimensions, is_option_type: is_option_type, equality_as_identity: equality_as_identity)
	;

%
function bool: _setOptionType(ITYPE_ALGEBRA: itype_algebra)
	=
	let {
		INFLUENCE: aggregation_neutral = itype_algebra.aggregation_neutral;
	} in
		exists(i in index_set(aggregation_neutral.iblock))(absent(aggregation_neutral.iblock[i]))
		%TODO enrich with feature
;

%
function bool: _setEquality(ITYPE_SIGNATURE: signature)
	=
	let {
		array[int] of ITYPE_SORT: sorts = signature.sorts;
	} in
		forall(i in index_set(sorts))(sorts[i] != ITYPE_SORT_RATIONAL)%TODO better model for equality as equivalence
	;

%%%%%%%
% Build e-algebra for i-type
function E_ALGEBRA: _buildITypeEalgebra(ALGEBRA: algebra, array[ITYPE_OPERATION_CLASS] of ALGEBRAIC_OPERATION: algebraic_operations, ITYPE_ALGEBRA: itype_algebra)
	=
	let {
% 		bool: precond1 = assert(index_set(itype_algebra.aggregation_absorbing) == IBLOCK_COMPONENT, "(1-1) index sets of algebraic elements and i-blocks must be equal");
% 		bool: precond2 = assert(index_sets_agree(itype_algebra.aggregation_absorbing, itype_algebra.propagation_absorbing), "(1-2) index sets of algebraic elements must agree");
% 		bool: precond3 = assert(index_sets_agree(itype_algebra.aggregation_absorbing, itype_algebra.propagation_neutral), "(1-3) index sets of algebraic elements must agree");
% 		bool: precond4 = assert(index_sets_agree(itype_algebra.aggregation_absorbing, itype_algebra.propagation_neutral), "(1-4) index sets of algebraic elements must agree");
		array[ALGEBRAIC_OPERATION, ALGEBRAIC_PROPERTY] of bool: properties = array2d(ALGEBRAIC_OPERATION, ALGEBRAIC_PROPERTY, [itype_algebra.properties[i,j] | h in ALGEBRAIC_OPERATION, i in ITYPE_OPERATION_CLASS, j in ALGEBRAIC_PROPERTY where algebraic_operations[i]==h]);

		array[int] of A_ELEMENT: itype_algebra_elements = [
			(algebra: algebra, value: itype_algebra.aggregation_absorbing.iblock),
			(algebra: algebra, value: itype_algebra.aggregation_neutral.iblock),
			(algebra: algebra, value: itype_algebra.propagation_absorbing.iblock),
			(algebra: algebra, value: itype_algebra.propagation_neutral.iblock)
			];
		array[ALGEBRAIC_OPERATION, ALGEBRAIC_ELEMENT] of A_ELEMENT: elements = array2d(ALGEBRAIC_OPERATION, ALGEBRAIC_ELEMENT, itype_algebra_elements);
	} in
		(algebra: algebra, 	properties: properties, elements: elements)
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE TYPE CHECKIING

%
function bool: _typeCheckInfluence(INFLUENCE: x)
	:: "_typeCheckInfluence($x): checks whether $x is well-typed - (par)"
	=
	%TODO solve this
	%TODO feature-enable these checks
	%assert(isVirtualElement(_toAlgebra(itype, x)) -> isOptAlgebra(itype.ealgebra), "(1-1) type checking: virtual influence over non-opt i-type (par)") /\ % GLOBAL
	%assert(isVirtualElement(_toAlgebra(itype, x)) -> equalAElements(_toAlgebra(itype, x), getNeutralElement(itype.ealgebra, itype.algebraic_operations[ITYPE_AGGREGATION])), "(1-2) type checking: virtual influence must be null (par)" ++ show(x) ++ show(equalAElements(_toAlgebra(itype, x), getNeutralElement(itype.ealgebra, itype.algebraic_operations[ITYPE_AGGREGATION])))) /\
	_typeCheckIblock(x.iblock, itype) % GLOBAL
	;


%
function var bool: _typeCheckInfluence(var INFLUENCE: x)
	:: "_typeCheckInfluence($x): checks whether $x is well-typed - (var)"
	=
	%TODO feature-enable these checks
		isVirtualElement(_toAlgebra(itype, x)) -> isOptAlgebra(itype.ealgebra) %, "(1-1) type checking: virtual influence over non-opt i-type (par)") /\ % GLOBAL
	/\isVirtualElement(_toAlgebra(itype, x)) -> equalAElements(_toAlgebra(itype, x), getNeutralElement(itype.ealgebra, itype.algebraic_operations[ITYPE_AGGREGATION])) %, "(1-2) type checking: virtual influence must be null (par)" ++ show(x) ++ show(equalAElements(_toAlgebra(itype, x), getNeutralElement(itype.ealgebra, itype.algebraic_operations[ITYPE_AGGREGATION])))) /\
	/\	_typeCheckIblock(x.iblock, itype) % GLOBAL
	;

%
function bool: _typeCheckInfluence(INFLUENCE: x, INFLUENCE: y)
	:: "_typeCheckInfluence($x,$y): checks whether $x and $y are consistently typed - (par)"
	=
	%TODO feature-enable these checks
	_typeCheckInfluence(x) /\
	_typeCheckInfluence(y)
	;

%
function var bool: _typeCheckInfluence(var INFLUENCE: x, var INFLUENCE: y)
	:: "_typeCheckInfluence($x,$y): checks whether $x and $y are consistently typed - (var)"
	=
	%TODO feature-enable these checks
	_typeCheckInfluence(x) /\
	_typeCheckInfluence(y)
	;

%
function bool: _typeCheckIblock(array[IBLOCK_COMPONENT] of opt int: iblock, ITYPE: it)
	:: "_typeCheckIblock($x,$it): checks whether $x i-block is encoded consistently with i-block type of itype $it - (par)"
	=
	let {
		array[IBLOCK_COMPONENT] of ITYPE_SORT: sorts = getBlockTypeSorts(it);
		array[IBLOCK_COMPONENT] of opt int: sizes = getBlockTypeSizes(it);
	} in
			assert(length(iblock) == getBlockTypeLength(itype), "(1) type checking: iblock of influence has not got the right length (par)")
		/\
			assert(forall(i in min(IBLOCK_COMPONENT)..<max(IBLOCK_COMPONENT))(occurs(iblock[i]) <-> occurs(iblock[i+1])), "(2) type checking: iblock components all occur or are all absent (par)")
		/\
			if	occurs(iblock[min(IBLOCK_COMPONENT)])
			then _typeCheckIblock(deopt(iblock), it)
			else true
			endif
	;

%
function bool: _typeCheckIblock(array[IBLOCK_COMPONENT] of int: iblock, ITYPE: it)
	:: "_typeCheckIblock($x,$it): checks whether $x deopt i-block is encoded consistently with i-block type of itype $it - (par)"
	=
	let {
		array[IBLOCK_COMPONENT] of ITYPE_SORT: sorts = getBlockTypeSorts(it);
		array[IBLOCK_COMPONENT] of opt int: sizes = getBlockTypeSizes(it);
	} in
			assert(
					forall(i in IBLOCK_COMPONENT)(
						if 		sorts[i] == ITYPE_SORT_ENUM
						then		iblock[i] in 1..deopt(sizes[i]) % native mzn int encoding
						elseif	sorts[i] == ITYPE_SORT_BOOL
						then		iblock[i] in 0..1 % pseudo-boolean encoding
						elseif	sorts[i] == ITYPE_SORT_RATIONAL
						then		true
						else 	false % "incomplete implementation"
						endif
					),
					"(1) type checking: inconsistent iblock component (par)")
%TODO carry on below: should build array mapping itype sorts and iblock sorts 
% 		/\
% 			assert(
% 					forall(i in SORT, j in IBLOCK_COMPONENT where i==ITYPE_SORT_RATIONAL /\ j==)(
% 						if 		sorts[i] == ITYPE_SORT_RATIONAL /\ 
% 						then		true
% 						else 	false % "incomplete implementation"
% 						endif
% 					),
% 					"(1) type checking: inconsistent iblock component (par)")		
% 				%TODO carry on ... check bounds on numerics, non-zero for denominators
	;

%
function var bool: _typeCheckIblock(array[IBLOCK_COMPONENT] of var opt int: iblock, ITYPE: it)
	:: "_typeCheckIblock($x,$it): checks whether $x i-block is encoded consistently with i-block type of itype $it - (var)"
	=
	let {
		array[IBLOCK_COMPONENT] of ITYPE_SORT: sorts = getBlockTypeSorts(it);
		array[IBLOCK_COMPONENT] of opt int: sizes = getBlockTypeSizes(it);
	} in
			length(iblock) == getBlockTypeLength(itype) %, "(1) type checking: iblock of influence has not got the right length (var)")
		/\
			forall(i in min(IBLOCK_COMPONENT)..<max(IBLOCK_COMPONENT))(occurs(iblock[i]) <-> occurs(iblock[i+1])) %, "(2) type checking: iblock components all occur or are all absent (var)")
		/\
			if	occurs(iblock[min(IBLOCK_COMPONENT)])
			then _typeCheckIblock(deopt(iblock), it)
			else true
			endif
	;

%
function var bool: _typeCheckIblock(array[IBLOCK_COMPONENT] of var int: iblock, ITYPE: it)
	:: "_typeCheckIblock($x,$it): checks whether $x deopt i-block is encoded consistently with i-block type of itype $it - (var)"
	=
	let {
		array[IBLOCK_COMPONENT] of ITYPE_SORT: sorts = getBlockTypeSorts(it);
		array[IBLOCK_COMPONENT] of opt int: sizes = getBlockTypeSizes(it);
	} in
					forall(i in IBLOCK_COMPONENT)(
						if 		sorts[i] == ITYPE_SORT_ENUM
						then		iblock[i] in 1..deopt(sizes[i]) % native mzn int encoding
						elseif	sorts[i] == ITYPE_SORT_BOOL
						then		iblock[i] in 0..1 % pseudo-boolean encoding
						elseif	sorts[i] == ITYPE_SORT_RATIONAL
						then		true
						else 	false % "incomplete implementation"
						endif
					)
					%,	"(1) type checking: inconsistent iblock component (var)")
%TODO carry on below: should build array mapping itype sorts and iblock sorts 
% 		/\
% 			assert(
% 					forall(i in SORT, j in IBLOCK_COMPONENT where i==ITYPE_SORT_RATIONAL /\ j==)(
% 						if 		sorts[i] == ITYPE_SORT_RATIONAL /\ 
% 						then		true
% 						else 	false % "incomplete implementation"
% 						endif
% 					),
% 					"(1) type checking: inconsistent iblock component (par)")		
% 				%TODO carry on ... check bounds on numerics, non-zero for denominators
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE CASTING

%
function INFLUENCE: _toInfluence(ITYPE: it, A_ELEMENT: x)
	:: "_toInfluence($it,x): casts algebraic element $x to influence of i-type $it - (par)"
	=
	(iblock: x.value)
	;

%
function var INFLUENCE: _toInfluence(ITYPE: it, var A_ELEMENT: x)
	:: "_toInfluence($it,x): casts algebraic element $x to influence of i-type $it - (var)"
	=
	(iblock: x.value)
	;

%
function A_ELEMENT: _toAlgebra(ITYPE: it, INFLUENCE: x)
	:: "_toAlgebra($x): casts influence $x to element of underlying algebra - (par)"
	=
	(algebra: it.ealgebra.algebra, value: x.iblock)
	;

%
function var A_ELEMENT: _toAlgebra(ITYPE: it, var INFLUENCE: x)
	:: "_toAlgebra($x): casts influence $x to element of underlying algebra - (var)"
	=
	(algebra: it.ealgebra.algebra, value: x.iblock)
	;
