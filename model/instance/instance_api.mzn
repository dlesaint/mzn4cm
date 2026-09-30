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
%	- a dataset includes a single input c-map defined over the extended influence type
type DATASET = record(
	% the extended influence type
	ITYPE: itype,
	% the input c-map defined over the extended influence type
	I_CMAP: icmap
	);

% Class for problem instances
%	- a problem instance includes a single dataset
%	- it also includes the c-map constructed from the input c-map of the dataset
type INSTANCE = record(
	% the dataset
	DATASET: dataset,
	% the c-map
	CMAP: cmap
	);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA

% Input cmap
I_CMAP: icmap;

% Dataset of problem instance
DATASET: dataset = (
	% declared in itype_api.mzn, defined from instance data
	itype: itype,
	% declared above, defined from instance data
	icmap: icmap,
	);

% Problem instance
INSTANCE: instance = (
	% declared and defined above
	dataset: dataset,
	% defined from dataset
	cmap: icmap2cmap(dataset.icmap),
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