%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FEATURE



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../feature/feature_api.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA

% De-opt debug feature
bool: DEOPT_F_DEBUG = F_DEBUG default false;

% De-opt null influence feature
bool: DEOPT_F_INFLUENCE_NULL = F_INFLUENCE_NULL default false;

% De-opt path minimality feature
FTYPE_PATH_MINIMALITY: DEOPT_F_PATH_MINIMALITY = F_PATH_MINIMALITY default F_PATH_MINIMALITY_NODE;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSERTIONS

% % disabled check - include "dag.mzn"; % for checking map acyclicity (predicate is not reified so no assertion possible)
% % "the graph (index_set($ns),from++to) must be a DAG");
% % constraint dag(array1d(ARC_ID, tail_head[ARC_ID, TAIL]), array1d(ARC_ID, tail_head[ARC_ID, HEAD]), [true | i in CONCEPT_ID], [true | ij in ARC_ID]); % "no cyclic map allowed");
