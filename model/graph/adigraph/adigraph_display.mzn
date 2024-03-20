%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A-DIGRAPH OUTPUT
%
%	- Implements part of A-DIGRAPH API
%		- OUTPUT
%			- displayADigraphHeader
%			- displayADigraphArcs
%			- displayADigraphTailsHeads
%			- displayADigraphInsOuts
%			- displayADigraphPredsSuccs
%			- displayADigraphNodes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../adigraph/adigraph_api.mzn";
include "../../utils/utils_string.mzn"; % for map2string



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayADigraphHeader(ADIGRAPH: adg) =
		["****** A-DIGRAPH ***********"]
	++	["\n"]
	++	["Name" ++ "\t" ++ show(adg.name)]
	++	["\n"]
	;

%
function array[int] of string: displayADigraphArcs(ADIGRAPH: adg) =
	let {
		array[int] of string: rows = map2string(index_set_1of2(adg.a));
		array[int] of string: cols = map2string(index_set_2of2(adg.a));
		array[int, int] of string: names = map2string(adg.a);
	} in
		["Arc-valued adjacency matrix"]
	++	["\n"]
% 	++	[show2d(adg.a)]
	++	[show2d_indexed(rows, cols, names)]
	++	["\n"]
	;

%
function array[int] of string: displayADigraphTailsHeads(ADIGRAPH: adg) =
	let {
		array[int] of string: rows = map2string(index_set_1of2(adg.tail_head));
		array[int] of string: cols = map2string(set2array(index_set_2of2(adg.tail_head)));
		array[int, int] of string: names = map2string(adg.tail_head);
	} in
		["Tail / head nodes"]
	++	["\n"]
	++	[show2d_indexed(rows, cols, names)]
	++	["\n"]
	;

%
function array[int] of string: displayADigraphInsOuts(ADIGRAPH: adg) =
	let {
		array[int] of string: rows = map2string(index_set_1of2(adg.in_out));
		array[int] of string: cols = map2string(set2array(index_set_2of2(adg.in_out)));
		array[int, int] of string: names = map2string(adg.in_out);
	} in
		["Incoming / outgoing arcs"]
	++	["\n"]
	++	[show2d_indexed(rows, cols, names)]
	++	["\n"]
	;

%
function array[int] of string: displayADigraphPredsSuccs(ADIGRAPH: adg) =
	let {
		array[int] of string: rows = map2string(index_set_1of2(adg.pred_succ));
		array[int] of string: cols = map2string(set2array(index_set_2of2(adg.pred_succ)));
		array[int, int] of string: names = map2string(adg.pred_succ);
	} in
		["Predecessor / successor nodes"]
	++	["\n"]
	++	[show2d_indexed(rows, cols, names)]
	++	["\n"]
	;

%
function array[int] of string: displayADigraphNodes(ADIGRAPH: adg) =
		["Tail nodes"]
	++	["="]
	++[show(adg.tails)]
	++["\n"]
	++["Head nodes"]
	++["="]
	++[show(adg.heads)]
	++["\n"]
	++["Source nodes"]
	++["="]
	++[show(adg.sources)]
	++["\n"]
	++["Sink nodes"]
	++["="]
	++[show(adg.sinks)]
	++["\n"]
	++["Disconnected nodes"]
	++["="]
	++[show(adg.loners)]
	++["\n"]
	;