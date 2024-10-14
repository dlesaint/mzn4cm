%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVES



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Path
predicate cmql_path (
    array[int] of CMAP: cmaps,
	var int: cmap,
    var opt int: x_origin_node,
    var opt int: x_destination_node,	
    array[int] of var opt int: x_arc_path,
	array[int] of var opt int: x_node_path
) :: "cmql_path($cmap,$x_origin_node,$x_destination_node,$x_node_path,$x_arc_path)"
;

function array[int] of string: cmql_path_output (
	CMAP: cmap,
	var opt int: x_origin_node,
	var opt int: x_destination_node,	
	array[int] of var opt int: x_arc_path,
	array[int] of var opt int: x_node_path
) :: "cmql_path_output($cmap,$x_origin_node,$x_destination_node,$x_arc_path_length,$x_arc_path)"
;
%% Value
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
predicate cmql_value (CMAP: cmap, var int: x_origin_node, var int: x_destination_node, var int: x_nr_paths, array[int] of var int: x_arc_path_lengths, array[int,int] of var opt int: x_arc_paths, array[int,int] of var opt int: x_node_paths, array[int,int,int] of var opt int: x_iblock_paths, array[int,int,int] of var opt int: x_propagated_iblocks, array[int,int] of var opt int: x_iblocks, array[int,int] of var opt int: x_aggregated_iblocks, var INFLUENCE: x_aggregated_influence)
		:: "cmql_value($cmap,$x_origin_node,$x_destination_node,$x_nr_paths,$x_arc_path_lengths,$x_arc_paths,$x_node_paths,$x_iblock_paths,$x_propagated_iblocks,$x_iblocks,$x_aggregated_iblocks,$x_aggregated_influence): determines and sorts a number of dipaths $x_nr_paths of lengths $x_arc_path_lengths connecting $x_origin_node to $x_destination_node in $cmap's digraph together with the associated arrays of arc sequences $x_arc_paths, node sequences $x_node_paths, arc i-block sequences $x_iblock_paths, path propagation series $x_propagated_iblocks, path propagation results $x_iblocks, path aggregation series of i-blocks $x_aggregated_iblocks, and aggregated influence $x_aggregated_influence( var)"
;
predicate cmql_value_fixed (
						CMAP: cmap,
						int: x_origin_node,
						int: x_destination_node,
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
	;
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
	;

function ann: cmql_value_search_classic(
						var int: x_nr_paths,
		)
	;
%% CMQL PRIMITIVES

%% PathValue

%
function ann: cmql_path_value_search(var int: cmap, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence, var bool: x_cmql_path_value);
%function ann: cmql_path_value_search_fixed(var int: x_arc_path_length, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int, int] of var opt int: x_iblock_path, array[int, int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence, var bool: x_cmql_path_value);
	
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
% - $x_propagated_iblocks is the series of i-blocks obtained by recursive influence propagation through the sequence x_iblock_path starting from the first i-block, finishing at the last, and completed with absent i-blocks to fill the opt array
% -- the series is empty iff no dipath exists between origin and destination nodes in the c-map digraph
% - $x_propagated_influence is the influence propagated through the dipath
% -- it is equal to the null influence iff no dipath exists between origin and destination nodes in the c-map digraph
predicate cmql_path_value(CMAP: cmap, var int: x_origin_node, var int: x_destination_node, var int: x_arc_path_length, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int, int] of var opt int: x_iblock_path, array[int, int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence)
	:: "cmql_path_value($cmap,$x_origin_node,$x_destination_node,$x_arc_path,$x_node_path,$x_iblock_path,$x_propagated_iblocks,$x_propagated_influence): determines a dipath connecting $x_origin_node to $x_destination_node in $cmap's digraph and the associated arc sequence $x_arc_path, node sequence $x_node_path, i-block sequence $x_iblock_path, i-block propagation series $x_propagated_iblocks and propagated influence $x_propagated_influence (var)"
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
	
	;
predicate cmql_path_value_classic (	
    array[int] of CMAP: cmaps,
	var int: cmap,	
    array[int] of var opt int: x_arc_path, 
	array[int] of var opt int: x_node_path,
	array[int] of var opt int: x_propagated_iblock,   
    var INFLUENCE: x_propagated_influence
);

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
predicate cmql_arc_influence_path(array[int] of CMAP: cmaps, var int: cmap, array[int] of var opt int: x_arc_path, array[int, int] of var opt int: x_iblock_path)
	:: "cmql_arc_influence_path($cmap,$x_arc_path,$x_iblock_path): determines consistent arc path $x_arc_path and i-block path $x_iblock_path wrt. cmap $cmap"
;

% Determines a minimal consistent arc path $x_arc_path of length $x_arc_path_length wrt. cmap $cmap and path-minimality feature:
% - cmap: the c-map
% -	x_arc_path_length: the length (possibly null) of the arc sequence in the solution dipath
% - x_arc_path: the sequence of arcs in the dipath completed with absent arcs
predicate cmql_arc_path(CMAP: cmap, var int: x_arc_path_length, array[int] of var opt int: x_arc_path)
	:: "cmql_arc_path($cmap,$x_arc_path_length,$x_arc_path): determines a minimal consistent arc path $x_arc_path of length $x_arc_path_length wrt. cmap $cmap and path-minimality feature (var)"
;

% cmql Length
predicate cmql_length (array[int] of CMAP: cmaps, var int: cmap,array[int] of var opt int: x_arc_path,array[int] of var opt int: x_node_path,var int: x_length);
%
function array[int] of string: cmql_path_value_output(CMAP: cmap, var int: x_arc_path_length, array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, array[int, int] of var opt int: x_iblock_path, array[int, int] of var opt int: x_propagated_iblocks, var INFLUENCE: x_propagated_influence);

function array[int] of string: cmql_path_value_output_classic(CMAP: cmap,array[int] of var opt int: x_arc_path, array[int] of var opt int: x_node_path, var INFLUENCE: x_propagated_influence);

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
	;

function array[int] of string: cmql_length_output (CMAP: cmap,array[int] of var opt int: x_arc_path,array[int] of var opt int: x_node_path,var int: x_length);