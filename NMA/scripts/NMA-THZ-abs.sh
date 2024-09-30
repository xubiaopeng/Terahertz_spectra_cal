source /home/xubiao/gromacs_201806/bin/GMXRC
gmx_d make_ndx -f file.pdb -o index.ndx
gmx_d editconf -f file.pdb -o file_ha.pdb -n index.ndx
gmx_d pdb2gmx -f file.pdb -ter -merge all -ingh -missing
gmx_d grompp -v -f cg.mdp -c conf.gro -p topol.top -o protein-vacuum.tpr
gmx_d mdrun -v -deffnm protein-vacuum -c protein-vacuum.gro -s protein-vacuum.tpr

source /usr/local/gromacs/bin/GMXRC
grompp_d -v -f cg.mdp -c conf.gro -p topol.top -o protein-vacuum_ref455.tpr -maxwarn 100
trjconv_d -f protein-vacuum.trr -s protein-vacuum_ref455.tpr  -ndec 24 -o test.gro -dump 28776
source /home/xubiao/gromacs_201806/bin/GMXRC
gmx_d grompp -v -f nm.mdp -c test.gro -p topol.top -o protein-vacuum-nma.tpr
gmx_d mdrun -v -s protein-vacuum-nma.tpr -mtx protein-vacumm-nma.mtx
gmx_d nmeig -f protein-vacumm-nma.mtx -s protein-vacuum-nma -first 1 -last 400

jupyter notebook --no-browser --ip=0.0.0.0


gmx_d nmtraj -s test.gro -v eigenvec.trr -o NMA-file.pdb -eignr 12 -phases 0 -temp 20000
gmx_d rmsf -f NMA-file.pdb -s conf.gro -o rmsf-file.xvg -res
