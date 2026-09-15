%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVES



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap.mzn";



%%-----------------------------New Primitives -------------------------------------------------
predicate cmql_k_variable (CMAP: cmap,
    var int: x_nb_path,
    array[int] of var int: x_paths_length,
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: x_arc_paths
);


predicate cmql_concatenation (
    var int: x_path_length,
    array[int] of var opt int: x_node_path,

    var int: y_path_length,
    array[int] of var opt int: y_node_path,

    var int: z_nb_paths,
    array[int] of var int: z_paths_length,
    array[int,int] of var opt int: z_node_paths

);

predicate cmql_inclusion (
    array[int,int] of var opt int: x_node_paths,
    array[int,int] of var opt int: y_node_paths
);

predicate cmql_addition (
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: y_node_paths,
    array[int, int] of var opt int: z_node_paths,
);

predicate cmql_fusion (
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: y_node_paths,
    array[int, int] of var opt int: z_node_paths,

    array[int] of var int: x_paths_length,
    array[int] of var int: y_paths_length,
    array[int] of var int: z_paths_length,
);

predicate cmql_influence (
    CMAP: cmap,
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: x_arc_paths,
    array[int,int] of var INFLUENCE: x_influence_path,
    var INFLUENCE: x_influence,
);