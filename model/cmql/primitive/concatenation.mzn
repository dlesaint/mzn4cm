include "./../../cmql/primitive_api.mzn";

include "./../../cmap/cmap_api.mzn";
include "./../../cmap/cmap.mzn";
include "./../../itype/itype_api.mzn";
include "./../../itype/itype.mzn";
include "./../../feature/feature_api.mzn";
include "./../../feature/feature.mzn";
include "./../../ranges/ranges_api.mzn";
include "./../../ranges/ranges.mzn";

predicate cmql_concatenation (
    var int: x_path_length,
    array[int] of var opt int: x_node_path,

    var int: y_path_length,
    array[int] of var opt int: y_node_path,

    var int: z_nb_paths,
    array[int] of var int: z_paths_length,
    array[int,int] of var opt int: z_node_paths

) = let {
	set of int: NODE_PATH = index_set_2of2(z_node_paths);
} in
    %(10) La taille de l'ensemble de chemins résultant est de 1
    z_nb_paths = 1 /\
    %(11) Determine le nombre de noeuds du chemin résultat
    z_paths_length[1] = x_path_length + y_path_length /\
    %(12-13) Concaténation
    forall (i in NODE_PATH)(occurs(x_node_path[i]) -> (z_node_paths[1,i] = x_node_path[i])) /\
    forall (i in NODE_PATH)(occurs(y_node_path[i]) -> (y_node_path[i] = z_node_paths[1, x_path_length+i])) /\
    true
;