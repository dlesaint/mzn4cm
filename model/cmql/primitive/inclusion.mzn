include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

predicate cmql_inclusion (
    array[int,int] of var opt int: x_node_paths,
    array[int,int] of var opt int: y_node_paths
) = let {
    set of int: PATH_ID = index_set_1of2(x_node_paths);
    set of int: NODE_PATH = index_set_2of2(x_node_paths);
    array[PATH_ID] of var 0..max(PATH_ID): xy_same_paths;
} in
%(14) Met en correspondance le i-ième de de x et son rang dans y
forall(i in PATH_ID) (occurs(x_node_paths[i,1]) -> forall(j in NODE_PATH)(x_node_paths[i,j] = y_node_paths[xy_same_paths[i], j])) /\

%(15) neutralise l'indexation pour les chemins vides de x
forall (i in PATH_ID)(absent(x_node_paths[i,1]) <-> xy_same_paths[i] = 0)
;