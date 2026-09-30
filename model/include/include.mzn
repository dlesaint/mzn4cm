%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CORE INCLUSION FILE



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

%% GRAPH
% Digraph
include "./../graph/digraph/digraph_api.mzn";
include "./../graph/digraph/digraph.mzn";
include "./../graph/digraph/digraph_display.mzn";
% Adigraph
include "./../graph/adigraph/adigraph_api.mzn";
include "./../graph/adigraph/adigraph.mzn";
include "./../graph/adigraph/adigraph_display.mzn";
% Graph
include "./../graph/adigraph_digraph.mzn";


%% ALGEBRA
% Algebra
include "./../algebra/algebra_api.mzn";
include "./../algebra/algebra.mzn";
include "./../algebra/algebra_display.mzn";
include "./../algebra/algebra_imp_api.mzn";


%% INFLUENCE TYPE
% TODO
include "./../itype/itype_api.mzn";
include "./../itype/itype.mzn";
include "./../itype/itype_display.mzn";
include "./../itype/itype_imp_api.mzn";


%% CMAPS
include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap.mzn";
include "./../cmap/cmap_display.mzn";


%% INSTANCE
include "./../instance/instance_api.mzn";
include "./../instance/instance.mzn";
include "./../instance/instance_display.mzn";

%% CMQL
% include "./model/model.mzn";
% include "./cmql/cmql.mzn";
include "./../display/visualisation.mzn"; %TODO

%% QUERY

%% FEATURES
% Feature
include "./../feature/feature_api.mzn";
include "./../feature/feature.mzn";
include "./../feature/feature_display.mzn";
