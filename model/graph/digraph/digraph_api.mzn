%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DIGRAPH API
%
%	- Defines
%		- CLASSES
%			- ARC
%			- DIGRAPH
%
%	- Declares
%		- ASSERTIONS
%			- assertDigraph
%		- OUTPUT
%			- displayDigraphHeader
%			- displayDigraphArcs


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES

% Class for arcs
type ARC = record(
	% tail node
	opt int: t,
	% head node
	opt int: h
	);

% Class for digraphs
type DIGRAPH = record(
	string: name,
	% number of nodes (nodes identified over 1..nr_nodes)
	int: nr_nodes,
	% number of arcs (arcs identified over 1..nr_arcs)
	int: nr_arcs,
	% map of arc ids to arcs
	array[int] of ARC: a
	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertDigraph(DIGRAPH: dg) :: "function assertDigraph($dg): asserts consistency of digraph $dg";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayDigraphHeader(DIGRAPH: dg);

%
function array[int] of string: displayDigraphArcs(DIGRAPH: dg);
