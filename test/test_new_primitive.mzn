%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% MAIN FILE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

% Core inclusion file
include "./../model/include/include.mzn";

% Influence type
include "./../model/include/include_itype.mzn";

% Influence operations
include "./../model/include/include_ioperations.mzn";

% CMQL
include "./../model/include/include_cmql.mzn";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

%
% constraint assert(mzn_internal_check_debug_mode(), "--debug flag is not set");

% 
constraint assertDataset(dataset);

% 
constraint assertInstance(instance);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY DATA
% the reference c-map
CMAP: cmap = instance.cmaps[1];

% the range of node ids in the c-map's digraph
set of int: NODE_ID = index_set(cmap.node_labels);

% the range of arc ids in the c-map's digraph
set of int: ARC_ID = index_set(cmap.arc_labels);

int: nb_paths = 34;
int: size_path = 10;
array[int,int] of var int: matrix = array2d(1..13,1..13,[1, 7, 14, 5, 10, 11, 10, 10, 13, 21, 15, 5, 18, 2, 1, 8, 2, 4, 12, 4, 4, 12, 16, 12, 2, 14, 1, 3, 1, 1, 2, 6, 2, 2, 6, 8, 6, 1, 1, 1, 3, 10, 1, 2, 6, 2, 2, 6, 8, 6, 1, 16, 9, 8, 21, 9, 1, 11, 10, 1, 8, 7, 11, 9, 24, 3, 9, 9, 3, 6, 1, 6, 6, 3, 7, 5, 3, 7, 9, 8, 21, 9, 1, 11, 1, 1, 8, 7, 11, 9, 24, 9, 16, 33, 9, 9, 17, 5, 1, 10, 7, 13, 9, 34, 3, 9, 16, 3, 6, 8, 6, 6, 1, 5, 2, 3, 11, 1, 3, 10, 1, 2, 6, 2, 2, 6, 1, 6, 1, 16, 3, 9, 12, 3, 6, 4, 6, 6, 8, 12, 1, 3, 6, 13, 16, 20, 13, 5, 13, 5, 5, 13, 16, 9, 1, 18, 1, 3, 10, 1, 2, 6, 2, 2, 6, 8, 6, 1, 1]);

set of int: PATH_ID = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..nb_paths else 1..nr_paths(transform_matrix(cmap.adigraph.a)) endif;

set of int: NODE_PATH = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..size_path else 1..min(max(NODE_ID), max(ARC_ID)+1)  endif;

set of int: ARC_PATH = 1..(max(NODE_PATH)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUERY VARIABLES
%%%%% 
var 0..size_path: x_path_length;
array[NODE_PATH] of var opt NODE_ID: x_node_path;

var 0..size_path: y_path_length;
array[NODE_PATH] of var opt NODE_ID: y_node_path;

var 0..nb_paths: z_nb_paths;
array[PATH_ID] of var 0..size_path: z_paths_length;
array[PATH_ID,NODE_PATH] of var opt NODE_ID: z_node_paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Solving
constraint x_path_length = 2;
constraint x_node_path[1] = 2;
constraint x_node_path[2] = 4;
constraint y_path_length = 2;
constraint y_node_path[1] = 2;
constraint y_node_path[2] = 4;
constraint cmql_concatenation(x_path_length, x_node_path, y_path_length, y_node_path, z_nb_paths, z_paths_length, z_node_paths);
solve satisfy;