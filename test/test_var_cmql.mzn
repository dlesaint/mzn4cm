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
array[int,int] of var int: matrix;

set of int: NODE_ID = 1..max(forall (i in index_set(cmaps)) (max(index_set(cmaps[i].node_labels)) ));

set of int: ARC_ID = 1..max(forall (i in index_set(cmaps)) (max(index_set(cmaps[i].arc_labels)) ));

set of int: PATH_ID = 1..nb_paths;

set of int: NODE_PATH = 1..size_path;

set of int: ARC_PATH = 1..(max(NODE_PATH)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY VARIABLES
var int: cmap;

array[ARC_PATH] of var opt int: x_arc_path;

array[NODE_PATH] of var opt int: x_node_path;

var int: x_length;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SOLVING STRATEGY

constraint

cmql_length(cmaps,cmap,x_arc_path, x_node_path);

solve 
satisfy;

