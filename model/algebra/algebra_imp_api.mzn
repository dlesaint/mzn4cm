%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ALGEBRA IMPLEMENTATION API
%
%	- Uses ALGEBRA API
%		- CLASSES
%			- A_ELEMENT
%			- DEOPT_A_ELEMENT
%
%	- Declares
%		- PAR/VAR ALGEBRAIC RELATIONS 
%			- equality (par)
%			- equality (var)
%   - PAR/VAR ALGEBRAIC OPERATIONS
%			- operation1 (par)
%			- operation2 (par)
%			- operation1 (var)
%			- operation2 (var)
%		- OUTPUT
%			- showNonVirtualElement



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../algebra/algebra_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC RELATIONS 

%
function bool: equality(A_ELEMENT: x, A_ELEMENT: y) :: "equality($x,$y): checks whether equality relation holds between $x and $y over $x.algebra - (par)";

%
function var bool: equality(var A_ELEMENT: x, var A_ELEMENT: y) :: "equality($x,$y): checks whether equality relation holds between $x and $y over $x.algebra - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR ALGEBRAIC OPERATIONS 

%
function A_ELEMENT: operation1(A_ELEMENT: x, A_ELEMENT: y) :: "operation1($x,$y): $x AND $y over $x.algebra - (par)";

%
function A_ELEMENT: operation2(A_ELEMENT: x, A_ELEMENT: y) :: "operation2($x,$y): $x OR $y over $x.algebra - (par)";

%
function var A_ELEMENT: operation1(var A_ELEMENT: x, var A_ELEMENT: y) :: "operation1($x,$y): $x AND $y over $x.algebra - (var)";

%
function var A_ELEMENT: operation2(var A_ELEMENT: x, var A_ELEMENT: y) :: "operation2($x,$y): $x OR $y over $x.algebra - (var)";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT 

%
function string: showNonVirtualElement(DEOPT_A_ELEMENT: x);
