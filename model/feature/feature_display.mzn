%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FEATURE OUTPUT
%
%	- Implements FEATURE API
%		- OUTPUT
%			- displayFeatureInfluenceNull
%			- displayFeaturePathMinimality



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../feature/feature_api.mzn";
include "../feature/feature.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
% function array[int] of string: displayFeatureGraphCyclicity() =
% 		["****** FEATURE: GRAPH CYCLICITY ***********"]
% 	++	["\n"]
% 	++	[show(F_GRAPH_CYCLICITY)]
% 	++	["\n"];

%
function array[int] of string: displayFeatureInfluenceNull() =
		["****** FEATURE: ENABLE OPT NULL INFLUENCE ELEMENT ***********"]
	++	["\n"]
	++	[show(DEOPT_F_INFLUENCE_NULL)]
	++	["\n"];

%
function array[int] of string: displayFeaturePathMinimality() =
		["****** FEATURE: VARIANT OF PATH MINIMALITY ***********"]
	++	["\n"]
	++	[show(DEOPT_F_PATH_MINIMALITY)]
	++	["\n"]
	;
