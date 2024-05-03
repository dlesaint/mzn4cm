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

predicate cmql_path_value(
						CMAP: cmap,
						var INFLUENCE: x_influence,
						var int: x_origin_node,
						var int: x_destination_node,
						var opt int: x_arc_path_length,
						array[int] of var opt int: x_node_path,
						array[int] of var opt int: x_arc_path,
						array[int] of var opt INFLUENCE: x_influence_path,
						array[int] of int: from, % placed in signature for visualization only
						array[int] of int: to, % placed in signature for visualization only
						%array[int] of var bool: x_node_in, % placed in signature for visualization only
						%array[int] of var bool: x_arc_in % placed in signature for visualization only
					)
	:: "predicate: cmql_path_value"
;

predicate cmql_value (
    CMAP: cmap,
    var INFLUENCE: x_influence,
    var int: x_origin_node,
    var int: x_destination_node,
    var int: nb_true_path,
    array[int,int] of var opt int: x_node_path,
    array[int,int] of var opt int: x_arc_path,    
	array[int] of var INFLUENCE: x_influences,
    array[int,int] of var opt INFLUENCE: x_influence_paths,
    array[int] of int: from, % placed in signature for visualization only
	array[int] of int: to, % placed in signature for visualization only
	%array[int,int] of var bool: x_node_in, % placed in signature for visualization only
	%array[int,int] of var bool: x_arc_in % placed in signature for visualization only
    )
    :: "predicate: cmql_value"
;
