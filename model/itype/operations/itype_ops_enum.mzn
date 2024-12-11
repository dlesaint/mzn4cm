% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% David Lesaint (david.lesaint@univ-angers.fr)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% % ENUMERATION I-TYPE OPERATIONS
% %
% %	- Uses ENUMERATION I-TYPE API
% %		- ENUMERATION
% %			- I_DOMAIN
% %
% % - Implements I-TYPE IMPLEMENTATION API
% %		- PAR/VAR I-TYPE RELATIONS 
% %			- iEquals (par)
% %			- iEquals (var)
% %		- PAR/VAR BINARY I-TYPE OPERATIONS
% %			-	iAggregate (par)
% %			-	iAggregate (var)
% %			-	iPropagate (par)
% %			-	iPropagate (var)



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% FILE INCLUSION

% include "./../../itype/itype_imp_api.mzn";

% include "./../../itype/type/itype_enum_api.mzn";



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% BINARY INFLUENCE OPERATIONS

% % Influence aggregation matrix
% array[I_DOMAIN, I_DOMAIN] of I_DOMAIN: I_AGGREGATE;

% % Influence propagation matrix
% array[I_DOMAIN, I_DOMAIN] of I_DOMAIN: I_PROPAGATE;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PAR/VAR I-TYPE RELATIONS 

% %
% function bool: iEquals(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
% 	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (par)"
% 	=
% 	assert(false, "bug: unexpected function call (equality should be identity - see _buildAlgebra() - and so pre-checked)", false)
% 	;
	
% %
% function var bool: iEquals(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
% 	:: "iEquals($x,$y): checks whether equality relation holds between $x and $y over i-type of $x - (var)"
% 	=
% 	assert(false, "bug: unexpected function call (equality should be identity - see _buildAlgebra() - and so pre-checked)", false)
% 	;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PAR/VAR BINARY I-TYPE OPERATIONS

% %% BINARY AGGREGATION
% %
% function array[IBLOCK_COMPONENT] of int: iAggregate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
% 	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (par)"
% 	=
% 	[I_AGGREGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])]]
% ;
	
% %
% function array[IBLOCK_COMPONENT] of var int: iAggregate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
% 	:: "iAggregate($x,$y): aggregate $x with $y over i-type of $x - (var)"
% 	=
% 	[I_AGGREGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])]]
% ;
	

% %% BINARY PROPAGATION
% %
% function array[IBLOCK_COMPONENT] of int: iPropagate(array[IBLOCK_COMPONENT] of int: x, array[IBLOCK_COMPONENT] of int: y)
% 	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (par)"
% 	=
% 	[I_PROPAGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])]]
% ;
	
% %
% function array[IBLOCK_COMPONENT] of var int: iPropagate(array[IBLOCK_COMPONENT] of var int: x, array[IBLOCK_COMPONENT] of var int: y)
% 	:: "iPropagate($x,$y): propagate $x with $y over i-type of $x - (var)"
% 	=
% 	[I_PROPAGATE[to_enum(I_DOMAIN, x[min(index_set(x))]), to_enum(I_DOMAIN, y[min(index_set(y))])]]
% ;
	

