%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% OUTPUT UTILITIES



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

% include "../display.mzn"; % for enum-based utilities




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERIC UTILITIES

%% map2string
% 
function array[int] of string: map2string(set of int: t) =
	[show(i) | i in t]
	; 

% 
function array[int] of string: map2string(array[$$T] of any $T: t) =
	[show(t[i]) | i in index_set(t)]
	; 

% % 
% function array[int] of string: map2string(array[$$T] of $T: t) =
% 	[show(t[i]) | i in index_set(t)]
% 	; 

% % 
% function array[int] of string: map2string(array[$$T] of var $T: t) =
% 	[show(t[i]) | i in index_set(t)]
% 	; 

% % 
% function array[int] of string: map2string(array[$$T] of var opt int: t) =
% % 	[if occurs(t[i]) then show(t[i]) else "<>" endif | i in index_set(t)]
% 	[show(t[i]) | i in index_set(t)]
% 	; 

% 
function array[int, int] of string: map2string(array[$$T,$$U] of any $T: t) =
	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
	; 

% % 
% function array[int, int] of string: map2string(array[$$T,$$U] of $T: t) =
% 	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
% 	; 

% % 
% function array[int, int] of string: map2string(array[$$T,$$U] of var $T: t) =
% 	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
% 	; 

% % 
% function array[int, int] of string: map2string(array[$$T,$$U] of opt $T: t) =
% 	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
% 	; 

% % 
% function array[int, int] of string: map2string(array[$$T,$$U] of var opt $T: t) =
% 	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
% 	; 

% % 
% function array[int, int] of string: map2string(array[$$T,$$U] of set of $T: t) =
% 	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
% 	; 

% % 
% function array[int, int] of string: map2string(array[$$T,$$U] of var opt set of $T: t) =
% 	array2d(index_set_1of2(t), index_set_2of2(t), [show(t[i,j]) | i in index_set_1of2(t), j in index_set_2of2(t)])
% 	; 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ENUM-BASED UTILITIES

% % map2name
% function string: map2name(DISPLAY: d, $$T: t) =
% 	map2name(d, [t])[1]
% 	;

% % map2name
% function array[int] of string: map2name(DISPLAY: d, array[$$T] of $T: t) =
% 	if d=D_ARC_ID
% 	then[show(t[i]) | i in index_set(t)]
% 	elseif d=D_CONCEPT_ID
% 	then [concepts[t[i]].name | i in index_set(t)]
% 	elseif d=D_ELEMENT
% 	then [show(t[i]) | i in index_set(t)]
% 	elseif d=D_HEAD_TAIL
% 	then [show(t[i]) | i in index_set(t)]
% 	elseif d=D_IN_OUT
% 	then [show(t[i]) | i in index_set(t)]
% 	elseif d=D_INFLUENCE
% 	then [showInfluence(t[i]) | i in index_set(t)]
% 	elseif d=D_INT
% 	then [show(t[i]) | i in index_set(t)]
% 	elseif d=D_NODE_ID
% % 	then [concepts[t[i]].name | i in index_set(t)]
% 	then[show(t[i]) | i in index_set(t)]
% 	elseif d=D_OPERATION
% 	then [show(t[i]) | i in index_set(t)]
% 	elseif d=D_PATH_INFLUENCE
% 	then ["(i:" ++ map2name(D_INFLUENCE, t[i].i) ++ ",l:" ++ show(t[i].l) ++ ",w:" ++ show(t[i].w) ++ ")" | i in index_set(t)]
% 	elseif d=D_PROPERTY
% 	then [show(t[i]) | i in index_set(t)]
% 	elseif d=D_PRED_SUCC
% 	then [show(t[i]) | i in index_set(t)]
% 	else
% 	assert(false, "bug", [])
% 	endif
% 	;


% my_show1d_indexed
% %
% function string: my_show1d_indexed(DISPLAY: C, array[$$J] of any $K: M) =
% 	let {
% 		array[int] of string: rows = [""];
% 		array[int] of string: cols = map2name(C, set2array(index_set(M)));
% 		array[int, int] of string: names = array2d(1..1,index_set(M), M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show1d_indexed(DISPLAY: C, array[$$J] of string: M) =
% 	let {
% 		array[int] of string: rows = [""];
% 		array[int] of string: cols = map2name(C, set2array(index_set(M)));
% 		array[int, int] of string: names = array2d(1..1,index_set(M), M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show1d_indexed(DISPLAY: C, array[$$J] of opt $$K: M) =
% 	let {
% 		array[int] of string: rows = [""];
% 		array[int] of string: cols = map2name(C, set2array(index_set(M)));
% 		array[int, int] of string: names = array2d(1..1,index_set(M), map2string(M));
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show1d_indexed(DISPLAY: C, array[$$J] of var opt $$K: M) =
% 	let {
% 		array[int] of string: rows = [""];
% 		array[int] of string: cols = map2name(C, set2array(index_set(M)));
% 		array[int, int] of string: names = array2d(1..1,index_set(M), map2string(M));
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;





% my_show2d_indexed
% %
% function string: my_show2d_indexed(DISPLAY: R, DISPLAY: C, array[$$I,$$J] of any $K: M) =
% 	let {
% 		array[int] of string: rows = map2name(R, set2array(index_set_1of2(M)));
% 		array[int] of string: cols = map2name(C, set2array(index_set_2of2(M)));
% 		array[int, int] of string: names = map2string(M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show2d_indexed(DISPLAY: R, DISPLAY: C, array[$$I,$$J] of string: M) =
% 	let {
% 		array[int] of string: rows = map2name(R, set2array(index_set_1of2(M)));
% 		array[int] of string: cols = map2name(C, set2array(index_set_2of2(M)));
% 		array[int, int] of string: names = M;
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show2d_indexed(DISPLAY: R, DISPLAY: C, array[$$I,$$J] of $$K: M) =
% 	let {
% 		array[int] of string: rows = map2name(R, set2array(index_set_1of2(M)));
% 		array[int] of string: cols = map2name(C, set2array(index_set_2of2(M)));
% 		array[int, int] of string: names = map2string(M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show2d_indexed(DISPLAY: R, DISPLAY: C, array[$$I,$$J] of opt $$K: M) =
% 	let {
% 		array[int] of string: rows = map2name(R, set2array(index_set_1of2(M)));
% 		array[int] of string: cols = map2name(C, set2array(index_set_2of2(M)));
% 		array[int, int] of string: names = map2string(M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show2d_indexed(DISPLAY: R, DISPLAY: C, array[$$I,$$J] of set of $$K: M) =
% 	let {
% 		array[int] of string: rows = map2name(R, set2array(index_set_1of2(M)));
% 		array[int] of string: cols = map2name(C, set2array(index_set_2of2(M)));
% 		array[int, int] of string: names = map2string(M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;

% %
% function string: my_show2d_indexed(DISPLAY: R, DISPLAY: C, array[$$I,$$J] of var opt $$K: M) =
% 	let {
% 		array[int] of string: rows = map2name(R, set2array(index_set_1of2(M)));
% 		array[int] of string: cols = map2name(C, set2array(index_set_2of2(M)));
% 		array[int, int] of string: names = map2string(M);
% 	} in
% 		show2d_indexed(rows, cols, names)
% 	;



