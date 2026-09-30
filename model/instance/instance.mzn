%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INSTANCE
%
%	- Implements INSTANCE API except output functions
%		- ASSERTIONS
%			- assertDataset
%			- assertInstance
%
%	- Uses CMAP API
%		- ASSERTIONS
%			- assertICmap
%			- assertCmap



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../instance/instance_api.mzn";

include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

% Checks consistency of dataset
function bool: assertDataset(DATASET: ds)
	:: "function assertDataset($ds): asserts consistency of dataset $ds"
	=
	assert(assertIType(ds.icmap.itype), "(1) dataset i-type must be consistent") /\
	assert(assertICmap(ds.icmap), "(2) dataset input cmap must be consistent")
	;

% Checks consistency of problem instance data
function bool: assertInstance(INSTANCE: pi)
	:: "function assertInstance($pi): asserts consistency of problem instance $pi"
	=
	assert(assertDataset(pi.dataset), "(1) instance dataset must be consistent") /\
	assert(assertCmap(pi.cmap), "(2) instance cmap must be consistent")
	;
