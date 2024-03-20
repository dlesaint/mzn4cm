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
	assert(forall(i in min(index_set(ds.icmaps))..<max(index_set(ds.icmaps))) (ds.icmaps[i] == ds.icmaps[i+1]), "(1) dataset input cmaps must share the same i-type") /\
	assert(forall(i in index_set(ds.icmaps))(assertIType(ds.icmaps[i].itype)), "(2) dataset i-types must be consistent") /\
	assert(forall(i in index_set(ds.icmaps))(assertICmap(ds.icmaps[i])), "(3) dataset input cmaps must be consistent")
	;

% Checks consistency of problem instance data
function bool: assertInstance(INSTANCE: pi)
	:: "function assertInstance($pi): asserts consistency of problem instance $pi"
	=
	assert(assertDataset(pi.dataset), "(1) instance dataset must be consistent") /\
	assert(forall(i in index_set(pi.cmaps)) (assertCmap(pi.cmaps[i])), "(2) instance cmaps must be consistent")
	;
