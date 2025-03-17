cd ../example;

source /home/xubiao/gromacs_201806/bin/GMXRC #load double precision gromacs2018
gmx_d pdb2gmx -f file.pdb -ter -merge all -ingh -missing # generate .top file
gmx_d grompp -v -f cg.mdp -c conf.gro -p topol.top -o protein-vacuum.tpr # generate .tpr file for energy minimization
gmx_d mdrun -v -deffnm protein-vacuum -c protein-vacuum.gro -s protein-vacuum.tpr # run double precision energy minimization

source /usr/local/gromacs/bin/GMXRC # load gromacs version 4.5.5 to generate gro files with high precision (24 decimals) from protein-vacuum.trr 
grompp_d -v -f cg.mdp -c conf.gro -p topol.top -o protein-vacuum_ref455.tpr -maxwarn 100 # generate the tpr file for gromacs version 4.5.5 
trjconv_d -f protein-vacuum.trr -s protein-vacuum_ref455.tpr  -ndec 24 -o test.gro -dump 28776 #take the final frame of the trajectory from energy minization to generate the high precision gro file 
source /home/xubiao/gromacs_201806/bin/GMXRC #load double precision gromacs2018
gmx_d grompp -v -f nm.mdp -c test.gro -p topol.top -o protein-vacuum-nma.tpr # use the high precision EM gro file to generate the tpr file for normal mode (NM) analysis
gmx_d mdrun -v -s protein-vacuum-nma.tpr -mtx protein-vacumm-nma.mtx # if the precision of protein-vacuum-nma.tpr is not high enough, the graidient will not equal to zero, and the NM will fail with negative eigenvalues. 
gmx_d nmeig -f protein-vacumm-nma.mtx -s protein-vacuum-nma -first 1 -last 400 

cd -;
#jupyter notebook --no-browser --ip=0.0.0.0 #
jupyter notebook calculate_intensity_from_charge_theory_and_example.py

cd ../example;
gmx_d nmtraj -s test.gro -v eigenvec.trr -o NMA-file.pdb -eignr 12 -phases 0 -temp 20000
gmx_d rmsf -f NMA-file.pdb -s conf.gro -o rmsf-file.xvg -res
