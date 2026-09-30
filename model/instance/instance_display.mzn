%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INSTANCE OUTPUT
%
% - Implements part of INSTANCE API
%		- OUTPUT
%			- displayInstance
%
%	- Uses CMAP API
%		- OUTPUT
%			- displayCmap



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "./../instance/instance_api.mzn";

include "./../cmap/cmap_api.mzn";
include "./../cmap/cmap_display.mzn";



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function array[int] of string: displayInstance(INSTANCE: pi) =
		["****** INSTANCE ***********"]
	++	["\n"]
	++	displayCmap(pi.cmap)
	;
