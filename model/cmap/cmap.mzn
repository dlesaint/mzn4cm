%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% C-MAP 
%
%	- Implements part of C-MAP API
%		- ASSERTIONS
%			- assertICmap
%			- assertCmap
%		- CASTING
%			- icmap2cmap
%			- cmap2icmap



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../cmap/cmap_api.mzn";
include "../graph/adigraph_digraph.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertICmap(I_CMAP: icmap)
	:: "function assertICmap($icmap): asserts consistency of instance c-map $icmap"
	=
	let {
		set of int: NODE_ID = index_set(icmap.node_labels);
	} in
		assert(set2array(NODE_ID) = [icmap.node_labels[i].node | i in NODE_ID], "(1) node label ids must be node label ranks") 
		%TODO/\ typecheck each influence
% 		assert(forall(i in index_set(icmap.arc_labels)) (icmap.itype, icmap.al[i].i)), "(2) arcs must be labeled consistently with influence type")
;

%
function bool: assertCmap(CMAP: cmap)
	:: "function assertCmap($cmap): asserts consistency of c-map $cmap"
	=
		assertDigraph(cmap.digraph) /\
		assertADigraph(cmap.adigraph) /\
		assertDigraphADigraph(cmap.digraph, cmap.adigraph) /\
		assert(set2array(index_set(cmap.node_labels)) = 1..cmap.digraph.nr_nodes, "(1-1) c-map and digraph node ranges must be equal") /\
		assert(set2array(index_set(cmap.arc_labels)) = 1..cmap.digraph.nr_arcs, "(1-2) c-map and digraph arc ranges must be equal") /\
		assert([cmap.arc_labels[ij].arc | ij in index_set(cmap.arc_labels)] == cmap.digraph.a, "(2-1) c-map and digraph arc maps must be equal") /\
		assertIType(cmap.itype) /\
		assert(index_set_1of2(cmap.influences) == index_set_1of2(cmap.adigraph.a) /\ index_set_2of2(cmap.influences) == index_set_2of2(cmap.adigraph.a), "(3-1) c-map influence and a-digraph arc matrices must have consistent index sets") /\
		assert(isOptType(cmap.itype) -> forall(i in index_set_1of2(cmap.influences), j in index_set_2of2(cmap.influences))(isNullInfluence(cmap.influences[i,j]) <-> absent(cmap.adigraph.a[i,j])), "(3-2) c-map influence and a-digraph arc matrices must have consistent null/absent submatrices")
	;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CASTING

% 
function INFLUENCE: buildInfluence(ITYPE: it, array[int] of ARC_LABEL: arc_labels, opt int: arc)
	=
	if	absent(arc)
	then		getNullInfluence(it)
	else		arc_labels[deopt(arc)].influence
	endif
	;
	
%
function CMAP: icmap2cmap(I_CMAP: icmap)
	:: "function icmap2cmap($icmap): casts instance c-map $icmap to c-map"
	=
	let {
		set of int: NODE_ID = index_set(icmap.node_labels);
		set of int: ARC_ID = index_set(icmap.arc_labels);	
		
		array[int] of ARC: arcs = [(t:icmap.arc_labels[ij].arc.t, h:icmap.arc_labels[ij].arc.h) | ij in ARC_ID];
		
		DIGRAPH: digraph = (name:icmap.name, nr_nodes:card(NODE_ID), nr_arcs:card(ARC_ID), a:arcs);
		%bool: b = assert(max(ARC_ID)==3,show(digraph));	
		ADIGRAPH: adigraph = digraph2adigraph(digraph);
		ITYPE: itype = icmap.itype;
		array[int, int] of INFLUENCE: influences = array2d(NODE_ID, NODE_ID, [ buildInfluence(itype, icmap.arc_labels, adigraph.a[i,j]) | i,j in NODE_ID]);
		
	} in
	(name:icmap.name, digraph:digraph, adigraph:adigraph, itype:itype, node_labels:icmap.node_labels, arc_labels:icmap.arc_labels, influences:influences) 
	;

function CMAP: icmap2cmap2(DATASET: dataset)
	:: "function icmap2cmap($icmap): casts instance c-map $icmap to c-map"
	=
	let {	
		set of int: N_CMAP = index_set(dataset.icmaps);
		set of int: NODE_ID = index_set(dataset.icmaps[arg_max([card(index_set(dataset.icmaps[i].node_labels)) | i in N_CMAP])].node_labels);
		set of int: ARC_ID = index_set(dataset.icmaps[arg_max([card(index_set(dataset.icmaps[i].arc_labels)) | i in N_CMAP])].arc_labels);

		array[int] of ARC: arcs = [(t:icmap.arc_labels[ij].arc.t, h:icmap.arc_labels[ij].arc.h) | ij in ARC_ID];		
		DIGRAPH: digraph = (name:icmap.name, nr_nodes:card(NODE_ID), nr_arcs:card(ARC_ID), a:arcs);		
		ADIGRAPH: adigraph = digraph2adigraph(digraph);
		ITYPE: itype = icmap.itype;
		array[int, int] of INFLUENCE: influences = array2d(NODE_ID, NODE_ID, [ buildInfluence(itype, icmap.arc_labels, adigraph.a[i,j]) | i,j in NODE_ID]);
		
	} in
	(name:icmap.name, digraph:digraph, adigraph:adigraph, itype:itype, node_labels:icmap.node_labels, arc_labels:icmap.arc_labels, influences:influences) 
	;
%
function I_CMAP: cmap2icmap(CMAP: cmap)
	:: "function cmap2icmap($cmap): casts c-map $cmap to instance c-map"
	=
	(name:cmap.name, itype:cmap.itype, node_labels:cmap.node_labels, arc_labels:cmap.arc_labels) 
	;
