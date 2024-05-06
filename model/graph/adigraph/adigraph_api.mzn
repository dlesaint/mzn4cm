%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ADJACENCY-ENCODED DIGRAPH (A-DIGRAPH) API
%
%	- Defines
%		- ENUMS
%			- TAIL_HEAD
%			- IN_OUT
%			- PRED_SUCC
%		- CLASSES
%			- ADIGRAPH
%
%	- Declares
%		- ASSERTIONS
%			- assertADigraph
%		- PATH COUNTING
%		- transform_matrix
%		- nr_paths
%		- sum_recursive
%		- matrix_multiply
%		- OUTPUT
%			- displayADigraphHeader
%			- displayADigraphArcs
%			- displayADigraphTailsHeads
%			- displayADigraphInsOuts
%			- displayADigraphPredsSuccs
%			- displayADigraphNodes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES

% Enumeration classifying arc nodes as tails or heads
enum TAIL_HEAD = {TAIL, HEAD};

% Enumeration classifying arcs incident to nodes as incoming or outgoing
enum IN_OUT = {IN, OUT};

% Enumeration classifying neighboring nodes as predecessors or successors
enum PRED_SUCC = {PRED, SUCC};

% Class for a-digraphs
type ADIGRAPH = record(
	string: name,
	% Optional arc-valued adjacency matrix
	array[int, int] of opt int: a,
	% Tail/head nodes array
	array[int, TAIL_HEAD] of int: tail_head,
	% Incoming/outgoing arcs array
	array[int, IN_OUT] of set of int: in_out,
	% Predecessors/successors array
	array[int, PRED_SUCC] of set of int: pred_succ,
	% Tail nodes set
	set of int: tails,
	% Head nodes set
	set of int: heads,
	% Source nodes set
	set of int: sources,
	% Sink nodes set
	set of int: sinks,
	% Disconnected nodes set
	set of int: loners,
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertADigraph(ADIGRAPH: adg) :: "function assertADigraph($adg): asserts consistency of a-digraph $adg";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayADigraphHeader(ADIGRAPH: adg);

%
function array[int] of string: displayADigraphArcs(ADIGRAPH: adg);

%
function array[int] of string: displayADigraphTailsHeads(ADIGRAPH: adg);

%
function array[int] of string: displayADigraphInsOuts(ADIGRAPH: adg);

%
function array[int] of string: displayADigraphPredsSuccs(ADIGRAPH: adg);

%
function array[int] of string: displayADigraphNodes(ADIGRAPH: adg);