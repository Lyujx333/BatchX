#!/bin/bash
#PBS -S /bin/bash
#PBS -l walltime=96:00:00
#PBS -q cpu15
#PBS -l nodes=1:ppn=40
#PBS -N vasp-TIFC
#PBS -o my.out
#PBS -e my.err
#PBS -V


#intel complie, just a example, need to modify
source /opt/intel/compilers_and_libraries_2018/linux/bin/compilervars.sh intel64
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2018.1.163/bin64/mpivars.sh


cd ${PBS_O_WORKDIR}

mkdir structures
cd structures
root_path=`pwd`
for i in $(seq -w 001 600)
do

   echo `pwd`
   mkdir 3RD.POSCAR.$i

   cp ../3RD.POSCAR.$i 3RD.POSCAR.$i/POSCAR
   cp ../INCAR ../KPOINTS ../POTCAR 3RD.POSCAR.$i

   cd 3RD.POSCAR.$i
   mpirun -np 80 /opt/software/vasp/vasp.5.4.4/vasp_std > log.dat #make sure this one work
	 
	 
cd ..
done






