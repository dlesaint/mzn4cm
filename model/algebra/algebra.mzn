%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ALGEBRA API IMPLEMENTATION
%
%	- Implements part of ALGEBRA API
%		- ALGEBRAIC ASSERTIONS
%			- assertAlgebra
%			- isEnumAlgebra
%			- isOptAlgebra
%			- isEqualityIdentity
%		- ALGEBRAIC PROPERTY CHECKING
%			- checkProperty
%			- isCommutative
%			- isAssociative
%			- hasAbsorbingElement
%			- hasNeutralElement
%		- ALGEBRAIC ELEMENTS
%			- getElement
%			- getAbsorbingElement
%			- getNeutralElement
%		- VIRTUAL AND UNDEFINED ELEMENTS
%			- getVirtualElement
%			- isVirtualElement (par)
%			- isVirtualElement (var)
%			- getUndefinedElement
%			- isUndefinedElement (par)
%		- CHECKERS 
%			- equalAlgebras (par)
%			- equalAElements (par)
%			- equalAElements (var)
%   - PAR/VAR ALGEBRAIC OPERATIONS
%			- operation (par)
%			- operation (var)
%
%	- Uses ALGEBRA IMPLEMENTATION API
%		- PAR/VAR ALGEBRAIC RELATIONS 
%			- equality (par)
%			- equality (var)
%   - PAR/VAR ALGEBRAIC OPERATIONS
%			- operation1 (par)
%			- operation1 (var)
%			- operation2 (par)
%			- operation2 (var)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../algebra/algebra_api.mzn";
include "../algebra/algebra_imp_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% META-ALGEBRAIC ASSERTIONS

%
function bool: assertAlgebra(E_ALGEBRA: ea)
	:: "function assertAlgebra($ea): asserts meta-properties of algebra $ea"
	=
	assert(length(ea.algebra.dimensions) > 0, "(1) number of algebra dimensions must be >0: " ++ show(ea.algebra.dimensions)) /\
	assert(isEnumAlgebra(ea) -> _assertEnumAlgebra(ea), "(2) inconsistent enumerated algebra: " ++ show(isEnumAlgebra(ea)) ++ show(_assertEnumAlgebra(ea)))
	%TODO more?
;

%
function bool: isEnumAlgebra(E_ALGEBRA: ea)
	:: "function isEnumAlgebra($al): checks whether none of the dimensions of algebra $ea is a built-in type"
	=
	card(index_set(ea.algebra.dimensions)) == 1 /\
	forall(i in index_set(ea.algebra.dimensions))(occurs(ea.algebra.dimensions[i]))
;

%
function bool: isOptAlgebra(E_ALGEBRA: ea)
	:: "function isOptAlgebra($al): checks whether algebra $ea is an option type, ie. it includes a virtual element"
	=
	ea.algebra.is_option_type
;

%
function bool: isEqualityIdentity(E_ALGEBRA: ea)
	:: "function isEqualityIdentity($al): checks whether equality is identity over algebra $ea"
	=
	ea.algebra.equality_as_identity
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALGEBRAIC PROPERTY CHECKING

% 
function bool: checkProperty(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao, ALGEBRAIC_PROPERTY: ap)
	:: "checkProperty($ea,$ao,$ap): checks algebraic property $ap of operation $ao over $ea"
	=
	if			ap == ALGEBRAIC_PROPERTY_COMMUTATIVITY
	then	isCommutative(ea, ao)
	elseif	ap == ALGEBRAIC_PROPERTY_ASSOCIATIVITY
	then	isAssociative(ea, ao)
	elseif	ap == ALGEBRAIC_PROPERTY_HAS_ABSORBING_ELEMENT
	then	hasAbsorbingElement(ea, ao)
	elseif	ap == ALGEBRAIC_PROPERTY_HAS_NEUTRAL_ELEMENT
	then	hasNeutralElement(ea, ao)
	else assert(false, "incomplete implementation", false)
	endif
;

%
function bool: isCommutative(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "isCommutative($ea,$ao): commutativity of operation $ao over $ea"
	=
	ea.properties[ao, ALGEBRAIC_PROPERTY_COMMUTATIVITY]
;

%
function bool: isAssociative(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "isAssociative($ea,$ao): associativity of operation $ao over $ea"
	=
	ea.properties[ao, ALGEBRAIC_PROPERTY_ASSOCIATIVITY]
;

%
function bool: hasAbsorbingElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "hasAbsorbingElement($ea,$ao): existence of absorbing element for operation $ao over $ea"
	=
	ea.properties[ao, ALGEBRAIC_PROPERTY_HAS_ABSORBING_ELEMENT]
;

%
function bool: hasNeutralElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "hasNeutralElement($ea,$ao): existence of neutral element for operation $ao over $ea"
	=
	ea.properties[ao, ALGEBRAIC_PROPERTY_HAS_NEUTRAL_ELEMENT]
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALGEBRAIC ELEMENTS

%
function A_ELEMENT: getElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao, ALGEBRAIC_ELEMENT: ae)
	:: "getElement($ea,$ao,$ae): returns element $ae of operation $ao over $ea"
	=
	if			ae == ALGEBRAIC_ELEMENT_ABSORBING
	then	getAbsorbingElement(ea, ao)
	elseif	ae == ALGEBRAIC_ELEMENT_NEUTRAL
	then	getNeutralElement(ea, ao)
	else assert(false, "incomplete implementation", getUndefinedElement(ea.algebra))
	endif
;

%
function A_ELEMENT: getAbsorbingElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "getAbsorbingElement($ea,$ao): returns absorbing element of operation $ao over $ea"
	=
	ea.elements[ao, ALGEBRAIC_ELEMENT_ABSORBING]
;

%
function A_ELEMENT: getNeutralElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "getNeutralElement($ea,$ao): returns neutral element of operation $ao over $ea"
	=
	ea.elements[ao, ALGEBRAIC_ELEMENT_NEUTRAL]
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VIRTUAL AND UNDEFINED ELEMENTS

%
function A_ELEMENT: getVirtualElement(E_ALGEBRA: ea)
	:: "getVirtualElement($ea): returns the virtual element of algebra $ea"
	=
	(algebra:ea.algebra, value:[<> | i in index_set(ea.algebra.dimensions)])
;

%
function bool: isVirtualElement(A_ELEMENT: x)
	:: "isVirtualElement($x): checks whether $x is virtual (par)"
	=
	forall(i in index_set(x.value))(
		absent(x.value[i])
	)
;

%
function var bool: isVirtualElement(var A_ELEMENT: x)
	:: "isVirtualElement($x): checks whether $x is virtual (var)"
	=
	forall(i in index_set(fix(x.algebra).dimensions))(
		absent(x.value[i])
	)
;
	
%
function A_ELEMENT: getUndefinedElement(ALGEBRA: al)
	:: "getUndefinedElement($al,$ao): returns undefined element over $al"
	=
	(algebra:al, value:[-1 | i in index_set(al.dimensions)]) % TODO switch to opt 'a' field
;

%
function bool: isUndefinedElement(A_ELEMENT: x)
	:: "isUndefinedElement($x): checks whether $x is undefined (par)"
	=
	forall(i in index_set(x.value))(
		x.value[i] == -1% TODO switch to opt 'a' field
	)
;
	
%
function var bool: isUndefinedElement(var A_ELEMENT: x)
	:: "isUndefinedElement($x): checks whether $x is undefined (var)"
	=
	forall(i in index_set(fix(x.algebra).dimensions))(
		x.value[i] == -1% TODO switch to opt 'a' field
	)
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECKERS

%
function bool: equalAlgebras(ALGEBRA: x, ALGEBRA: y)
	:: "equalAlgebras($x, $y): checks whether $x is equal to $y - (par)"
	=
		x.dimensions == y.dimensions
	/\	x.is_option_type == y.is_option_type
	/\	x.equality_as_identity == y.equality_as_identity
;

%
function bool: equalAElements(A_ELEMENT: x, A_ELEMENT: y)
	:: "equalAElements($x, $y): checks whether $x is equal to $y over algebra of $x - (par)"
	=
		equalAlgebras(x.algebra, y.algebra)
	/\	x.value == y.value
;

%
function var bool: equalAElements(var A_ELEMENT: x, var A_ELEMENT: y)
	:: "equalAElements($x, $y): checks whether $x is equal to $y over algebra of $x - (var)"
	=
		equalAlgebras(fix(x.algebra), fix(y.algebra))
	/\	x.value == y.value
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC OPERATIONS

%
function A_ELEMENT: operation(ALGEBRAIC_OPERATION: ao, A_ELEMENT: x, A_ELEMENT: y)
	:: "operation($ao,$x,$y): binary operation $x $ao $y over $x.algebra - (par)"
	=
	let {
		bool: precond1 = assert(not(isUndefinedElement(x) \/ isUndefinedElement(y)), "algebraic operation only supported on defined elements (par)");
		bool: precond2 = assert(equalAlgebras(x.algebra, y.algebra), "algebraic operation must be applied to elements from the same algebra (par)" ++ show(x) ++ show(y));
		bool: precond3 = assert((isVirtualElement(x) \/ isVirtualElement(y)) -> x.algebra.is_option_type, "arguments of non-optional algebra cannot apply to optional elements (par)" ++ show(x) ++ show(y));
	} in
		if			ao == ALGEBRAIC_OPERATION_1
		then	operation1(x, y)
		elseif	ao == ALGEBRAIC_OPERATION_2
		then	operation2(x, y)
		else	assert(false, "incomplete implementation", x)
		endif
;

%
function var A_ELEMENT: operation(ALGEBRAIC_OPERATION: ao, var A_ELEMENT: x, var A_ELEMENT: y)
	:: "operation($ao,$x,$y): binary operation $x $ao $y over $x.algebra - (var)"
	=
	let {
		constraint not(isUndefinedElement(x) \/ isUndefinedElement(y));
		bool: precond2 = assert(equalAlgebras(fix(x.algebra), fix(y.algebra)), "algebraic operation must be applied to elements belonging to the same algebraic structure (var)");
		constraint (isVirtualElement(x) \/ isVirtualElement(y)) -> fix(x.algebra).is_option_type;
	} in
		if			ao == ALGEBRAIC_OPERATION_1
		then	operation1(x, y)
		elseif	ao == ALGEBRAIC_OPERATION_2
		then	operation2(x, y)
		else	assert(false, "incomplete implementation", x)
		endif
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE

%
% function array[int] of int: encode(array[int] of int: dimensions, int: i)
% 	:: "TODO encode($dimensions): returns the cross-product of the proper ranges of cardinalities $dimensions"
% 	=
% 	let {
% 		bool: precond = assert(al.is_enum, "algebra must be enumerated");
% 		int: nr_dimensions = card(index_set(dimensions));
% 		int: nr_elements = product(i in index_set(dimensions))(dimensions[i]);
% 	} in
% 		if	nr_dimensions == 1
% 		then
% 			if	i == 1
% 			then [1]
% 			else 
% 		else	encode(dimensions
	

%%% ENUMERATED ALGEBRA GENERATOR 

%
function array[int] of A_ELEMENT: _generatorEnumAlgebra(E_ALGEBRA: ea)
	:: "_generatorEnumAlgebra($ea): returns the array of elements of enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
% 		int: nr_elements = product(i in index_set(ea.algebra.dimensions))(deopt(ea.algebra.dimensions[i]));
	} in
		if	ea.algebra.is_option_type
		then [getVirtualElement(ea)]
		else []
		endif
		++ [(algebra:ea.algebra, value:[i]) | i in 1..deopt(ea.algebra.dimensions[1])]%TODO lift to n dimensions
% 		++ [(algebra:ea.algebra, value:encode(ea.algebra.dimensions, i)) | i in 1..nr_elements]
;


%%% ENUMERATED ALGEBRA CHECKERS 

% checks consistency of algebraic descriptors for enumerated algebra $ea 
function bool: _assertEnumAlgebra(E_ALGEBRA: ea)
	:: "_assertEnumAlgebra($ea): checks consistency of descriptors for enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
	} in
		forall(i in index_set_1of2(ea.properties), j in index_set_2of2(ea.properties))(
			_checkPropertyEnumAlgebra(ea, i, j) == ea.properties[i,j]
			)
		/\
		forall(i in index_set_1of2(ea.properties))(
			let {
				A_ELEMENT: ga = _getAbsorbingElement(ea, i);
				A_ELEMENT: gn = _getNeutralElement(ea, i);
				A_ELEMENT: oa = ea.elements[i, ALGEBRAIC_ELEMENT_ABSORBING];
				A_ELEMENT: on = ea.elements[i, ALGEBRAIC_ELEMENT_NEUTRAL];
			} in
				((isUndefinedElement(ga) \/ isUndefinedElement(oa)) -> equalAElements(ga, oa)) /\ % == on option type pars is true only if same optionality
				(not(isUndefinedElement(ga) \/ isUndefinedElement(oa)) -> equality(ga, oa)) /\ % equality() handle optionality of null elements
				((isUndefinedElement(gn) \/ isUndefinedElement(on)) -> equalAElements(gn, on)) /\
				(not(isUndefinedElement(gn) \/ isUndefinedElement(on)) -> equality(gn, on))
			)
;

% checks algebraic property $ap of operation $ao over enumerated algebra $ea
function bool: _checkPropertyEnumAlgebra(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao, ALGEBRAIC_PROPERTY: ap)
	:: "_checkPropertyEnumAlgebra($ea,$ao,$ap): checks algebraic property $ap of operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
	} in
		if			ap == ALGEBRAIC_PROPERTY_COMMUTATIVITY
		then	_isCommutativeEnumAlgebra(ea, ao)
		elseif	ap == ALGEBRAIC_PROPERTY_ASSOCIATIVITY
		then	_isAssociativeEnumAlgebra(ea, ao)
		elseif	ap == ALGEBRAIC_PROPERTY_HAS_ABSORBING_ELEMENT
		then	_hasAbsorbingElementEnumAlgebra(ea, ao)
		elseif	ap == ALGEBRAIC_PROPERTY_HAS_NEUTRAL_ELEMENT
		then	_hasNeutralElementEnumAlgebra(ea, ao)
		else assert(false, "incomplete implementation", false)
		endif
;

% checks commutativity of operation $ao over enumerated algebra $ea
function bool: _isCommutativeEnumAlgebra(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "_isCommutativeEnumAlgebra($ea,$ao): commutativity of operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
	} in
		forall(x,y in _generatorEnumAlgebra(ea))(
			equality(operation(ao, x, y), operation(ao, y, x))
		)
;

% checks associativity of operation $ao over enumerated algebra $ea
function bool: _isAssociativeEnumAlgebra(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "_isAssociativeEnumAlgebra($ea,$ao): associativity of operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
	} in
		forall(x,y,z in _generatorEnumAlgebra(ea))(
			equality(operation(ao, x, operation(ao, y, z)), operation(ao, operation(ao, x, y), z))
		)
;

% checks existence of absorbing element for operation $ao over enumerated algebra $ea
function bool: _hasAbsorbingElementEnumAlgebra(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "_hasAbsorbingElementEnumAlgebra($ea,$ao): existence of absorbing element for operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
		array[int] of bool: absorbing = [forall(y in _generatorEnumAlgebra(ea))(equality(operation(ao, x, y), x) /\ equality(operation(ao, y, x), x)) | x in _generatorEnumAlgebra(ea)];
	} in
		count(i in absorbing)(i) = 1 % absorbing element is unique if it exists
;

% checks existence of neutral element for operation $ao over enumerated algebra $ea
function bool: _hasNeutralElementEnumAlgebra(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "_hasNeutralElementEnumAlgebra($ea,$ao): existence of neutral element for operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
		array[int] of bool: neutral = [forall(y in _generatorEnumAlgebra(ea))(equality(operation(ao, x, y), y) /\ equality(operation(ao, y, x), y)) | x in _generatorEnumAlgebra(ea)];
	} in
		count(i in neutral)(i) = 1 % neutral element is unique if it exists
;

%
function A_ELEMENT: _getAbsorbingElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "_getAbsorbingElement($ea,$ao): returns absorbing element of operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
		array[int] of A_ELEMENT: A = _generatorEnumAlgebra(ea);
		array[int] of bool: absorbing = [forall(y in A)(equality(operation(ao, x, y), x) /\ equality(operation(ao, y, x), x)) | x in A];
		int: i = arg_max(absorbing);
	} in
		if i == min(index_set(absorbing)) /\ not(absorbing[min(index_set(absorbing))])
		then getUndefinedElement(ea.algebra)
		else (algebra:ea.algebra, value:A[i].value)
		endif
;

%
function A_ELEMENT: _getNeutralElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao)
	:: "_getNeutralElement($ea,$ao): returns neutral element of operation $ao over enumerated algebra $ea"
	=
	let {
		bool: precond = assert(isEnumAlgebra(ea), "algebra must be enumerated");
		array[int] of A_ELEMENT: A = _generatorEnumAlgebra(ea);
		array[int] of bool: neutral = [forall(v in A)(equality(operation(ao, u, v), v) /\ equality(operation(ao, v, u), v)) | u in A];
		int: i = arg_max(neutral);
	} in
		if i == min(index_set(neutral)) /\ not(neutral[min(index_set(neutral))])
		then getUndefinedElement(ea.algebra)
		else (algebra:ea.algebra, value:A[i].value)
		endif
;
