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

predicate cmql_influence (
    CMAP: cmap,
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: x_arc_paths,
    array[int,int] of var INFLUENCE: x_influence_path,
    var INFLUENCE: x_influence,
) = let {
    set of int: PATH_ID = index_set_1of2(x_node_paths);
	set of int: NODE_PATH = index_set_2of2(x_node_paths);
    %set of int: IBLOCK_COMPONENT = index_set(cmap.itype.iblock_type.sorts);
    %set of int: ARC_ID = index_set(cmap.arc_labels);

    array[PATH_ID, NODE_PATH] of var INFLUENCE: x_propagated_path;
    array[PATH_ID] of var INFLUENCE: x_propagated_influence;
    array[PATH_ID] of var INFLUENCE: x_agregated_influence;

    % arc influences flattened to a plain array (arrays of records containing arrays cannot be indexed by a var)
    %array[ARC_ID, IBLOCK_COMPONENT] of opt int: iblocks = array2d(ARC_ID, IBLOCK_COMPONENT, [cmap.arc_labels[a].influence.iblock[k] | a in ARC_ID, k in IBLOCK_COMPONENT]);
} in
%(29) Pose la première valeur des calculs de propagation
forall (i in PATH_ID) (x_propagated_path[i,1] = getPropagationNeutral(cmap.itype)) /\
%(30) noeud absent corresponde à l'influence neutre pour la propagation
forall (i in PATH_ID)(forall (j in 2..max(NODE_PATH))((absent(x_node_paths[i,j]))->(x_propagated_path[i,j] = getPropagationNeutral(cmap.itype)))) /\
%(31) Calcul de propagation
forall (i in PATH_ID)(forall (j in 2..max(NODE_PATH))((occurs(x_node_paths[i,j]))->(x_propagated_path[i,j] = propagate(x_propagated_path[i,j-1], x_influence_path[i,j])))) /\
%(32) Un chemin vide a une influence nulle pour l'agrégation
forall (i in PATH_ID)(absent(x_node_paths[i,1]) -> (x_propagated_influence[i] = getNullInfluence(cmap.itype))) /\
%(33) Un chemin non vide a comme influnce la dernière influence propagé
forall (i in PATH_ID)((occurs(x_node_paths[i,1]))->(x_propagated_influence[i] = x_propagated_path[i, max(NODE_PATH)])) /\
%(34) La première influence agrégée est égale à l'influence propagée du premier chemin
x_agregated_influence[1] = x_propagated_influence[1] /\
%(35) Calcul de l'influence agrégée
forall (i in 2..max(PATH_ID))(x_agregated_influence[i] = aggregate(x_agregated_influence[i-1], x_propagated_influence[i])) /\
%(36) Résultat
x_influence = x_agregated_influence[max(PATH_ID)] /\

true
;