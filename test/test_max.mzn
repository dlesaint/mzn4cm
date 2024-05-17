var int: x_length;
var int: y_length;
array[1..3] of var opt 1..10: x;
array[1..3] of var opt 1..10: y;
int: size = length(x);
array[0..size] of var bool: b;

constraint y_length == 1;
constraint x_length == 2;
constraint occurs(x[1]);
constraint occurs(y[1]);
constraint occurs(y[2]);
constraint x[1] < y[1];
constraint if y_length == 0
           then forall(i in 0..size) (b[i])
           else 
                b[size] = (x_length < y_length) /\
                forall(i in 0..size-1)(b[i] = ((x[1 + i] <= y[1 + i]) /\ ((x[1 + i] <  y[1 + i] /\ (occurs(y[i+1]) \/ occurs(x[i+1])))\/ b[i+1]))) /\
                b[0]
            endif;
solve satisfy;
