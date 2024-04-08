%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE: VALUE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

include "strict_lex2.mzn";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICATES FOR PATH COMPUTATION


predicate cmql_value (
    CMAP: cmap,
    var INFLUENCE: x_influence,
    var int: x_origin_node,
    var int: x_destination_node,
    var int: nb_true_path,
    array[int,int] of var opt int: x_node_path,
    array[int,int] of var opt int: x_arc_path,    
	array[int] of var INFLUENCE: x_influences,
    array[int,int] of var INFLUENCE: x_influence_paths,
    array[int] of int: from, % placed in signature for visualization only
	array[int] of int: to, % placed in signature for visualization only
	array[int,int] of var bool: x_node_in, % placed in signature for visualization only
	array[int,int] of var bool: x_arc_in % placed in signature for visualization only
    )
    :: "predicate: cmql_path_value"
= 
let {
        set of int: NB_PATH = 1..3; %TODO: calculer le nombre d’arcs
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_ID = index_set(cmap.arc_labels);
        
% 		array[ARC_ID] of NODE_ID: from = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, TAIL]);
% 		array[ARC_ID] of NODE_ID: to = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, HEAD]);
		
        array[NB_PATH, IBLOCK_COMPONENT] of opt int: iblocks = array2d(NB_PATH, IBLOCK_COMPONENT, [x_influences[i].iblock[j] | i in NB_PATH, j in IBLOCK_COMPONENT]);
		array[NB_PATH, IBLOCK_COMPONENT] of var opt int: x_iblocks;
% 		array[NODE_ID] of var bool: x_node_in;
% 		array[ARC_ID] of var bool: x_arc_in;
        array[NB_PATH] of var int: x_arc_path_length;
	} in 
		forall(i in NB_PATH) (
            cmql_path_value(
                cmap,
                x_influences[i],
                x_origin_node, 
                x_destination_node, 
                x_arc_path_length[i], 
                x_node_path[i,NODE_ID], 
                x_arc_path[i,ARC_ID],
                x_influence_paths[i,ARC_ID],
                from[ARC_ID], 
                to[ARC_ID], 
                x_node_in[i,NODE_ID], 
                x_arc_in[i,ARC_ID])
            )        
        /\	(x_iblocks[min(NB_PATH), IBLOCK_COMPONENT] == [iblocks[x_influences[min(NB_PATH)], j] | j in IBLOCK_COMPONENT])
        % assignation de l’influence
        /\ forall(i in min(NB_PATH)<..max(NB_PATH))(
					(occurs(x_influences[i]) -> x_iblocks[i, IBLOCK_COMPONENT] 
% 					x_influence_path[i]
					 == iPropagate((iblock: deopt([(iblocks[x_influences[i], j]) | j in IBLOCK_COMPONENT])), (iblock: deopt(x_iblocks[i-1, IBLOCK_COMPONENT]))).iblock)
			)
        /\ x_influence == (iblock: [x_iblocks[nb_true_path, i] | i in IBLOCK_COMPONENT])
        /\ nb_true_path == count(forall (i in NB_PATH) (occurs(x_influences[i])))
    ;