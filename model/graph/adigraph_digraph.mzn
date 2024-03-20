%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CAST FUNCTIONS FOR DIGRAPHS AND A-DIGRAPHS
%
%	Defines
%		- ASSERTIONS
%			- assertDigraphADigraph
%		- CASTING
%			- digraph2adigraph
%			- adigraph2digraph



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../graph/adigraph/adigraph_api.mzn";
include "../graph/digraph/digraph_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertDigraphADigraph(DIGRAPH: dg, ADIGRAPH: adg)
	:: "function assertDigraphADigraph($dg, $adg): asserts consistency between digraph $dg and a-digraph $adg"
	=
	let {
		ADIGRAPH: adg1 = digraph2adigraph(dg);
	} in
		assert(true /\ adg.name == adg1.name, "names must be consistent") /\ %TODO enforce?
		assert(adg.a == adg1.a, "optional arc-valued adjacency matrices must be consistent") /\
		assert(adg.tail_head == adg1.tail_head, "tail/head nodes arrays must be consistent") /\
		assert(adg.in_out == adg1.in_out, "Incoming/outgoing arcs arrays must be consistent") /\
		assert(adg.pred_succ == adg1.pred_succ, "Predecessors/successors arrays must be consistent") /\
		assert(adg.tails == adg1.tails, "Tail nodes sets must be consistent") /\
		assert(adg.heads == adg1.heads, "Head nodes sets must be consistent") /\
		assert(adg.sources == adg1.sources, "Source nodes sets must be consistent") /\
		assert(adg.sinks == adg1.sinks, "Sink nodes sets must be consistent") /\
		assert(adg.loners == adg1.loners, "Disconnected nodes sets must be consistent")
	;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CASTING

% Casts digraph to a-digraph
function ADIGRAPH: digraph2adigraph(DIGRAPH: dg)
	:: "function digraph2adigraph($dg): casts digraph $dg to a-digraph"
	=
	let {
		string: name = "a" ++ dg.name;
		set of int: NODE_ID = 1..dg.nr_nodes;
		set of int: ARC_ID = 1..dg.nr_arcs;
		array[ARC_ID, TAIL_HEAD] of NODE_ID: tail_head = array2d(ARC_ID, TAIL_HEAD, [k | ij in ARC_ID, th in TAIL_HEAD, k in NODE_ID where (k==dg.a[ij].t /\ th==TAIL) \/ (k==dg.a[ij].h /\ th==HEAD)]);
		array[NODE_ID, IN_OUT] of set of ARC_ID: out_in = array2d(NODE_ID, IN_OUT, [{ij | ij in ARC_ID where i==tail_head[ij,th]} | i in NODE_ID, th in TAIL_HEAD]);
		array[NODE_ID, IN_OUT] of set of ARC_ID: in_out = array2d(NODE_ID, IN_OUT, [out_in[i, to_enum(IN_OUT, 2 - (j + 1) mod 2)] | i in NODE_ID, j in IN_OUT]);
		array[NODE_ID, PRED_SUCC] of set of NODE_ID: pred_succ = array2d(NODE_ID, PRED_SUCC, [{j | j in NODE_ID where (io==IN /\ j in {k | k in NODE_ID, ki in in_out[i,io] where k==dg.a[ki].t}) \/ (io==OUT /\ j in {k | k in NODE_ID, ik in in_out[i,io] where k==dg.a[ik].h})} | i in NODE_ID, io in IN_OUT]);
		set of NODE_ID: tails = {i | i in NODE_ID where in_out[i,OUT]!={}};
		set of NODE_ID: heads = {i | i in NODE_ID where in_out[i,IN]!={}};
		set of NODE_ID: sources = tails diff heads;
		set of NODE_ID: sinks = heads diff tails;
		set of NODE_ID: loners = NODE_ID diff (tails union heads);
		array[NODE_ID, NODE_ID] of opt ARC_ID: arcs = array2d(NODE_ID, NODE_ID, [if(j in pred_succ[i,SUCC]) then min({ij | ij in in_out[i,OUT] where dg.a[ij].h==j}) else <> endif | i,j in NODE_ID]);
	} in
		(name:name, a:arcs, tail_head:tail_head, in_out:in_out, pred_succ:pred_succ, tails:tails, heads:heads, sources:sources, sinks:sinks, loners:loners)
	;

% Casts a-digraph to digraph
function DIGRAPH: adigraph2digraph(ADIGRAPH: adg)
	:: "function adigraph2digraph($dg): casts a-digraph $dg to digraph"
	=
	let {
		string: name = "un_" ++ adg.name;
		set of int: NODE_ID = index_set_1of2(adg.a);
		array[int] of opt int: o_arcs = [adg.a[i,j] | i in index_set_1of2(adg.a), j in index_set_2of2(adg.a)];
		array[int] of int: t_arcs = deopt([o_arcs[i] | i in index_set(o_arcs) where occurs(o_arcs[i])]);
		set of int: ARC_ID = array2set(t_arcs);
		array[int] of ARC: arcs = [(t:adg.tail_head[ij, TAIL], h:adg.tail_head[ij, HEAD]) | ij in ARC_ID];
	} in
		(name:name, nr_nodes:card(NODE_ID), nr_arcs:card(ARC_ID), a:arcs)
	;
