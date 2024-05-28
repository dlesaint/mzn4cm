import subprocess
import os
from preprocess_and_run import *
from datetime import datetime
import random

def od (adj_matrix):
    i = 0
    j = 0
    max = 0
    for k in range(0,int(sqrt(len(matrix)))):
        for l in range(0,int(sqrt(len(matrix)))):
            if adj_matrix[k*int(sqrt(len(matrix))) +l] > max:
                max = adj_matrix[k*int(sqrt(len(matrix))) +l]
                i = k
                j = l
    return i,j

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

directory_path = "data/icmap/kifanlo"   
file_list = list_files_in_directory(directory_path)
print(file_list)
output_file = "output3.json"
import subprocess
import random
import json
from math import sqrt

output_file = "output2.json"
results = []

try:
    for file in file_list:
        # Initialisation des données pour ce fichier
        result_entry = {
            "name": file,
            "data": []
        }

        adj_matrix = parse_icmap_file(f"data/icmap/kifanlo/{file}")
        print(adj_matrix)
        size_path = max_legth(adj_matrix)
        nb_paths, matrix = adj_matrix_to_nb_path_no_cycles(adj_matrix)

        with open("data.dzn", "w") as f:
            f.write(f"nb_paths={nb_paths};")
            f.write(f"\nmatrix=array2d(1..{int(sqrt(len(matrix)))},1..{int(sqrt(len(matrix)))},{matrix});")
            f.write(f"size_path={size_path};")

        # Première solution trouvée
        entry = {
            "type": "première solution",
            "path_value": "",
            "value": ""
        }
        
        command = f"minizinc test/test_path_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn --json-stream -s"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            entry["path_value"] = result.stdout
        except subprocess.TimeoutExpired:
            print("\nCommand timed out")

        command = f"minizinc test/test_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn --json-stream -s"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            entry["value"] = result.stdout
        except subprocess.TimeoutExpired:
            print("\nCommand timed out")

        result_entry["data"].append(entry)

        # Plus grand nombre de chemin
        i, j = od(matrix)
        i = i + 1
        j = j + 1
        with open("data/cmql/cmql_test.dzn", "w") as f:
            f.write(f"origin_node = {i+1};")
            f.write(f"destination_node = {j+1};")

        entry = {
            "type": "Plus grand nombre de chemin",
            "path_value": "",
            "value": ""
        }
        
        command = f"minizinc test/test_path_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn -d data/cmql/cmql_test.dzn --json-stream -s"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            entry["path_value"] = result.stdout
        except subprocess.TimeoutExpired:
            print("\nCommand timed out")

        command = f"minizinc test/test_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn -d data/cmql/cmql_test.dzn --json-stream -s"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            entry["value"] = result.stdout
        except subprocess.TimeoutExpired:
            print("\nCommand timed out")

        result_entry["data"].append(entry)

        # Aléatoire
        i = int(random.uniform(1, int(sqrt(len(matrix)))))
        j = int(random.uniform(1, int(sqrt(len(matrix)))))
        with open("data/cmql/cmql_test.dzn", "w") as f:
            f.write(f"origin_node = {i};")
            f.write(f"destination_node = {j};")

        entry = {
            "type": "noeuds aléatoires",
            "path_value": "",
            "value": ""
        }
        
        command = f"minizinc test/test_path_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn -d data/cmql/cmql_test.dzn --json-stream -s --time-limit 6000"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            entry["path_value"] = result.stdout
        except subprocess.TimeoutExpired:
            print("\nCommand timed out")

        command = f"minizinc test/test_value.mzn -d data/icmap/kifanlo/{file} -d data/itype/itype_opt_rational_plus_times.dzn -d data.dzn -d data/cmql/cmql_test.dzn --json-stream -s --time-limit 6000"
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            entry["value"] = result.stdout
        except subprocess.TimeoutExpired:
            print("\nCommand timed out")

        result_entry["data"].append(entry)
        
        results.append(result_entry)

    # Sauvegarder les résultats dans un fichier JSON
    with open(output_file, 'w', encoding='utf-8') as out:
        json.dump(results, out, ensure_ascii=False, indent=4)

except Exception as e:
    print(f"Une erreur s'est produite lors de l'exécution de la commande: {e}")
