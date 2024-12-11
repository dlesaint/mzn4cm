%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DIGRAPH
%
%	- Implements part of DIGRAPH API
%		- ASSERTIONS
%			- assertDigraph



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../digraph/digraph_api.mzn";
include "../../ranges/ranges.mzn"; % for assertions
include "lex_chain_less.mzn"; % for assertions



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertDigraph(DIGRAPH: dg)
	:: "function assertDigraph($dg): asserts consistency of digraph $dg"
	=
	assert(isProperRange(1..dg.nr_nodes), "(1) nodes of digraph $dg must form a proper range of ints") /\
	assert(isProperRange(1..dg.nr_arcs), "(2) arc ids of digraph $dg must form a proper range of ints") /\
	assert(1..dg.nr_arcs == index_set(dg.a), "(3) every arc of digraph $dg must be identified by its index in the array of arcs") /\
	assert(array2set(_mapToNodes(dg.a, _FIELD_ARC_TAIL)) subset 1..dg.nr_nodes, "(4-1) every arc tail must be a node of digraph $dg") /\
	assert(array2set(_mapToNodes(dg.a, _FIELD_ARC_HEAD)) subset 1..dg.nr_nodes, "(4-2) every arc head must be a node of digraph $dg") /\
	%assert(forall(ij in 1..dg.nr_arcs)(dg.a[ij].t != dg.a[ij].h), "(5-1) arcs cannot be loops") /\

	assert(forall(ij,kl in 1..dg.nr_arcs where ij<kl)(dg.a[ij].t != dg.a[kl].t \/ dg.a[ij].h != dg.a[kl].h \/ (absent(dg.a[ij].t) /\ absent(dg.a[ij].t))), "(5-2) duplicate arcs are forbidden")
% 	TODO 
% 	/\
% 	% (6) entails (5-2)
% 	assert(fix(lex_chain_less(_mapToNodes(dg.a))), "(6) array [TAIL_HEAD,1..$dg.nr_arcs] of arc nodes must be lex-sorted strictly increasing")	
;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE DATA TYPES

% Enumeration for arc node descriptor
enum _FIELD_ARC = {_FIELD_ARC_TAIL, _FIELD_ARC_HEAD};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE

%
function array[$$I] of opt int: _mapToNodes(array[$$I] of ARC: arcs, _FIELD_ARC: f)
	:: "function _mapToNodes($arcs, $f): key-preserving map of array[$$I] of arcs $arcs to array[$$I] of their tail or head nodes based on field $f"
	=
	if			f==_FIELD_ARC_TAIL
	then 	array1d(index_set(arcs), [arcs[i].t | i in index_set(arcs)])
	elseif	f==_FIELD_ARC_HEAD
	then 	array1d(index_set(arcs), [arcs[i].h | i in index_set(arcs)])
	else		assert(false, "bug", [])
	endif
	;

% 
function array[1..2, $$I] of opt int: _mapToNodes(array[$$I] of ARC: arcs)
	:: "function _mapToNodes($arcs): key-preserving map of array[$$I] of arcs $arcs to array[TAIL_HEAD, index_set($arcs)] of their tail and head nodes"
	=
	array2d(1..2, index_set(arcs), _mapToNodes(arcs, _FIELD_ARC_TAIL) ++ _mapToNodes(arcs, _FIELD_ARC_HEAD))
	;

% %
% function array[$$J] of int: mapSliceToNodes(array[$$I] of int: arcs, _FIELD_ARC: f, array[$$J] of int: keys)
% 	:: "function mapSliceToNodes($arcs, $f, $keys): slices and maps array of arcs of digraph $dg to array of their tail or head nodes of arcs based on field $f and slicing array $keys"
% 	=
% 	let {
% 		array[int] of int: nodes = _mapToNodes(arcs, f);
% 	} in
% 	if			f==_FIELD_ARC_TAIL \/ _FIELD_ARC_HEAD
% 	then 	array1d(index_set(keys), [nodes[arcs[i]] | i in index_set(keys)])
% 	else		assert(false, "bug", [])
% 	endif
% 	;

% % 
% function array[int] of var int: mapArcs(DIGRAPH: dg, _FIELD_ARC: f, array[int] of var int: x)
% 	:: "function mapArcToNodes($dg, $f, $arcs): maps array of arcs of digraph $dg to array of tail or head nodes based on field $f"
% 	=
% 	let {
% 		array[int] of int: nodes = mapArcsToNodes(dg, f);
% 	} in
% 	if			f==_FIELD_ARC_TAIL \/ _FIELD_ARC_HEAD
% 	then 	array1d(index_set(arc_ids), [nodes[arcs[i]] | i in index_set(arcs)])
% 	else		assert(false, "bug", [])
% 	if f=_FIELD_ARC_TAIL
% 	then array1d(index_set(x), [arcs[x[i]].t | i in index_set(x)])
% 	elseif f=_FIELD_ARC_HEAD
% 	then array1d(index_set(x), [arcs[x[i]].h | i in index_set(x)])
% 	elseif f=_FIELD_ARC_INFLUENCE
% 	then array1d(index_set(x), [arcs[x[i]].i | i in index_set(x)])
% 	else x
% 	endif
% 	;

% % 
% function array[int] of opt int: mapArcs(_FIELD_ARC: f, array[int] of opt ARC_ID: x) =
% 	if f=_FIELD_ARC_TAIL
% 	then array1d(index_set(x), [if occurs(x[i]) then arcs[deopt(x[i])].t else <> endif | i in index_set(x)])
% 	elseif f=_FIELD_ARC_HEAD
% 	then array1d(index_set(x), [if occurs(x[i]) then arcs[deopt(x[i])].h else <> endif | i in index_set(x)])
% 	elseif f=_FIELD_ARC_INFLUENCE
% 	then array1d(index_set(x), [if occurs(x[i]) then arcs[deopt(x[i])].i else <> endif | i in index_set(x)])
% 	else x
% 	endif
% 	;

% % 
% function array[int] of var opt int: mapArcs(_FIELD_ARC: f, array[int] of var opt ARC_ID: x) =
% 	if f=_FIELD_ARC_TAIL
% 	then array1d(index_set(x), [if occurs(x[i]) then arcs[deopt(x[i])].t else <> endif | i in index_set(x)])
% 	elseif f=_FIELD_ARC_HEAD
% 	then array1d(index_set(x), [if occurs(x[i]) then arcs[deopt(x[i])].h else <> endif | i in index_set(x)])
% 	elseif f=_FIELD_ARC_INFLUENCE
% 	then array1d(index_set(x), [if occurs(x[i]) then arcs[deopt(x[i])].i else <> endif | i in index_set(x)])
% 	else x
% 	endif
% 	;
