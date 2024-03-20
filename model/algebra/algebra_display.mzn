%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% David Lesaint (david.lesaint@univ-angers.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ALGEBRA OUTPUT
%
%	- Implements part of ALGEBRA API
%		- OUTPUT
%			- showAlgebraElement
%			- displayAlgrebraHeader
%			- displayAlgebraProperties
%			- displayAlgebraElements
%
%	- Uses ALGEBRA IMPLEMENTATION API
%		- OUTPUT
%			- showNonVirtualElement



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILE INCLUSION

include "../algebra/algebra_api.mzn";
include "../algebra/algebra_imp_api.mzn";

include "../utils/utils_string.mzn"; % for map2string



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTPUT

%
function string: showAlgebraElement(A_ELEMENT: x) =
	if			isUndefinedElement(x)
	then "X"
	elseif	isVirtualElement(x)
	then "<>"
	else
	showNonVirtualElement((algebra:x.algebra, value:deopt(x.value)))
	endif
;

%
function array[int] of string: displayAlgrebraHeader(E_ALGEBRA: ea) =
		["****** ALGEBRA ***********"]
	++	["\n"]
	++	[show(ea.algebra)]
	++	["\n"]
;

%
function array[int] of string: displayAlgebraProperties(E_ALGEBRA: ea) =
	let {
		array[int] of string: rows = map2string(set2array(ALGEBRAIC_OPERATION));
		array[int] of string: cols = map2string(set2array(ALGEBRAIC_PROPERTY));
		array[int, int] of string: names = array2d(ALGEBRAIC_OPERATION, ALGEBRAIC_PROPERTY, [show(checkProperty(ea, i, j)) | i in ALGEBRAIC_OPERATION, j in ALGEBRAIC_PROPERTY]);
	} in
% 		["Existence of neutral and absorbing elements, commutativity, associativity"]
% 	++	[" of algebra " ++ show(ea)]
% 	++	["\n"]
		[show2d_indexed(rows, cols, names)]
	++	["\n"]
;


%
function array[int] of string: displayAlgebraElements(E_ALGEBRA: ea) =
	let {
		array[int] of string: rows = map2string(set2array(ALGEBRAIC_OPERATION));
		array[int] of string: cols = map2string(set2array(ALGEBRAIC_ELEMENT));
		array[int, int] of string : names = 
					array2d(ALGEBRAIC_OPERATION, ALGEBRAIC_ELEMENT, 
%									[if isVirtualElement(getElement(ea, i, j)) then "<>" else let {opt A_ELEMENT: v = getElement(ea, i, j);} in showAlgebraElement((a:deopt(v.id), k:deopt(v.k))) endif 
									[showAlgebraElement(getElement(ea, i, j)) 
% 									[""
									| i in ALGEBRAIC_OPERATION, j in ALGEBRAIC_ELEMENT]);
	} in
% 		["Neutral and absorbing elements"]
% 	++	[" of algebra " ++ show(ea)]
% 	++	["\n"]
		[show2d_indexed(rows, cols, names)]
	++	["\n"]
;
