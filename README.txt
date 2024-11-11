**The relevant files for rerunning any of these FEP calculations are located in the folder "FEP". Within that folder the following commands are relevant:**

Permissions for scripts need to be changed to enable them to be executable:
chmod +x run_GROMACS_FEP.sh
chmod +x template_files/qjob

To run the initial script, edit the script to use your username and use the following format:
./run_GROMACS_FEP.sh cation anion concentration(M) temperature(K) total_time(ns) FEP_direction(forward_or_bakward) replicate_number parallel boxsize(nm) force(yes/no)

for example
./run_GROMACS_FEP.sh Na Cl 0 300 2 salt forward 1 no 3 no



The key MD scripts:
- run_extension_GROMACS_FEP.sh can be used to extend out any trajectories.
- run_GROMACS_FEP_paired.sh for a forced ion pair (would need extensions to other salts other than the alkali halides in the thermo paper)
- run_extension_paired.sh to extend the forced ion pair beyond the initial time given
- other scripts used for analyses



**The Entropy model developed for this paper and displayed in Figure 5 is located in the jupyter notebook "Entropy_model.ipynb." This notebook includes all the parameters, etc., and it is all within one script.**
