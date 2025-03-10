#!/bin/bash
#PBS -S /bin/bash
#PBS -l walltime=96:00:00
#PBS -q cpu15
#PBS -l nodes=1:ppn=40
#PBS -N vasp-SIFC
#PBS -o my.out
#PBS -e my.err
#PBS -V


#intel
source /opt/intel/compilers_and_libraries_2018/linux/bin/compilervars.sh intel64
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2018.1.163/bin64/mpivars.sh


cd ${PBS_O_WORKDIR}

mkdir structures
cd structures
for i in $(seq -w 01 04)
 do
    mkdir $i
    cp ../POSCAR-0$i $i/POSCAR
    cp ../INCAR ../KPOINTS ../POTCAR $i/
	cd $i
	
    mpirun -np 40 /opt/software/vasp/vasp.5.4.4/vasp_std > log.dat #make sure this one work
   cd ..	
  done  


#phonopy -d --dim="3 3 1"
#phonopy -f structures/{01..04}/vasprun.xml 
#phonopy -p -c POSCAR band.conf -s
#phonopy-bandplot --gnuplot > phonon.dat
#phonopy -p -c POSCAR band2.conf
#vaspkit--------73-------739

