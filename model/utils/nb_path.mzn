function array[int,int] of opt int: matrice_multiply (set of int: nbSommet, set of int: nbArc, array[int,int] of opt int: a, array[int,int] of opt int: b) = 
  let {
    array[int,int] of opt int: c  = array2d(nbSommet, nbSommet, [sum([if occurs(a[i,k])/\ occurs(b[k,j]) then a[i,k]*b[k,j] else <> endif | k in nbSommet]) | i in nbSommet, j in nbSommet])
  } in 
    c
 ;
 
function int: sum (set of int: nbSommet, array[int,int] of opt int: matrice) = 
  let {
    int: somme  = sum (j in nbSommet, k in nbSommet) (if occurs(matrice[j,k]) then deopt(matrice[j,k]) else 0 endif);
  } in 
    somme
;

function int: sum_recursive (set of int: nbSommet, set of int: nbArc, array[int,int] of opt int: matriceO, array[int,int] of opt int: matriceN, int: i) = 
  let {
    int: nbPath = sum(nbSommet, matriceN);
    int: j  = i+1;
  } in 
    if (j == max(nbArc)) then 
      nbPath
    else 
      nbPath + sum_recursive(nbSommet, nbArc, matriceO, matrice_multiply(nbSommet, nbArc,matriceN, matriceO),j)
     endif
 ;
 
function int: nb_path (set of int: nbSommet,set of int: nbArc, array[int,int] of opt int: matrix) = 
  let {
    int: nbPath = sum_recursive(nbSommet, nbArc, matrix, matrix, min(nbArc)-1);
  } in 
    nbPath
 ;