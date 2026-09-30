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

    % index (dans x et dans y) du chemin dont provient le i-ième chemin de z
    % (domaine PATH_ID et non 0..max(PATH_ID) : un index 0 hors bornes dans un tableau
    % opt fait échouer la compilation, "var opt int vs var opt top")
    array[PATH_ID] of var PATH_ID: zxID;
    array[PATH_ID] of var PATH_ID: zyID;
} in
%(16)
    cmql_inclusion(x_node_paths, z_node_paths) /\
    cmql_inclusion(y_node_paths, z_node_paths) /\

%(17) Tout chemin non vide de z est un chemin de x ou un chemin de y
    forall (i in PATH_ID)(occurs(z_node_paths[i,1]) ->
        (forall (j in NODE_PATH)(z_node_paths[i,j] = x_node_paths[zxID[i],j])
      \/ forall (j in NODE_PATH)(z_node_paths[i,j] = y_node_paths[zyID[i],j]))) /\

%(18) Fixe les index des chemins vides de z (évite les solutions symétriques)
    forall(i in PATH_ID)(absent(z_node_paths[i,1]) -> (zxID[i] = 1 /\ zyID[i] = 1)) /\
    true
;