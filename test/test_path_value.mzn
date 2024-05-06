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
%% QUERY

%
constraint :: "constraint: path propagation between origin and destination nodes"
		% binds origin node if given
		(occurs(origin_node) -> x_origin_node == origin_node)
		% binds destination node if given
	/\	(occurs(destination_node) -> x_destination_node == destination_node)
		% searches for non-empty dipath
	/\	cmql_path_value(cmap, x_origin_node, x_destination_node, x_arc_path_length, x_arc_path, x_node_path, x_iblock_path, x_propagated_iblocks, x_propagated_influence)
	/\	x_cmql_path_value == (x_arc_path_length > 0)
	/\	x_cmql_path_value
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

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
output :: "o_solution"
let {
	set of int: ARC_PATH_LENGTH = 1..fix(x_arc_path_length);
	array[int] of opt NODE_ID : o_x_node_path = fix([deopt(x_node_path[i]) | i in index_set(x_node_path) where occurs(x_node_path[i])]);
	array[int] of opt ARC_ID : o_x_arc_path = fix([deopt(x_arc_path[i]) | i in index_set(x_arc_path) where occurs(x_arc_path[i])]);
	array[ARC_PATH_LENGTH,IBLOCK_COMPONENT] of opt int: o_x_iblock_path = array2d(ARC_PATH_LENGTH, IBLOCK_COMPONENT, fix([deopt(x_iblock_path[i,j]) | i in index_set_1of2(x_iblock_path), j in index_set_2of2(x_iblock_path) where occurs(x_iblock_path[i,j])])); 
	array[ARC_PATH_LENGTH,IBLOCK_COMPONENT] of opt int: o_x_propagated_iblocks = array2d(ARC_PATH_LENGTH, IBLOCK_COMPONENT, fix([deopt(x_propagated_iblocks[i,j]) | i in index_set_1of2(x_propagated_iblocks), j in index_set_2of2(x_propagated_iblocks) where occurs(x_propagated_iblocks[i,j])])); 
} in
	["NODE_ID =\t\t"]
++	[ show(NODE_ID)]
++	["\n"]
++	["NODE_PATH =\t\t"]
++	[ show(NODE_PATH)]
++	["\n"]
++	["ARC_ID =\t\t"]
++	[ show(ARC_ID)]
++	["\n"]
++	["ARC_PATH =\t\t"]
++	[ show(ARC_PATH)]
++	["\n"]
++	["IBLOCK_COMPONENT =\t\t"]
++	[ show(IBLOCK_COMPONENT)]
++	["\n"]
++	["Path length =\t\t"]
++	[ show(x_arc_path_length)]
++	["\n"]
++	["Node path =\t\t"]
% ++	[my_show1d_indexed(D_INT, (map2name(D_NODE_ID, [fix(o_x_node_path[i]) | i in index_set(o_x_node_path)])))]
++	[cmap.node_labels[deopt(o_x_node_path[i])].concept.name ++ if i < max(index_set(o_x_node_path)) then " - " else "" endif | i in index_set(o_x_node_path)]
++	["\n"]
++	["Arc path =\t\t"]
++	[ "(" ++ show(cmap.arc_labels[deopt(o_x_arc_path[i])].arc.t) ++ "," ++ show(cmap.arc_labels[deopt(o_x_arc_path[i])].arc.h) ++ ")" ++ if i < max(index_set(o_x_arc_path)) then " - " else "" endif | i in index_set(o_x_arc_path)]
++	["\n"]
++	["Path arc influences=\t"]
++	[ showInfluence((iblock: deopt(row(o_x_iblock_path,i)))) ++ if i < max(index_set_1of2(o_x_iblock_path)) then " " else "" endif | i in index_set_1of2(o_x_iblock_path)]
++	["\n"]
++	["Propagated i-path=\t"]
++	[ showInfluence((iblock: deopt(row(o_x_propagated_iblocks,i)))) ++ if i < max(index_set_1of2(o_x_propagated_iblocks)) then " " else "" endif | i in index_set_1of2(o_x_propagated_iblocks)]
++	["\n"]
++	["Propagated influence =\t"]
++	[showInfluence(fix(x_propagated_influence)) ++ " == " ++ show(fix(x_propagated_influence))]
++	["\n"]
;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PREDICATES FOR DAGs

% %
% predicate lt(var NODE_ID: x, var NODE_ID: y) =
% 	let {
% 		array[NODE_ID] of var bool: xn_inpath;
% 		array[ARC_ID] of var bool: xa_inpath;
% 		var int: x_length;
% 		constraint dpath(from, to, i, j, xn_inpath, xa_inpath);
% 		constraint x_length = sum(xa_inpath);
% 	} in
% 		x_length > 0
% 	;
	
% %
% predicate lte(var NODE_ID: x, var NODE_ID: y) =
% 	(x != y) -> lt(x, y);
	
% % lte(x,y) <-> occurs(x) /\ occurs(y) /\ lte(deopt(x), deopt(y))
% predicate lte(var opt NODE_ID: x, var opt NODE_ID: y) =
% 	occurs(x) /\
% 	occurs(y) /\
% 	lte(deopt(x), deopt(y))
% 	;
	
% %
% predicate incomparable(var opt NODE_ID: x, var opt NODE_ID: y) =
% 	not(lte(x,y)) /\ 
% 	not(lte(y,x))
% 	;
	
% % arg_sort based on less_than
% predicate arg_sort(array[NODE_ID] of var opt NODE_ID: x, array[NODE_ID] of var NODE_ID: p) =
% 	all_different(p) /\
% 	forall(j in 1..length(x)-1) (
% 		(lte(x[p[j]], x[p[j+1]]) \/ (incomparable(x[p[j]], x[p[j+1]]) -> p[j] < p[j+1])) /\
% 		(x[p[j]] == x[p[j+1]] -> p[j] < p[j+1]) % !! do not use ~= in place of ==
% 		)
% 	;


% function string: my_show2d_indexed(array[$$I] of var $$I: V, string: hc) =
% 	let {
% 		array[int] of string: hr = map2name(set2array(index_set(T)));
% 		array[int] of string: S = map2string(array2d(, 1..1, V));
% 	} in
% 		my_show2d_indexed(hr, [hc], ["0/1"], S)
% 	;