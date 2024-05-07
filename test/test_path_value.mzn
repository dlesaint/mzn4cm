%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TEST CMQL QUERY: PATH_VALUE



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

% CMQL VISUALIZATION (optional)
include "./../model/cmql/primitive/primitive_path_value_viz.mzn";



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

% the optional fixed origin node
opt NODE_ID: origin_node;

% the optional fixed destination node
opt NODE_ID: destination_node;

% assertions
constraint assert((occurs(origin_node) \/ occurs(destination_node)) -> deopt(origin_node )!= deopt(destination_node), "path origin and destination concepts must be different");



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY VARIABLES

% the origin node of the solution path
var NODE_ID: x_origin_node
	:: no_output
;
	
% the destination node of the solution path
var NODE_ID: x_destination_node
	:: no_output
;

% the range for indexing any sequence of nodes corresponding to a solution path
% - the upper-bound depends on the chosen path-minimality definition amongst the 2 variants
set of int: NODE_PATH = if F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE then 1..min(max(NODE_ID), max(ARC_ID)+1) else 1..max(ARC_ID)+1 endif;

% the range for indexing any sequence of arcs corresponding to a solution path
% - the upper-bound depends on the chosen path-minimality definition amongst the 2 variants
set of int: ARC_PATH = 1..max(NODE_PATH)-1;

% the length of the arc sequence for the solution path
% - x_arc_path_length==0 iff no solution path exists
var 0..card(ARC_PATH): x_arc_path_length;

% the arc sequence for the solution path completed with absent arcs
% - x_arc_path[i] is the id of the i-th occurring arc in the arc sequence
% - x_arc_path[i] is absent iff i is greater than the length of the arc sequence
array[ARC_PATH] of var opt ARC_ID: x_arc_path
	:: no_output
;

% the node sequence for the solution path completed with absent nodes
% - x_node_path[i] is the id of the i-th occurring node in the node sequence
% - x_node_path[i] is absent iff max(0, i-2) is greater than or equal to the length of the arc sequence
array[NODE_PATH] of var opt NODE_ID: x_node_path
	:: no_output
;

% the sequence of i-blocks labeling the arcs in the solution path and completed with absent i-blocks
% - x_iblock_path[i,IBLOCK_COMPONENT] is the i-block of the i-th occurring arc in the arc sequence
% - x_iblock_path[i,IBLOCK_COMPONENT] is absent iff i is greater than the length of the arc sequence
array[ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_iblock_path;

% the series of i-blocks recursively computed by propagation over the i-block sequence for the solution path
% - x_propagated_iblocks[i,IBLOCK_COMPONENT] == iPropagate(x_propagated_iblocks[i-1,IBLOCK_COMPONENT], x_iblock_path[i,IBLOCK_COMPONENT])
% - x_propagated_iblocks[i,IBLOCK_COMPONENT] is absent iff i is greater than the length of the arc i-block sequence
array[ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_propagated_iblocks;

% the influence propagated from the origin node to the destination node through the solution path and corresponding to the last term of the propagation series
% - x_propagated_influence == (iblock: x_propagated_iblocks[x_arc_path_length,IBLOCK_COMPONENT]) iff x_arc_path_length!=0 (a solution path exists)
% - x_propagated_influence == getNullInfluence(cmap.itype) iff x_arc_path_length==0 (no solution path exists)
var INFLUENCE: x_propagated_influence
	:: no_output
;

% optional boolean variable representing the satisfiability of the query
var bool: x_cmql_path_value;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY CONSTRAINT

%
constraint :: "constraint: path propagation between origin and destination nodes"
	% binds origin node if given
	(x_origin_node == origin_node) /\ % !! see semantics of == over opt vars
	% binds destination node if given
	(x_destination_node == destination_node) /\ % !! see semantics of == over opt vars
	% searches for non-empty dipath
	cmql_path_value(cmap, x_origin_node, x_destination_node, x_arc_path_length, x_arc_path, x_node_path, x_iblock_path, x_propagated_iblocks, x_propagated_influence) /\
	% reifying satisfiability of query (to customize)
	x_cmql_path_value == (x_arc_path_length > 0) /\
	% forcing satisfiability
	x_cmql_path_value
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY SEARCH STRATEGY

solve
	:: cmql_path_value_search(x_origin_node, x_destination_node, x_arc_path_length, x_arc_path, x_node_path, x_iblock_path, x_propagated_iblocks, x_propagated_influence, x_cmql_path_value)
	satisfy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY OUTPUT

%
output :: "o_instance"
	displayInstance(instance);

%
output :: "o_query"
["****** TEST - Query cmql_path_value - Path influence propagation ***********"]
++ ["\n"]
++ ["Origin node =\t\t"]
% ++ [show(cmap.node_labels[origin_node])]
++ [show(cmap.node_labels[fix(x_origin_node)])]
++ ["\n"]
++ ["Destination node =\t"]
% ++ [show(cmap.node_labels[destination_node])]
++ [show(cmap.node_labels[fix(x_destination_node)])]
++ ["\n"]
;

%
output :: "o_solution_cmql_path_value"
	cmql_path_value_output(cmap, x_arc_path_length, x_arc_path, x_node_path, x_iblock_path, x_propagated_iblocks, x_propagated_influence);
