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
CMAP: cmap = instance.cmap;

% the range of node ids in the c-map's digraph
set of int: NODE_ID = index_set(cmap.node_labels);

% the range of arc ids in the c-map's digraph
set of int: ARC_ID = index_set(cmap.arc_labels);

NODE_ID: s_node;
NODE_ID: t_node;

int: nb_paths;
int: size_path;

set of int: PATH_ID = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..nb_paths else 1..nr_paths(transform_matrix(cmap.adigraph.a)) endif;

set of int: NODE_PATH = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..size_path else 1..min(max(NODE_ID), max(ARC_ID)+1)  endif;

set of int: ARC_PATH = 1..(max(NODE_PATH)-1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUERY VARIABLES
%%%%% 

var 0..nb_paths: result_nb_paths;
array[PATH_ID] of var 0..size_path: result_paths_length;
array[PATH_ID,NODE_PATH] of var opt NODE_ID: result_node_paths;
array[PATH_ID,ARC_PATH] of var opt ARC_ID: result_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: result_influence_paths;
var INFLUENCE: result_influence;

var 0..nb_paths: a_nb_paths;
array[PATH_ID] of var 0..size_path: a_paths_length;
array[PATH_ID,NODE_PATH] of var opt NODE_ID: a_node_paths;
array[PATH_ID,ARC_PATH] of var opt ARC_ID: a_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: a_influence_paths;

var 0..nb_paths: b_nb_paths;
array[PATH_ID] of var 0..size_path: b_paths_length;
array[PATH_ID,NODE_PATH] of var opt NODE_ID: b_node_paths;
array[PATH_ID,ARC_PATH] of var opt ARC_ID: b_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: b_influence_paths;

var 0..nb_paths: f_nb_paths;
array[PATH_ID] of var 0..size_path: f_paths_length;
array[PATH_ID,NODE_PATH] of var opt NODE_ID: f_node_paths;
array[PATH_ID,ARC_PATH] of var opt ARC_ID: f_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: f_influence_paths;

var 0..nb_paths: fr_nb_paths;
array[PATH_ID] of var 0..size_path: fr_paths_length;
array[PATH_ID,NODE_PATH] of var opt NODE_ID: fr_node_paths;
array[PATH_ID,ARC_PATH] of var opt ARC_ID: fr_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: fr_influence_paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS
%%%%%%
constraint cmql_k_variable(cmap, a_nb_paths, a_paths_length, a_node_paths, a_arc_paths, a_influence_paths);
constraint a_nb_paths = 1 /\ a_paths_length[1] = 1 /\  a_node_paths[1,1] = s_node;

constraint b_nb_paths = 1 /\ b_paths_length[1] = 1 /\  b_node_paths[1,1] = t_node;
constraint cmql_k_variable(cmap, b_nb_paths, b_paths_length, b_node_paths, b_arc_paths, b_influence_paths);

constraint cmql_k_variable(cmap, f_nb_paths, f_paths_length, f_node_paths, f_arc_paths, f_influence_paths);
constraint cmql_k_variable(cmap, fr_nb_paths, fr_paths_length, fr_node_paths, fr_arc_paths, fr_influence_paths);
constraint cmql_fusion(a_node_paths,f_node_paths, fr_node_paths, a_paths_length, f_paths_length, fr_paths_length );

constraint cmql_fusion(fr_node_paths, b_node_paths, result_node_paths, fr_paths_length, b_paths_length, result_paths_length);

constraint cmql_k_variable(cmap, result_nb_paths, result_paths_length, result_node_paths, result_arc_paths, result_influence_paths);
constraint cmql_influence(cmap, result_node_paths, result_arc_paths, result_influence_paths, result_influence);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH
%%%%%%
% solve :: seq_search([
%     int_search([result_nb_paths, a_nb_paths, b_nb_paths, f_nb_paths, fr_nb_paths], input_order, indomain_reverse_split),
%     int_search(result_paths_length ++ a_paths_length ++ b_paths_length ++ f_paths_length ++ fr_paths_length, input_order, indomain_split),
%     int_search(array1d(result_node_paths) ++ array1d(a_node_paths) ++ array1d(b_node_paths) ++ array1d(f_node_paths) ++ array1d(fr_node_paths), input_order, indomain_min)
% ])
%     maximize(result_nb_paths);

solve maximize(result_nb_paths);