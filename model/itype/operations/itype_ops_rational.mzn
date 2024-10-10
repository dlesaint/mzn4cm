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
%			- iSmallerThan (par)
%			- iSmallerThan (var)
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
function bool: iEquals(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
	=
	x[1] * y[2] == x[2] * y[1]
;

%
function var bool: iEquals(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)"
	=
	x[1] * y[2] == x[2] * y[1]
;

%
function bool: iSmallerThan(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iSmallerThan($x,$y): checks whether $x is smaller than $y over i-type of $x - (par)"
	=
	x[1] * y[2] < x[2] * y[1]
;

%
function var bool: iSmallerThan(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iSmallerThan($x,$y): checks whether $x is smaller than $y over i-type of $x - (var)"
	=
	x[1] * y[2] < x[2] * y[1]
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR BINARY I-TYPE OPERATIONS

%% BINARY AGGREGATION
%
function array[IBLOCK_COMPONENT] of int: iAggregate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
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
	else	assert(false, "bug - incomplete implementation", [])
	endif
;

%
function array[IBLOCK_COMPONENT] of var int: iAggregate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
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
	else	assert(false, "bug - incomplete implementation", [])
	endif
;


%% BINARY PROPAGATION
%
function array[IBLOCK_COMPONENT] of int: iPropagate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
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
	else	assert(false, "bug - incomplete implementation", [])
	endif
;

%
function array[IBLOCK_COMPONENT] of var int: iPropagate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y) %%::promise_total
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
	else	assert(false, "bug - incomplete implementation", [])
	endif
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE 

%
function int: greatestCommonDivisor(int: x, int: y)
	:: "greatestCommonDivisor($x,$y): returns greatest common divisor of $x and $y - (par)"
	=
	if 			x == 0
	then	y
	elseif	y == 0
	then	x
	else	greatestCommonDivisor(y, x mod y)
	endif
;

%
function var int: greatestCommonDivisor(var int: x, var int: y)
	:: "greatestCommonDivisor($x,$y): returns greatest common divisor of $x and $y - (var)"
	=
	let {
		set of int: GCD = 1..min(min(ub(x),ub(y)),100);
		array[GCD] of var int: x_gcd;
		array[GCD] of var int: y_gcd;
		constraint x_gcd[1] == abs(x);
		constraint y_gcd[1] == abs(y);
 		constraint forall(i in min(GCD)<..<max(GCD))(x_gcd[i] == y_gcd[i-1]);		
 		constraint forall(i in min(GCD)<..<max(GCD))(if y_gcd[i-1] == 0 \/ y_gcd[i-1] == 0 then y_gcd[i] == 0 else y_gcd[i] == x_gcd[i-1] mod y_gcd[i-1] endif);
		var GCD: z;
		constraint z = min([i | i in GCD where x_gcd[i] == 0 \/ y_gcd[i] == 0]);
		var GCD: j;
		constraint j = if x_gcd[z] == 0 then y_gcd[z] else x_gcd[z] endif;
	} in
		j
;

%
function array[IBLOCK_COMPONENT] of int: iRationalReduce(array[IBLOCK_COMPONENT] of int: x)
	:: "iRationalReduce($x,$y): reduces $x by dividing numerator and denominator with their greatest common divisor - (par)"
	=
	let {
		int: gcd = greatestCommonDivisor(x[1], x[2]);
	} in
		[x[1] div gcd, x[2] div gcd]
;

%
function array[IBLOCK_COMPONENT] of var int: iRationalReduce(array[IBLOCK_COMPONENT] of var int: x)
	:: "iRationalReduce($x,$y): reduces $x by dividing numerator and denominator with their greatest common divisor - (var)"
	=
	let {
		var int: x_gcd = greatestCommonDivisor(x[1], x[2]) ::is_defined_var;
		array[IBLOCK_COMPONENT] of var int: z ::is_defined_var;
		constraint
			(z[1] == x[1] div x_gcd) /\
			(z[2] == x[2] div x_gcd)
			:: defines_var(z)
			;
	} in
		z
;

%
function array[IBLOCK_COMPONENT] of int: iRationalPlus(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iRationalPlus($x,$y): adds $x to $y over i-type of $x - (par)"
	=
	iRationalReduce([x[1] * y[2] + x[2] * y[1], x[2] * y[2]])
;

%
function array[IBLOCK_COMPONENT] of var int: iRationalPlus(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iRationalPlus($x,$y): adds $x to $y over i-type of $x - (var)"
	=
	let {
		array[IBLOCK_COMPONENT] of var int: z ::is_defined_var;
		constraint
			(z[1] == x[1] * y[2] + x[2] * y[1]) /\
			(z[2] == x[2] * y[2])
			:: defines_var(z)
			;
	} in
		iRationalReduce(z)
		%z
;

%
function array[IBLOCK_COMPONENT] of int: iRationalTimes(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iRationalTimes($x,$y): multiplies $x and $y over i-type of $x - (par)"
	=
	iRationalReduce([x[1] * y[1], x[2] * y[2]])
;

%
function array[IBLOCK_COMPONENT] of var int: iRationalTimes(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iRationalTimes($x,$y): multiplies $x and $y over i-type of $x - (var)"
	=
	let {
		array[IBLOCK_COMPONENT] of var int: z ::is_defined_var;
		constraint
			(z[1] == x[1] * y[1]) /\
			(z[2] == x[2] * y[2])
			:: defines_var(z)
			;
	} in
		%iRationalReduce(z)
		z
;

%
function array[IBLOCK_COMPONENT] of int: iRationalMin(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iRationalMin($x,$y): returns the minimum of $x and $y over i-type of $x - (par)"
	=
	if	iSmallerThan(x, y)
	then	x
	else	y
	endif
;

%
function array[IBLOCK_COMPONENT] of var int: iRationalMin(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iRationalMin($x,$y): returns the minimum of $x and $y over i-type of $x - (var)"
	=
	let {
		array[IBLOCK_COMPONENT] of var int: z ::is_defined_var;
		constraint
			(iSmallerThan(x, y) -> z == x) /\ 
			(iSmallerThan(y, x) -> z == y) /\
			(iEquals(x, y) -> z == x)
			:: defines_var(z)
			;
	} in
		z
;

%
function array[IBLOCK_COMPONENT] of int: iRationalMax(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
	:: "iRationalMax($x,$y): returns the maximum of $x and $y over i-type of $x - (par)"
	=
	if	iSmallerThan(x, y)
	then	y
	else	x
	endif
;

%
function array[IBLOCK_COMPONENT] of var int: iRationalMax(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
	:: "iRationalMax($x,$y): returns the maximum of $x and $y over i-type of $x - (var)"
	=
	let {
		array[IBLOCK_COMPONENT] of var int: z ::is_defined_var;
		constraint
			(iSmallerThan(x, y) -> z == y) /\ 
			(iSmallerThan(y, x) -> z == x) /\
			(iEquals(x, y) -> z == x)
			:: defines_var(z)
			;
	} in
		z
;
