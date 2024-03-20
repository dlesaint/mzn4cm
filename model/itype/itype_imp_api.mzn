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
function bool: iEquals(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)";

%
function var bool: iEquals(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y) :: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR BINARY I-TYPE OPERATIONS

%% BINARY AGGREGATION
%
function DEOPT_INFLUENCE: iAggregate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y) :: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)";

%
function var DEOPT_INFLUENCE: iAggregate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y) :: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)";


%% BINARY PROPAGATION
%
function DEOPT_INFLUENCE: iPropagate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)";

%
function var DEOPT_INFLUENCE: iPropagate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

% Getter for influence value symbol
function string: iShow(DEOPT_INFLUENCE: x) :: "iShow($x): returns string representation of non-virtual influence $x";	
