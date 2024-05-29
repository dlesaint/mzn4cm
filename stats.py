import json
import csv

def parse_multiple_json(json_string):
    # Split the JSON string by newlines and then filter out any empty strings
    json_parts = [part.strip() for part in json_string.split('\n') if part.strip()]
    return [json.loads(part) for part in json_parts]

def parse_multiple_json2(json_string):
    # Split the JSON string by newlines and then filter out any empty strings
    json_parts = [part.strip() for part in json_string.split('\n') if part.strip()]
    json_parts2 = []
    for i in range(1, len(json_parts)-1) :
        json_parts2.append(json_parts[i])
    return [ json.loads(part) for part in  json_parts2]

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
        
# Fonction pour extraire la valeur de "x_arc_path_length"
def extract_x_nr_paths(path_value_output):
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
            return o_json_objects.get('x_nr_paths', 0)
        
        except json.JSONDecodeError:
            print("Error decoding o_json")
            return None
        
def update_stats(stats_dict, new_data):
    
    for key, value in new_data.items():
        if key in stats_dict:
            if isinstance(stats_dict[key], (int, float)) and isinstance(value, (int, float)):
                stats_dict[key] += value
        else:
            
            stats_dict[key] = value

# Charger les données JSON depuis un fichier
with open('output2.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

# Ouvrir le fichier CSV pour écriture
with open('stats.csv', 'w', newline='', encoding='utf-8') as csvfile:
    # Définir les noms des colonnes
    fieldnames = [
        'name', 'number of vertices', 'density', 'number of paths', 'number of vars (value)',
        'number of propagation (value)', 'flatening time (value)', 'solving time (value)',
        'path length', 'number of vars (path_value)', 'number of propagation (path_value)',
        'flatening time (path_value)', 'solving time (path_value)'
    ]
    
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    
    for entry in data:
        name = entry['name']
        for solution in entry['data']:
            row = {'name': name}
            path_value_stats = {}
            value_stats = {}
            path_value_output = {}
            value_output = {}
            trace_data = None
            
           # Extraire les données de "path_value" et "value"
            if 'path_value' in solution and solution['path_value']:
                try:
                    path_value_objects = parse_multiple_json(solution['path_value'])
                    for obj in path_value_objects:
                        if obj.get('type') == 'trace':
                            trace_data = obj['message']['userData']
                        elif obj.get('type') == 'statistics':
                            update_stats(path_value_stats, obj['statistics'])
                        elif obj.get('type') == 'solution':
                            update_stats(path_value_output, obj['output'])
                except json.JSONDecodeError:
                    print(f"Error decoding JSON for path_value in {name}")

            if 'value' in solution and solution['value']:
                try:
                    value_objects = parse_multiple_json(solution['value'])
                    for obj in value_objects:
                        if obj.get('type') == 'statistics':
                            update_stats(value_stats, obj['statistics'])
                        elif obj.get('type') == 'solution':
                            update_stats(value_output, obj['output'])
                except json.JSONDecodeError:
                    print(f"Error decoding JSON for value in {name}")
            
            # Remplir les champs pour le CSV
            if trace_data:
                row['number of vertices'] = len(trace_data['nodes'])
                row['density'] = len(trace_data['edgeLabels']) / (len(trace_data['nodes']) * (len(trace_data['nodes']) - 1))
                
                
            
            if value_stats:
                row['number of vars (value)'] = value_stats.get('variables', 0)
                row['number of propagation (value)'] = value_stats.get('propagations', 0)
                row['flatening time (value)'] = value_stats.get('flatTime', 0)
                row['solving time (value)'] = value_stats.get('solveTime', 0)
            
            if path_value_stats:
                row['number of vars (path_value)'] = path_value_stats.get('flatBoolVars', 0)
                row['number of propagation (path_value)'] = path_value_stats.get('propagations', 0)
                row['flatening time (path_value)'] = path_value_stats.get('flatTime', 0)
                row['solving time (path_value)'] = path_value_stats.get('solveTime', 0)
            row['path length'] = extract_x_arc_path_length(path_value_output)             
            row['number of paths'] = extract_x_nr_paths(value_output)
            writer.writerow(row)
