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

predicate cmql_fusion (
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: y_node_paths,
    array[int, int] of var opt int: z_node_paths,

    array[int] of var int: x_paths_length,
    array[int] of var int: y_paths_length,
    array[int] of var int: z_paths_length,
) =
let {
    set of int: PATH_ID = index_set_1of2(x_node_paths);
	set of int: NODE_PATH = index_set_2of2(x_node_paths);

    array[PATH_ID] of var 0..max(PATH_ID): zID;
    array[PATH_ID] of var 0..max(PATH_ID): xID;
    array[PATH_ID] of var 0..max(PATH_ID): yID;
    array[PATH_ID, PATH_ID] of var 0..max(PATH_ID): xyID;
}
in

    %(19)
    forall (i in PATH_ID)((xID[i] + yID[i] +zID[i] != 0) -> (xID[i] * yID[i] * zID[i] != 0)) /\
    %(20)
    forall (i in PATH_ID)((zID[i] != 0) -> (z_paths_length[zID[i]] = x_paths_length[xID[i]] + y_paths_length[yID[i]] -1)) /\
    %(21)
    forall (i in PATH_ID)((zID[i] != 0) -> (forall (j in NODE_PATH)((j <= x_paths_length[xID[i]])->(z_node_paths[zID[i],j] = x_node_paths[xID[i], j])))) /\
    %(22)
    forall (i in PATH_ID)((zID[i] != 0)->(forall (j in NODE_PATH)((j >= x_paths_length[xID[i]])->(z_node_paths[zID[i],j] = y_node_paths[yID[i], j-x_paths_length[xID[i]]+1])))) /\
    %(23)
    forall (k,l in PATH_ID) ((x_paths_length[k] != 0) -> ((x_node_paths[k, max(1,x_paths_length[k])] = y_node_paths[l,1]) -> (xID[xyID[k,l]] = k /\ yID[xyID[k,l]] = l))) /\
    %(24)
    forall (m in PATH_ID)((z_paths_length[m] != 0) -> (m in zID)) /\
    %(25)
    forall (i in 1..(max(PATH_ID)-1))((zID[i] <= zID[i+1]) /\ ((zID[i] = zID[i+1] /\ zID[i] != 0) -> (xID[i] < xID[i+1]))) /\
    true;
