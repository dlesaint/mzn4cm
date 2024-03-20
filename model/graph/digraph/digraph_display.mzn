%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DIGRAPH OUTPUT
%
%	- Implements part of DIGRAPH API
%		- OUTPUT
%			- displayDigraphHeader
%			- displayDigraphArcs



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../digraph/digraph_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

function array[int] of string: displayDigraphHeader(DIGRAPH: dg) =
		["****** DIGRAPH ***********"]
	++	["\n"]
	++	["Name" ++ "\t" ++ show(dg.name)]
	++	["\n"]
	;

function array[int] of string: displayDigraphArcs(DIGRAPH: dg) =
		["Arcs"]
	++	["\n"]
	++	[show(dg.a)] %TODO custom display?
	++	["\n"]
	;
