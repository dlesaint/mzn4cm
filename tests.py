import subprocess
import os
#from preprocess_and_run import test

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
output_file = "output.txt"
try:
    with open(output_file, 'w', encoding='utf-8') as out:
        for file in file_list:
            fichier = open(os.path.join(directory_path,file),"r",encoding="utf-8")
            command = f"python3 preprocess_and_run.py test/test_value.mzn -icmap data/icmap/kifanlo/{file} -itype data/itype/itype_opt_rational_plus_times.dzn"
            #test("test/test_value.mzn",f"data/icmap/kifanlo/{file}", "data/itype/itype_opt_rational_plus_times.dzn",None,None,None)
            subprocess.run(command, shell=True,stdout=fichier,stderr=fichier,text=True)
            subprocess.run(command, shell=True,stdout=fichier,stderr=fichier,text=True)
            print(f"La sortie de la commande a été écrite dans le fichier {output_file}")
except Exception as e:
    print(f"Une erreur s'est produite lors de l'exécution de la commande: {e}")
