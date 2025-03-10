# BatchX
This is a program that can perform automated batch calculations of thermal conductivity based on DFT(VASP).Based on programs such as VASP, VASPKIT, ShengBTE, Phonopy, and thirdorder. It only requires inputting an unoptimized initial structure(POSCAR) and a command, and it can automatically invoke the user's PBS cluster for computation.

The First Way to use it is (A example in Solution1 Directory)
  Configure/Complie
    1.Modify the vasp40.sh & TIFC.sh & SIFC.sh & sh40.sh (these are pbs run vasp scirpt) to the vasp complie environment fit for you.
    2.A easier way is Replace it with the scirpt that you are using, but make sure all the filename no difference!!!
  Usage:
    1.Place ALL the raw structure that needs to be calculated in the POSCARs folder.(You don't need to worry about naming the poscar file)
    2.Use bash or nohup(automated background processing), command like "bash BatchX1_template.sh" & ""
  Configure/Complie Attention Plzzz:
    Make sure that the current python environment can run phonopy and thirdorder!!!
    Make sure the vaspkit can be called directly in the current environment!!!
    Edit the Config.sh according to the guide.
    Then bash configure.sh.And you will get the BatchX1_template.sh which is suit for you.
    Also you will get a "template" directory,you can copy this one for your every project every times. 
    Run bash/nohup command in the directory BatchX1.sh exsited!
  Usage Attention Plzzz:
    1. Do not place POSCAR and POTCAR files in the pr folder.
    2. All the material structures that need to be calculated are placed in POSCARs in the form of a file,
    which does not need to be named, but does not have the same name.
    3. BatchX can automatically identify and classify the material as it is calculating.
    4. In the optimization and self-consistent period, the KPOINT Setting is performed with auccracy 0.2 Monkhorst-Pack Scheme through VASPKIT.
    5. SuperCell Rule based on reasonable empirical method, and it will show on the fileneme, like SIFC-222 TIFC-333.
  commands like:
    nohup bash /home/user1/BatchProject1/BatchX1_template.sh > logfile.log 2>&1 & echo $!
    bash BatchX1_template > logfile.log 2>&1 & echo $!
