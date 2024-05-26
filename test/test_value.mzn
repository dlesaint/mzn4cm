%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TEST CMQL QUERY: VALUE



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

% the optional fixed origin node
opt NODE_ID: origin_node;

% the optional fixed destination node
opt NODE_ID: destination_node;

int: nb_paths;
% assertions
constraint assert((occurs(origin_node) /\ occurs(destination_node)) -> deopt(origin_node )!= deopt(destination_node), "path origin and destination concepts must be different");

% the range of paths of length <= max(NODE_ID), not necessarily node-minimal or arc-minimal
%set of int: PATH_ID = 1..nr_paths(transform_matrix(cmap.adigraph.a));
%bool:  b = assert(false, show(F_NB_PATH_COUNTING));
set of int: PATH_ID = if DEOPT_F_NB_PATH_COUNTING == F_PYTHON_COUNTING then 1..nb_paths else 1..nr_paths(transform_matrix(cmap.adigraph.a)) endif ;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY VARIABLES

% the origin node of the solution paths
var NODE_ID: x_origin_node
	:: no_output
;
	
% the destination node of the solution paths
var NODE_ID: x_destination_node
	:: no_output
;

% the range for indexing any sequence of nodes corresponding to a solution path
% - the upper-bound depends on the chosen path-minimality definition amongst the 2 variants
set of int: NODE_PATH = if F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE then 1..min(max(NODE_ID), max(ARC_ID)+1) else 1..max(ARC_ID)+1 endif;

% the range for indexing any sequence of arcs corresponding to a solution path
% - the upper-bound depends on the chosen path-minimality definition amongst the 2 variants
set of int: ARC_PATH = 1..max(NODE_PATH)-1;

% the number of solutions paths
var 0..card(PATH_ID): x_nr_paths;

% the lengths of the arc sequences for the solution paths
% - x_arc_path_length[i]==0 iff the i-th solution path is empty
array[PATH_ID] of var 0..card(ARC_PATH): x_arc_path_lengths;

% the arc sequences for the solution paths completed with absent arcs
% - x_arc_paths[i,j] is the id of the j-th occurring arc in the i-th arc sequence
% - x_arc_paths[i,j] is absent iff the i-th arc sequence is empty or else j is greater than its length
array[PATH_ID, ARC_PATH] of var opt ARC_ID: x_arc_paths
	:: no_output
;

% the node sequences for the solution paths completed with absent nodes
% - x_node_paths[i,j] is the id of the j-th occurring node in the i-th node sequence
% - x_node_paths[i,j] is absent iff the i-th arc sequence is empty or else max(0, j-2) is greater than or equal to its length
array[PATH_ID, NODE_PATH] of var opt NODE_ID: x_node_paths
	:: no_output
;

% the sequence of i-blocks labeling the arcs in each solution path and completed with absent i-blocks
% - x_iblock_path[i,j,IBLOCK_COMPONENT] is the i-block of the j-th occurring arc in the i-th arc sequence
% - x_iblock_path[i,j,IBLOCK_COMPONENT] is absent iff the i-th arc sequence is empty or else j is greater than its length
array[PATH_ID, ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_iblock_paths;

% the series of i-blocks recursively computed by propagation over the i-block sequence for each solution path
% - x_propagated_iblocks[i,j,IBLOCK_COMPONENT] == iPropagate(x_propagated_iblocks[i,j-1,IBLOCK_COMPONENT], x_iblock_path[i,j,IBLOCK_COMPONENT])
% - x_propagated_iblocks[i,j,IBLOCK_COMPONENT] is absent iff the i-th arc i-block sequence is empty or else j is greater than its length
array[PATH_ID, ARC_PATH, IBLOCK_COMPONENT] of var opt int: x_propagated_iblocks;

% the array of i-blocks corresponding to the i-blocks obtained by propagation through the solution paths
% - x_iblocks[i,IBLOCK_COMPONENT] == x_propagated_iblocks[i,x_arc_path_lengths[i],IBLOCK_COMPONENT] iff the i-th solution path is not empty
% - x_iblocks[i,IBLOCK_COMPONENT] is absent iff the i-th solution path is empty
array[PATH_ID, IBLOCK_COMPONENT] of var opt int: x_iblocks;

% the series of aggregated i-blocks recursively computed by aggregation over the array of i-blocks propagated through the solution paths
% - x_aggregated_iblocks[i,IBLOCK_COMPONENT] == iAggregate(x_aggregated_iblocks[i-1,IBLOCK_COMPONENT], x_iblocks[i,IBLOCK_COMPONENT])
% - x_aggregated_iblocks[i,IBLOCK_COMPONENT] is absent iff the i-th solution path is empty
array[PATH_ID, IBLOCK_COMPONENT] of var opt int: x_aggregated_iblocks;

% the influence aggregated from the first solution path to the last solution path and corresponding to the last term of the aggregation series
% - x_aggregated_influence == (iblock: x_aggregated_iblocks[x_nr_paths,IBLOCK_COMPONENT]) iff x_nr_paths!=0 (a solution path exists)
% - x_aggregated_influence == getNullInfluence(cmap.itype) iff x_nr_paths==0 (no solution path exists)
var INFLUENCE: x_aggregated_influence
	:: no_output
;

% optional boolean variable representing the satisfiability of the query
var bool: x_cmql_value;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY CONSTRAINT

%
constraint :: "constraint: path aggregation between origin and destination nodes"
	% binds origin node if given
	(occurs(origin_node) -> (x_origin_node == deopt(origin_node))) /\ % !! see semantics of == over opt vars
	% binds destination node if given
	(occurs(destination_node) -> (x_destination_node == deopt(destination_node))) /\ % !! see semantics of == over opt vars
	% searches for non-empty dipaths
	if DEOPT_F_FIXED_NODE = F_UNFIXED then
		cmql_value(cmap, x_origin_node, x_destination_node, x_nr_paths, x_arc_path_lengths, x_arc_paths, x_node_paths, x_iblock_paths, x_propagated_iblocks, x_iblocks, x_aggregated_iblocks, x_aggregated_influence) 
	else
		cmql_value_fixed(cmap, deopt(origin_node), deopt(destination_node), x_nr_paths, x_arc_path_lengths, x_arc_paths, x_node_paths, x_iblock_paths, x_propagated_iblocks, x_iblocks, x_aggregated_iblocks, x_aggregated_influence) 
	endif /\
	% reifying satisfiability of query (to customize)
	x_cmql_value == (x_nr_paths >= 1) /\
	% forcing satisfiability
	x_cmql_value /\
	true
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY SEARCH STRATEGY

solve
	:: cmql_value_search(x_origin_node, x_destination_node, x_nr_paths, x_arc_path_lengths, x_arc_paths, x_node_paths, x_iblock_paths, x_propagated_iblocks, x_iblocks, x_aggregated_iblocks, x_aggregated_influence, x_cmql_value)
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
output :: "o_solution_cmql_value"
	cmql_value_output(cmap, x_nr_paths, x_arc_path_lengths, x_arc_paths, x_node_paths, x_iblock_paths, x_propagated_iblocks, x_iblocks, x_aggregated_iblocks, x_aggregated_influence);
