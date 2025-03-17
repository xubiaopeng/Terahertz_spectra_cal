# add ions to neutralize the system so that the PME can be safely used
grep -v HOH 4yfq_apo.pdb > 4yfq_clean.pdb # remove HOH
gmx_d pdb2gmx -f 4yfq_clean.pdb -o 4yfq_processed.gro -water spce
gmx_d editconf -f 4yfq_processed.gro -o 4yfq_newbox.gro -c -d 1.0 -bt cubic
gmx_d solvate -cp 4yfq_newbox.gro -cs spc216.gro -o 4yfq_solv.gro -p topol.top
gmx_d grompp -f ions.mdp -c 4yfq_solv.gro -p topol.top -o ions.tpr
gmx_d genion -s ions.tpr -o 4yfq_solv_ions.gro -p topol.top -pname SOD -nname CL -neutral # replace SOL with ions

# remove additional water molecules for MD in vaccum
grep -v HW1 4yfq_solv_ions.gro > 4yfq_1.gro
grep -v HW2 4yfq_1.gro > 4yfq_2.gro
grep -v OW 4yfq_2.gro > 4yfq_new.gro

# MD simulation in vaccumm
gmx_d grompp -f minim.mdp -c 4yfq_new.gro -p topol.top -o em.tpr
gmx_d mdrun -v -deffnm em
gmx_d grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr  #2fs * 50000 = 100 ps
nohup gmx_d mdrun -deffnm nvt -v &
gmx_d grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr  ##2fs * 50000 = 100 ps
gmx_d  mdrun -deffnm npt -v

gmx_d grompp -f md.mdp -c npt.gro -p topol.top -o md_0_1.tpr             #0.001ps * 300000000 = 300 ns
nohup gmx_d mdrun -deffnm md_0_1 -nt 1 -v &

# take the last 100ns trajectory and make alignment
gmx_mpi trjconv -s md_0_1.tpr -f md_0_1.trr -b 200000 -e 300000 -o md100-final.trr
gmx_mpi trjconv -s md_300.tpr -f md100-final.trr -o md100-final-aligned.trr -fit rot+trans

# calculate the dipole momentum and corrlation function
gmx_mpi dipoles -f md100-final-aligned.trr -s md_300.tpr -o 4yfq-1-dip100-final.xvg -c 4yfq-1-acf100-final.xvg -P 1 -corr mol

