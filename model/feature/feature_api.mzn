%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FEATURE API
%
%	- Defines
%		- ENUMERATIONS
%			- FTYPE_PATH_MINIMALITY
%
%	- Declares
%		- ENUMERATION CASES
%			- F_INFLUENCE_OPT_NULL
%			- F_PATH_MINIMALITY
%		- OUTPUT
%			- displayFeatureInfluenceNull
%			- displayFeaturePathMinimality



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA TYPES

% Path minimality cases
enum FTYPE_PATH_MINIMALITY = {F_PATH_MINIMALITY_ARC, F_PATH_MINIMALITY_NODE};

enum FTYPE_NB_PATH_COUNTING = {F_MINIZINC_COUNTING, F_PYTHON_COUNTING};

enum FTYPE_FIXED_NODE = {F_FIXED, F_UNFIXED};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA

% Opt debug influence feature
%	- if feature is true then debug assertions will be enabled
%	- otherwise (if the feature is not set or is set to false) no debug assertions will be enabled 
opt bool: F_DEBUG;

% % TODO
% % Graph acyclicity check if feature occurs
% opt bool: F_GRAPH_ACYCLICITY;

% Opt null influence feature
%	- if feature is true then the null element is set to <>
%	- otherwise (if the feature is not set or is set to false) the null element is the influence value specified as +-neutral and *-absorbing in the supplied influence type 
opt bool: F_INFLUENCE_NULL;

% Path minimality feature
%	- if feature is set then its value will dictate how minimal paths are computed:
%		- F_PATH_MINIMALITY_ARC: a path is minimal iff it does not traverse an arc more than once
%		- F_PATH_MINIMALITY_NODE: a path is minimal iff it does not traverse a node more than once
%	- otherwise (if the feature is not set) the default value is set to F_PATH_MINIMALITY_NODE
opt FTYPE_PATH_MINIMALITY: F_PATH_MINIMALITY;

% Number of paths for aggregation feature
%
opt FTYPE_NB_PATH_COUNTING: F_NB_PATH_COUNTING;

opt FTYPE_FIXED_NODE: F_FIXED_NODE;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

% TODO
% function array[int] of string: displayFeatureGraphCyclicity();

%
function array[int] of string: displayFeatureInfluenceNull();

%
function array[int] of string: displayFeaturePathMinimality();
