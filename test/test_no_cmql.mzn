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

set of int: NODE_PATH = if DEOPT_F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE then 1..min(max(NODE_ID), max(ARC_ID)+1) else 1..max(ARC_ID)+1 endif;

set of int: PATH_ID = 1..10;
% the range for indexing any sequence of arcs corresponding to a solution path
% - the upper-bound depends on the chosen path-minimality definition amongst the 2 variants
set of int: ARC_PATH = 1..max(NODE_PATH)-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY VARIABLES

var NODE_ID: x_origin_node;

var NODE_ID: x_destination_node;

var 0..card(PATH_ID): x_nr_paths;

array[PATH_ID] of var 0..card(ARC_PATH): x_arc_path_lengths;

array[PATH_ID, ARC_PATH] of var opt ARC_ID: x_arc_paths;

array[PATH_ID, NODE_PATH] of var opt NODE_ID: x_node_paths;

array[PATH_ID, ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_iblock_paths;

array[PATH_ID, ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_propagated_iblocks;

array[PATH_ID] of var INFLUENCE: x_iblocks;

array[PATH_ID, IBLOCK_COMPONENT] of var opt int: x_aggregated_iblocks;

var INFLUENCE: x_aggregated_influence;

array[ARC_PATH] of var opt ARC_ID: x_arc_path;

array[NODE_PATH] of var opt NODE_ID: x_node_path;

var INFLUENCE: x_propagated_influence;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SOLVING STRATEGY
constraint 
%cmql_path(cmap,x_origin_node, x_destination_node,x_arc_path, x_node_path) %/\
%cmql_path_value_classic(cmap, x_arc_path,x_node_path,x_propagated_influence)
cmql_value_classic(cmap, x_origin_node, x_destination_node, x_aggregated_influence, x_arc_paths, x_node_paths, x_iblocks, x_arc_path_lengths, x_nr_paths)

;
% 
solve :: cmql_value_search_classic(x_nr_paths) 
satisfy;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%output :: "o_instance" displayInstance(instance);

%output cmql_path_output(cmap,x_origin_node,x_destination_node,x_node_path,x_arc_path);

%output cmql_path_value_output_classic(cmap, x_arc_path,x_node_path,x_propagated_influence);

output cmql_value_output_classic(cmap,x_destination_node, x_origin_node, x_aggregated_influence, x_arc_paths, x_node_paths, x_iblocks, x_arc_path_lengths, x_nr_paths);
