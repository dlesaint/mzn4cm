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

predicate cmql_path_value_classic (
    CMAP: cmap,	
    array[int] of var opt int: x_arc_path, 
	array[int] of var opt int: x_node_path,
	array[int] of var opt int: x_propagated_iblock,   
    var INFLUENCE: x_propagated_influence
) :: "cmql_path_value($cmap,$x_arc_path_length,$x_arc_path,$x_node_path,$x_propagated_iblocks,$x_propagated_influence)"
= 
let {
    set of int: NODE_PATH = index_set(x_node_path);
    set of int: ARC_PATH = index_set(x_arc_path);
	set of int: NODE_ID = index_set(cmap.node_labels);
	var NODE_ID: c1;
	var NODE_ID: c2;
	var 0..card(ARC_PATH): x_arc_path_length;
	array[ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_iblock_path;
	array[ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_propagated_iblocks;
} in 
	
	% (1) determining a path
	cmql_path(cmap, c1,c2,x_arc_path, x_node_path) /\
	% (2) determining the length of the path
	%cmql_length(cmap, x_arc_path, x_node_path,x_arc_path_length) /\
    % (4-1) determining a sequence of arcs corresponding to a minimal dipath of the right length in the c-map
		%cmql_arc_path(cmap, x_arc_path_length, x_arc_path) /\
		% (4-2) determining minimal consistent arc and node sequences
		%cmql_arc_node_path(cmap, x_arc_path, x_node_path) /\
		% (4-3) determining consistent arc and i-block sequences	
		cmql_arc_influence_path(cmap, x_arc_path, x_iblock_path) /\

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
		(x_arc_path_length == 0 -> forall (i in IBLOCK_COMPONENT)(absent(x_propagated_iblock[i]))) /\
		% - the solution path is not empty only if x_propagated_influence is the last occurring propagated i-block
		(x_arc_path_length > 0 -> x_propagated_influence == (iblock: [x_propagated_iblocks[x_arc_path_length,j] | j in IBLOCK_COMPONENT])) /\
		(x_arc_path_length > 0 -> x_propagated_iblock[IBLOCK_COMPONENT] == [x_propagated_iblocks[x_arc_path_length,j] | j in IBLOCK_COMPONENT]) /\

    true
;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: cmql_path_value_output_classic(CMAP: cmap, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, var INFLUENCE: x_propagated_influence)
	=
	let {
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_ID = index_set(cmap.arc_labels);
		set of int: NODE_PATH = index_set(x_node_path);
		set of int: ARC_PATH = index_set(x_arc_path);        
		%set of int: IBLOCK_COMPONENT = index_set_2of2(x_iblock_path);		
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
	++	["Node path\t\t"]
	% ++	[my_show1d_indexed(D_INT, (map2name(D_NODE_ID, [fix(o_x_node_path[i]) | i in index_set(o_x_node_path)])))]
	++	[if occurs(fix(x_node_path[i])) then cmap.node_labels[fix(deopt(x_node_path[i]))].concept.name else NO_NODE endif ++ if i < max(index_set(x_node_path)) then PATH_SEPARATOR else "" endif | i in index_set(x_node_path)]
	++	["\n"]
	++	["Arc path\t\t"]
	++	[if occurs(fix(x_arc_path[i])) then "(" ++ show(cmap.arc_labels[fix(deopt(x_arc_path[i]))].arc.t) ++ "," ++ show(cmap.arc_labels[fix(deopt(x_arc_path[i]))].arc.h) ++ ")" else NO_ARC endif ++ if i < max(index_set(x_arc_path)) then PATH_SEPARATOR else "" endif | i in index_set(x_arc_path)]
++	["\n"]
	++	["Propagated influence\t"]
	++	[showInfluence(fix(x_propagated_influence)) ++ " == " ++ show(fix(x_propagated_influence))]
	++	["\n"]
	;
