from math import sqrt
import os
import subprocess
from preprocess_and_run import adj_matrix_to_nb_path_no_cycles, max_legth, parse_icmap_file

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
    
import json
import re


def extract_values(json_stream):
    # Charger le JSON complet
    data = [json.loads(line) for line in json_stream.split('\n') if line]

    x_arc_path_length = None
    solve_time = None
    failures = None
    print(data)
    # Parcourir les structures JSON
    for item in data:
        if 'output' in item:
            output = item['output']
            print(output)
            if 'dzn' in output:
                dzn = output['dzn']
                print(dzn)
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

file = "LT02.dzn"
adj_matrix = parse_icmap_file(f"data/icmap/kifanlo/{file}")
#print(adj_matrix)
size_path = max_legth(adj_matrix)
nb_paths, matrix = adj_matrix_to_nb_path_no_cycles(adj_matrix)

with open("data.dzn", "w") as f:
    f.write(f"nb_paths={nb_paths};")
    f.write(f"\nmatrix=array2d(1..{int(sqrt(len(matrix)))},1..{int(sqrt(len(matrix)))},{matrix});")
    f.write(f"size_path={size_path};")

path_length = []
solve_time = []
failures = []
timed_out = 0

try:
    for i in range(1,adj_matrix[0].size+1):
        for j in range(1,adj_matrix[0].size+1):
            if i != j :
                print(str(i) + "  " + str(j))
                with open("data/cmql/cmql_test.dzn","w") as f:
                    f.write(f"origin_node = {i};")
                    f.write(f"destination_node = {j};")
                    f.write(f"F_PATH_MINIMALITY == F_PATH_MINIMALITY_ARC")
                command = f"minizinc test/test_path_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn -d data/cmql/cmql_test.dzn --json-stream -s -t 100000"
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

except Exception as e:
    print(f"Une erreur s'est produite lors de l'exécution de la commande: {e}")
print(path_length)
print(solve_time)
print(failures)
cp = []
s = []
f = []
for i in range(1, adj_matrix[0].size):
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

#j = '''{"type": "solution", "output": {"mzn_vis_0": {"es": [false, true, false, true, true, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false], "ns": [true, true, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, true]}, "raw": "{\"es\": [false, true, false, true, true, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false], \"ns\": [true, true, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, true]}\n", "dzn": "matrix = \n[| 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0\n | 1, 1, 3, 1, 1, 3, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 3, 1\n | 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0\n | 1, 0, 3, 1, 1, 3, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 3, 1\n | 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0\n | 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0\n | 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n | 1, 0, 3, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 3, 1\n | 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n | 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0\n | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0\n | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0\n | 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0\n | 1, 0, 3, 1, 1, 3, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 3, 1\n | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0\n | 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0\n | 1, 0, 3, 1, 1, 3, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1\n | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0\n | 1, 0, 3, 0, 1, 3, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 3, 1\n |];\nx_arc_path_length = 4;\nx_iblock_path = \n[|  3,  4\n |  3,  4\n |  4,  4\n |  3,  4\n | <>, <>\n | <>, <>\n | <>, <>\n | <>, <>\n |];\nx_propagated_iblocks = \n[|   3,   4\n |   9,  16\n |  36,  64\n | 108, 256\n |  <>,  <>\n |  <>,  <>\n |  <>,  <>\n |  <>,  <>\n |];\nx_cmql_path_value = true;\n"}, "sections": ["mzn_vis_0", "raw", "dzn"]}'''

#extract_values(j)