%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE VISUALIZATION: PATH_VALUE



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUERY DATA/VARS AND CONSTRAINTS FOR VISUALIZATION

% the array of arc tails of the c-map
array[ARC_ID] of NODE_ID: from = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, TAIL]);

% the array of arc heads of the c-map
array[ARC_ID] of NODE_ID: to = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, HEAD]);

% the nodes belonging to or not belonging to the solution path
array[NODE_ID] of var bool: x_node_in 	:: no_output;

% the arcs belonging to or not belonging to the solution path
array[ARC_ID] of var bool: x_arc_in 	:: no_output;

%
predicate viz_cmql_path_value(CMAP: cmap, array[int] of var opt int: x_node_path, array[int] of var opt int: x_arc_path, array[int] of var bool: x_node_in, array[int] of var bool: x_arc_in)
	:: "viz_cmql_path_value($cmap,$x_node_path,$x_arc_path,$x_node_in,$x_arc_in): determines arc array $x_arc_in and node array $x_node_in consistent with arc sequence $x_arc_path and node sequence $x_node_path (var)"
	=
	(forall(i in index_set(x_node_in))(x_node_in[i] <-> i in x_node_path)) /\
	(forall(i in index_set(x_arc_in))(x_arc_in[i] <-> i in x_arc_path)) /\
	true
;

% sets necessary variables for visualization
constraint viz_cmql_path_value(cmap, x_node_path, x_arc_path, x_node_in, x_arc_in);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZATION

output vis_digraph_highlight(
		[cmap.node_labels[i].concept.name | i in NODE_ID], % node labels
		from, % from
		to, % to
		[showInfluence(cmap.arc_labels[i].influence) | i in ARC_ID], % edge labels
		x_node_in, % node bools
		x_arc_in % edge bools
);