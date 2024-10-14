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
array[int] of CMAP: cmaps = instance.cmaps;

int: nb_paths;

int: size_path;

set of int: N_CMAP = index_set(cmaps);

set of int: NODE_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].node_labels)) | i in N_CMAP])].node_labels);
set of int: ARC_ID = index_set(cmaps[arg_max([card(index_set(cmaps[i].arc_labels)) | i in N_CMAP])].arc_labels);

set of int: PATH_ID = 1..nb_paths;

set of int: ARC_PATH = 1..size_path;

set of int: NODE_PATH = 1..(max(ARC_PATH)+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY VARIABLES
var N_CMAP: cmap;

var NODE_ID: x_origin_node;

var NODE_ID: x_destination_node;

var ARC_PATH: x_length;

array[ARC_PATH] of var opt ARC_ID: x_arc_path;

array[NODE_PATH] of var opt NODE_ID: x_node_path;

array[ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_iblock_path;

array[ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_propagated_iblocks;  

var INFLUENCE: x_propagated_influence;

var bool: x_cmql;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SOLVING STRATEGY

constraint
%cmql_length(cmaps, cmap, x_arc_path, x_node_path, x_length)
%/\ cmql_path(cmaps, cmap, x_origin_node, x_destination_node, x_arc_path, x_node_path)
cmql_path_value(cmaps, cmap, x_origin_node, x_destination_node, x_length, x_arc_path, x_node_path, x_iblock_path, x_propagated_iblocks, x_propagated_influence)
/\ x_length == 2
;

solve %::cmql_path_value_search(cmap, x_arc_path, x_node_path, x_propagated_iblock, x_propagated_influence, x_cmql)
satisfy;

