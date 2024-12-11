%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% C-MAP API
%
%	- Defines
%		- CLASSES
%			- CONCEPT
%			- NODE_LABEL
%			- ARC_LABEL
%			- I_CMAP
%			- CMAP
%
%	- Declares
%		- ASSERTIONS
%			- assertICmap
%			- assertCmap
%		- CASTING
%			- icmap2cmap
%			- cmap2icmap
%		- OUTPUT
%			- displayCmapHeader
%			- displayCmapArcInfluences
%			- displayCmap



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../graph/adigraph/adigraph_api.mzn";
include "./../graph/digraph/digraph_api.mzn";
include "./../itype/itype_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES

% Class for concepts
type CONCEPT = record(
	string: name
	);

% Class for node labels
type NODE_LABEL = record(
	% node
	int: node,
	% concept
	CONCEPT: concept
	);

% Class for arc labels
type ARC_LABEL = record(
	% arc
	ARC: arc,
	% i-block
	INFLUENCE: influence
	);

% Class for input c-maps
type I_CMAP = record(
	% name
	string: name,
	% i-type
	ITYPE: itype,
	% node labels
	array[int] of NODE_LABEL: node_labels,
	% arc labels
	array[int] of ARC_LABEL: arc_labels
 	);

% Class for c-maps
type CMAP = record(
	% name
	string: name,
	% input digraph
	DIGRAPH: digraph,
	% a-digraph
	ADIGRAPH: adigraph,
	% i-type
	ITYPE: itype,
	% node labels
	array[int] of opt NODE_LABEL: node_labels,
	% arc labels
	array[int] of opt ARC_LABEL: arc_labels,
	% influence matrix
	array[int, int] of opt INFLUENCE: influences
 	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTION

%
function bool: assertICmap(I_CMAP: icmap) :: "function assertICmap($icmap): asserts consistency of input c-map $icmap";

%
function bool: assertCmap(CMAP: cmap) :: "function assertCmap($cmap): asserts consistency of c-map $cmap";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CASTING

%
function CMAP: icmap2cmap(I_CMAP: icmap) :: "function icmap2cmap($icmap): casts input c-map $icmap to c-map";

%
function I_CMAP: cmap2icmap(CMAP: cmap) :: "function cmap2icmap($cmap): casts c-map $cmap to input c-map";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayCmapHeader(CMAP: cmap);

%
function array[int] of string: displayCmapArcInfluences(CMAP: cmap);

%
function array[int] of string: displayCmap(CMAP: cmap);