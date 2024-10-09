import math
import os
import re

import numpy as np

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

def list_files_in_directory(directory):
    try:
        # Récupérer la liste de tous les fichiers dans le répertoire
        files = [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
        return files
    except FileNotFoundError:
        print(f"Le répertoire {directory} n'existe pas.")
        return []
    except PermissionError:
        print(f"Permission refusée pour accéder au répertoire {directory}.")
        return []

# Vérifie si c’est acyclique
def is_acyclic(adj_matrix):
    n = len(adj_matrix)
    visited = [False] * n
    rec_stack = [False] * n

    def dfs(v):
        visited[v] = True
        rec_stack[v] = True

        for neighbor in range(n):
            if adj_matrix[v][neighbor] == 1:
                if not visited[neighbor]:
                    if dfs(neighbor):
                        return True
                elif rec_stack[neighbor]:
                    return True

        rec_stack[v] = False
        return False

    for node in range(n):
        if not visited[node]:
            if dfs(node):
                return False
    return True
# Plus grand chemin (arc-minimal)
def max_path_length(adj_matrix):
    n = len(adj_matrix)
    max_length = 0

    def dfs(v, visited, path_length):
        nonlocal max_length
        visited[v] += 1
        max_length = max(max_length, path_length)

        for neighbor in range(n):
            if adj_matrix[v][neighbor] == 1:
                if visited[neighbor] < 2:  # We can visit a node twice
                    dfs(neighbor, visited, path_length + 1)

        visited[v] -= 1

    for node in range(n):
        dfs(node, [0] * n, 0)

    return max_length

#Cherche la taille du plus grand chemin
def topological_sort_util(v, visited, stack, adj_matrix):
    visited[v] = True
    for i in range(len(adj_matrix)):
        if adj_matrix[v][i] != 0:
            if not visited[i]:
                topological_sort_util(i, visited, stack, adj_matrix)
    stack.append(v)

def topological_sort(adj_matrix):
    visited = [False] * len(adj_matrix)
    stack = []

    for i in range(len(adj_matrix)):
        if not visited[i]:
            topological_sort_util(i, visited, stack, adj_matrix)
    
    return stack[::-1]

def longest_path(adj_matrix):
    top_order = topological_sort(adj_matrix)
    dist = [-float('inf')] * len(adj_matrix)
    dist[top_order[0]] = 0

    while top_order:
        u = top_order.pop(0)
        if dist[u] != -float('inf'):
            for i in range(len(adj_matrix)):
                if adj_matrix[u][i] != 0:
                    if dist[i] < dist[u] + adj_matrix[u][i]:
                        dist[i] = dist[u] + adj_matrix[u][i]
    
    max_distance = max(dist)
    return max_distance if max_distance != -float('inf') else 0

#Calcul écart-type
def calculate_mean(data):
    return sum(data) / len(data)

def calculate_variance(data, is_sample=True):
    mean = calculate_mean(data)
    squared_diffs = [(x - mean) ** 2 for x in data]
    if is_sample:
        return sum(squared_diffs) / (len(data) - 1)
    else:
        return sum(squared_diffs) / len(data)

def calculate_std_deviation(data, is_sample=True):
    variance = calculate_variance(data, is_sample)
    return math.sqrt(variance)

#Énumération de chemins
def count_paths_no_revisit_nodes(adj_matrix, start, end):
    n = len(adj_matrix)
    path_count = 0

    def dfs(v, visited):
        nonlocal path_count
        if v == end:
            path_count += 1
            return

        visited[v] = True

        for neighbor in range(n):
            if adj_matrix[v][neighbor] == 1 and not visited[neighbor]:
                dfs(neighbor, visited)

        visited[v] = False

    visited = [False] * n
    dfs(start, visited)
    return path_count

def count_paths_no_revisit_arcs(adj_matrix, start, end):
    n = len(adj_matrix)
    path_count = 0

    def dfs(v, visited_arcs):
        nonlocal path_count
        if v == end:
            path_count += 1
            return

        for neighbor in range(n):
            if adj_matrix[v][neighbor] == 1 and (v, neighbor) not in visited_arcs:
                visited_arcs.add((v, neighbor))
                dfs(neighbor, visited_arcs)
                visited_arcs.remove((v, neighbor))

    visited_arcs = set()
    dfs(start, visited_arcs)
    return path_count

def max_nb_path (adj_matrix):
    max = 0
    for i in range(0,adj_matrix[0].size):
        for j in range(0,adj_matrix[0].size):
            if i != j:
                tmp = count_paths_no_revisit_arcs(adj_matrix,i,j)
                if (tmp > max):
                    max = tmp
    return max

#partie principale
directory_path = "data/icmap/kifanlo"  
file_list = list_files_in_directory(directory_path)
print(file_list)
l = []
for file in file_list:
    adj_matrix = parse_icmap_file(f"data/icmap/kifanlo/{file}")
    if is_acyclic(adj_matrix):
        pathlength = max_path_length(adj_matrix)
        l.append(pathlength)
        print(file + " " + str(pathlength))
m = calculate_mean(l)
print(m)
e = calculate_variance(l,is_sample=False)
print(e)