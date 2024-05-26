import os
import subprocess
import argparse
import re
import numpy as np


def adj_matrix_to_nb_path (adj_matrix):
    tmp_matrix = adj_matrix
    sum_matrix = adj_matrix
    for i in range(1, adj_matrix.shape[0]) :
        tmp_matrix = np.dot(tmp_matrix, adj_matrix)
        sum_matrix = sum_matrix + tmp_matrix
    max = 0
    for i in range(adj_matrix.shape[0]):
        for j in range(adj_matrix.shape[0]):
            if sum_matrix[i][j] > max:
                max = sum_matrix[i][j]
    print(sum_matrix)
    return max

def parse_icmap_file(icmap_file):
    """Parse the ICMap file and extract the adjacency matrix."""
    with open(icmap_file, 'r') as file:
        content = file.read()
    
    # Extract node count
    node_count = len(re.findall(r'\(node:\d+, concept:\(name:"[^"]+"\)\)', content))
    
    # Initialize adjacency matrix
    adj_matrix = np.zeros((node_count, node_count), dtype=int)
    # Extract arc_labels and fill the adjacency matrix
    arc_labels = re.findall(r'\(arc:\(t:(\d+), h:(\d+)\), influence:\(iblock:\[(.*?)\]\)\)', content)
    for t, h, influence in arc_labels:        
        t, h = int(t) - 1, int(h) - 1  # Adjusting index to be zero-based
        adj_matrix[t][h] = 1

    return adj_matrix

def add_parameters_to_dzn(dzn_file, nb_paths, args):
    with open(dzn_file,"w") as f:
        f.write(f"nb_paths={nb_paths};")
        if args.minizinc_calc != None:
            f.write(f"\nF_NB_PATH_COUNTING={args.minizinc_calc};")
        if args.fixed != None:
            f.write(f"\nF_FIXED_NODE={args.fixed};")

def run_minizinc_command(args, dzn_file):
    """Run a MiniZinc command after adding parameters to a .dzn file."""    
    command = f"minizinc {args.model} -d {args.icmap} -d {args.itype} -d {dzn_file} "
    if args.data != None:
        command += f"-d {args.data}"
    print(command)
    subprocess.run(command, shell=True)
    

def main():
    parser = argparse.ArgumentParser(description="Run MiniZinc command with additional parameters.")
    parser.add_argument("model", type=str, help="The MiniZinc command to run")
    parser.add_argument("-icmap", type=str, required=True, help="Additional parameters to add to the .dzn file (key=value)")
    parser.add_argument("-itype", type=str, required=True, help="Additional parameters to add to the .dzn file (key=value)")
    parser.add_argument("-data", type=str, required=False, help="Additional parameters to add to the .dzn file (key=value)")    
    parser.add_argument("-minizinc_calc", type=str, required=False, help="Additional parameters to add to the .dzn file (key=value)")    
    parser.add_argument("-fixed", type=str, required=False, help="Additional parameters to add to the .dzn file (key=value)") 
    args = parser.parse_args()

    icmap_parameters = parse_icmap_file(args.icmap)
    print(icmap_parameters)
    nb_paths = adj_matrix_to_nb_path(icmap_parameters)
    print(nb_paths)

    dzn_file = "data.dzn"
    add_parameters_to_dzn(dzn_file,nb_paths, args)
    run_minizinc_command(args, dzn_file)

if __name__ == "__main__":
    main()
