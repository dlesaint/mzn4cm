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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICATES FOR PATH COMPUTATION


predicate cmql_value (
    CMAP: cmap,
    var INFLUENCE: x_influence,
    var int: x_origin_node,
    var int: x_destination_node,
    array[int] of var int: x_arc_path_length,
    array[int,int] of var opt int: x_node_path,
    array[int,int] of var opt int: x_arc_path,    
	array[int] of var INFLUENCE: x_influences,
    array[int,int] of var INFLUENCE: x_influence_paths,
    array[int,int] of int: from, % placed in signature for visualization only
	array[int,int] of int: to, % placed in signature for visualization only
	array[int,int] of var bool: x_node_in, % placed in signature for visualization only
	array[int,int] of var bool: x_arc_in % placed in signature for visualization only
    )
    :: "predicate: cmql_path_value"
= 
let {
        set of int: NB_ARC = 1..100; %TODO: calculer le nombre d’arcs
		set of int: NODE_ID = 1..100;
		set of int: ARC_ID = 1..100;
        
% 		array[ARC_ID] of NODE_ID: from = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, TAIL]);
% 		array[ARC_ID] of NODE_ID: to = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, HEAD]);
		
        
		%array[ARC_ID, IBLOCK_COMPONENT] of opt int: iblocks = array2d(ARC_ID, IBLOCK_COMPONENT, [influences[i].iblock[j] | i in ARC_ID, j in IBLOCK_COMPONENT]);
		%array[ARC_ID, IBLOCK_COMPONENT] of var opt int: x_iblocks;
% 		array[NODE_ID] of var bool: x_node_in;
% 		array[ARC_ID] of var bool: x_arc_in;
	} in {
		forall(i in NB_ARC) (cmql_path_value(
            cmap,
            x_influences[i],
            x_origin_node, 
            x_destination_node, 
            x_arc_path_length[i], 
            x_node_path[i,1..100], 
            x_arc_path[i,1..100],
            x_influence_paths[i,1..100],
            from[i,1..100], 
            to[i,1..100], 
            x_node_in[i,1..100], 
            x_arc_in[i,1..100]))    
    }
