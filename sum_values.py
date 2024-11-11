import sys


def sum_values(filename, temperature):
    # Flags to decide when to start and stop parsing lines
    start_parsing = False
    stop_parsing = False
    
    # Initialize sums
    s_A_sum = 0
    s_A_error_sum = 0
    s_B_sum = 0
    s_B_error_sum = 0

    with open(filename, 'r') as file:
        for line in file:
            if "Final results in kJ/mol:" in line:
                stop_parsing = True

            if start_parsing and not stop_parsing:
                columns = line.split()
                if len(columns) < 8 or not columns[4].replace('.', '', 1).replace('-', '', 1).isdigit():
                    continue
#if len(columns) < 8:  # Ensure that there are enough columns
#                    continue
                s_A_sum += float(columns[4])*1.380649E-23*temperature*6.02214076E23/1000
                s_A_error_sum += float(columns[5])**2*1.380649E-23*temperature*6.02214076E23/1000
                s_B_sum += float(columns[6])*1.380649E-23*temperature*6.02214076E23/1000
                s_B_error_sum += float(columns[7])**2*1.380649E-23*temperature*6.02214076E23/1000

            if "Detailed results in kT (see help for explanation):" in line:
                start_parsing = True
                continue  # Skip the current line and move to the next one
                continue  # Skip the current line and move to the next one
                continue  # Skip the current line and move to the next one

    # Convert squared error sums to standard deviations
    s_A_error_sum = s_A_error_sum**0.5
    s_B_error_sum = s_B_error_sum**0.5

    print(f"s_A Sum: {s_A_sum} ± {s_A_error_sum} s_B Sum: {s_B_sum} ± {s_B_error_sum}")
    #print(f"s_B Sum: {s_B_sum} ± {s_B_error_sum}"


#if __name__ == "__main__":
#    sum_values("bar_analysis.dat")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python sum_values.py <filename> <temperature>")
        sys.exit(1)
    filename = sys.argv[1]
    temperature = float(sys.argv[2])
    sum_values(filename, temperature)
