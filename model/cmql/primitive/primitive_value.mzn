%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE: VALUE


%TODO API listing here



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

include "./../../cmql/primitive/primitive_path_value.mzn"; % for determining paths
include "count_eq.mzn"; % for counting paths
include "lex_less.mzn"; % for sorting paths lexicographically by sorting node sequences numerically



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEARCH STRATEGY PRIMITIVES FOR PATH COMPUTATION AND PROPAGATION

function ann: cmql_value_search(
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
						var INFLUENCE: x_aggregated_influence,
						var bool: x_cmql_value
		)
	=
	seq_search([
		
		int_search([x_cmql_value], input_order, indomain_max),
		int_search([x_origin_node, x_destination_node], input_order, indomain_min),		
		int_search([x_nr_paths], input_order, indomain_max),
		int_search(x_arc_path_lengths, input_order, indomain_min),
		int_search([x_arc_paths[i,j] | i in index_set_1of2(x_arc_paths), j in index_set_2of2(x_arc_paths)], input_order, indomain_min),
		int_search([x_node_paths[i,j] | i in index_set_1of2(x_node_paths), j in index_set_2of2(x_node_paths)], input_order, indomain_min),
		int_search([x_iblock_paths[i,j,k] | i in index_set_1of3(x_iblock_paths), j in index_set_2of3(x_iblock_paths), k in index_set_3of3(x_iblock_paths)], input_order, indomain_min),
		int_search([x_propagated_iblocks[i,j,k] | i in index_set_1of3(x_propagated_iblocks), j in index_set_2of3(x_propagated_iblocks), k in index_set_3of3(x_propagated_iblocks)], input_order, indomain_min),
		int_search([x_iblocks[i,j] | i in index_set_1of2(x_iblocks), j in index_set_2of2(x_iblocks)], input_order, indomain_min),
		int_search([x_aggregated_iblocks[i,j] | i in index_set_1of2(x_aggregated_iblocks), j in index_set_2of2(x_aggregated_iblocks)], input_order, indomain_min),
	])
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICATES FOR MULTI-PATH COMPUTATION AND AGGREGATION

% Determines a (possibly empty) set of dipaths in a c-map such that:
% - $cmap is the reference c-map
% - $x_origin_node is the origin node of every dipath
% - $x_destination_node is the destination node of every dipath
% - $x_nr_paths is the number of dipaths
%	-- $x_nr_paths==0 is no dipath connecting origin and destination nodes exists in the c-map's digraph
% - $x_arc_path_lengths[i] is the length of the i-th dipath
%	-- $x_arc_path_lengths[i]==0 is the i-th dipath is empty
% -- the dipaths are sorted by ascending length up the last non-empty dipath and empty dipaths occupy the last positions
% -- dipaths of the same length are sorted lexicographically in ascending order of arc id sequences
% - $x_arc_paths[i] is the sequence of arcs connecting the origin and destination nodes in the i-th dipath, completed with absent arcs to fill the opt array
% -- the sequence is empty iff the length of the dipath is 0
% -- the sequence forms a dipath in the digraph of the c-map 
% -- the sequence is arc-minimal if required by the path-minimality feature
% - $x_node_paths[i] is the sequence of nodes including and connecting the origin and destination nodes along the i-th dipath in the c-map digraph, completed with absent nodes to fill the opt array
% -- the sequence is empty the length of the dipath is 0
% -- the sequence forms a dipath in the digraph of the c-map 
% -- the sequence is path-minimal if required by the path-minimality feature
% - $x_iblock_paths[i] is the sequence of i-blocks encoding the influences labeling the arcs of the i-th dipath, completed with absent i-blocks to fill the opt array
% -- the sequence is empty (ie. the array only contains absent i-blocks) iff the length of the dipath is 0
% - $x_propagated_iblocks[i] is the series of i-blocks obtained by recursive influence propagation through the i-th sequence of i-blocks starting from the first i-block, finishing at the last, and completed with absent i-blocks to fill the opt array
% -- the series is empty iff the length of the dipath is 0
% - $x_iblocks[i] is the i-th value of $x_propagated_iblocks
% - $x_aggregated_iblocks is the series of i-blocks obtained by recursive influence aggregation through the sequence x_iblocks starting from the first i-block, finishing at the last, and completed with absent i-blocks to fill the opt array
% -- the series is empty iff no dipath exists between origin and destination nodes in the c-map digraph
% - $x_aggregated_influence is the influence aggregated through the dipaths
% -- it is equal to the null influence iff no dipath exists between origin and destination nodes in the c-map digraph
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
		:: "cmql_value($cmap,$x_origin_node,$x_destination_node,$x_nr_paths,$x_arc_path_lengths,$x_arc_paths,$x_node_paths,$x_iblock_paths,$x_propagated_iblocks,$x_iblocks,$x_aggregated_iblocks,$x_aggregated_influence): determines and sorts a number of dipaths $x_nr_paths of lengths $x_arc_path_lengths connecting $x_origin_node to $x_destination_node in $cmap's digraph together with the associated arrays of arc sequences $x_arc_paths, node sequences $x_node_paths, arc i-block sequences $x_iblock_paths, path propagation series $x_propagated_iblocks, path propagation results $x_iblocks, path aggregation series of i-blocks $x_aggregated_iblocks, and aggregated influence $x_aggregated_influence( var)"
	= 
	let {
		set of int: PATH_ID = index_set_1of2(x_arc_paths);
		set of int: ARC_PATH = index_set_2of2(x_arc_paths);
		set of int: NODE_PATH = index_set_2of2(x_node_paths);
		set of int: IBLOCK_COMPONENT = index_set(cmap.itype.iblock_type.sorts);
		array[PATH_ID] of var INFLUENCE: x_propagated_influences
	} in
		assert(index_set(x_arc_path_lengths) == PATH_ID, "cmql_value: the index set of $x_arc_path_lengths must be equal to the range of possible paths in the c-map between 2 nodes") /\
		assert(index_set_2of2(x_arc_paths) == ARC_PATH, "cmql_value: the column index set of $x_arc_paths must be equal to the range of possible arc sequences in the c-map between 2 nodes") /\
		assert(index_set_3of3(x_iblock_paths) == IBLOCK_COMPONENT, "cmql_value: the 3rd index set of $x_iblock_paths must be equal to the i-block-type encoding range of $cmap's i-type") /\
		assert(isProperRange(index_set(x_arc_path_lengths)), "cmql_value: the index set of $x_arc_path_lengths must be a proper range") /\
		assert(index_set(x_arc_path_lengths) == index_set_1of2(x_arc_paths), "cmql_value: the index set of $x_arc_path_lengths must be equal to the row index set of $x_arc_paths") /\
		assert(index_set(x_arc_path_lengths) == index_set_1of2(x_node_paths), "cmql_value: the index set of $x_arc_path_lengths must be equal to the row index set of $x_node_paths") /\
		assert(index_set(x_arc_path_lengths) == index_set_1of3(x_iblock_paths), "cmql_value: the index set of $x_arc_path_lengths must be equal to the row index set of $x_iblock_paths") /\
		assert(index_set(x_arc_path_lengths) == index_set_1of3(x_propagated_iblocks), "cmql_value: the index set of $x_arc_path_lengths must be equal to the row index set of $x_propagated_iblocks") /\
		assert(index_set(x_arc_path_lengths) == index_set_1of2(x_iblocks), "cmql_value: the index set of $x_arc_path_lengths must be equal to the row index set of $x_iblocks") /\
		assert(index_set(x_arc_path_lengths) == index_set_1of2(x_aggregated_iblocks), "cmql_value: the index set of $x_arc_path_lengths must be equal to the row index set of $x_aggregated_iblocks") /\
		assert(isProperRange(index_set_2of2(x_arc_paths)), "cmql_value: the column index set of $x_arc_paths must be a proper range") /\
		assert(index_set_2of2(x_arc_paths) == index_set_2of3(x_iblock_paths), "cmql_arc_influence_path: the column index set of $x_arc_paths must be equal to the column index set of $x_iblock_paths") /\
		assert(isProperRange(index_set_3of3(x_iblock_paths)), "cmql_value: the 3rd index set of $x_iblock_paths must be a proper range") /\
		assert(index_set_3of3(x_iblock_paths) == index_set_3of3(x_propagated_iblocks), "cmql_arc_influence_path: the 3rd index set of $x_iblock_paths must be equal to the 3rd index set of $x_propagated_iblocks") /\
		assert(index_set_3of3(x_iblock_paths) == index_set_2of2(x_iblocks), "cmql_arc_influence_path: the 3rd index set of $x_iblock_paths must be equal to the column index set of $x_iblocks") /\
		assert(index_set_3of3(x_iblock_paths) == index_set_2of2(x_aggregated_iblocks), "cmql_arc_influence_path: the 3rd index set of $x_iblock_paths must be equal to the column index set of $x_aggregated_iblocks") /\

		% (1) origin and destination nodes must be different
		(x_origin_node != x_destination_node) /\

		% (2) bounding the number of solution paths
		(0 <= x_nr_paths) /\
		(x_nr_paths <= max(PATH_ID)) /\
		
		% (3) the number of solution paths is the number of paths whose length is positive
		count_eq(x_arc_path_lengths, 0, card(PATH_ID) - x_nr_paths) /\
				
		% (4-1) determining solution paths and propagation results
		forall(i in PATH_ID)(cmql_path_value(cmap, x_origin_node,x_destination_node,x_arc_path_lengths[i], x_arc_paths[i,ARC_PATH], x_node_paths[i,NODE_PATH], x_iblock_paths[i,ARC_PATH,IBLOCK_COMPONENT], x_propagated_iblocks[i,ARC_PATH,IBLOCK_COMPONENT], x_propagated_influences[i])) /\
 		% (4-2) sorting solution paths lexicographically by ascending path length first then ascending arc ids
		lex_chain_less_opt(x_nr_paths, x_arc_path_lengths, x_arc_paths) /\
		% (4-3) check that all path begin with the origin node and end with destination node
		forall (i in PATH_ID)(i <= x_nr_paths -> (x_origin_node == x_node_paths[i,min(NODE_PATH)] /\ x_destination_node = x_node_paths[i,x_arc_path_lengths[i]+1])) /\
		% (5) determining the propagated i-block of each path (x_iblocks)
% 		forall(i in PATH_ID)(i <= x_nr_paths <-> forall(j in IBLOCK_COMPONENT)(occurs(x_iblocks[i,j]))) /\ % entailed by next+1 constraint
		forall(i in PATH_ID)(i > x_nr_paths -> forall(j in IBLOCK_COMPONENT)(absent(x_iblocks[i,j]))) /\
		forall(i in PATH_ID)(i <= x_nr_paths -> forall(j in IBLOCK_COMPONENT)(deopt(x_iblocks[i,j]) == element(i, x_arc_path_lengths[i],j, x_propagated_iblocks))) /\ % !! keep deopt on x_iblocks !!

		% (6-1) deopting aggregated i-block occurrences based on the number of solution paths
		% - the i-th path occurs iff all the components of the i-th aggregated i-block occur
		% - the i-th path is absent only if all the components of the i-th aggregated i-block are absent
		% NB. every row access to x_aggregated_iblocks below is within bounds since PATH_ID is the row index set of x_aggregated_iblocks
% 		forall(i in PATH_ID)(i <= x_nr_paths <-> forall(j in IBLOCK_COMPONENT)(occurs(x_aggregated_iblocks[i,j]))) /\ % entailed by (6-2)
		forall(i in PATH_ID)(i > x_nr_paths -> forall(j in IBLOCK_COMPONENT)(absent(x_aggregated_iblocks[i,j]))) /\

		% (6-2) recursively computing the aggregated i-blocks by traversing the x_iblocks sequence
		% - the first occurring aggregated i-block is the first i-block (encoding the propagated influence of the first solution path)
		% - the i-th occurring aggregated i-block is the aggregation of the i-1-th aggregated block with the i-th i-block
		% NB. every row access to x_aggregated_iblocks below is within bounds since PATH_ID is the row index set of x_aggregated_iblocks
		(x_aggregated_iblocks[min(PATH_ID),IBLOCK_COMPONENT] == x_iblocks[min(PATH_ID),IBLOCK_COMPONENT]) /\
		forall(i in min(PATH_ID)<..max(PATH_ID))
			((i <= x_nr_paths) -> x_aggregated_iblocks[i,IBLOCK_COMPONENT] == iAggregate(deopt(x_aggregated_iblocks[i-1,IBLOCK_COMPONENT]), deopt(x_iblocks[i,IBLOCK_COMPONENT]))) /\

		% (7) determining the aggregated influence
		% - there is no solution path only if x_aggregated_influence is the null influence (ie. neutral element for i-aggregation)
		(x_nr_paths == 0 -> equals(x_aggregated_influence, getNullInfluence(cmap.itype))) /\ %(iblock: getAbsorbingElement(cmap.itype.ealgebra, ALGEBRAIC_OPERATION_2).value)) /\
		% - there exists solution paths only if x_aggregated_influence is the last occurring aggregated i-block
		(x_nr_paths > 0 -> x_aggregated_influence == (iblock: [x_aggregated_iblocks[x_nr_paths,j] | j in IBLOCK_COMPONENT])) /\

		true
    ;


%
predicate lex_chain_less_opt(var int: x_on, array[int] of var int: x_lengths, array[int, int] of var opt int: x)
	=
	increasing_opt_lengths(x_on, x_lengths) /\
	assert(index_set(x_lengths) == index_set_1of2(x), "lex_chain_less_opt: the index set of $x_lengths must be equal to the row index set of $x") /\
	forall(i in min(index_set_1of2(x))..<max(index_set_1of2(x)))(
		lex_less_opt(x_lengths[i], x_lengths[i+1], x[i,index_set_2of2(x)], x[i+1,index_set_2of2(x)])
	)
;
		
%
predicate increasing_opt_lengths(var int: y, array[int] of var int: x)
	=
	forall(i in index_set(x))(i <= y <-> x[i] != 0) /\
	forall(i in min(index_set(x))..<max(index_set(x)))(i+1 <= y -> x[i] <= x[i+1])
;
		
%
predicate lex_less_opt(var int: x_length, var int: y_length, array[int] of var opt int: x, array[int] of var opt int: y)
	=
	assert(isProperRange(index_set(x)), "lex_less_opt: the index set of $x is a proper range") /\
	assert(index_set(x) == index_set(y), "lex_less_opt: the index sets of $x and $y must be equal") /\
	let {
		int: size = length(x);
		array[0..size] of var bool: b :: is_defined_var;
	} in
	if y_length == 0 \/ x_length != y_length
	then
		 	forall(i in 0..size)(b[i])
	else	
% 			x_length > 0 /\ % !! entailed by increasing_opt_lengths
% 			x_length <= y_length /\ !! entailed by increasing_opt_lengths
			b[size] = (x_length < y_length) /\
			forall(i in 0..size-1)(b[i] = ((x[1 + i] <= y[1 + i]) /\ ((x[1 + i] <  y[1 + i] /\ (occurs(y[i+1]) \/ occurs(x[i+1])))\/ b[i+1]))) /\ % !! simplification of next constraint due to cmql_path_value/cmql_arc_path
% 			forall(i in 0..size-1)(b[i] = (occurs(x[1 + i]) /\ occurs(y[1 + i])) -> (x[1 + i] <= y[1 + i] /\ (x[1 + i] <  y[1 + i] \/ b[i+1]))) /\
			b[0]
  endif
  :: defines_var(b)
 ;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: cmql_value_output(
						CMAP: cmap,
						var int: x_nr_paths,
						array[int] of var int: x_arc_path_lengths,
						array[int,int] of var opt int: x_arc_paths,
						array[int,int] of var opt int: x_node_paths,
						array[int,int,int] of var opt int: x_iblock_paths,
						array[int,int,int] of var opt int: x_propagated_iblocks,
						array[int,int] of var opt int: x_iblocks,
						array[int,int] of var opt int: x_aggregated_iblocks,
						var INFLUENCE: x_aggregated_influence)
	=
	let {
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_ID = index_set(cmap.arc_labels);
		set of int: PATH_ID = index_set_1of2(x_arc_paths);
		set of int: NODE_PATH = index_set_2of2(x_node_paths);
		set of int: ARC_PATH = index_set_2of2(x_arc_paths);
		set of int: IBLOCK_COMPONENT = index_set_3of3(x_iblock_paths);
		string: PATH_SEPARATOR = ":";
		string: NO_NODE = "__";
		string: NEXT_NODE_PATH = "\n\t\t\t";
		string: NO_ARC = "_____";
		string: NEXT_ARC_PATH = "\n\t\t\t";
		string: NO_IBLOCK = "__";
		string: NEXT_IBLOCK_PATH = "\n\t\t\t";
	} in
		["NODE_ID\t\t\t"]
	++	[ show(NODE_ID)]
	++	["\n"]
	++	["NODE_PATH\t\t"]
	++	[ show(NODE_PATH)]
	++	["\n"]
	++	["ARC_ID\t\t\t"]
	++	[ show(ARC_ID)]
	++	["\n"]
	++	["ARC_PATH\t\t"]
	++	[ show(ARC_PATH)]
	++	["\n"]
	++	["IBLOCK_COMPONENT\t"]
	++	[ show(IBLOCK_COMPONENT)]
	++	["\n"]
	++	["PATH_ID =\t\t"]
	++	[ show(PATH_ID)]
	++	["\n"]
	++	["Number of paths\t\t"]
	++	[ show(x_nr_paths)]
	++	["\n"]
	++	["Path lengths\t\t"]
	++	[ show(x_arc_path_lengths)]
	++	["\n"]
	++	["Node paths\t\t"]
	++	[if j==min(index_set_2of2(x_node_paths)) then "path " ++ show(i) ++ ":\t" endif ++ if occurs(fix(x_node_paths[i,j])) then cmap.node_labels[fix(deopt(x_node_paths[i,j]))].concept.name else NO_NODE endif ++ if j < max(index_set_2of2(x_node_paths)) then PATH_SEPARATOR else NEXT_NODE_PATH endif | i in index_set_1of2(x_node_paths), j in index_set_2of2(x_node_paths)]
	++	["\n"]
	++	["Arc paths\t\t"]
	++	[if j==min(index_set_2of2(x_arc_paths)) then "path " ++ show(i) ++ ":\t" endif ++ if occurs(fix(x_arc_paths[i,j])) then "(" ++ show(cmap.arc_labels[fix(deopt(x_arc_paths[i,j]))].arc.t) ++ "," ++ show(cmap.arc_labels[fix(deopt(x_arc_paths[i,j]))].arc.h) ++ ")" else NO_ARC endif ++ if j < max(index_set_2of2(x_arc_paths)) then PATH_SEPARATOR else NEXT_ARC_PATH endif | i in index_set_1of2(x_arc_paths), j in index_set_2of2(x_arc_paths)]
	++	["\n"]
	++	["I-block paths\t\t"]
	++	[if j==min(index_set_2of3(x_iblock_paths)) then "path " ++ show(i) ++ ":\t" endif ++ showInfluence((iblock: fix(x_iblock_paths[i,j,index_set_3of3(x_iblock_paths)]))) ++ if j < max(index_set_2of3(x_iblock_paths)) then PATH_SEPARATOR else NEXT_IBLOCK_PATH endif | i in index_set_1of3(x_iblock_paths), j in index_set_2of3(x_iblock_paths)]
	++	["\n"]
	++	["Propagated i-paths\t"]
	++	[if j==min(index_set_2of3(x_propagated_iblocks)) then "path " ++ show(i) ++ ":\t" endif ++ showInfluence((iblock: fix(x_propagated_iblocks[i,j,index_set_3of3(x_propagated_iblocks)]))) ++ if j < max(index_set_2of3(x_propagated_iblocks)) then PATH_SEPARATOR else NEXT_IBLOCK_PATH endif | i in index_set_1of3(x_propagated_iblocks), j in index_set_2of3(x_propagated_iblocks)]
	++	["\n"]
	++	["I-blocks to aggregate\t"]
	++	["path " ++ show(i) ++ ":\t" ++ showInfluence((iblock: fix(x_iblocks[i,index_set_2of2(x_iblocks)]))) ++ NEXT_IBLOCK_PATH | i in index_set_1of2(x_iblocks)]
	++	["\n"]
	++	["Aggregation trace\t"]
	++	["path " ++ show(i) ++ ":\t" ++ showInfluence((iblock: fix(x_aggregated_iblocks[i,index_set_2of2(x_aggregated_iblocks)]))) ++ NEXT_IBLOCK_PATH | i in index_set_1of2(x_aggregated_iblocks)]
	++	["\n"]
	++	["Aggregated influence\t"]
	++	[showInfluence(fix(x_aggregated_influence)) ++ " == " ++ show(fix(x_aggregated_influence))]
	++	["\n"]
	;