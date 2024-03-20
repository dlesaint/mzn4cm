%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A-DIGRAPH
%
%	- Implements part of A-DIGRAPH API
%		- ASSERTIONS
%			- assertADigraph



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../adigraph/adigraph_api.mzn";
include "../../ranges/ranges.mzn"; % for assertions



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertADigraph(ADIGRAPH: adg)
	:: "function assertADigraph($adg): asserts consistency of a-digraph $adg"
	=
	let {
		set of int: NODE = index_set_1of2(adg.a);
		array[int] of opt int: o_arcs = [adg.a[i,j] | i in index_set_1of2(adg.a), j in index_set_2of2(adg.a)];
		array[int] of int: arcs = [deopt(o_arcs[i]) | i in index_set(o_arcs) where occurs(o_arcs[i])];
		set of int: ARC = array2set(arcs);
	} in
		assert(NODE = index_set_2of2(adg.a), "(1-1) arc matrix must be square with identical index sets") /\
		assert(isProperRange(ARC), "(1-2) arc matrix must determine a proper range of arcs") /\
		assert(forall(i,j in ARC where i<j)(arcs[i]!=arcs[j]), "(1-3) duplicate arcs are forbidden") /\
		% (1-4) entails (1-3)
		assert(forall(i in ARC where i+1 in ARC)(arcs[i]<arcs[i+1]), "(1-4) arcs must be increasing by traversing matrix left to right from top row to bottom row") /\	
		
		assert(forall(i in NODE)(absent(adg.a[i,i])), "(2) arcs cannot be loops") /\
		
		assert(index_set_1of2(adg.tail_head) == ARC, "(3-1) tails/heads array must be indexed over the range of arcs") /\
		assert(array2set(col(adg.tail_head, TAIL)) subset NODE, "(3-2) tails column must be subset of nodes") /\
		assert(array2set(col(adg.tail_head, HEAD)) subset NODE, "(3-3) heads column must be subset of nodes") /\
		assert(forall(ij in ARC)(ij == deopt(adg.a[adg.tail_head[ij,TAIL], adg.tail_head[ij,HEAD]])), "(3-4) tails/heads array must be consistent with arc matrix") /\
		assert(forall(i,j in NODE, ij in ARC where occurs(adg.a[i,j]) /\ ij=deopt(adg.a[i,j]))(i == adg.tail_head[ij,TAIL] /\ j == adg.tail_head[ij,HEAD]), "(3-5) tails/heads array must cover arc matrix") /\
		
		assert(index_set_1of2(adg.in_out) == NODE, "(4-1) ins/outs array must be indexed over the range of nodes") /\
		assert(array_union(col(adg.in_out, IN)) subset ARC, "(4-2) union over ins column must be subset of arcs") /\
		assert(array_union(col(adg.in_out, OUT)) subset ARC, "(4-3) union over outs column must be subset of arcs") /\
		assert(forall(i in NODE, hi in adg.in_out[i,IN])(i == adg.tail_head[hi,HEAD]), "(4-4) ins array must be consistent with tails/heads array") /\
		assert(forall(i in NODE, ij in adg.in_out[i,OUT])(i == adg.tail_head[ij,TAIL]), "(4-5) outs array must be consistent with tails/heads array") /\
		assert(forall(ij in ARC, i,j in NODE where occurs(adg.a[i,j]) /\ ij=deopt(adg.a[i,j]))(ij in adg.in_out[i,OUT] /\ ij in adg.in_out[j,IN]), "(4-6) ins/outs array must cover arc matrix") /\

		assert(index_set_1of2(adg.pred_succ) == NODE, "(5-1) preds/succs array must be indexed over the range of nodes") /\
		assert(array_union(col(adg.pred_succ, PRED)) subset NODE, "(5-2) union over preds column must be subset of nodes") /\
		assert(array_union(col(adg.pred_succ, SUCC)) subset NODE, "(5-3) union over succs column must be subset of nodes") /\
		assert(forall(j in NODE, i in adg.pred_succ[j,PRED])(occurs(adg.a[i,j])), "(5-4) preds array must be consistent with arc matrix") /\
		assert(forall(i in NODE, j in adg.pred_succ[i,SUCC])(occurs(adg.a[i,j])), "(5-5) succs array must be consistent with arc matrix") /\
		assert(forall(i,j in NODE where occurs(adg.a[i,j]))(i in adg.pred_succ[j,PRED] /\ j in adg.pred_succ[i,SUCC]), "(5-6) preds/succs array must cover arc matrix") /\

		assert(adg.tails == array2set(col(adg.tail_head,TAIL)), "(6) tails must be consistent and complete wrt. arc matrix") /\
		assert(adg.heads == array2set(col(adg.tail_head,HEAD)), "(7) heads must be consistent and complete wrt. arc matrix") /\
		assert(adg.sources == adg.tails diff adg.heads, "(8) sources must be tails that are not heads") /\
		assert(adg.sinks == adg.heads diff adg.tails, "(9) sinks must be heads that are not tails") /\
		assert(adg.loners == NODE diff (adg.tails union adg.heads), "(10) loners must be nodes that are neither tails nor heads")
;
