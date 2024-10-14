%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE: PATH_VALUE


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

include "alldifferent.mzn"; % for path minimality feature



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEARCH STRATEGY PRIMITIVES FOR PATH COMPUTATION AND PROPAGATION

function ann: cmql_path_value_search(var int: x_origin_node, var int: x_destination_node, var int: x_arc_path_length, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int, int] of var opt int: x_iblock_path, array[int, int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence, var bool: x_cmql_path_value)
	=
	seq_search([
		int_search([x_cmql_path_value], input_order, indomain_max),
		int_search([x_origin_node, x_destination_node], input_order, indomain_min),
		int_search([x_arc_path_length], input_order, indomain_min)
	])
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICATES FOR PATH COMPUTATION AND PROPAGATION

% Determines a (possibly empty) dipath in a c-map such that:
% - $cmap is the reference c-map
% - $x_origin_node is the origin node of the dipath
% - $x_destination_node is the destination node of the dipath
% - $x_arc_path is the sequence of arcs connecting the origin and destination nodes in the dipath, completed with absent arcs to fill the opt array
% -- the sequence is empty (ie. the array only contains absent arc ids) iff no dipath exists between origin and destination nodes in the c-map digraph
% -- the sequence forms a dipath in the digraph of the c-map 
% -- the sequence is arc-minimal if required by the path-minimality feature
% - $x_arc_path_length is the length of the sequence of arcs
% -- the length is 0 iff the sequence of arcs is empty
% - $x_node_path is the sequence of nodes including and connecting the origin and destination nodes along the dipath in the c-map digraph, completed with absent nodes to fill the opt array
% -- the sequence is empty (ie. the array only contains absent node ids) iff no dipath exists between origin and destination nodes in the c-map digraph
% -- the sequence forms a dipath in the digraph of the c-map 
% -- the sequence is path-minimal if required by the path-minimality feature
% - $x_iblock_path is the sequence of i-blocks encoding the influences labeling the arcs of the dipath, completed with absent i-blocks to fill the opt array
% -- the sequence is empty (ie. the array only contains absent i-blocks) iff no dipath exists between origin and destination nodes in the c-map digraph
% - $x_propagated_iblocks is the series of i-blocks obtained by recursive influence propagation through the sequence of i-blocks starting from the first i-block, finishing at the last, and completed with absent i-blocks to fill the opt array
% -- the series is empty iff no dipath exists between origin and destination nodes in the c-map digraph
% - $x_propagated_influence is the influence propagated through the dipath
% -- it is equal to the null influence iff no dipath exists between origin and destination nodes in the c-map digraph
predicate cmql_path_value(
						array[int] of CMAP: cmaps,
						var int: cmap,
						var int: x_origin_node,
						var int: x_destination_node,
						var int: x_arc_path_length,
						array[int] of var opt int: x_arc_path,
						array[int] of var opt int: x_node_path,
						array[int, int] of var opt int: x_iblock_path,
						array[int, int] of var opt int: x_propagated_iblocks,
						var INFLUENCE: x_propagated_influence
					)
	:: "cmql_path_value($cmap,$x_origin_node,$x_destination_node,$x_arc_path,$x_node_path,$x_iblock_path,$x_propagated_iblocks,$x_propagated_influence): determines a dipath connecting $x_origin_node to $x_destination_node in $cmap's digraph and the associated arc sequence $x_arc_path, node sequence $x_node_path, i-block sequence $x_iblock_path, i-block propagation series $x_propagated_iblocks and propagated influence $x_propagated_influence (var)"
	=
	let {
		set of int: NODE_PATH = index_set(x_node_path);
		set of int: ARC_PATH = index_set(x_arc_path);
	} in
		assert(index_set_1of2(x_propagated_iblocks) == index_set(x_arc_path), "cmql_path_value: the row index set of $x_propagated_iblocks  must be equal to the index set of $x_arc_path") /\
		assert(index_set_2of2(x_propagated_iblocks) == index_set(cmaps[1].itype.iblock_type.sorts), "cmql_path_value: the column index set of $x_propagated_iblocks must be equal to the i-block-type encoding range of $cmap's i-type") /\

		% (1) origin and destination nodes must be different
		(x_origin_node != x_destination_node) /\
				
		% (2) bounding x_arc_path_length
		(0 <= x_arc_path_length) /\
		(x_arc_path_length <= max(ARC_PATH)) /\
		
		% (3) binding the first and last occuring nodes to origin and destination nodes
		(x_node_path[min(NODE_PATH)] ~= x_origin_node) /\
		(x_node_path[x_arc_path_length+1] ~= x_destination_node) /\

		% (4-1) determining a sequence of arcs corresponding to a minimal dipath of the right length in the c-map
		cmql_arc_path(cmaps,cmap, x_arc_path_length, x_arc_path) /\
		% (4-2) determining minimal consistent arc and node sequences
		cmql_arc_node_path(cmaps,cmap, x_arc_path, x_node_path) /\
		% (4-3) determining consistent arc and i-block sequences	
		cmql_arc_influence_path(cmaps,cmap, x_arc_path, x_iblock_path) /\

		% (5-1) matching arc and propagated i-block occurrences
		% - the i-th arc occurs iff all the components of the i-th propagated i-block occur
		% - the i-th arc is absent iff all the components of the i-th propagated i-block are absent
		% NB. every row access to x_propagated_iblocks below is within bounds since ARC_PATH is the row index set of x_propagated_iblocks
% 		forall(i in ARC_PATH)(occurs(x_arc_path[i]) <-> forall(j in IBLOCK_COMPONENT)(occurs(x_propagated_iblocks[i,j]))) /\ % entailed by (6)
		forall(i in ARC_PATH)(absent(x_arc_path[i]) -> forall(j in IBLOCK_COMPONENT)(absent(x_propagated_iblocks[i,j]))) /\

		% (5-2) recursively computing the propagated i-blocks by traversing the i-block sequence
		% - the first occurring propagated i-block is the first i-block (encoding the influence of the first occurring arc)
		% - the i-th occurring propagated i-block is the propagation of the i-1-th propagated block with the i-th i-block
		% NB. every row access to x_propagated_iblocks below is within bounds since ARC_PATH is the row index set of x_propagated_iblocks
		(x_propagated_iblocks[min(ARC_PATH),IBLOCK_COMPONENT] == x_iblock_path[min(ARC_PATH),IBLOCK_COMPONENT]) /\
		forall(i in min(ARC_PATH)<..max(ARC_PATH))
			(occurs(x_arc_path[i]) -> x_propagated_iblocks[i,IBLOCK_COMPONENT] == iPropagate(deopt(x_propagated_iblocks[i-1,IBLOCK_COMPONENT]), deopt(x_iblock_path[i,IBLOCK_COMPONENT]))) /\

		% (6) determining the propagated influence
		% - the solution path is empty only if x_propagated_influence is the null influence (ie. absorbing element for i-propagation)
		(x_arc_path_length == 0 -> equals(x_propagated_influence, getNullInfluence(cmaps[1].itype))) /\ %(iblock: getAbsorbingElement(cmap.itype.ealgebra, ALGEBRAIC_OPERATION_2).value)) /\
		% - the solution path is not empty only if x_propagated_influence is the last occurring propagated i-block
		(x_arc_path_length > 0 -> x_propagated_influence == (iblock: [x_propagated_iblocks[x_arc_path_length,j] | j in IBLOCK_COMPONENT])) /\

		
		true
	;


predicate cmql_path_value_fixed(
						CMAP: cmap,
						int: origin_node,
						int: destination_node,
						var int: x_arc_path_length,
						array[int] of var opt int: x_arc_path,
						array[int] of var opt int: x_node_path,
						array[int, int] of var opt int: x_iblock_path,
						array[int, int] of var opt int: x_propagated_iblocks,
						var INFLUENCE: x_propagated_influence
					)
	:: "cmql_path_value_fixed($cmap,$origin_node,$destination_node,$x_arc_path,$x_node_path,$x_iblock_path,$x_propagated_iblocks,$x_propagated_influence): determines a dipath connecting $x_origin_node to $x_destination_node in $cmap's digraph and the associated arc sequence $x_arc_path, node sequence $x_node_path, i-block sequence $x_iblock_path, i-block propagation series $x_propagated_iblocks and propagated influence $x_propagated_influence (var)"
	=
	let {
		set of int: NODE_PATH = index_set(x_node_path);
		set of int: ARC_PATH = index_set(x_arc_path);
	} in
		assert(index_set_1of2(x_propagated_iblocks) == index_set(x_arc_path), "cmql_path_value: the row index set of $x_propagated_iblocks  must be equal to the index set of $x_arc_path") /\
		assert(index_set_2of2(x_propagated_iblocks) == index_set(cmap.itype.iblock_type.sorts), "cmql_path_value: the column index set of $x_propagated_iblocks must be equal to the i-block-type encoding range of $cmap's i-type") /\

			
		% (2) bounding x_arc_path_length
		(0 <= x_arc_path_length) /\
		(x_arc_path_length <= max(ARC_PATH)) /\
		
		% (3) binding the first and last occuring nodes to origin and destination nodes
		(x_node_path[min(NODE_PATH)] ~= origin_node) /\
		(x_node_path[x_arc_path_length+1] ~= destination_node) /\

		% (4-1) determining a sequence of arcs corresponding to a minimal dipath of the right length in the c-map
		%cmql_arc_path(cmap, x_arc_path_length, x_arc_path) /\
		% (4-2) determining minimal consistent arc and node sequences
		%cmql_arc_node_path(cmap, x_arc_path, x_node_path) /\
		% (4-3) determining consistent arc and i-block sequences	
		%cmql_arc_influence_path(cmap, x_arc_path, x_iblock_path) /\

		% (5-1) matching arc and propagated i-block occurrences
		% - the i-th arc occurs iff all the components of the i-th propagated i-block occur
		% - the i-th arc is absent iff all the components of the i-th propagated i-block are absent
		% NB. every row access to x_propagated_iblocks below is within bounds since ARC_PATH is the row index set of x_propagated_iblocks
% 		forall(i in ARC_PATH)(occurs(x_arc_path[i]) <-> forall(j in IBLOCK_COMPONENT)(occurs(x_propagated_iblocks[i,j]))) /\ % entailed by (6)
		forall(i in ARC_PATH)(absent(x_arc_path[i]) -> forall(j in IBLOCK_COMPONENT)(absent(x_propagated_iblocks[i,j]))) /\

		% (5-2) recursively computing the propagated i-blocks by traversing the i-block sequence
		% - the first occurring propagated i-block is the first i-block (encoding the influence of the first occurring arc)
		% - the i-th occurring propagated i-block is the propagation of the i-1-th propagated block with the i-th i-block
		% NB. every row access to x_propagated_iblocks below is within bounds since ARC_PATH is the row index set of x_propagated_iblocks
		(x_propagated_iblocks[min(ARC_PATH),IBLOCK_COMPONENT] == x_iblock_path[min(ARC_PATH),IBLOCK_COMPONENT]) /\
		forall(i in min(ARC_PATH)<..max(ARC_PATH))
			(occurs(x_arc_path[i]) -> x_propagated_iblocks[i,IBLOCK_COMPONENT] == iPropagate(deopt(x_propagated_iblocks[i-1,IBLOCK_COMPONENT]), deopt(x_iblock_path[i,IBLOCK_COMPONENT]))) /\

		% (6) determining the propagated influence
		% - the solution path is empty only if x_propagated_influence is the null influence (ie. absorbing element for i-propagation)
		(x_arc_path_length == 0 -> equals(x_propagated_influence, getNullInfluence(cmap.itype))) /\ %(iblock: getAbsorbingElement(cmap.itype.ealgebra, ALGEBRAIC_OPERATION_2).value)) /\
		% - the solution path is not empty only if x_propagated_influence is the last occurring propagated i-block
		(x_arc_path_length > 0 -> x_propagated_influence == (iblock: [x_propagated_iblocks[x_arc_path_length,j] | j in IBLOCK_COMPONENT])) /\
		
		true
	;

% Determines minimal consistent arc path $x_arc_path and node path $x_node_path wrt. cmap $cmap and path-minimality feature.
predicate cmql_arc_node_path(array[int] of CMAP: cmaps, var int: cmap, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path)
	:: "cmql_arc_node_path($cmap,$x_arc_path,$x_node_path): determines minimal consistent arc path $x_arc_path and node path $x_node_path wrt. cmap $cmap and path-minimality feature (var)"
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
	} in
		assert(max(index_set(x_node_path)) == 1 + max(index_set(x_arc_path)), "cmql_arc_node_path: index sets of $x_node_path and $x_node_path must be consistent") /\

		% (1) path minimality based on the path-minimality feature configuration
		% - if node-wise path minimality, all nodes must be different in the path
		(DEOPT_F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE -> all_different(x_node_path)) /\ % all_different on optional array is supported and relaxed wrt. opt values - see fzn_all_different_int_opt
		
		% (2) matching arc and node occurrences
		% - the i-th node occurs if the i+1-th node occurs
		% - the 1st arc is absent only if the first node is absent
		% - the i-th arc is absent only if the i+1-th node is absent
		% NB. every access to x_node_path below is within bounds since max(ARC_PATH)<max(NODE_PATH)
% 		forall(i in min(NODE_PATH)<..max(NODE_PATH))(occurs(x_node_path[i-1]) <- occurs(x_node_path[i])) /\
		(absent(x_arc_path[min(ARC_PATH)]) -> absent(x_node_path[min(NODE_PATH)])) /\
		forall(i in ARC_PATH)(absent(x_arc_path[i]) -> absent(x_node_path[i+1])) /\
		
		% (3) matching nodes with arcs
		% - the i-th occurring node is the tail of the i-th occurring arc
		% - the last occurring node is the head of the last occurring arc
		% NB. every access to x_node_path below is within bounds since max(ARC_PATH)<max(NODE_PATH)
		forall(i in ARC_PATH)(occurs(x_arc_path[i]) -> (x_node_path[i] == from[cmap,x_arc_path[i]] /\ x_node_path[i + 1] == to[cmap,x_arc_path[i]])) /\

		true
	;


% Determines consistent arc path $x_arc_path and i-block path $x_iblock_path wrt. cmap $cmap.
predicate cmql_arc_influence_path(array[int] of CMAP: cmaps, var int: cmap, array[int] of var opt int: x_arc_path, array[int, int] of var opt int: x_iblock_path)
	:: "cmql_arc_influence_path($cmap,$x_arc_path,$x_iblock_path): determines consistent arc path $x_arc_path and i-block path $x_iblock_path wrt. cmap $cmap"
	=
	let {
		% cmap data
		set of int: N_CMAP = index_set(cmaps);
		set of int: ARC_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].arc_labels)) | i in N_CMAP])].arc_labels);
		set of int: IBLOCK_COMPONENT = index_set(cmaps[1].itype.iblock_type.sorts);
		array[N_CMAP,ARC_ID, IBLOCK_COMPONENT] of opt int: iblocks = array3d(N_CMAP,ARC_ID, IBLOCK_COMPONENT, [cmaps[k].arc_labels[i].influence.iblock[j] | k in N_CMAP, i in ARC_ID, j in IBLOCK_COMPONENT]);
		% indexing range for solution arrays
		set of int: ARC_PATH = index_set(x_arc_path);
	} in
		assert(index_set_1of2(x_iblock_path) == index_set(x_arc_path), "cmql_arc_influence_path: the row index set of $x_iblock_path  must be equal to the index set of $x_arc_path") /\
		assert(index_set_2of2(x_iblock_path) == index_set(cmaps[1].itype.iblock_type.sorts), "cmql_arc_influence_path: the column index set of $x_iblock_path must be equal to the i-block-type encoding range of $cmap's i-type") /\

		% (1) matching arc and i-block (row in i-block path array) occurrences
		% - the i-th arc occurs iff all the components of the i-th i-block occur
		% - the i-th arc is absent only if all the component elements of the i-th i-block are absent
		% NB. every row access to x_iblock_path below is within bounds since ARC_PATH is the row index set of x_iblock_path
% 		forall(i in ARC_PATH)(occurs(x_arc_path[i]) <-> forall(j in IBLOCK_COMPONENT)(occurs(x_iblock_path[i,j]))) /\ % !! entailed by (2)
		forall(i in ARC_PATH)(absent(x_arc_path[i]) -> forall(j in IBLOCK_COMPONENT)(absent(x_iblock_path[i,j]))) /\
		
		% (2) matching i-blocks with arcs
		% - the i-th occurring i-block is the i-block labeling the i-th ocurring arc in the c-map
		% NB. every row access to x_iblock_path below is within bounds since ARC_PATH is the row index set of x_iblock_path
		forall(i in ARC_PATH)(occurs(x_arc_path[i]) -> x_iblock_path[i,IBLOCK_COMPONENT] == [iblocks[cmap,x_arc_path[i],j] | j in IBLOCK_COMPONENT]) /\

		true
	;


% Determines a minimal consistent arc path $x_arc_path of length $x_arc_path_length wrt. cmap $cmap and path-minimality feature.
predicate cmql_arc_path(array[int] of CMAP: cmaps, var int: cmap, var int: x_arc_path_length, array[int] of var opt int: x_arc_path)
	:: "cmql_arc_path($cmap,$x_arc_path_length,$x_arc_path): determines a minimal consistent arc path $x_arc_path of length $x_arc_path_length wrt. cmap $cmap and path-minimality feature (var)"
	=
	let {
		set of int: N_CMAP = index_set(cmaps);
		set of int: NODE_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].node_labels)) | i in N_CMAP])].node_labels);
		set of int: ARC_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].arc_labels)) | i in N_CMAP])].arc_labels);		
		array[N_CMAP,ARC_ID] of NODE_ID: from = array2d(N_CMAP,ARC_ID, [cmaps[i].adigraph.tail_head[j, TAIL] | i in N_CMAP, j in ARC_ID]);
		array[N_CMAP,ARC_ID] of NODE_ID: to = array2d(N_CMAP,ARC_ID, [cmaps[i].adigraph.tail_head[j, HEAD] | i in N_CMAP, j in ARC_ID]);
		% indexing range for solution array
		set of int: ARC_PATH = index_set(x_arc_path);
		%set of int: NODE_PATH = index_set(x_node_path);
	} in
		assert(isProperRange(index_set(x_arc_path)), "cmql_arc_path: index set of $x_arc_path must be a proper range") /\

		% (1) path minimality based on the path-minimality feature configuration
		% - if arc-wise path minimality, all arcs must be different in the path
		(DEOPT_F_PATH_MINIMALITY == F_PATH_MINIMALITY_ARC -> all_different(x_arc_path)) /\ % all_different on optional array is supported and relaxed wrt. opt values - see fzn_all_different_int_opt
		
		% (2) the length of the path is the number of occurring arcs in the arc path array and their maximum index
		% - every arc is absent if the length is 0
		% - every arc occurs if the next arc occurs
		forall(i in ARC_PATH)(occurs(x_arc_path[i]) <-> i <= x_arc_path_length) /\

		% (3) restricting occurring arcs to range over the arcs of the cmap
% 		forall(i in ARC_PATH)(occurs(x_arc_path[i]) -> x_arc_path[i] in ARC_ID) /\ % x in S false if x absent % entailed by (4)

		% (4) matching heads and tails of successive occurring arcs
		forall(i in min(ARC_PATH)<..max(ARC_PATH))(occurs(x_arc_path[i]) -> from[cmap,x_arc_path[i]] == to[cmap,x_arc_path[i-1]]) /\

		

		true
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: cmql_path_value_output(CMAP: cmap, var int: x_arc_path_length, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int, int] of var opt int: x_iblock_path, array[int, int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence)
	=
	let {
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_ID = index_set(cmap.arc_labels);
		set of int: NODE_PATH = index_set(x_node_path);
		set of int: ARC_PATH = index_set(x_arc_path);
		set of int: IBLOCK_COMPONENT = index_set_2of2(x_iblock_path);
		string: PATH_SEPARATOR = ":";
		string: NO_NODE = "_";
		string: NO_ARC = "_";
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
	++	["Path length\t\t"]
	++	[ show(x_arc_path_length)]
	++	["\n"]
	++	["Node path\t\t"]
	% ++	[my_show1d_indexed(D_INT, (map2name(D_NODE_ID, [fix(o_x_node_path[i]) | i in index_set(o_x_node_path)])))]
	++	[if occurs(fix(x_node_path[i])) then cmap.node_labels[fix(deopt(x_node_path[i]))].concept.name else NO_NODE endif ++ if i < max(index_set(x_node_path)) then PATH_SEPARATOR else "" endif | i in index_set(x_node_path)]
	++	["\n"]
	++	["Arc path\t\t"]
	++	[if occurs(fix(x_arc_path[i])) then "(" ++ show(cmap.arc_labels[fix(deopt(x_arc_path[i]))].arc.t) ++ "," ++ show(cmap.arc_labels[fix(deopt(x_arc_path[i]))].arc.h) ++ ")" else NO_ARC endif ++ if i < max(index_set(x_arc_path)) then PATH_SEPARATOR else "" endif | i in index_set(x_arc_path)]
	++	["\n"]
	++	["I-block path\t\t"]
% 	++	[if occurs(x_iblock_path[i,min(index_set_2of2(x_iblock_path))]) then showInfluence((iblock: fix(deopt(row(x_iblock_path,i))))) else fix(deopt(x_iblock_path[i,min(index_set_2of2(x_iblock_path))])) endif ++ if i < max(index_set_1of2(x_iblock_path)) then " " else "" endif | i in index_set_1of2(x_iblock_path)]
	++	[showInfluence((iblock: fix((row(x_propagated_iblocks,i))))) ++ if i < max(index_set_1of2(x_propagated_iblocks)) then " " else "" endif | i in index_set_1of2(x_propagated_iblocks)]
	++	["\n"]
	++	["Propagation trace\t"]
	++	[showInfluence((iblock: fix(row(x_iblock_path,i)))) ++ if i < max(index_set_1of2(x_iblock_path)) then " " else "" endif | i in index_set_1of2(x_iblock_path)]
	++	["\n"]
	++	["Propagated influence\t"]
	++	[showInfluence(fix(x_propagated_influence)) ++ " == " ++ show(fix(x_propagated_influence))]
	++	["\n"]
	;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PREDICATES FOR DAGs

% include "dag.mzn"; % for path arc minimality feature in dpath
% include "path.mzn"; % for dpath
% %
% predicate lt(var CONCEPT_ID: x, var CONCEPT_ID: y) =
% 	let {
% 		array[CONCEPT_ID] of var bool: xc_inpath;
% 		array[ARC_ID] of var bool: xa_inpath;
% 		var int: x_length;
% 		constraint dpath(from, to, i, j, xc_inpath, xa_inpath);
% 		constraint x_length = sum(xa_inpath);
% 	} in
% 		x_length > 0
% 	;
	
% %
% predicate lte(var CONCEPT_ID: x, var CONCEPT_ID: y) =
% 	(x != y) -> lt(x, y);
	
% % lte(x,y) <-> occurs(x) /\ occurs(y) /\ lte(deopt(x), deopt(y))
% predicate lte(var opt CONCEPT_ID: x, var opt CONCEPT_ID: y) =
% 	occurs(x) /\
% 	occurs(y) /\
% 	lte(deopt(x), deopt(y))
% 	;
	
% %
% predicate incomparable(var opt CONCEPT_ID: x, var opt CONCEPT_ID: y) =
% 	not(lte(x,y)) /\ 
% 	not(lte(y,x))
% 	;
	
% % arg_sort based on less_than
% predicate arg_sort(array[CONCEPT_ID] of var opt CONCEPT_ID: x, array[CONCEPT_ID] of var CONCEPT_ID: p) =
% 	all_different(p) /\
% 	forall(j in 1..length(x)-1) (
% 		(lte(x[p[j]], x[p[j+1]]) \/ (incomparable(x[p[j]], x[p[j+1]]) -> p[j] < p[j+1])) /\
% 		(x[p[j]] == x[p[j+1]] -> p[j] < p[j+1]) % !! do not use ~= in place of ==
% 		)
% 	;
