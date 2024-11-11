def remove_duplicates_and_fix_lines(file_lines):
    # Process file lines, applying specific rules for columns and removing duplicates
    seen_timesteps = set()
    corrected_lines = []
    for line in file_lines[33:]:  # Skip header lines
        parts = line.strip().split()
        if len(parts) < 10 or parts[0] in seen_timesteps:
            continue  # Skip malformed lines or duplicates based on timestep
        if parts[1] == parts[4] == parts[5] == parts[7] == "0.0000000" and float(parts[2]) > 100:
            seen_timesteps.add(parts[0])
            corrected_lines.append(line)
    return file_lines[:33] + corrected_lines  # Return header + corrected lines

def fix_glitched_file_v8(input_filepath, output_filepath):
    with open(input_filepath, 'r') as file:
        file_lines = file.readlines()

    corrected_lines = remove_duplicates_and_fix_lines(file_lines)

    with open(output_filepath, 'w') as file:
        file.writelines(corrected_lines)

# Example usage
input_filepath = 'NAIO_0M_300K_2ns_salt/Lambda_20/Production_MD_backward/md20.xvg'  # Adjust this to your input file's location
output_filepath = 'NAIO_0M_300K_2ns_salt/Lambda_20/Production_MD_backward/md20_fixed2.xvg'  # Adjust this to your desired output file's location

fix_glitched_file_v8(input_filepath, output_filepath)

