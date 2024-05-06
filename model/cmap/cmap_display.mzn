%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% C-MAP OUTPUT
%
%	- Implements part of C-MAP API
%		- OUTPUT
%			- displayCmapHeader
%			- displayCmapArcInfluences



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../cmap/cmap_api.mzn";

include "./../graph/digraph/digraph_display.mzn";
include "./../graph/adigraph/adigraph_display.mzn";
include "./../algebra/algebra_display.mzn";
include "./../itype/itype_display.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayCmapHeader(CMAP: cmap) =
		["****** C-MAP ***********"]
	++	["\n"]	
	++	["Name" ++ "\t" ++ show(cmap.name)]
	++	["\n"]
	;

%
function array[int] of string: displayCmapArcInfluences(CMAP: cmap) =
	let {
		array[int] of string: rows = [cmap.node_labels[i].concept.name | i in index_set_1of2(cmap.influences)];
		array[int] of string: cols = [cmap.node_labels[j].concept.name | j in index_set_2of2(cmap.influences)];
		%TODO get proper null element symbol from algebra
		array[int, int] of string: names = array2d(index_set(rows), index_set(cols), [showInfluence(cmap.influences[i,j]) | i in index_set(rows), j in index_set(cols)]);
%		array[int, int] of string: names = array2d(index_set(rows), index_set(cols), [if isNullElement((algebra:cmap.itype.algebra, value:cmap.i[i,j,SUBDOMAIN_ID])) then "<>" else showInfluence([deopt(cmap.i[i,j])]) endif | i in index_set(rows), j in index_set(cols)]);
% 		array[int, int] of string: names = array2d(index_set(rows), index_set(cols), [if isNullElement(A_ELEMENTcmap.i[i,j]) then "<>" else showInfluence([deopt(cmap.i[i,j])]) endif | i in index_set(rows), j in index_set(cols)]);
	} in
		["Influence matrix"]
	++	["\n"]
	++	[show2d_indexed(rows, cols, names)]
	++	["\n"]
	;

%
function array[int] of string: displayCmap(CMAP: cmap) =
% 		displayDigraphHeader(cmap.digraph)
% 	++	displayDigraphArcs(cmap.digraph)
		displayADigraphHeader(cmap.adigraph)
	++	displayADigraphArcs(cmap.adigraph)
% 	++	displayADigraphTailsHeads(cmap.adigraph)
% 	++	displayADigraphInsOuts(cmap.adigraph)
% 	++	displayADigraphPredsSuccs(cmap.adigraph)
% 	++	displayADigraphNodes(cmap.adigraph)
	++	displayITypeHeader(cmap.itype)
	++	displayITypeSignature(cmap.itype)
% 	++	displayITypeDomains(cmap.itype)
	++	displayITypeBlockType(cmap.itype)
% 	++	displayITypeAlgebra(cmap.itype)
	++	displayITypeAggregationOperation(cmap.itype)
	++	displayITypePropagationOperation(cmap.itype)
	++	displayAlgrebraHeader(getAlgebra(cmap.itype))
% 	++	displayAlgebraProperties(getAlgebra(cmap.itype))
	++	displayAlgebraElements(getAlgebra(cmap.itype))
	++	displayCmapHeader(cmap)
	++	displayCmapArcInfluences(cmap)
	;