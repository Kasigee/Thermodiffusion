Permissions for scripts need to be changed to enable them to be executable:
chmod +x run_GROMACS_FEP.sh
chmod +x template_files/qjob

To run the initial script:
./run_GROMACS_FEP.sh cation anion concentration(M) temperature(K) total_time(ns) FEP_direction(forward_or_bakward) replicate_number parallel boxsize(nm) force(yes/no)

for example
./run_GROMACS_FEP.sh Na Cl 0 300 2 salt forward 1 no 3 no



The key MD scripts:
- run_extension_GROMACS_FEP.sh can be used to extend out any trajectories.
- run_GROMACS_FEP_paired.sh for a forced ion pair (would need extensions to other salts other than the alkali halides in the thermo paper)
- run_extension_paired.sh to extend the forced ion pair beyond the initial time given
- other scripts used for analyses