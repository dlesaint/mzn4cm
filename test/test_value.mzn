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

% CMQL VISUALIZATION (optional)
include "./../model/cmql/primitive/primitive_value_viz.mzn";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

%
% constraint assert(mzn_internal_check_debug_mode(), "--debug flag is not set");

% 
constraint assertDataset(dataset);

% 
constraint assertInstance(instance);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INSTANCE CMAP DATA

%
CMAP: cmap = instance.cmaps[1];

%
set of int: NODE_ID = index_set(cmap.node_labels);

%
set of int: ARC_ID = index_set(cmap.arc_labels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY INPUT DATA

% optional origin node
opt NODE_ID: origin_node;

% optional destination node
opt NODE_ID: destination_node;


% Assertions
constraint assert((occurs(origin_node) \/ occurs(destination_node)) -> deopt(origin_node )!= deopt(destination_node), "path origin and destination concepts must be different");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY DATA/VARS FOR VISUALIZATION ONLY

array[ARC_ID] of NODE_ID: from = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, TAIL]);
array[ARC_ID] of NODE_ID: to = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, HEAD]);
array[NODE_ID] of var bool: x_node_in 	:: no_output;
array[ARC_ID] of var bool: x_arc_in 	:: no_output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY VARIABLES

%
var NODE_ID: x_origin_node
	:: no_output
;
	
%
var NODE_ID: x_destination_node
	:: no_output
;

%
array[int] of var 0..card(ARC_ID): x_arc_path_length;

%
array[int,NODE_ID] of var opt NODE_ID: x_node_path
	:: no_output
;

%
array[int,ARC_ID] of var opt ARC_ID: x_arc_path
	:: no_output
;

%
array[ARC_ID] of var INFLUENCE: x_influence_path;

%
var INFLUENCE: x_influence
	:: no_output
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY

%
constraint :: "constraint: path propagation between origin and destination nodes"
			% binds origin node if given
			(occurs(origin_node) -> x_origin_node == origin_node)
			% binds destination node if given
		/\	(occurs(destination_node) -> x_destination_node == destination_node)
			% query
		/\	cmql_value(cmap, x_influence, x_origin_node, x_destination_node, x_arc_path_length, x_node_path, x_arc_path, x_influence_path, from, to, x_node_in, x_arc_in)
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
	%array[int,int] of var NODE_ID : o_x_node_path;
	%forall (j in NB_ARC) (o_x_node_path[j] = deopt([x_node_path[j][i] | i in index_set(x_node_path[j]) where occurs(fix(x_node_path[j][i]))]));
	%array[int] of var ARC_ID : o_x_arc_path = deopt([x_arc_path[i] | i in index_set(x_arc_path) where occurs(fix(x_arc_path[i]))]);
} in
	 ["Path length =\t\t"]
++ [ show(x_arc_path_length)]
++ ["\n"]
++	 ["Node path =\t\t"]
% ++ [my_show1d_indexed(D_INT, (map2name(D_NODE_ID, [fix(o_x_node_path[i]) | i in index_set(o_x_node_path)])))]
%++ [ cmap.node_labels[fix(o_x_node_path[i])].concept.name ++ if i < max(index_set(o_x_node_path)) then " - " else "" endif | i in index_set(o_x_node_path)]
++ ["\n"]
++ ["Arc path =\t\t"]
%++ [ "(" ++ show(cmap.arc_labels[fix(o_x_arc_path[i])].arc.t) ++ "," ++ show(cmap.arc_labels[fix(o_x_arc_path[i])].arc.h) ++ ")" ++ if i < max(index_set(o_x_arc_path)) then " - " else "" endif | i in index_set(o_x_arc_path)]
++ ["\n"]
++ ["Influence  path=\t"]
++ [ showInfluence(fix(x_influence_path[i])) ++ if i < max(index_set(x_influence_path)) then " " else "" endif | i in index_set(x_influence_path)]
++ ["\n"]
++ ["I-block path =\t\t"]
++ [show(x_influence_path)]
++ ["\n"]
++ ["Propagated influence =\t"]
++ [showInfluence(fix(x_influence)) ++ " == " ++ show(fix(x_influence))]
++ ["\n"]
;