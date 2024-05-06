%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVES



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CMQL PRIMITIVES




% III.DEF.30
% PathValue

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
predicate cmql_path_value(CMAP: cmap, var int: x_origin_node, var int: x_destination_node, var int: x_arc_path_length, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int, int] of var opt int: x_iblock_path, array[int, int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence)
	:: "cmql_path_value($cmap,$x_origin_node,$x_destination_node,$x_arc_path,$x_node_path,$x_iblock_path,$x_propagated_iblocks,$x_propagated_influence): determines a dipath connecting $x_origin_node to $x_destination_node in $cmap's digraph and the associated sequence of arcs $x_arc_path, sequence of nodes $x_node_path, sequence of i-blocks $x_iblock_path, propagation series of i-blocks $x_propagated_iblocks and propagated influence $x_propagated_influence (var)"
;

% Determines minimal consistent arc path $x_arc_path and node path $x_node_path wrt. cmap $cmap and path-minimality feature:
% - cmap: the c-map
% - x_arc_path: the sequence of arcs in the dipath completed with absent arcs
% - x_node_path: the sequence of nodes in the dipath completed with absent nodes
predicate cmql_arc_node_path(CMAP: cmap, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path)
	:: "cmql_arc_node_path($cmap,$x_arc_path,$x_node_path): determines minimal consistent arc path $x_arc_path and node path $x_node_path wrt. cmap $cmap and path-minimality feature (var)"
;

% Determines consistent arc path $x_arc_path and i-block path $x_iblock_path wrt. cmap $cmap:
% - cmap: the c-map
% - x_arc_path: the sequence of arcs in the dipath completed with absent arcs
% - x_iblock_path: the sequence of i-blocks labeling the arcs in the dipath completed with absent i-blocks
predicate cmql_arc_influence_path(CMAP: cmap, array[int] of var opt int: x_arc_path, array[int, int] of var opt int: x_iblock_path)
	:: "cmql_arc_influence_path($cmap,$x_arc_path,$x_iblock_path): determines consistent arc path $x_arc_path and i-block path $x_iblock_path wrt. cmap $cmap"
;

% Determines a minimal consistent arc path $x_arc_path of length $x_arc_path_length wrt. cmap $cmap and path-minimality feature:
% - cmap: the c-map
% -	x_arc_path_length: the length (possibly null) of the arc sequence in the solution dipath
% - x_arc_path: the sequence of arcs in the dipath completed with absent arcs
predicate cmql_arc_path(CMAP: cmap, var int: x_arc_path_length, array[int] of var opt int: x_arc_path)
	:: "cmql_arc_path($cmap,$x_arc_path_length,$x_arc_path): determines a minimal consistent arc path $x_arc_path of length $x_arc_path_length wrt. cmap $cmap and path-minimality feature (var)"
;
