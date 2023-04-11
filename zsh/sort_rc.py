import argparse
from itertools import groupby

def sort_bashrc(bashrc_path):
    # Open the .bashrc file for reading
    with open(bashrc_path, "r") as f:
        data = f.read()

    # Split the file contents into individual lines
    lines = data.split("\n")

    # Create a list of all the functions in the file and extract the
    # non-function lines into a separate list
    functions = []
    non_functions = []
    current_function = ""
    for line in lines:
        if line.startswith("function"):
            # Start of a new function
            if current_function:
                # Store the previous function
                functions.append(current_function)
            current_function = line + "\n"
        elif current_function and line.strip() == "}":
            # End of the current function
            current_function += "}\n\n"
            functions.append(current_function)
            current_function = ""
        elif current_function:
            # Add the current line to the current function
            current_function += line + "\n"
        elif line.strip() or line == '':
            # This is a non-empty line outside of a function, so add it to the
            # non-functions list
            non_functions.append(line)

    if current_function:
        # Store the final function
        functions.append(current_function)
    # Sort the functions alphabetically
    functions.sort()
    non_functions_dedup = [i[0] for i in groupby(non_functions)]

    # Write the sorted functions to a new file at the top of the file,
    # followed by the non-function lines, followed by any blank lines,
    # followed by any remaining non-function lines
    sorted_file_path = bashrc_path + "_sorted"
    with open(sorted_file_path, "w") as f:
        for function in functions:
            f.write(function)
        f.write("##### Non-function lines #####\n")
        for line in non_functions_dedup:
            f.write(line + "\n")

    print(f"Sorted functions written to {sorted_file_path}.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("bashrc_path", help="Path to the .bashrc file to sort.")
    args = parser.parse_args()
    sort_bashrc(args.bashrc_path)
