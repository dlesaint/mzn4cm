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

NODE_ID: a;
NODE_ID: b;
NODE_ID: c;

int: nb_paths;
int: size_path;

set of int: PATH_ID = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..nb_paths else 1..nr_paths(transform_matrix(cmap.adigraph.a)) endif;

set of int: NODE_PATH = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..size_path else 1..min(max(NODE_ID), max(ARC_ID)+1)  endif;

set of int: ARC_PATH = 1..(max(NODE_PATH)-1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUERY VARIABLES
%%%%% 

var NODE_ID: a_node;
var INFLUENCE: a_influence;
var NODE_ID: b_node;
var INFLUENCE: b_influence;
var 0..nb_paths: l_nb_paths;
array[PATH_ID] of var 0..size_path: l_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: l_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: l_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: l_influence_path;

var 0..nb_paths: c_nb_paths;
array[PATH_ID] of var 0..size_path: c_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: c_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: c_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: c_influence_path;


var 0..nb_paths: union_nb_paths;
array[PATH_ID] of var 0..size_path: union_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: union_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: union_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: union_influence_path;


var 0..nb_paths: left_nb_paths;
array[PATH_ID] of var 0..size_path: left_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: left_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: left_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: left_influence_path;

var 0..nb_paths: f1_nb_paths;
array[PATH_ID] of var 0..size_path: f1_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: f1_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: f1_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: f1_influence_path;

var 0..nb_paths: right_nb_paths;
array[PATH_ID] of var 0..size_path: right_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: right_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: right_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: right_influence_path;

var 0..nb_paths: result_nb_paths;
array[PATH_ID] of var 0..size_path: result_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: result_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: result_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: result_influence_path;

var 0..nb_paths: final_nb_paths;
array[PATH_ID] of var 0..size_path: final_paths_length;
array[PATH_ID, NODE_PATH] of var opt NODE_ID: final_node_paths;
array[PATH_ID, ARC_PATH] of var opt ARC_ID: final_arc_paths;
array[PATH_ID, NODE_PATH] of var INFLUENCE: final_influence_path;
var INFLUENCE: final_influence;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINTS
%%%%%%
constraint a_node = a /\ b_node = b;
constraint cmql_concatenation(a_node, a_influence, b_node, b_influence, l_nb_paths, l_paths_length, l_node_paths, l_influence_path);
constraint cmql_k_variable(cmap, l_nb_paths, l_paths_length, l_node_paths, l_arc_paths, l_influence_path);

constraint cmql_k_variable(cmap, c_nb_paths, c_paths_length, c_node_paths, c_arc_paths, c_influence_path);
constraint c_nb_paths = 1 /\ c_paths_length[1] = 1 /\ c_node_paths[1,1] = c;
constraint cmql_k_variable(cmap, union_nb_paths, union_paths_length, union_node_paths, union_arc_paths, union_influence_path);
constraint cmql_addition(l_node_paths, c_node_paths, union_node_paths);

constraint cmql_k_variable(cmap, left_nb_paths, left_paths_length, left_node_paths, left_arc_paths, left_influence_path);
constraint cmql_k_variable(cmap, f1_nb_paths, f1_paths_length, f1_node_paths, f1_arc_paths, f1_influence_path);
constraint cmql_fusion(left_node_paths, union_node_paths, f1_node_paths, left_paths_length, union_paths_length, f1_paths_length);

constraint cmql_k_variable(cmap, right_nb_paths, right_paths_length, right_node_paths, right_arc_paths, right_influence_path);
constraint cmql_k_variable(cmap, result_nb_paths, result_paths_length, result_node_paths, result_arc_paths, result_influence_path);
constraint cmql_fusion(f1_node_paths, right_node_paths, result_node_paths, f1_paths_length, right_paths_length, result_paths_length);

constraint cmql_k_variable(cmap, final_nb_paths, final_paths_length, final_node_paths, final_arc_paths, final_influence_path);
constraint cmql_inclusion(final_node_paths, result_node_paths);
constraint cmql_influence(cmap, final_node_paths, final_arc_paths, final_influence_path, final_influence);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH
%%%%%%
% solve :: seq_search([
%     int_search([l_nb_paths, c_nb_paths, union_nb_paths, left_nb_paths, f1_nb_paths, right_nb_paths, result_nb_paths, final_nb_paths], input_order, indomain_reverse_split),
%     int_search(l_paths_length ++ c_paths_length ++ union_paths_length ++ left_paths_length ++ f1_paths_length ++ right_paths_length ++ result_paths_length ++ final_paths_length, input_order, indomain_split),
%     int_search(array1d(l_node_paths) ++ array1d(c_node_paths) ++ array1d(union_node_paths) ++ array1d(left_node_paths) ++ array1d(f1_node_paths) ++ array1d(right_node_paths) ++ array1d(result_node_paths) ++ array1d(final_node_paths), input_order, indomain_min)
% ])
%     maximize(final_nb_paths);

solve maximize(final_nb_paths);