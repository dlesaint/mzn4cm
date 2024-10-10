include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

predicate cmql_length (
    array[int] of CMAP: cmaps,
    var int: cmap,
    array[int] of var opt int: x_arc_path,
    array[int] of var opt int: x_node_path,
    var int: x_length
) = 
let {
    set of int: ARC_PATH = index_set(x_arc_path);
} in
    %Calcul la taille du chemin
    forall (i in ARC_PATH) (occurs(x_arc_path[i]) <-> x_length >= i)
;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

function array[int] of string: cmql_length_output (
	CMAP: cmap,
	array[int] of var opt int: x_arc_path,
	array[int] of var opt int: x_node_path,
    var int: x_length
)
= 
let {
		set of int: NODE_ID = index_set(cmap.node_labels);
		set of int: ARC_PATH = index_set(x_arc_path);
	} in
		["Node path : "] ++ [show(x_node_path)] ++ ["\n"] ++
		["Arc path : "] ++ [show(x_arc_path)] ++ ["\n"] ++
    ["Path length : "] ++ [show(x_length)]
	;