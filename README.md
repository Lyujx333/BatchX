# BatchX
This is a program that can perform automated batch calculations of thermal conductivity based on DFT(VASP).Based on programs such as VASP, VASPKIT, ShengBTE, Phonopy, and thirdorder. It only requires inputting an unoptimized initial structure(POSCAR) and a command, and it can automatically invoke the user's PBS cluster for computation.

The First Way to use it is (A example in Solution1 Directory)
  Configure/Complie
    1.Modify the vasp40.sh & TIFC.sh & SIFC.sh & sh40.sh (these are pbs run vasp scirpt) to the vasp complie environment fit for you.
    2.A easier way is Replace it with the scirpt that you are using, but make sure all the filename no difference!!!
  Usage:
    1.Place ALL the raw structure that needs to be calculated in the POSCARs folder.(You don't need to worry about naming the poscar file)
    2.
