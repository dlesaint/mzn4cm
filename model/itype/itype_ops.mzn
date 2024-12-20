%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BOOLEAN I-TYPE OPERATIONS
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

include "./../itype/itype_imp_api.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BINARY INFLUENCE OPERATIONS
array[I_DOMAIN,I_DOMAIN] of opt I_DOMAIN: I_AGGREGATE; %= array2d(I_DOMAIN,I_DOMAIN, [I_DOMAIN[1] | i in I_DOMAIN,j in I_DOMAIN]);

array[I_DOMAIN,I_DOMAIN] of opt I_DOMAIN: I_PROPAGATE; %= array2d(I_DOMAIN,I_DOMAIN, [I_DOMAIN[1] | i in I_DOMAIN,j in I_DOMAIN]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAR/VAR I-TYPE RELATIONS 

%
function bool: iEquals(array[int] of int: x, array[int] of int: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
	=
	if getBlockTypeSorts(itype)[1] == ITYPE_SORT_RATIONAL
	then
	x[1]*y[2] == x[2]*y[1]
	else
	assert(false, "bug: unexpected function call (equality should be identity - see _buildAlgebra() - and so pre-checked)", false)
	endif
	;
	
%
function var bool: iEquals(array[int] of var int: x, array[int] of var int: y)
	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)"
	=
	if getBlockTypeSorts(itype)[1] == ITYPE_SORT_RATIONAL
	then
	x[1]*y[2] == x[2]*y[1]
	else
	assert(false, "bug: unexpected function call (equality should be identity - see _buildAlgebra() - and so pre-checked)", false)
	endif
	;

	% %
function bool: iSmallerThan(array[int] of int: x, array[int] of int: y)
	:: "iSmallerThan($x,$y): checks whether $x is smaller than $y over i-type of $x - (par)"
	=
	x[1] * y[2] < x[2] * y[1]
;

%
function var bool: iSmallerThan(array[int] of var int: x, array[int] of var int: y)
	:: "iSmallerThan($x,$y): checks whether $x is smaller than $y over i-type of $x - (var)"
	=
	x[1] * y[2] < x[2] * y[1]
;
%% BINARY AGGREGATION
function array[IBLOCK_COMPONENT] of int: iAggregate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
=
	iAg(x,y,min(SORT));

function array[int] of int: iAg(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y, int: i)
= 
	if i == max(SORT)
	then iAggregate(x,y,i)
	else iAggregate(x,y,i) ++ iAg(x,y,i+1)
	endif;
%
function array[int] of int: iAggregate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y, int: i)
    ::  "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
    =
	if getAggregation(itype)[i] == ITYPE_BOOL_OR
    then [max(x[sort_size[i]],y[sort_size[i]])]
    elseif getAggregation(itype)[i] == ITYPE_BOOL_AND
    then [x[sort_size[i]]*y[sort_size[i]]]
	elseif 	getAggregation(itype)[i] == ITYPE_RATIONAL_PLUS
	then	iRationalPlus(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getAggregation(itype)[i] == ITYPE_RATIONAL_TIMES
	then	iRationalTimes(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getAggregation(itype)[i] == ITYPE_RATIONAL_MIN
	then	iRationalMin(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getAggregation(itype)[i] == ITYPE_RATIONAL_MAX
	then	iRationalMax(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif getAggregation(itype)[i] == ITYPE_AGGREGATION_ENUM
	then [deopt(I_AGGREGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])])]
    else assert(false, "bug - incomplete implementation",[])
	endif
;
%
function array[IBLOCK_COMPONENT] of var int: iAggregate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
=
	iAg(x,y,min(SORT));

function array[int] of var int: iAg(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y, int: i)
= 
	if i == max(SORT)
	then iAggregate(x,y,i)
	else iAggregate(x,y,i) ++ iAg(x,y,i+1)
	endif;

function array[int] of var int: iAggregate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y, int: i)
    ::  "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
    =	
	if getAggregation(itype)[i] == ITYPE_BOOL_OR
    then [max(x[sort_size[i]],y[sort_size[i]])]
    elseif getAggregation(itype)[i] == ITYPE_BOOL_AND
    then [x[sort_size[i]]*y[sort_size[i]]]
	elseif 	getAggregation(itype)[i] == ITYPE_RATIONAL_PLUS
	then	iRationalPlus(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getAggregation(itype)[i] == ITYPE_RATIONAL_TIMES
	then	iRationalTimes(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getAggregation(itype)[i] == ITYPE_RATIONAL_MIN
	then	iRationalMin(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getAggregation(itype)[i] == ITYPE_RATIONAL_MAX
	then	iRationalMax(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif getAggregation(itype)[i] == ITYPE_AGGREGATION_ENUM
	then [deopt(I_AGGREGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])])]
    else assert(false, "bug - incomplete implementation",[])
	endif
;

%% BINARY PROPAGATION
%
function array[IBLOCK_COMPONENT] of int: iPropagate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
=
	iPr(x,y,min(SORT));
function array[int] of int: iPr(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y,int: i)
=
	if i == max(SORT)
	then iPropagate(x,y,i)
	else iPropagate(x,y,i) ++ iPr(x,y,i+1)
	endif;

function array[IBLOCK_COMPONENT] of int: iPropagate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y,int: i)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	if getPropagation(itype)[i] == ITYPE_BOOL_OR
    then [max(x[sort_size[i]],y[sort_size[i]])]
    elseif getPropagation(itype)[i] == ITYPE_BOOL_AND
    then [x[sort_size[i]]*y[sort_size[i]]]
	elseif 	getPropagation(itype)[i] == ITYPE_RATIONAL_PLUS
	then	iRationalPlus(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getPropagation(itype)[i] == ITYPE_RATIONAL_TIMES
	then	iRationalTimes(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getPropagation(itype)[i] == ITYPE_RATIONAL_MIN
	then	iRationalMin(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getPropagation(itype)[i] == ITYPE_RATIONAL_MAX
	then	iRationalMax(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif getPropagation(itype)[i] == ITYPE_AGGREGATION_ENUM
	then [deopt(I_AGGREGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])])]
    else assert(false, "bug - incomplete implementation",[])
	endif
;

%
function array[IBLOCK_COMPONENT] of var int: iPropagate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
=
	iPr(x,y,min(SORT));
	
function array[int] of var int: iPr(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y,int: i)
=
	if i == max(SORT)
	then iPropagate(x,y,i)	
	else iPropagate(x,y,i) 
		++ 
		iPr(x,y,i+1)
	endif;

function array[int] of var int: iPropagate(array[int] of var int: x, array[int] of var int: y,int: i)
	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
	=
	if getPropagation(itype)[i] == ITYPE_BOOL_OR
    then [max(x[sort_size[i]],y[sort_size[i]])]
    elseif getPropagation(itype)[i] == ITYPE_BOOL_AND
    then [x[sort_size[i]]*y[sort_size[i]]]
	elseif 	getPropagation(itype)[i] == ITYPE_RATIONAL_PLUS
	then	iRationalPlus(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getPropagation(itype)[i] == ITYPE_RATIONAL_TIMES
	then	iRationalTimes(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getPropagation(itype)[i] == ITYPE_RATIONAL_MIN
	then	iRationalMin(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif	getPropagation(itype)[i] == ITYPE_RATIONAL_MAX
	then	iRationalMax(array1d(1..2,x[sort_size[i]..sort_size[i]+1]), array1d(1..2,y[sort_size[i]..sort_size[i]+1]))
	elseif getPropagation(itype)[i] == ITYPE_AGGREGATION_ENUM
	then [deopt(I_AGGREGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])])]
    else assert(false, "bug - incomplete implementation",[])
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
function array[1..2] of int: iRationalReduce(array[1..2] of int: x)
	:: "iRationalReduce($x,$y): reduces $x by dividing numerator and denominator with their greatest common divisor - (par)"
	=
	let {
		int: gcd = greatestCommonDivisor(x[1], x[2]);
	} in
		[x[1] div gcd, x[2] div gcd]
;

%
function array[1..2] of var int: iRationalReduce(array[1..2] of var int: x)
	:: "iRationalReduce($x,$y): reduces $x by dividing numerator and denominator with their greatest common divisor - (var)"
	=
	let {
		var int: x_gcd = greatestCommonDivisor(x[1], x[2]) ::is_defined_var;
		array[1..2] of var int: z ::is_defined_var;
		constraint
			(z[1] == x[1] div x_gcd) /\
			(z[2] == x[2] div x_gcd)
			:: defines_var(z)
			;
	} in
		z
;

%
function array[1..2] of int: iRationalPlus(array[1..2] of int: x, array[1..2] of int: y)
	:: "iRationalPlus($x,$y): adds $x to $y over i-type of $x - (par)"
	=
	iRationalReduce([x[1] * y[2] + x[2] * y[1], x[2] * y[2]])
;

%
function array[1..2] of var int: iRationalPlus(array[1..2] of var int: x, array[1..2] of var int: y)
	:: "iRationalPlus($x,$y): adds $x to $y over i-type of $x - (var)"
	=
	let {
		array[1..2] of var int: z ::is_defined_var;
		constraint
			(z[1] == x[1] * y[2] + x[2] * y[1]) /\
			(z[2] == x[2] * y[2])
			:: defines_var(z)
			;
	} in
		%iRationalReduce(z)
		z
;

%
function array[1..2] of int: iRationalTimes(array[1..2] of int: x, array[1..2] of int: y)
	:: "iRationalTimes($x,$y): multiplies $x and $y over i-type of $x - (par)"
	=
	iRationalReduce([x[1] * y[1], x[2] * y[2]])
;

%
function array[1..2] of var int: iRationalTimes(array[1..2] of var int: x, array[1..2] of var int: y)
	:: "iRationalTimes($x,$y): multiplies $x and $y over i-type of $x - (var)"
	=
	let {
		array[1..2] of var int: z ::is_defined_var;
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
function array[1..2] of int: iRationalMin(array[1..2] of int: x, array[1..2] of int: y)
	:: "iRationalMin($x,$y): returns the minimum of $x and $y over i-type of $x - (par)"
	=
	if	iSmallerThan(x, y)
	then	x
	else	y
	endif
;

%
function array[1..2] of var int: iRationalMin(array[1..2] of var int: x, array[1..2] of var int: y)
	:: "iRationalMin($x,$y): returns the minimum of $x and $y over i-type of $x - (var)"
	=
	let {
		array[1..2] of var int: z ::is_defined_var;
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
function array[1..2] of int: iRationalMax(array[1..2] of int: x, array[1..2] of int: y)
	:: "iRationalMax($x,$y): returns the maximum of $x and $y over i-type of $x - (par)"
	=
	if	iSmallerThan(x, y)
	then	y
	else	x
	endif
;

%
function array[1..2] of var int: iRationalMax(array[1..2] of var int: x, array[1..2] of var int: y)
	:: "iRationalMax($x,$y): returns the maximum of $x and $y over i-type of $x - (var)"
	=
	let {
		array[1..2] of var int: z ::is_defined_var;
		constraint
			(iSmallerThan(x, y) -> z == y) /\ 
			(iSmallerThan(y, x) -> z == x) /\
			(iEquals(x, y) -> z == x)
			:: defines_var(z)
			;
	} in
		z
;
