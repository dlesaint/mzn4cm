% make sure the first array is lexicographically inferior to the other
predicate lex_2_table (array[int] of var int: a, array[int] of var int: b, set of int: size) = 
  a[min(size)] <= b[min(size)]
  /\ forall( i in size) ((i < max(size) /\ a[i] == b[i]) -> a[i+1] <= b[i+1])
  /\ count([a[i] != b[i] | i in size]) >= 1
;

% make sure that the columns of a array are lexicographically ordered
predicate lex_chain ( array[int, int] of var int: a, set of int: col, set of int: line) = 
  forall (i in  col, j in col) ( (i<j) -> lex_2_table(a[line, i], a[line, j], col))
;

predicate lex_strict (array[int,int] of var int: a, set of int: col, set of int: line) = 
  lex_chain(a,col,line)
  /\
  lex_chain(                                 %% transpose
        array2d(index_set_2of2(a), index_set_1of2(a),
            [a[i, j] | j in index_set_2of2(a), i in index_set_1of2(a)]
        ),line,col
    )
;

%% Same than above but with opt values
predicate lex_2_table_opt (array[int] of var opt int: a, array[int] of var opt int: b, set of int: size) = 
  a[min(size)] <= b[min(size)]
  /\ forall( i in size) ((i < max(size) /\ a[i] == b[i]) -> a[i+1] <= b[i+1])
  /\ count([a[i] != b[i] | i in size]) >= 1
;

predicate lex_chain_opt ( array[int, int] of var opt int: a, set of int: col, set of int: line) = 
  forall (i in  col, j in col) ( (i<j) -> lex_2_table_opt(a[i,col], a[j,col], line))
;

predicate lex_strict_opt (array[int,int] of var opt int: a, set of int: col, set of int: line) = 
  lex_chain_opt(a,col,line)
  /\
  lex_chain_opt(                                 %% transpose
        array2d(index_set_2of2(a), index_set_1of2(a),
            [a[i, j] | j in index_set_2of2(a), i in index_set_1of2(a)]
        ),line,col
    )
;


  