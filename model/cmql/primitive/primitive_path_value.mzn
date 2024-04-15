%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CMQL PRIMITIVE: PATH_VALUE



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

include "alldifferent.mzn"; % for path concept minimality feature in dpath
include "dag.mzn"; % for path arc minimality feature in dpath
include "path.mzn"; % for dpath



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICATES FOR PATH COMPUTATION

%
predicate cmql_path_value(
						CMAP: cmap,
						var INFLUENCE: x_influence,
						var int: x_origin_node,
						var int: x_destination_node,
						var opt int: x_arc_path_length,
						array[int] of var opt int: x_node_path,
						array[int] of var opt int: x_arc_path,
						array[int] of var opt INFLUENCE: x_influence_path,
						array[int] of int: from, % placed in signature for visualization only
						array[int] of int: to, % placed in signature for visualization only
						%array[int] of var bool: x_node_in, % placed in signature for visualization only
						%array[int] of var bool: x_arc_in % placed in signature for visualization only
					)
	:: "predicate: cmql_path_value"
	=
		assert(isProperRange(index_set(x_node_path)), "cmql_path_value: index sets of $x_node_path must be a proper range") /\
		assert(index_sets_agree(x_node_path, cmap.node_labels), "cmql_path_value: index sets of $x_node_path and c$-map must agree") /\
		assert(isProperRange(index_set(x_arc_path)), "cmql_path_value: index sets of $x_arc_path must be a proper range") /\
		assert(index_sets_agree(x_arc_path, cmap.arc_labels), "cmql_path_value: index sets of $x_arc_path and $c-map must agree") /\
		assert(index_sets_agree(x_influence_path, x_arc_path), "cmql_path_value: index sets of $x_influence_path and $x_arc_path must agree") /\
	let {
		set of int: NODE_ID = index_set(x_node_path);
		set of int: ARC_ID = index_set(x_arc_path);
% 		array[ARC_ID] of NODE_ID: from = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, TAIL]);
% 		array[ARC_ID] of NODE_ID: to = array1d(ARC_ID, cmap.adigraph.tail_head[ARC_ID, HEAD]);
		array[ARC_ID] of INFLUENCE: influences = array1d(ARC_ID, [cmap.arc_labels[i].influence | i in ARC_ID]);
		array[ARC_ID, IBLOCK_COMPONENT] of opt int: iblocks = array2d(ARC_ID, IBLOCK_COMPONENT, [influences[i].iblock[j] | i in ARC_ID, j in IBLOCK_COMPONENT]);
		array[ARC_ID, IBLOCK_COMPONENT] of var opt int: x_iblocks;
% 		array[NODE_ID] of var bool: x_node_in;
% 		array[ARC_ID] of var bool: x_arc_in;
	} in
		assert(index_sets_agree(from, x_arc_path), "cmql_path_value: index sets of $from and $x_arc_path must agree") /\
		%assert(index_sets_agree(from, x_arc_in), "cmql_path_value: index sets of $from and $x_arc_in must be identical") /\
		assert(dom_array(from ++ to) subset index_set(x_node_path),"cmql_path_value: nodes in $from and $to must be in index set of $x_node_path") /\
		%assert(index_sets_agree(x_node_in, x_node_path), "cmql_path_value: index sets of $x_node_in and $x_node_path must agree") /\
		%assert(index_sets_agree(x_arc_in, x_arc_path), "cmql_path_value: index sets of $x_arc_in and $x_arc_path must agree") /\
		%assert(dom_array(from) subset index_set(x_node_in), "cmql_path_value: nodes in $from must be in index set of $x_node_in") /\
		%assert(dom_array(to) subset index_set(x_node_in), "cmql_path_value: nodes in $to must be in index set of $x_node_in") /\

		% Absent case
			absent(x_arc_path_length) <-> forall (i in NODE_ID) (absent(x_node_path[i]))
		/\ 	absent(x_arc_path_length) <-> forall (i in ARC_ID) (absent(x_arc_path[i]))
		% S’il n’y a pas de chemin, la valeur renvoyer est le neutre
		/\ absent(x_arc_path_length) -> x_influence == (iblock: getNeutralElement(cmap.itype.ealgebra, ALGEBRAIC_OPERATION_2).value)
		/\ absent(x_arc_path_length) <-> forall(i in ARC_ID, j in IBLOCK_COMPONENT) (absent(x_iblocks[i,j]))
				% origin and destination nodes must be different
		/\	x_origin_node != x_destination_node
				% bounds path length
		/\	occurs(x_arc_path_length) <-> deopt(x_arc_path_length) in 0..card(ARC_ID)
				% enforces path minimality
		/\	if	F_PATH_MINIMALITY == F_PATH_MINIMALITY_NODE
					% all_different on opt OK - see fzn_all_different_int_opt
			then	all_different(x_node_path)
			else 	% F_PATH_MINIMALITY = F_PATH_MINIMALITY_ARC
					% entailed by path computation constraints TODO check!!
					true
			endif
			
%				% !! dpath cannot be used inside predicate as it cannot be reified in MZN (always true? check if inexistence of path means every node/arc variable is false in input var arrays)
% 				% determines a path possibly including cycles
% 		/\	dpath(from, to, x_origin_node, x_destination_node, x_node_in, x_arc_in)

				% forcing path existence
				% TODO consider removing?
		/\	occurs(x_arc_path_length) <-> deopt(x_arc_path_length) > 0

				% maps arcs of path to boolean arc array
		%/\	forall(i in ARC_ID)((x_arc_in[i] <-> exists(j in ARC_ID)(deopt(x_arc_path[j]) == i)))
				% maps nodes of path to boolean node array
		%/\	forall(i in NODE_ID)((x_node_in[i] <-> exists(j in NODE_ID)(deopt(x_node_path[j]) == i)))

				% deopts arcs of path and sets arc path length
		/\	occurs(x_arc_path_length) -> (forall(i in ARC_ID)((occurs(x_arc_path[i]) <-> deopt(x_arc_path_length) >= i)))
% 				% entailed by above constraint
% 				% sets path length to number of arcs in path
% 				% |- arc path length is 0 iff no arcs in path
% 		/\	x_arc_path_length = count(x_arc_in)
		
				% sets origin node as origin of path
		/\	occurs(x_arc_path[min(ARC_ID)]) -> (from[deopt(x_arc_path[min(ARC_ID)])] == x_origin_node)
				% chains arcs of path
		/\ 	occurs(x_arc_path_length) -> (forall (i in min(ARC_ID)<..max(ARC_ID)) (deopt(x_arc_path_length) >= i -> occurs(x_arc_path[i])))
		/\	occurs(x_arc_path_length) -> (forall(i in min(ARC_ID)<..max(ARC_ID))(deopt(x_arc_path_length) >= i -> to[deopt(x_arc_path[i-1])] == from[deopt(x_arc_path[i])]))
				% sets destination node as destination of path
		/\	occurs(x_arc_path_length) -> (to[deopt(x_arc_path[deopt(x_arc_path_length)])] == x_destination_node)

				% matches nodes of path with tail nodes of arcs of path
				% !! forall over ARC_ID, not NODE_ID !!
		/\	occurs(x_arc_path_length) -> (forall(i in ARC_ID)((deopt(x_arc_path_length) >= i -> deopt(x_node_path[i]) == from[deopt(x_arc_path[i])])))
				% matches last node of path with head node of last arc of path
		/\	occurs(x_arc_path_length) -> (deopt(x_node_path[deopt(x_arc_path_length) + 1]) == to[deopt(x_arc_path[deopt(x_arc_path_length)])])
				% entailed by above constraints
				% deopts nodes of path based on node path length (= 1 + arc path length)
		/\	occurs(x_arc_path_length) -> (forall(i in NODE_ID)((occurs(x_node_path[i]) <-> deopt(x_arc_path_length) + 1 >= i)))
		
				% matches influence path with arc path
		/\	(forall(i in ARC_ID)(occurs(x_arc_path[i]) <-> forall(j in IBLOCK_COMPONENT)(occurs(x_influence_path[i].iblock[j]))))
		/\	(forall(i in ARC_ID)(absent(x_arc_path[i]) <-> forall(j in IBLOCK_COMPONENT)(absent(x_influence_path[i].iblock[j]))))

				% binds i-block vars and path influence vars
		/\	forall(i in ARC_ID)(occurs(x_influence_path[i]) -> deopt(x_influence_path[i]).iblock == x_iblocks[i, IBLOCK_COMPONENT])

				% sets influence of first arc
				% !! TODO can't look up directly on var influence object (cmap.arc_labels[x_arc_path[min(ARC_ID)]].influence) so look up on iblocks ...
				% "type error: array access using a variable is not supported for array of a record type which contain an array"
		/\	occurs(x_arc_path_length) -> (x_iblocks[min(ARC_ID), IBLOCK_COMPONENT] == [iblocks[x_arc_path[min(ARC_ID)], j] | j in IBLOCK_COMPONENT])

				% propagates influence recursively through path
		/\	occurs(x_arc_path_length) -> (forall(i in min(ARC_ID)<..max(ARC_ID))(
					(occurs(x_arc_path[i]) -> x_iblocks[i, IBLOCK_COMPONENT] 
% 					x_influence_path[i]
					 == iPropagate((iblock: deopt([(iblocks[x_arc_path[i], j]) | j in IBLOCK_COMPONENT])), (iblock: deopt(x_iblocks[i-1, IBLOCK_COMPONENT]))).iblock)
			))
		
				% sets path influence
		/\	occurs(x_arc_path_length) -> x_influence == (iblock: [x_iblocks[x_arc_path_length, i] | i in IBLOCK_COMPONENT])
	;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PREDICATES FOR DAGs

% %
% predicate lt(var CONCEPT_ID: x, var CONCEPT_ID: y) =
% 	let {
% 		array[CONCEPT_ID] of var bool: xc_inpath;
% 		array[ARC_ID] of var bool: xa_inpath;
% 		var int: x_length;
% 		constraint dpath(from, to, i, j, xc_inpath, xa_inpath);
% 		constraint x_length = sum(xa_inpath);
% 	} in
% 		x_length > 0
% 	;
	
% %
% predicate lte(var CONCEPT_ID: x, var CONCEPT_ID: y) =
% 	(x != y) -> lt(x, y);
	
% % lte(x,y) <-> occurs(x) /\ occurs(y) /\ lte(deopt(x), deopt(y))
% predicate lte(var opt CONCEPT_ID: x, var opt CONCEPT_ID: y) =
% 	occurs(x) /\
% 	occurs(y) /\
% 	lte(deopt(x), deopt(y))
% 	;
	
% %
% predicate incomparable(var opt CONCEPT_ID: x, var opt CONCEPT_ID: y) =
% 	not(lte(x,y)) /\ 
% 	not(lte(y,x))
% 	;
	
% % arg_sort based on less_than
% predicate arg_sort(array[CONCEPT_ID] of var opt CONCEPT_ID: x, array[CONCEPT_ID] of var CONCEPT_ID: p) =
% 	all_different(p) /\
% 	forall(j in 1..length(x)-1) (
% 		(lte(x[p[j]], x[p[j+1]]) \/ (incomparable(x[p[j]], x[p[j+1]]) -> p[j] < p[j+1])) /\
% 		(x[p[j]] == x[p[j+1]] -> p[j] < p[j+1]) % !! do not use ~= in place of ==
% 		)
% 	;
