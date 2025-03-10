#!/bin/bash
#PBS -S /bin/bash
#PBS -l walltime=96:00:00
#PBS -q cpu15
#PBS -l nodes=1:ppn=40
#PBS -N vasp
#PBS -o my.out
#PBS -e my.err
#PBS -V


#intel
source /opt/intel/compilers_and_libraries_2018/linux/bin/compilervars.sh intel64
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2018.1.163/bin64/mpivars.sh


cd ${PBS_O_WORKDIR}

#vasp

    mpirun -np 40 /opt/software/vasp/vasp.5.4.4/vasp_std > log.dat #make sure the std path is correct


