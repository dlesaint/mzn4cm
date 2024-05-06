%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% I-TYPE IMPLEMENTATION API
%
%	- Uses I-TYPE API
%		- CLASSES
%			- ITYPE_SIGNATURE
%			- ITYPE_DOMAINS
%			- ITYPE_ALGEBRA
%			- DEOPT_INFLUENCE
%
%	- Declares
%		- OBJECTS
%			- itype_signature
%			- itype_domains
%			- itype_algebra
%		- PAR/VAR I-TYPE RELATIONS 
%			- iEquals (par)
%			- iEquals (var)
%		- PAR/VAR BINARY I-TYPE OPERATIONS
%			-	iAggregate (par)
%			-	iAggregate (var)
%			-	iPropagate (par)
%			-	iPropagate (var)
%		- OUTPUT
%			- iShow



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../itype/itype_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA

% The number of sorts
int: itype_nr_sorts;

% The signature of the i-type
ITYPE_SIGNATURE: itype_signature;

% The domains for the sorts of the i-type
ITYPE_DOMAINS: itype_domains;

% The algebraic structure of the i-type
ITYPE_ALGEBRA: itype_algebra;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: iEquals(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)";

%
function var bool: iEquals(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y) :: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR BINARY I-TYPE OPERATIONS

%% BINARY AGGREGATION
%
function array[IBLOCK_COMPONENT] of int: iAggregate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y) :: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)";

%
function array[IBLOCK_COMPONENT] of var int: iAggregate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y) :: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)";


%% BINARY PROPAGATION
%
function array[IBLOCK_COMPONENT] of int: iPropagate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)";

%
function array[IBLOCK_COMPONENT] of var int: iPropagate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

% Getter for influence value symbol
function string: iShow(array[IBLOCK_COMPONENT] of int: x) :: "iShow($x): returns string representation of non-virtual influence $x";	
