from math import sqrt
import os
import random
import subprocess

import numpy as np
from preprocess_and_run import max_legth, parse_icmap_file

# Fonction pour extraire la valeur de "x_arc_path_length"
def extract_x_arc_path_length(path_value_output):
    if 'o_json' in path_value_output:
        try:
            # Récupérer la chaîne JSON brute
            o_json_raw = path_value_output['o_json']
            
            # Trouver la position de la fin de la première partie JSON
            end_of_json = o_json_raw.find('}') + 1
            o_json_cleaned = o_json_raw[:end_of_json]
            
            # Parse the JSON string into a dictionary
            o_json_objects = json.loads(o_json_cleaned)
            
            # Extract the 'x_arc_path_length' value, with a default of 0 if not present
            return o_json_objects.get('x_arc_path_length', 0)
        
        except json.JSONDecodeError:
            print("Error decoding o_json")
            return None
        

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
    return max,sum_matrix
   
import json
import re


def extract_values(json_stream):
    # Charger le JSON complet
    data = [json.loads(line) for line in json_stream.split('\n') if line]

    x_arc_path_length = None
    solve_time = None
    failures = None

    # Parcourir les structures JSON
    for item in data:
        if 'output' in item:
            output = item['output']
            #print(output)
            if 'dzn' in output:                
                dzn = output['dzn']
                x_arc_path_length_match = re.search(r'x_arc_path_length = (\d+);', dzn)
                if x_arc_path_length_match:
                    x_arc_path_length = int(x_arc_path_length_match.group(1))
        if 'statistics' in item:
            statistics = item['statistics']
            if 'solveTime' in statistics:
                solve_time = statistics['solveTime']
            if 'failures' in statistics:
                failures = statistics['failures']
    
    return x_arc_path_length, solve_time, failures


  
file = "graph.dzn"
adj_matrix = parse_icmap_file(f"{file}")
size_path = max_legth(adj_matrix)
nb_paths, matrix = adj_matrix_to_nb_path(adj_matrix)
output_m = []
for i in matrix:
    for j in i:
        output_m.append(j)
with open("data.dzn", "w") as f:
    f.write(f"nb_paths={nb_paths};")
    f.write(f"\nmatrix=array2d(1..{int(sqrt(len(output_m)))},1..{int(sqrt(len(output_m)))},{output_m});")
    f.write(f"size_path={size_path};")

path_length = []
solve_time = []
failures = []
timed_out = 0

try:
    for i in range(1,100):
        u = random.randint(1, adj_matrix[0].size-1)
        v = random.randint(u+1, adj_matrix[0].size)
        print(str(u) + "  " + str(v))
        with open("data/cmql/cmql_test.dzn","w") as f:
            f.write(f"origin_node = {u};")
            f.write(f"destination_node = {v};")
        command = f"minizinc test/test_value.mzn -d {file} -d data/itype/itype_opt_rational_min_max.dzn -d data.dzn -d data/cmql/cmql_test.dzn --json-stream -s -t 100000"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=60)
            #print(result.stdout)
            l,s,f = extract_values(result.stdout)
            path_length.append(l)
            solve_time.append(s)
            failures.append(f)
            print("path_length: " + str(l) + " solve_time: " + str(s) + " failures: " + str(f))
        except subprocess.TimeoutExpired:
            timed_out += 1
            print("\nCommand timed out")
        print(str(i/1000) + " %")
                

except Exception as e:
    print(f"Une erreur s'est produite lors de l'exécution de la commande: {e}")
print(path_length)
print(solve_time)
print(failures)

cp = []
s = []
f = []
for i in range(1, adj_matrix.size):
    cp.append(0)
    s.append(0)
    f.append(0)
for i in range(0,len(path_length)):
    s[path_length[i]] += solve_time[i]
    f[path_length[i]] += failures[i]
    cp[path_length[i]] += 1

for i in range(0,len(cp)):
    if cp[i] > 0:
        s[i] = s[i]/cp[i]
        f[i] = f[i]/cp[i]
print(cp)
print(s)
print(f)
print(timed_out)