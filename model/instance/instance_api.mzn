%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INSTANCE API
%
%	- Defines
%		- CLASSES
%			- DATASET
%			- INSTANCE
%		- OBJECTS
%			- dataset
%			- instance
%
%	- Declares
%		- OBJECTS
%			- icmap
%		- ASSERTIONS
%			- assertDataset
%			- assertInstance
%		- OUTPUT
%			- displayInstance
%			- displayCmaps
%
%	- Uses INFLUENCE API
%		- CLASSES
%			- E_INFLUENCE_TYPE
%
%	- Uses CMAP API
%		- CLASSES
%			- I_CMAP
%			- CMAP



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../itype/itype_api.mzn";
include "./../itype/itype.mzn";

include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES

% Class for datasets
%	- a dataset is defined for a given extended influence type
%	- a dataset includes one or more input c-maps, all of which are defined over the extended influence type
type DATASET = record(
	% the extended influence type
	ITYPE: itype,
	% the input c-maps defined over the extended influence type
	array[int] of I_CMAP: icmaps
	);

% Class for problem instances
%	- a problem instance includes a single dataset
%	- it also includes the c-maps constructed from the input c-maps of the dataset
type INSTANCE = record(
	% the dataset
	DATASET: dataset,	
	% the c-maps
	array[int] of CMAP: cmaps
	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA

% Input cmap
% !! right now, only a single cmap per instance is supported !!
array[int] of I_CMAP: icmaps;

% % Input cmaps to pick from catalog (icmap_catalog.mzn)
% % !! for future versions allowing mutliple cmaps !!
% array[int] of I_CMAP: icmaps;

% Dataset of problem instance
DATASET: dataset = (
	% declared in itype_api.mzn, defined from instance data
	itype: itype,
	% declared above, defined from instance data
	icmaps: icmaps,
	);

% Problem instance
INSTANCE: instance = (
	% declared and defined above
	dataset: dataset,
	% defined from dataset
	cmaps: [icmap2cmap(dataset.icmaps[i]) | i in index_set(dataset.icmaps)],
	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

% Checks consistency of dataset
function bool: assertDataset(DATASET: ds)
	:: "function assertDataset($ds): asserts consistency of dataset $ds";

% Checks consistency of problem instance data
function bool: assertInstance(INSTANCE: pi)
	:: "function assertInstance($pi): asserts consistency of problem instance $pi";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayInstance(INSTANCE: pi);

%
function array[int] of string: displayCmaps(array[int] of CMAP: cmaps);