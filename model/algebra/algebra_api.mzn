%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ALGEBRA API
%
%	- Defines
%		- ENUMERATIONS
%			- ALGEBRAIC_OPERATION
%			- ALGEBRAIC_PROPERTY
%			- ALGEBRAIC_ELEMENT
%		- CLASSES
%			- ALGEBRA
%			- A_ELEMENT
%			- DEOPT_A_ELEMENT
%			- E_ALGEBRA
%
%	- Declares
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
%		- PAR/VAR ALGEBRAIC RELATIONS 
%			- equality (par)
%			- equality (var)
%   - PAR/VAR ALGEBRAIC OPERATIONS
%			- operation (par)
%			- operation (var)
%		- OUTPUT
%			- showAlgebraElement
%			- displayAlgrebraHeader
%			- displayAlgebraProperties
%			- displayAlgebraElements



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES 

% Class for algebras
type ALGEBRA = record(
	%
	% string: name,
	% the algebraic domain encoding as an array of dimensions
	%		- the number of dimensions is > 0
	%		- each dimension either maps to
	% 		- a built-in type (bool or int) in which case the corresponding dimension value is set to <>
	%			- a range of ints or an enumeration in which case the corresponding dimension value is set to the cardinality of the range/enum
	array[int] of opt int: dimensions,
	% whether the algebraic domain is an option type
	%		- if so, the *virtual element* is considered part of the domain
	bool: is_option_type,
	% whether equality between algebraic domain elements is an equivalence relation or is identity
	bool: equality_as_identity,
	);

% Class for algebra domain elements
type A_ELEMENT = record(
	% algebra of element
	ALGEBRA: algebra,
	% array encoding the domain element as a n-uple of opt ints indexed over the n encoding dimensions
	% 3 encodings based on the domain element:
	%		- the virtual element: all integers are absent (equal to <>)
	%		- an undefined (non-existing) element: all integers are equal to -1 (NB. used to represent non-existing algebraic elements, eg. absence of a neutral element) TODO
	% 	- any other domain element: the i-th integer is the encoding of the value of the domain element on the i-th dimension 
	% 		- the interpretation of the n-uple (encoding/decoding to/from built-in types, enums, object types, etc.) is left to the client code  
	array[int] of opt int: value,
	);

% Class for de-opted algebra domain elements
type DEOPT_A_ELEMENT = record(
	% algebra of element
	ALGEBRA: algebra,
	% array of non-optional integers encoding a defined and non-virtual domain element 
	array[int] of int: value,
	);

% Class of algebraic operations
enum ALGEBRAIC_OPERATION = {ALGEBRAIC_OPERATION_1, ALGEBRAIC_OPERATION_2};

% Class of algebraic properties
enum ALGEBRAIC_PROPERTY = {ALGEBRAIC_PROPERTY_HAS_ABSORBING_ELEMENT, ALGEBRAIC_PROPERTY_HAS_NEUTRAL_ELEMENT, ALGEBRAIC_PROPERTY_COMMUTATIVITY, ALGEBRAIC_PROPERTY_ASSOCIATIVITY};

% Class of algebraic elements
enum ALGEBRAIC_ELEMENT = {ALGEBRAIC_ELEMENT_ABSORBING, ALGEBRAIC_ELEMENT_NEUTRAL};

% Class for extended algebraic types
type E_ALGEBRA = record(
	% algebra
	ALGEBRA: algebra,
	% properties[i,j]: whether algebraic property j holds for algebraic operation i
	array[ALGEBRAIC_OPERATION, ALGEBRAIC_PROPERTY] of bool: properties,
	% elements[i,j]: the algebraic element j of algebraic operation i
		% - is the undefined element iff operation i has no algebraic element j
	array[ALGEBRAIC_OPERATION, ALGEBRAIC_ELEMENT] of A_ELEMENT: elements,
	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALGEBRAIC ASSERTIONS

% Checks meta-properties of algebras
function bool: assertAlgebra(E_ALGEBRA: ea) :: "function assertAlgebra($ea): asserts meta-properties of algebra $ea";

%
function bool: isEnumAlgebra(E_ALGEBRA: ea) :: "function isEnumAlgebra($ea): checks whether none of the dimensions of algebra $ea is a built-in type";

%
function bool: isOptAlgebra(E_ALGEBRA: ea)	:: "function isOptAlgebra($ea): checks whether algebra $ea is an option type, ie. it includes a virtual element";

%
function bool: isEqualityIdentity(E_ALGEBRA: ea) :: "function isEqualityIdentity($ea): checks whether equality is identity over algebra $ea";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALGEBRAIC PROPERTY CHECKING

% Checks algebraic property $ap of operation $ao
function bool: checkProperty(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao, ALGEBRAIC_PROPERTY: ap) :: "checkProperty($ea,$ao,$ap): checks algebraic property $ap of operation $ao over $ea";

% checks commutativity of operation $ao
function bool: isCommutative(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao) :: "isCommutative($ea,$ao): commutativity of operation $ao over $ea";

% checks associativity of operation $ao
function bool: isAssociative(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao) :: "isAssociative($ea,$ao): associativity of operation $ao over $ea";

% checks existence of absorbing element for operation $ao
function bool: hasAbsorbingElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao) :: "hasAbsorbingElement($ea,$ao): existence of absorbing element for operation $ao over $ea";

% checks existence of neutral element for operation $ao
function bool: hasNeutralElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao) :: "hasNeutralElement($ea,$ao): existence of neutral element for operation $ao over $ea";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALGEBRAIC ELEMENTS

% Algebraic element $ie of operation $ao over $ea
function A_ELEMENT: getElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao, ALGEBRAIC_ELEMENT: ae) :: "getElement($ea,$ao,$ae): returns element $ae of operation $ao over $ea";

% Absorbing element for operation $ao over $ea
function A_ELEMENT: getAbsorbingElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao) :: "getAbsorbingElement($ea,$ao): returns absorbing element of operation $ao over $ea";

% Neutral element for operation $ao over $ea
function A_ELEMENT: getNeutralElement(E_ALGEBRA: ea, ALGEBRAIC_OPERATION: ao) :: "getNeutralElement($ea,$ao): returns neutral element of operation $ao over $ea";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VIRTUAL AND UNDEFINED ELEMENTS

% Virtual element for algebra $al
function A_ELEMENT: getVirtualElement(E_ALGEBRA: ea) :: "getVirtualElement($ea): returns the virtual element of algebra $ea"	;

% Checks nullity of element $x (par)
function bool: isVirtualElement(A_ELEMENT: x) :: "isVirtualElement($x): checks whether $x is virtual (par)";

% Checks nullity of element $x (var)
function var bool: isVirtualElement(var A_ELEMENT: x) :: "isVirtualElement($x): checks whether $x is virtual (var)";

% Undefined element for algebra $al
function A_ELEMENT: getUndefinedElement(ALGEBRA: al) :: "getUndefinedElement($al): returns the undefined element over $al"	;

% Checks undefinability of element $x (par)
function bool: isUndefinedElement(A_ELEMENT: x) :: "isUndefinedElement($x): checks whether $x is undefined (par)";

% Checks undefinability of element $x (var)
function var bool: isUndefinedElement(var A_ELEMENT: x) :: "isUndefinedElement($x): checks whether $x is undefined (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECKERS

%
function bool: equalAlgebras(ALGEBRA: x, ALGEBRA: y) :: "equalAlgebras($x, $y): checks whether $x is equal to $y - (par)";

%
function bool: equalAElements(A_ELEMENT: x, A_ELEMENT: y) :: "equalAElements($x, $y): checks whether $x is equal to $y over algebra of $x - (par)";

%
function var bool: equalAElements(var A_ELEMENT: x, var A_ELEMENT: y) :: "equalAElements($x, $y): checks whether $x is equal to $y over algebra of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC RELATIONS 

%
function bool: equality(A_ELEMENT: x, A_ELEMENT: y) :: "equality($x,$y): checks whether equality relation holds between $x and $y over $x.algebra - (par)";

%
function var bool: equality(var A_ELEMENT: x, var A_ELEMENT: y) :: "equality($x,$y): checks whether equality relation holds between $x and $y over $x.algebra - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC OPERATIONS

% Evaluates operation $ao over pars ($x,$y) in $x.algebra
function A_ELEMENT: operation(ALGEBRAIC_OPERATION: ao, A_ELEMENT: x, A_ELEMENT: y) :: "operation($ao,$x,$y): evaluates operation $ao over pars ($x,$y) in $x.algebra";

% Evaluates operation $ao over vars ($x,$y) in $x.algebra
function var A_ELEMENT: operation(ALGEBRAIC_OPERATION: ao, var A_ELEMENT: x, var A_ELEMENT: y) :: "operation($ao,$x,$y): evaluates operation $ao over vars ($x,$y) in $x.algebra";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function string: showAlgebraElement(A_ELEMENT: x);

%
function array[int] of string: displayAlgrebraHeader(E_ALGEBRA: al);

%
function array[int] of string: displayAlgebraProperties(E_ALGEBRA: al);

%
function array[int] of string: displayAlgebraElements(E_ALGEBRA: al);
