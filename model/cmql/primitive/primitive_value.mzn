%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE: VALUE



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

include "decreasing.mzn"; % for sorting paths lexicographically
include "lex_less.mzn"; % for sorting paths lexicographically


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICATES FOR MULTI-PATH COMPUTATION AND AGGREGATION


predicate cmql_value (
						CMAP: cmap,
						var int: x_origin_node,
						var int: x_destination_node,
						var int: x_nr_paths,
						array[int] of var int: x_arc_path_lengths,
						array[int,int] of var opt int: x_arc_paths,
						array[int,int] of var opt int: x_node_paths,
						array[int,int,int] of var opt int: x_iblock_paths,
						array[int,int,int] of var opt int: x_propagated_iblocks,
						array[int,int] of var opt int: x_iblocks,
						array[int,int] of var opt int: x_aggregated_iblocks,
						var INFLUENCE: x_aggregated_influence
		)
		:: "cmql_value($cmap,$x_origin_node,$x_destination_node,$x_nr_paths,$x_arc_path_lengths,$x_arc_paths,$x_node_paths,$x_iblock_paths,$x_propagated_iblocks,$x_iblocks,$x_aggregated_iblocks,$x_aggregated_influence): (var)"
	= 
	let {
		set of int: PATH_ID = index_set_1of2(x_arc_paths);
		set of int: ARC_PATH = index_set_2of2(x_arc_paths);
		set of int: NODE_PATH = index_set_2of2(x_node_paths);
		set of int: IBLOCK_COMPONENT = index_set(cmap.itype.iblock_type.sorts);
		array[PATH_ID] of var INFLUENCE: x_propagated_influences;
	} in
		% (1) origin and destination nodes must be different
		(x_origin_node != x_destination_node) /\
				
		% (2) bounding the number of solution paths
		(0 <= x_nr_paths) /\
		(x_nr_paths <= max(PATH_ID)) /\
		
		% (3) the number of solution paths is the number of paths whose length is positive
		x_nr_paths == count([(x_arc_path_lengths[i] != 0) | i in PATH_ID]) /\
		
		% (4-1) determining solution paths and propagation results
		forall(i in PATH_ID)(cmql_path_value(cmap, x_origin_node, x_destination_node, x_arc_path_lengths[i], x_arc_paths[i,ARC_PATH], x_node_paths[i,NODE_PATH], x_iblock_paths[i,ARC_PATH,IBLOCK_COMPONENT], x_propagated_iblocks[i,ARC_PATH,IBLOCK_COMPONENT], x_propagated_influences[i])) /\
		% (4-2) sorting solution paths lexicographically
		decreasing(x_arc_path_lengths) /\
		lex_less_opt(x_arc_path_lengths, x_node_paths) /\
		
		% (5) determining the propagated i-block of each path (x_iblocks)
% 		forall(i in PATH_ID)((i > x_nr_paths) <-> forall(j in IBLOCK_COMPONENT)(absent(x_iblocks[i,j]))) /\
% 		forall(i in PATH_ID)((i <= x_nr_paths) <-> forall(j in IBLOCK_COMPONENT)(occurs(x_iblocks[i,j]))) /\
% 		forall(i in PATH_ID)((i <= x_nr_paths) -> deopt(x_iblocks[i,IBLOCK_COMPONENT]) == deopt([x_propagated_iblocks[i,x_arc_path_lengths[i],k] | k in IBLOCK_COMPONENT])) /\

		% (6-1) deopting aggregated i-block occurrences based on the number of solution paths
		% - the i-th path occurs iff all the components of the i-th aggregated i-block occur
		% - the i-th path is absent iff all the components of the i-th aggregated i-block are absent
		% NB. every row access to x_aggregated_iblocks below is within bounds since PATH_ID is the row index set of x_aggregated_iblocks
% 		forall(i in PATH_ID)(i <= x_nr_paths <-> forall(j in IBLOCK_COMPONENT)(occurs(x_aggregated_iblocks[i,j]))) /\
% 		forall(i in PATH_ID)(i > x_nr_paths <-> forall(j in IBLOCK_COMPONENT)(absent(x_aggregated_iblocks[i,j]))) /\

		% (6-2) recursively computing the aggregated i-blocks by traversing the x_iblocks sequence
		% - the first occurring aggregated i-block is the first i-block (encoding the propagated influence of the first solution path)
		% - the i-th occurring aggregated i-block is the aggregation of the i-1-th aggregated block with the i-th i-block
		% NB. every row access to x_aggregated_iblocks below is within bounds since PATH_ID is the row index set of x_aggregated_iblocks
% 		((1 <= x_nr_paths) -> deopt(x_aggregated_iblocks[min(PATH_ID),IBLOCK_COMPONENT]) == deopt(x_iblocks[min(PATH_ID),IBLOCK_COMPONENT])) /\
% 		forall(i in min(PATH_ID)<..max(PATH_ID))
% 			((i <= x_nr_paths) -> deopt(x_aggregated_iblocks[i,IBLOCK_COMPONENT]) == iAggregate(deopt(x_aggregated_iblocks[i-1,IBLOCK_COMPONENT]), deopt(x_iblocks[i,IBLOCK_COMPONENT]))) /\
		
		% (7) determining the aggregated influence
		% - there is no solution path only if x_aggregated_influence is the null influence (ie. neutral element for i-aggregation)
% 		(x_nr_paths == 0 -> equals(x_aggregated_influence, getNullInfluence(cmap.itype))) /\ %(iblock: getAbsorbingElement(cmap.itype.ealgebra, ALGEBRAIC_OPERATION_2).value)) /\
% 		% - there exists solution paths only if x_aggregated_influence is the last occurring aggregated i-block
% 		(x_nr_paths > 0 -> x_aggregated_influence == (iblock: deopt([x_aggregated_iblocks[x_nr_paths,j] | j in IBLOCK_COMPONENT]))) /\
		
		true
    ;


% %
% predicate lex_strict_opt(array[int,int] of var opt int: a, set of int: col, set of int: line)
% 	=
% 	lex_chain_opt(a, col, line) /\
%   lex_chain_opt(array2d(index_set_2of2(a), index_set_1of2(a), [a[i, j] | j in index_set_2of2(a), i in index_set_1of2(a)]), line, col)
% ;

%
predicate lex_less_opt(array[int] of var int: x_length, array[int, int] of var opt int: x)
	=
	forall(i in min(index_set_1of2(x))..<max(index_set_1of2(x)))(
		lex_less_opt(x_length[i], x_length[i+1], x[i,index_set_2of2(x)], x[i+1,index_set_2of2(x)])
	)
;
		
%
predicate lex_less_opt(var int: x_length, var int: y_length, array[int] of var opt int: x, array[int] of var opt int: y)
	=
	let {
		int: lx = min(index_set(x));
		int: ly = min(index_set(y));
		int: size = card(index_set(x)) - 1;
		array[0..size+1] of var bool: b :: is_defined_var;
	} in
	if y_length == 0 then true
	else		x_length != 0
			/\	b[size + 1] = (x_length < y_length)  
			/\	forall(i in 0..size)(b[i] = (occurs(x[lx + i]) /\ occurs(y[lx + i]) /\ x[lx + i] <= y[ly + i] /\ (x[lx + i] <  y[ly + i] \/ b[i+1])))
					::defines_var(b)
			/\ b[0]
  endif
 ;


% %
% predicate lex_2_table_opt(array[int] of var opt int: X, array[int] of var opt int: Y)
% 	=
% 	((occurs(X[min(index_set(X))]) /\ occurs(Y[min(index_set(Y))])) -> deopt(X[min(index_set(X))]) <= deopt(Y[min(index_set(Y))])) /\
% 	(absent(X[min(index_set(X))]) -> absent(Y[min(index_set(Y))])) /\
% 	forall(i in index_set(X) where i < max(index_set(X)))((occurs(X[i]) /\ occurs(Y[i])) -> (X[i] == Y[i] -> X[i+1] <= Y[i+1])) /\
% 	count([X[i] != Y[i] | i in index_set(X)]) >= 1
% ;

% %
% predicate lex_strict(array[int,int] of var int: a, set of int: col, set of int: line)
% 	=
% 	lex_chain(a, col, line) /\
% 	lex_chain(array2d(index_set_2of2(a), index_set_1of2(a), [a[i, j] | j in index_set_2of2(a), i in index_set_1of2(a)]), line, col) % transpose
% ;

% % make sure that the columns of a array are lexicographically ordered
% predicate lex_chain(array[int, int] of var int: a, set of int: col, set of int: line)
% 	=
% 	forall(i in col, j in col)(i < j -> lex_2_table(a[line, i], a[line, j], col))
% ;

% % make sure the first array is lexicographically inferior to the other
% predicate lex_2_table(array[int] of var int: a, array[int] of var int: b, set of int: size)
% 	=
% 		a[min(size)] <= b[min(size)]
% 	/\	forall(i in size)((i < max(size) /\ a[i] == b[i]) -> a[i+1] <= b[i+1])
% 	/\	count([a[i] != b[i] | i in size]) >= 1
% ;
