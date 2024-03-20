%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE VISUALIZATION: PATH_VALUE



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION



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