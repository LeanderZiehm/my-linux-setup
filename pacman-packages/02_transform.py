import json


def main():
    transform_extracted_pacman_packages("./packages_data/extracted_all_installed_packages.txt","./packages_data/transformed_all_installed_packages.json")
    transform_extracted_pacman_packages("./packages_data/extracted_explicitly_installed_packages.txt","./packages_data/transformed_explicitly_installed_packages.json")


def transform_extracted_pacman_packages(input_path:str,output_path:str):

    packages = []
    current_pkg = {}
    with open(input_path) as f:
        for line in f:
            line = line.strip()
            if not line:  # empty line → end of package block
                if current_pkg:
                    packages.append(current_pkg)
                    current_pkg = {}
                continue
            if "  : " in line:
                key, value = line.split("  : ", 1)
                key = key.strip().replace(" ", "_").lower()
                value = value.strip()
                current_pkg[key] = value

    # add last package if file doesn't end with a newline
    if current_pkg:
        packages.append(current_pkg)

    with open(output_path, "w") as f:
        json.dump(packages, f, indent=2)



if __name__ == "__main__":
    main()