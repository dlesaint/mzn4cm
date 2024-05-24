array[1..5,1..5] of int: matrix = array2d(1..5,1..5,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
int: nr_path = nr_paths(matrix);

solve satisfy;

%
function int: nr_paths(array[int,int] of int: matrix) =
	let {
		bool: precond = assert(index_set_1of2(matrix) == index_set_2of2(matrix), "nr_paths: $matrix must be a square matrix");
		array[int,int] of int: result = sum_recursive(matrix, matrix, min(index_set_2of2(matrix))-1);
  } in 
    max(result)
;

%return a matrix of the sum of the powers of the input matrix
function array[int,int] of int: sum_recursive(array[int,int] of int: matrixO, array[int,int] of int: matrixN, int: i) = 
	let {
		bool: precond1 = assert(index_set_1of2(matrixO) == index_set_2of2(matrixO), "sum_recursive: $matrixO must be a square matrix");
		bool: precond2 = assert(index_set_1of2(matrixN) == index_set_2of2(matrixN), "sum_recursive: $matrixN must be a square matrix");
		bool: precond3 = assert(index_set_1of2(matrixO) == index_set_1of2(matrixN), "sum_recursive: the row index set of $matrixO and column index set of $matrixN must be equal");
		array[int,int] of int: nr_paths = array2d(index_set_1of2(matrixN), index_set_2of2(matrixN),[matrixN[k,l] | k in index_set_1of2(matrixN), l in index_set_2of2(matrixN)]); % NB. sum supported on opt arrays
		int: j = i+1;
	} in 
		if j == max(index_set_2of2(matrixN))
		then		nr_paths
		else		array2d(index_set_1of2(matrixN), index_set_2of2(matrixN),[nr_paths[k,l] + sum_recursive(matrixO, matrix_multiply(matrixN, matrixO), j)[k,l] | k in index_set_1of2(matrixN), l in index_set_2of2(matrixN)])
		endif
;

% ruturns the matrix product of two matrices
function array[int,int] of int: matrix_multiply(array[int,int] of int: matrixN, array[int,int] of int: matrixO) =
	let {
		bool: precond1 = assert(index_set_2of2(matrixN) == index_set_1of2(matrixO), "matrix_multiply: the column index set of $matrixN and row index set of $matrixO must be equal");
	} in 
		array2d(index_set_1of2(matrixN), index_set_2of2(matrixN), [sum([if occurs(matrixN[i,k])/\ occurs(matrixO[k,j]) then matrixN[i,k]*matrixO[k,j] else 0 endif | k in index_set_2of2(matrixN)]) | i in index_set_1of2(matrixN), j in index_set_2of2(matrixO)])
	;