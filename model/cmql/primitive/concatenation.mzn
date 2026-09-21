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
    var int: x_node,
    var INFLUENCE: x_influence,

    var int: y_node,
    var INFLUENCE: y_influence,

    var int: z_nb_paths,
    array[int] of var int: z_paths_length,
    array[int,int] of var opt int: z_node_paths,
    array[int,int] of var INFLUENCE: z_influence_paths

) = let {
	set of int: NODE_PATH = index_set_2of2(z_node_paths);
} in
    %(10) La taille de l'ensemble de chemins résultant est de 1
    z_nb_paths = 1 /\
    %(11) Determine le nombre de noeuds du chemin résultat
    z_paths_length[1] = 2 /\
    %(12-13) Concaténation
    z_node_paths[1,1] = x_node /\ z_node_paths[1,2] = y_node /\
    z_influence_paths[1,1] = x_influence /\ z_influence_paths[1,2] = y_influence /\
    true
;

predicate cmql_concatenation (
    var int: x_nb_paths,
    array[int] of var int: x_paths_length,
    array[int,int] of var opt int: x_node_paths,
    array[int,int] of var INFLUENCE: x_influence_paths,

    var int: y_node,
    var INFLUENCE: y_influence,

    var int: z_nb_paths,
    array[int] of var int: z_paths_length,
    array[int,int] of var opt int: z_node_paths,
    array[int,int] of var INFLUENCE: z_influence_paths

) = let {
	set of int: NODE_PATH = index_set_2of2(z_node_paths);
} in
    %(10) La taille de l'ensemble de chemins résultant est de 1
    z_nb_paths = 1 /\ x_nb_paths =1 /\
    %(11) Determine le nombre de noeuds du chemin résultat
    z_paths_length[1] = x_paths_length[1] + 1 /\
    %(12-13) Concaténation
    forall (i in NODE_PATH)(occurs(x_node_paths[1,i]) -> (z_node_paths[1,i] = x_node_paths[1,i])) /\
    y_node = z_node_paths[1, x_paths_length[1]+1] /\
    true
;

predicate cmql_concatenation (
    var int: x_node,
    var INFLUENCE: x_influence,
    
    var int: y_nb_paths,
    array[int] of var int: y_paths_length,
    array[int,int] of var opt int: y_node_paths,
    array[int,int] of var INFLUENCE: y_influence_paths,

    

    var int: z_nb_paths,
    array[int] of var int: z_paths_length,
    array[int,int] of var opt int: z_node_paths,
    array[int,int] of var INFLUENCE: z_influence_paths

) = let {
	set of int: NODE_PATH = index_set_2of2(z_node_paths);
} in
    %(10) La taille de l'ensemble de chemins résultant est de 1
    z_nb_paths = 1 /\ y_nb_paths =1 /\
    %(11) Determine le nombre de noeuds du chemin résultat
    z_paths_length[1] = y_paths_length[1] + 1 /\
    %(12-13) Concaténation
    forall (i in NODE_PATH)(occurs(y_node_paths[1,i]) -> (z_node_paths[1,i+1] = y_node_paths[1,i])) /\
    x_node = z_node_paths[1, 1] /\
    true
;


predicate cmql_concatenation (
    var int: x_nb_paths,
    array[int] of var int: x_paths_length,
    array[int,int] of var opt int: x_node_paths,
    array[int,int] of var INFLUENCE: x_influence_paths,
    
    var int: y_nb_paths,
    array[int] of var int: y_paths_length,
    array[int,int] of var opt int: y_node_paths,
    array[int,int] of var INFLUENCE: y_influence_paths,

    

    var int: z_nb_paths,
    array[int] of var int: z_paths_length,
    array[int,int] of var opt int: z_node_paths,
    array[int,int] of var INFLUENCE: z_influence_paths

) = let {
	set of int: NODE_PATH = index_set_2of2(z_node_paths);
} in
    %(10) La taille de l'ensemble de chemins résultant est de 1
    z_nb_paths = 1 /\ x_nb_paths = 1 /\ y_nb_paths = 1 /\
    %(11) Determine le nombre de noeuds du chemin résultat
    z_paths_length[1] = y_paths_length[1] + x_paths_length[1] /\
    %(12-13) Concaténation
    forall (i in NODE_PATH)(occurs(y_node_paths[1,i]) -> (z_node_paths[1,i+1] = y_node_paths[1,i])) /\
    forall (i in NODE_PATH)(occurs(y_node_paths[1,i]) -> (z_node_paths[1,i] = x_node_paths[1,i])) /\
    true
;