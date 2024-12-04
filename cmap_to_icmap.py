import os

def combine_icmaps(input_folder, output_file):
    """
    Combine multiple .dzn files into a single file with a list of icmaps.
    
    Args:
        input_folder (str): Path to the folder containing the .dzn files.
        output_file (str): Path to the output .dzn file.
    """
    icmaps = []
    
    for filename in os.listdir(input_folder):
        if filename.endswith(".dzn"):
            filepath = os.path.join(input_folder, filename)
            with open(filepath, "r") as file:
                content = file.read()
                # Extract the content between parentheses and add to the list
                icmaps.append(content.replace("icmap =(", "(").strip().rstrip(");"))
    
    # Combine all icmaps into a single array
    combined_content = "icmaps = [\n    " + ",\n    ".join(icmaps) + "\n];"

    
    # Write the combined content to the output file
    with open(output_file, "w") as outfile:
        outfile.write(combined_content)

# Example usage
input_folder = "data/icmap/kifanlo"  # Folder containing .dzn files
output_file = "data/icmap/icms_R_kifanlo"  # Output file

# Ensure the input folder exists and contains the uploaded files
os.makedirs(input_folder, exist_ok=True)

# Move the uploaded files to the input folder for testing
#os.rename(file_ye15, os.path.join(input_folder, "YE15.dzn"))
#os.rename(file_icms, os.path.join(input_folder, "icms_S_test.dzn"))

# Combine the files
combine_icmaps(input_folder, output_file)

# Verify the result by reading the output file
with open(output_file, "r") as f:
    combined_content = f.read()

combined_content
