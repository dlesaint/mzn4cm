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

predicate cmql_k_variable (
    CMAP: cmap,
    var int: x_nb_path,
    array[int] of var int: x_paths_length,
    array[int, int] of var opt int: x_node_paths,
    array[int, int] of var opt int: x_arc_paths,
	array[int,int] of var INFLUENCE: x_influence_path
) = 
let {
    set of int: PATH_ID = index_set_1of2(x_arc_paths);
	set of int: ARC_ID = index_set(cmap.arc_labels);
	set of int: ARC_PATH = index_set_2of2(x_arc_paths);
	set of int: NODE_PATH = index_set_2of2(x_node_paths);

	% arc influences flattened to a plain array (arrays of records containing arrays cannot be indexed by a var)
    array[ARC_ID, IBLOCK_COMPONENT] of opt int: iblocks = array2d(ARC_ID, IBLOCK_COMPONENT, [cmap.arc_labels[a].influence.iblock[k] | a in ARC_ID, k in IBLOCK_COMPONENT]);
} in 
%(1) Scinde les variables-noeuds d'une ligne en complétant la séquence de noeuds du chemin par des noeuds virtuels
forall (i in PATH_ID) (forall(j in ARC_PATH)(absent(x_node_paths[i,j]) -> absent(x_node_paths[i,j+1])))
%(2) Lie le nombre de noeuds d'un chemin à l'occurence du dernier noeud non-virtuel
/\ forall (i in PATH_ID)(forall (j in NODE_PATH)(occurs(x_node_paths[i,j]) <-> x_paths_length[i] >= j))
%(3) Interdit les cycles dans chaque chemins
/\ forall (i in PATH_ID)(alldifferent(x_node_paths[i, NODE_PATH]))
%(4) Rassemble les chemins vides en fin de tableau
/\ forall (i in PATH_ID)(x_nb_path < i <-> x_paths_length[i] = 0)
%(5-6) Forcent un ordre lexicographique strict sur les chemins non-vides
/\ lex_chain_less_opt(x_nb_path, x_paths_length, x_arc_paths) /\
%(7) Applique le pattern de (1) aux variables-arcs
forall (i in PATH_ID)(forall (j in min(ARC_PATH)..<max(ARC_PATH))(absent(x_arc_paths[i,j]) -> absent(x_arc_paths[i,j+1]))) /\
%(8) Couple les varialbles arcs et noeuds des chemins
forall (i in PATH_ID)(forall(j in ARC_PATH)(occurs(x_arc_paths[i,j]) <-> occurs(x_node_paths[i,j+1]))) /\
%(9) Impose la compatibilité avec les chemins du graphe de la CMAP
forall (i in PATH_ID)(forall (j in ARC_PATH)(occurs(x_arc_paths[i,j]) -> (x_node_paths[i,j] = cmap.adigraph.tail_head[x_arc_paths[i,j],TAIL] /\ x_node_paths[i,j+1] = cmap.adigraph.tail_head[x_arc_paths[i,j],HEAD]))) /\
%(26) Les noeuds vide on l'influence neutre de l'agrégation
forall (i in PATH_ID)(forall (j in NODE_PATH)((x_influence_path[i,j] = getNullInfluence(cmap.itype))<->(absent(x_node_paths[i,j])))) /\
%(27) Si le chemin n'est pas vide la première influence est le neutre de la propagation
forall (i in PATH_ID)(occurs(x_node_paths[i,1]) -> (x_influence_path[i,1] = getPropagationNeutral(cmap.itype))) /\
%(28) L'influence d'un noeud non-vide est l'étiquetage de l'arc entrant
forall (i in PATH_ID)(forall (j in 2..max(NODE_PATH))(occurs(x_node_paths[i,j]) -> (x_influence_path[i,j] = (iblock: [iblocks[deopt(x_arc_paths[i,j-1]), k] | k in IBLOCK_COMPONENT])))) /\
true
;

predicate lex_chain_less_opt(var int: x_on, array[int] of var int: x_lengths, array[int, int] of var opt int: x)
	=
	increasing_opt_lengths(x_on, x_lengths) /\
	assert(index_set(x_lengths) == index_set_1of2(x), "lex_chain_less_opt: the index set of $x_lengths must be equal to the row index set of $x") /\
	forall(i in min(index_set_1of2(x))..<max(index_set_1of2(x)))(
		lex_less_opt(x_lengths[i], x_lengths[i+1], x[i,index_set_2of2(x)], x[i+1,index_set_2of2(x)])
	)
;
		
%
predicate increasing_opt_lengths(var int: y, array[int] of var int: x)
	=
	%forall(i in index_set(x))(i <= y <-> x[i] != 0) /\
	forall(i in min(index_set(x))..<max(index_set(x)))(i+1 <= y -> x[i] <= x[i+1])
;
		
%
predicate lex_less_opt(var int: x_length, var int: y_length, array[int] of var opt int: x, array[int] of var opt int: y)
	=
	%assert(isProperRange(index_set(x)), "lex_less_opt: the index set of $x is a proper range") /\
	assert(index_set(x) == index_set(y), "lex_less_opt: the index sets of $x and $y must be equal") /\
	let {
		int: size = length(x);
		array[0..size] of var bool: b :: is_defined_var;
	} in
	if y_length == 0 \/ x_length != y_length
	then
		 	forall(i in 0..size)(b[i])
	else	
% 			x_length > 0 /\ % !! entailed by increasing_opt_lengths
% 			x_length <= y_length /\ !! entailed by increasing_opt_lengths
			b[size] = (x_length < y_length) /\
			forall(i in 0..size-1)(b[i] = ((x[1 + i] <= y[1 + i]) /\ ((x[1 + i] <  y[1 + i] /\ (occurs(y[i+1]) \/ occurs(x[i+1])))\/ b[i+1]))) /\ % !! simplification of next constraint due to cmql_path_value/cmql_arc_path
% 			forall(i in 0..size-1)(b[i] = (occurs(x[1 + i]) /\ occurs(y[1 + i])) -> (x[1 + i] <= y[1 + i] /\ (x[1 + i] <  y[1 + i] \/ b[i+1]))) /\
			b[0]
  endif
  :: defines_var(b)
 ;