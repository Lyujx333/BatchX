#!/bin/bash
#PBS -S /bin/bash
#PBS -l walltime=100:00:00
#PBS -q cpu15
#PBS -l nodes=1:ppn=40
#PBS -N ShengBTE
#PBS -o my.out
#PBS -e my.err
#PBS -V


#intel complie, just a example, need to modify
source /opt/intel/compilers_and_libraries_2018/linux/bin/compilervars.sh intel64
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2018.1.163/bin64/mpivars.sh


#just a example


#ShengBTE

   mpirun -np 40 /path/to/your/ShengBTE/ShengBTE > log


