%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% RATIONAL I-TYPE OPERATIONS
%
% - Implements I-TYPE IMPLEMENTATION API
%		- PAR/VAR I-TYPE RELATIONS 
%			- iEquals (par)
%			- iEquals (var)
%		- PAR/VAR BINARY I-TYPE OPERATIONS
%			-	iAggregate (par)
%			-	iAggregate (var)
%			-	iPropagate (par)
%			-	iPropagate (var)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../../itype/itype_imp_api.mzn";

include "./../../itype/type/itype_rational_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: iEquals(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
	=
	x.iblock[1] * y.iblock[2] == x.iblock[2] * y.iblock[1]
;

%
function var bool: iEquals(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)"
	=
	x.iblock[1] * y.iblock[2] == x.iblock[2] * y.iblock[1]
;

%
function bool: iSmallerThan(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iSmallerThan($x,$y): checks whether $x is smaller than $y over i-type of $x - (par)"
	=
	x.iblock[1] * y.iblock[2] < x.iblock[2] * y.iblock[1]
;

%
function var bool: iSmallerThan(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iSmallerThan($x,$y): checks whether $x is smaller than $y over i-type of $x - (var)"
	=
	x.iblock[1] * y.iblock[2] < x.iblock[2] * y.iblock[1]
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR BINARY I-TYPE OPERATIONS

%% BINARY AGGREGATION
%
function DEOPT_INFLUENCE: iAggregate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
	=
	if 		getAggregation(itype) == ITYPE_AGGREGATION_PLUS
	then	iRationalPlus(x, y)
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_TIMES
	then	iRationalTimes(x, y)
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_MIN
	then	iRationalMin(x, y)
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_MAX
	then	iRationalMax(x, y)
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;

%
function var DEOPT_INFLUENCE: iAggregate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)"
	=
	if 		getAggregation(itype) == ITYPE_AGGREGATION_PLUS
	then	iRationalPlus(x, y)
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_TIMES
	then	iRationalTimes(x, y)
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_MIN
	then	iRationalMin(x, y)
	elseif	getAggregation(itype) == ITYPE_AGGREGATION_MAX
	then	iRationalMax(x, y)
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;


%% BINARY PROPAGATION
%
function DEOPT_INFLUENCE: iPropagate(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	if 		getPropagation(itype) == ITYPE_PROPAGATION_PLUS
	then	iRationalPlus(x, y)
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_TIMES
	then	iRationalTimes(x, y)
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_MIN
	then	iRationalMin(x, y)
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_MAX
	then	iRationalMax(x, y)
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;

%
function var DEOPT_INFLUENCE: iPropagate(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y) %::promise_total
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)"
	=
	let {
% 	bool: precond = assert(false, "bug" ++ show(getPropagation(itype)));
	} in
	if 		getPropagation(itype) == ITYPE_PROPAGATION_PLUS
	then	iRationalPlus(x, y)
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_TIMES
	then	iRationalTimes(x, y) % add smallerThan relation (par/var function) to algebra and itype APIs

	elseif	getPropagation(itype) == ITYPE_PROPAGATION_MIN
	then	iRationalMin(x, y)
	elseif	getPropagation(itype) == ITYPE_PROPAGATION_MAX
	then	iRationalMax(x, y)
	else	assert(false, "bug - incomplete implementation", (iblock: []))
	endif
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE 

%
function int: greatestCommonDivisor(int: x, int: y)
	:: "greatestCommonDivisor($x,$y): returns greatest common divisor of $x and $y - (par)"
	=
	if 		x == 0
	then	y
	elseif	y == 0
	then x
	else greatestCommonDivisor(y, x mod y)
	endif
;

%
function var int: greatestCommonDivisor(var int: x, var int: y)
	:: "greatestCommonDivisor($x,$y): returns greatest common divisor of $x and $y - (var)"
	=
	let {
		int : size = min(min(ub(x), ub(y)),100);
		var 1..(size+1): z;
		array[0..size] of var int: x_gcd;
		array[0..size] of var int: y_gcd;
		
		constraint forall (i in 0..(size)) (
			x_gcd[i] = x mod (i+1) /\ y_gcd[i] = y mod (i+1)
		);
		constraint z = 1+  max([i | i in 0..size where x_gcd[i] == 0 /\ y_gcd[i] ==0]);
		
	} in 
 		1
;

%
function DEOPT_INFLUENCE: iRationalReduce(DEOPT_INFLUENCE: x)
	:: "iRationalReduce($x,$y): reduces $x by dividing numerator and denominator with their greatest common divisor - (par)"
	=
	let {
		int: gcd = greatestCommonDivisor(x.iblock[1], x.iblock[2]);
	} in
		(iblock: [x.iblock[1] div gcd, x.iblock[2] div gcd])
;

%
function var DEOPT_INFLUENCE: iRationalReduce(var DEOPT_INFLUENCE: x)
	:: "iRationalReduce($x,$y): reduces $x by dividing numerator and denominator with their greatest common divisor - (var)"
	=
	let {
		var int: gcd = greatestCommonDivisor(x.iblock[1], x.iblock[2]) ::is_defined_var;
		var DEOPT_INFLUENCE: z ::is_defined_var;
		constraint z.iblock[1] == x.iblock[1] div gcd;
		constraint z.iblock[2] == x.iblock[2] div gcd;
	} in
		z
;

%
function DEOPT_INFLUENCE: iRationalPlus(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iRationalPlus($x,$y): adds $x to $y over i-type of $x - (par)"
	=
	iRationalReduce((iblock: [x.iblock[1] * y.iblock[2] + x.iblock[2] * y.iblock[1], x.iblock[2] * y.iblock[2]]))
;

%
function var DEOPT_INFLUENCE: iRationalPlus(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iRationalPlus($x,$y): adds $x to $y over i-type of $x - (var)"
	=
	let {
		var DEOPT_INFLUENCE: z ::is_defined_var;
		constraint z.iblock[1] == x.iblock[1] * y.iblock[2] + x.iblock[2] * y.iblock[1];
		constraint z.iblock[2] == x.iblock[2] * y.iblock[2];
	} in
		iRationalReduce(z)
;

%
function DEOPT_INFLUENCE: iRationalTimes(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iRationalTimes($x,$y): multiplies $x and $y over i-type of $x - (par)"
	=
	iRationalReduce((iblock: [x.iblock[1] * y.iblock[1], x.iblock[2] * y.iblock[2]]))
;

%
function var DEOPT_INFLUENCE: iRationalTimes(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iRationalTimes($x,$y): multiplies $x and $y over i-type of $x - (var)"
	=
	% !! compiler error for: (iblock: [x.iblock[1] * y.iblock[1], x.iblock[2] * y.iblock[2]])
	let {
		var DEOPT_INFLUENCE: z ::is_defined_var;
		constraint z.iblock[1] == x.iblock[1] * y.iblock[1];
		constraint z.iblock[2] == x.iblock[2] * y.iblock[2];
	} in
		iRationalReduce(z)
;

%
function DEOPT_INFLUENCE: iRationalMin(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iRationalMin($x,$y): returns the minimum of $x and $y over i-type of $x - (par)"
	=
	if	iSmallerThan(x, y)
	then	x
	else	y
	endif
;

%
function var DEOPT_INFLUENCE: iRationalMin(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iRationalMin($x,$y): returns the minimum of $x and $y over i-type of $x - (var)"
	=
	let {
		var DEOPT_INFLUENCE: z ::is_defined_var;
		constraint iSmallerThan(x, y) -> (false /\ forall(i in IBLOCK_COMPONENT)(z.iblock[i] == x.iblock[i])); % TODO z == y ?
		constraint iSmallerThan(y, x) -> (false /\ forall(i in IBLOCK_COMPONENT)(z.iblock[i] == y.iblock[i]));
		constraint iEquals(x, y) -> forall(i in IBLOCK_COMPONENT)(z.iblock[i] == x.iblock[i] /\ z.iblock[i] == y.iblock[i]);
	} in
		z
;

%
function DEOPT_INFLUENCE: iRationalMax(DEOPT_INFLUENCE: x, DEOPT_INFLUENCE: y)
	:: "iRationalMax($x,$y): returns the maximum of $x and $y over i-type of $x - (par)"
	=
	if	iSmallerThan(x, y)
	then	y
	else	x
	endif
;

%
function var DEOPT_INFLUENCE: iRationalMax(var DEOPT_INFLUENCE: x, var DEOPT_INFLUENCE: y)
	:: "iRationalMax($x,$y): returns the maximum of $x and $y over i-type of $x - (var)"
	=
	let {
		var DEOPT_INFLUENCE: z ::is_defined_var;
		constraint iSmallerThan(x, y) -> forall(i in IBLOCK_COMPONENT)(z.iblock[i] == y.iblock[i]); % TODO z == y ?
		constraint iSmallerThan(y, x) -> forall(i in IBLOCK_COMPONENT)(z.iblock[i] == x.iblock[i]);
		constraint iEquals(x, y) -> forall(i in IBLOCK_COMPONENT)(z.iblock[i] == x.iblock[i] /\ z.iblock[i] == y.iblock[i]);
	} in
		z
;
