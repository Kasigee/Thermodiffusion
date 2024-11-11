#!/usr/bin/env python3
length=2
ion_at='CL'
type='anion'
water_atom='H'
water_atom2='O'
lambda_num=0
forback=''
import MDAnalysis as mda
import solvation_analysis
from MDAnalysis.analysis import rdf
from multiprocessing import Pool
import matplotlib.pyplot as plt
import sys
import os
import multiprocessing
import glob
from functools import partial

# Initialize a figure for the RDF plots
rdf_figure = plt.figure()

# Initialize lists to store the rdf data
rdf_data = []
rdf_distances = []


# Initialize empty lists for data storage
coordination_numbers = []
four_shell_percentages = []
five_shell_percentages = []
six_shell_percentages = []
seven_shell_percentages = []
eight_shell_percentages = []
residence_times_cutoff = []
residence_times_fit = []
radii = []

ion='CL'
print("Loading Trajectory")
#u = mda.Universe(f"{ion}_water_fixed.gro", f"Lambda_{lambda_num}/Production_MD{forback}/md{lambda_num}.trr", in_memory=True)
grofiles=glob.glob(f"*_water_fixed.gro")
grofile=grofiles[0]
u = mda.Universe(grofile, f"Lambda_{lambda_num}/Production_MD{forback}/md{lambda_num}.trr")
print("Trajectory loaded")



def process_segment(u,start_frame, end_frame):
    #ion='CL'
    #print("Loading Trajectory")
    #u = mda.Universe(f"{ion}_water_fixed.gro", f"Lambda_{lambda_num}/Production_MD{forback}/md{lambda_num}.trr", in_memory=True)
    #u = mda.Universe(f"{ion}_water_fixed.gro", f"Lambda_{lambda_num}/Production_MD{forback}/md{lambda_num}.trr")
    #print("Trajectroy loaded")
    ion='FILLION'
    ion_atoms = u.atoms.select_atoms(f"resname {ion}")
    water_at = u.atoms.select_atoms(f"type {water_atom}")

    # instantiate solute
    from solvation_analysis.solute import Solute
    solute = Solute.from_atoms(ion_atoms, {f"{water_atom}": water_at }, solute_name=f"{ion_at}")
    solute = Solute.from_atoms(
        ion_atoms,
        {water_atom: water_at},
        solute_name=ion,
        radii={f"{water_atom}":3.15}
    )
    print(f"running solute from {start_frame} to {end_frame}")
    solute.run(start=start_frame, stop=end_frame)

    # Define AtomGroups for which to calculate RDF
    ag1 = u.select_atoms(f'resname {ion_at}')  # Select your atoms of interest
    ag2 = u.select_atoms(f'type {water_atom}')  # Select your atoms of interest
    #     ag3 = u.select_atoms(f'type {water_atom2}')  # Select your atoms of interest

    # Calculate RDF
    r = rdf.InterRDF(ag1, ag2)
    print(f"running rdf from {start_frame} to {end_frame}")
    r.run(start=start_frame, stop=end_frame)

    #     # Calculate RDF
    #     r2 = rdf.InterRDF(ag3, ag2)
    #     r2.run()
        
    # Store RDF data
    rdf_data.append(r.rdf)
    rdf_distances.append(r.bins)
        
    #     # Store RDF data
    #     rdf2_data.append(r2.rdf)
    #     rdf2_distances.append(r2.bins)
        
        # inspect the coordination numbers
    solute.coordination.coordination_numbers
    CN=solute.coordination.coordination_numbers

    #     print(solute.coordination.coordination_numbers)

    # inspect the pairing percentages
    solute.pairing.solvent_pairing

    # inspect coordination numbers by frame
    solute.coordination.coordination_numbers_by_frame
    solute.speciation.speciation_fraction.head(8)

    # calculate # of shells with 4 BN and any number of FEC or PF6
    #     solute.speciation.calculate_shell_fraction({water_atom: 5})
    four_shell_Percent=solute.speciation.calculate_shell_fraction({water_atom: 4})
    five_shell_Percent=solute.speciation.calculate_shell_fraction({water_atom: 5})
    six_shell_Percent=solute.speciation.calculate_shell_fraction({water_atom: 6})
    seven_shell_Percent=solute.speciation.calculate_shell_fraction({water_atom: 7})
    eight_shell_Percent=solute.speciation.calculate_shell_fraction({water_atom: 8})

    from solvation_analysis.residence import Residence

    # warnings are expected
    residence = Residence.from_solute(solute)
    #     residence2 = Residence.from_solute(solvent)


    solute.residence = residence
    solute.residence
        
    # Append data to the lists
    coordination_numbers.append(CN)
    four_shell_percentages.append(four_shell_Percent)
    five_shell_percentages.append(five_shell_Percent)
    six_shell_percentages.append(six_shell_Percent)
    seven_shell_percentages.append(seven_shell_Percent)
    eight_shell_percentages.append(eight_shell_Percent)
    residence_times_cutoff.append(residence.residence_times_cutoff)
    residence_times_fit.append(residence.residence_times_fit)
    radii.append(solute.radii)
    print(start_frame,end_frame,ion_at,"CN:",CN,"5_shell_%:",five_shell_Percent,"RT:",residence.residence_times_cutoff,residence.residence_times_fit,solute.radii)


# Divide the trajectory into segments
#num_frames = 20000
num_frames = TOTALFRAMES
num_segments = 5
frames_per_segment = num_frames // num_segments

segments = [(u,i*frames_per_segment, (i+1)*frames_per_segment) for i in range(num_segments)]

from tqdm import tqdm
print("Starting")
with Pool(8) as pool:
    results2 = list(tqdm(pool.starmap(process_segment, segments), total=len(segments)))

# Combine results from all segments
# ...
# Assuming results is a list of tuples with (coord_nums, residence_times) from each segment
all_coord_nums = []
all_residence_times = []

for coord_nums, residence_times in results2:
    all_coord_nums.extend(coord_nums)
    all_residence_times.extend(residence_times)

# all_coord_nums and all_residence_times now contain combined data from all segments
print("Combined Coordination Numbers:", all_coord_nums)
print("Combined Residence Times:", all_residence_times)

