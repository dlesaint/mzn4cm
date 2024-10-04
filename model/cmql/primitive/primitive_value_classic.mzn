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

function ann: cmql_value_search_classic(
						var int: x_nr_paths,
		)
	=
	seq_search([	
		int_search([x_nr_paths], input_order, indomain_max)
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
predicate cmql_value_classic (
						CMAP: cmap,
						var opt int: x_origin_node,
						var opt int: x_destination_node,
						var INFLUENCE: x_aggregated_influence,
                        array[int,int] of var opt int: x_arc_paths,
                        array[int,int] of var opt int: x_node_paths,
                        array[int] of var INFLUENCE: x_iblocks,
                        array[int] of var int: x_arc_path_lengths,
                        var int: x_nr_paths
		)
		:: "cmql_value($cmap,$x_origin_node,$x_destination_node,$x_nr_paths,$x_arc_path_lengths,$x_arc_paths,$x_node_paths,$x_iblock_paths,$x_propagated_iblocks,$x_iblocks,$x_aggregated_iblocks,$x_aggregated_influence): determines and sorts a number of dipaths $x_nr_paths of lengths $x_arc_path_lengths connecting $x_origin_node to $x_destination_node in $cmap's digraph together with the associated arrays of arc sequences $x_arc_paths, node sequences $x_node_paths, arc i-block sequences $x_iblock_paths, path propagation series $x_propagated_iblocks, path propagation results $x_iblocks, path aggregation series of i-blocks $x_aggregated_iblocks, and aggregated influence $x_aggregated_influence( var)"
	= 
	let {
        set of int: NODE_ID = index_set(cmap.node_labels);
        set of int: ARC_ID = index_set(cmap.arc_labels);
        set of int: PATH_ID = 1..10;
        set of int: NODE_PATH = if DEOPT_F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE then 1..min(max(NODE_ID), max(ARC_ID)+1) else 1..max(ARC_ID)+1 endif;
        set of int: ARC_PATH = 1..max(NODE_PATH)-1;
        %array[PATH_ID, ARC_PATH] of var opt ARC_ID: x_arc_paths;
        %array[PATH_ID, NODE_PATH] of var opt NODE_ID: x_node_paths;
        %array[PATH_ID] of var INFLUENCE: x_iblocks;
        %array[PATH_ID] of var int: x_arc_path_lengths;
        %var PATH_ID: x_nr_paths;
        array[PATH_ID, IBLOCK_COMPONENT] of var opt int: x_aggregated_iblocks;
        array[PATH_ID, IBLOCK_COMPONENT] of var opt int: x_iblock_paths;
	} in
        %x_nr_paths == 1 /\
        %assert(false, show(ARC_PATH)) /\
        % (1) check that origine and destination nodes are different
        x_origin_node != x_destination_node /\
        % (2) determine the dipaths
        forall(i in PATH_ID)(
            cmql_path_value_classic(cmap,x_arc_paths[i,ARC_PATH], x_node_paths[i, NODE_PATH], x_iblock_paths[i, IBLOCK_COMPONENT], x_iblocks[i])
        ) /\
        % (3) checks the lengths of the paths
        forall(i in PATH_ID)(
           cmql_length(cmap, x_arc_paths[i],  x_node_paths[i], x_arc_path_lengths[i])
        ) /\
        % (4) checks that the paths begin and end with the origin and destination nodes
        forall(i in PATH_ID)( (i <= x_nr_paths) -> 
            (x_node_paths[i,1] == x_origin_node /\
            x_node_paths[i, x_arc_path_lengths[i]+1] == x_destination_node)
        ) /\
        % (5) check the number of paths
        count_eq(x_arc_path_lengths, 0, card(PATH_ID) - x_nr_paths) /\
        % (6) sorting solution paths lexicographically by ascending path length first then ascending arc ids
		lex_chain_less_opt(x_nr_paths, x_arc_path_lengths, x_arc_paths) /\
		
        % (7) determining the propagated i-block of each path (x_iblocks) % entailed by next+1 constraint
        forall(i in PATH_ID)(i > x_nr_paths -> forall(j in IBLOCK_COMPONENT)(absent(x_aggregated_iblocks[i,j]))) /\

        % (8)
        (x_aggregated_iblocks[min(PATH_ID),IBLOCK_COMPONENT] == x_iblock_paths[min(PATH_ID),IBLOCK_COMPONENT]) /\
		forall(i in min(PATH_ID)<..max(PATH_ID))
			((i <= x_nr_paths) -> x_aggregated_iblocks[i,IBLOCK_COMPONENT] == iAggregate(deopt(x_aggregated_iblocks[i-1,IBLOCK_COMPONENT]), deopt(x_iblock_paths[i,IBLOCK_COMPONENT]))) /\

        % (9) determining the aggregated influence
		% - there is no solution path only if x_aggregated_influence is the null influence (ie. neutral element for i-aggregation)
		(x_nr_paths == 0 -> equals(x_aggregated_influence, getNullInfluence(cmap.itype))) /\ %(iblock: getAbsorbingElement(cmap.itype.ealgebra, ALGEBRAIC_OPERATION_2).value)) /\
		% - there exists solution paths only if x_aggregated_influence is the last occurring aggregated i-block
		(x_nr_paths > 0 -> x_aggregated_influence == (iblock: [x_aggregated_iblocks[x_nr_paths,j] | j in IBLOCK_COMPONENT])) /\
        true
    ;








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: cmql_value_output_classic(
						CMAP: cmap,
						var int: x_destination_node,
						var int: x_origin_node,
						var INFLUENCE: x_aggregated_influence,
                        array[int,int] of var opt int: x_arc_paths,
                        array[int,int] of var opt int: x_node_paths,
                        array[int] of var INFLUENCE: x_iblocks,
                        array[int] of var int: x_arc_path_lengths,
                        var int: x_nr_paths
                        )
	=
	let {
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_ID = index_set(cmap.arc_labels);
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
	++	["ARC_ID\t\t\t"]
	++	[ show(ARC_ID)]
	++	["\n"]

	++	["Origin Node\t\t"]
	++	[ show(x_origin_node)]
	++	["\n"]
	++	["Destination Node\t\t"]
	++	[ show(x_destination_node)]
	++	["\n"]
	++	["Aggregated influence\t"]
	++	[showInfluence(fix(x_aggregated_influence)) ++ " == " ++ show(fix(x_aggregated_influence))]
	++	["\n"]
    ++	["Number of paths\t\t"]
    ++	[ show(x_nr_paths)]
    ++	["\n"]
    ++	["Arc path lengths\t"]
    ++	[ show(x_arc_path_lengths)]
    ++	["\n"]
    ++	["Node paths\t\t"]
	++	[if j==min(index_set_2of2(x_node_paths)) then "path " ++ show(i) ++ ":\t" endif ++ if occurs(fix(x_node_paths[i,j])) then cmap.node_labels[fix(deopt(x_node_paths[i,j]))].concept.name else NO_NODE endif ++ if j < max(index_set_2of2(x_node_paths)) then PATH_SEPARATOR else NEXT_NODE_PATH endif | i in index_set_1of2(x_node_paths), j in index_set_2of2(x_node_paths)]
	++	["\n"]
	++	["Arc paths\t\t"]
	++	[if j==min(index_set_2of2(x_arc_paths)) then "path " ++ show(i) ++ ":\t" endif ++ if occurs(fix(x_arc_paths[i,j])) then "(" ++ show(cmap.arc_labels[fix(deopt(x_arc_paths[i,j]))].arc.t) ++ "," ++ show(cmap.arc_labels[fix(deopt(x_arc_paths[i,j]))].arc.h) ++ ")" else NO_ARC endif ++ if j < max(index_set_2of2(x_arc_paths)) then PATH_SEPARATOR else NEXT_ARC_PATH endif | i in index_set_1of2(x_arc_paths), j in index_set_2of2(x_arc_paths)]
	++	["\n"]
    ++	["Iblock paths\t\t"]
    ++	[if occurs(fix(x_iblocks[i])) then showInfluence(fix(x_iblocks[i])) else NO_IBLOCK endif ++ if i < max(index_set(x_iblocks)) then PATH_SEPARATOR else NEXT_IBLOCK_PATH endif | i in index_set(x_iblocks)]
    ++	["\n"]
	;