from math import sqrt
import os
import subprocess
import argparse
import re
import numpy as np
# -------------- Calcul de la taille max des chemins ------------------
from collections import defaultdict, deque

def matrix_to_adjacency_list(matrix):
    graph = defaultdict(list)
    for u in range(len(matrix)):
        for v in range(len(matrix[u])):
            if matrix[u][v] != 0:  # Suppose que 0 signifie aucune connexion
                graph[u].append((v, matrix[u][v]))
    return graph

def topological_sort(graph, V):
    in_degree = [0] * V
    for u in range(V):
        for v, _ in graph[u]:
            in_degree[v] += 1

    queue = deque([i for i in range(V) if in_degree[i] == 0])
    topo_order = []
    while queue:
        u = queue.popleft()
        topo_order.append(u)
        for v, _ in graph[u]:
            in_degree[v] -= 1
            if in_degree[v] == 0:
                queue.append(v)
    
    return topo_order

def longest_path_with_cycles(matrix, start):
    def dfs(graph, node, visited, memo):
        if node in visited:
            return -float('inf')  # Ignorer ce chemin si le nœud est déjà visité dans cette branche
        if memo[node] != -1:
            return memo[node]  # Si on a déjà calculé le chemin max pour ce nœud, on retourne le résultat mémorisé

        visited.add(node)  # Marquer le nœud comme visité
        max_dist = 0  # Initialiser la distance maximale pour ce nœud

        for neighbor, weight in graph[node]:
            # Calculer la distance pour chaque voisin en évitant les boucles
            max_dist = max(max_dist, weight + dfs(graph, neighbor, visited, memo))
        
        visited.remove(node)  # Retirer le nœud du chemin actuel pour explorer d'autres chemins
        memo[node] = max_dist  # Mémoriser la distance maximale depuis ce nœud
        return max_dist

    V = len(matrix)
    graph = matrix_to_adjacency_list(matrix)
    memo = [-1] * V  # Mémo pour stocker les résultats intermédiaires
    visited = set()  # Ensemble pour suivre les nœuds visités

    # Calculer la distance maximale à partir du nœud de départ
    return dfs(graph, start, visited, memo)

def max_legth (adj_matrix):
    result = 0
    for i in range(adj_matrix.shape[0]):
        tmp =  longest_path_with_cycles(adj_matrix,i)
        #print(tmp)        
        if result<tmp:
            result = tmp
    #print(result)
    return(result)

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
    #print(sum_matrix)
    #print(max)
    return max
def count_paths_dfs(adj_matrix,start,end):
    def dfs(current,end,visited):
        if current == end:
            return 1
        visited[current] = True
        count = 0
        for neighbor in range(len(adj_matrix)):
            if adj_matrix[current][neighbor] == 1 and not visited[neighbor]:
                count += dfs(neighbor,end,visited)
        visited[current] = False
        return count
    visited = [False] * len(adj_matrix)    
        
    return dfs(start,end,visited)

def adj_matrix_to_nb_path_no_cycles (adj_matrix):
    max = 0
    array = []
    for i in range(0,adj_matrix.shape[0]):
        for j in range(0,adj_matrix.shape[0]):
            tmp = count_paths_dfs(adj_matrix,i,j)
            array.append(tmp)
            if tmp > max:
                max = tmp 
    return max,array

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

def add_parameters_to_dzn(dzn_file, nb_paths, matrix, size_path, args):
    with open(dzn_file,"w") as f:
        f.write(f"nb_paths={nb_paths};")
        f.write(f"\nmatrix=array2d(1..{int(sqrt(len(matrix)))},1..{int(sqrt(len(matrix)))},{matrix});")
        f.write(f"\nsize_path={size_path};")
        if args.minizinc_calc != None:
            f.write(f"\nF_NB_PATH_COUNTING={args.minizinc_calc};")
        if args.fixed != None:
            f.write(f"\nF_FIXED_NODE={args.fixed};")

def run_minizinc_command(args, dzn_file):
    """Run a MiniZinc command after adding parameters to a .dzn file."""    
    command = f"minizinc {args.model} -d {args.icmap} -d {args.itype} -d {dzn_file}"
    if args.data != None:
        command += f" -d {args.data}"
    command += f" -v -s --time-limit 60000"
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
    adj_matrix_to_nb_path(icmap_parameters)
    nb_paths,matrix = adj_matrix_to_nb_path_no_cycles(icmap_parameters)    
    print(nb_paths)
    print(matrix)    
    size_path = max_legth(icmap_parameters)
    print(size_path)
    dzn_file = "data.dzn"
    add_parameters_to_dzn(dzn_file,nb_paths,matrix, size_path, args)
    run_minizinc_command(args, dzn_file)

if __name__ == "__main__":    
    main()
