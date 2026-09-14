include "alldifferent.mzn";
include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

predicate cmql_addition (
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: y_node_paths,
    array[int, int] of var opt int: z_node_paths,
) = let {
    set of int: PATH_ID = index_set_1of2(x_node_paths);
	set of int: NODE_PATH = index_set_2of2(x_node_paths);

    array[PATH_ID] of var 0..max(PATH_ID): xID;
    array[PATH_ID] of var 0..max(PATH_ID): yID;
    array[PATH_ID] of var 0..max(PATH_ID): zxID;
    array[PATH_ID] of var 0..max(PATH_ID): zyID;
} in
%(16)
    cmql_inclusion(x_node_paths, z_node_paths) /\
    cmql_inclusion(y_node_paths, z_node_paths) /\

%(17)
    forall (i in PATH_ID)(occurs(z_node_paths[i,1]) -> (i = xID[zxID[i]] \/ i = yID[zyID[i]])) /\

%(18) 
    forall(i in PATH_ID)(absent(z_node_paths[i,1]) -> (zxID[i] = 0 /\ zyID[i] = 0)) /\
    true
;