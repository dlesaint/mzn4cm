%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INSTANCE OUTPUT
%
% - Implements part of INSTANCE API
%		- OUTPUT
%			- displayInstance
%			- displayCmaps
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
	++	displayCmaps(pi.cmaps)
	;

%
function array[int] of string: displayCmaps(array[int] of CMAP: cmaps) =
	if	length(cmaps) == 1
	then displayCmap(cmaps[min(index_set(cmaps))])
	else displayCmap(cmaps[min(index_set(cmaps))]) ++ displayCmaps(cmaps[min(index_set(cmaps))<..max(index_set(cmaps))])
	endif
	;
