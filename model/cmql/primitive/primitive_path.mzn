include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

include "alldifferent.mzn";

function ann: cmql_path_search(var bool: x_cmql_path, var int: x_origin_node, var int: x_destination_node)
	=
	seq_search([
		int_search([x_cmql_path], input_order, indomain_max),
		int_search([x_origin_node, x_destination_node], input_order, indomain_min)
	])
;

predicate cmql_path (
    array[int] of CMAP: cmaps,
	var int: cmap,
    var opt int: x_origin_node,
    var opt int: x_destination_node,	
    array[int] of var opt int: x_arc_path,
	array[int] of var opt int: x_node_path
) :: "cmql_path($cmap,$x_origin_node,$x_destination_node,$x_node_path,$x_arc_path)"
=
let {
		% cmap data
		set of int: N_CMAP = index_set(cmaps);
		set of int: NODE_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].node_labels)) | i in N_CMAP])].node_labels);
		set of int: ARC_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].arc_labels)) | i in N_CMAP])].arc_labels);		
		array[N_CMAP,ARC_ID] of NODE_ID: from = array2d(N_CMAP,ARC_ID, [cmaps[i].adigraph.tail_head[j, TAIL] | i in N_CMAP, j in ARC_ID]);
		array[N_CMAP,ARC_ID] of NODE_ID: to = array2d(N_CMAP,ARC_ID, [cmaps[i].adigraph.tail_head[j, HEAD] | i in N_CMAP, j in ARC_ID]);
		% indexing range for solution array
		set of int: ARC_PATH = index_set(x_arc_path);
		set of int: NODE_PATH = index_set(x_node_path);
		var int: x_path_length;
	} in
		assert(isProperRange(index_set(x_arc_path)), "cmql_arc_path: index set of $x_arc_path must be a proper range") /\
		% (1) origin and destination nodes must be different
		(x_origin_node != x_destination_node) /\
		
		% (2) binding the first and last occuring nodes to origin and destination nodes
		(x_node_path[min(NODE_PATH)] ~= x_origin_node) /\
		(x_node_path[x_path_length+1] ~= x_destination_node) /\

		% (3) path minimality based on the path-minimality feature configuration
		(DEOPT_F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE -> all_different(x_node_path)) /\
		(DEOPT_F_PATH_MINIMALITY == F_PATH_MINIMALITY_ARC -> all_different(x_arc_path)) /\

		% (4-1) matching arc and node occurrences
		(absent(x_arc_path[min(ARC_PATH)]) -> absent(x_node_path[min(NODE_PATH)])) /\
		forall(i in ARC_PATH)(absent(x_arc_path[i]) -> absent(x_node_path[i+1])) /\
		% (4-2) matching nodes with arcs
		% - the i-th occurring node is the tail of the i-th occurring arc
		% - the last occurring node is the head of the last occurring arc
		% NB. every access to x_node_path below is within bounds since max(ARC_PATH)<max(NODE_PATH)
		forall(i in ARC_PATH)(occurs(x_arc_path[i]) -> (x_node_path[i] == from[cmap,x_arc_path[i]] /\ x_node_path[i + 1] == to[cmap,x_arc_path[i]])) /\
		% (5) the length of the path is the number of occurring arcs in the arc path array and their maximum index
		% - every arc is absent if the length is 0
		% - every arc occurs if the next arc occurs
		%cmql_length(cmaps,cmap, x_arc_path,x_node_path, path_length) /\
		forall (i in ARC_PATH) (occurs(x_arc_path[i]) <-> x_path_length >= i) /\
		% (6) matching heads and tails of successive occurring arcs
		forall(i in min(ARC_PATH)<..max(ARC_PATH))(occurs(x_arc_path[i]) -> from[cmap,x_arc_path[i]] == to[cmap,x_arc_path[i-1]]) /\
		true
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

function array[int] of string: cmql_path_output (
	CMAP: cmap,
	var opt int: x_origin_node,
	var opt int: x_destination_node,
	array[int] of var opt int: x_node_path,
	array[int] of var opt int: x_arc_path
) :: "cmql_path_output($cmap,$x_origin_node,$x_destination_node,$x_arc_path_length,$x_arc_path)"
= 
let {
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_PATH = index_set(x_arc_path);
	} in
	[
		"Origin node: "] ++ [show(x_origin_node)] ++ ["\n"] ++
		["Destination node: "] ++ [show(x_destination_node)] ++ ["\n"] ++
		["Node path : "] ++ [show(x_node_path)] ++ ["\n"] ++
		["Arc path : "] ++ [show(x_arc_path)]
	;