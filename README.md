
```markdown
# BatchX

This is a program designed to perform automated batch calculations of thermal conductivity based on DFT (VASP) and BTE.
It integrates tools such as VASP, VASPKIT, ShengBTE, Phonopy, and thirdorder.
BatchX requires only an unoptimized initial structure (POSCAR) and a command to automatically invoke the user's PBS cluster for computation.

---

## First Way to Use It

### Configure/Compile
1. **Modify the PBS Scripts**: Update `vasp40.sh`, `TIFC.sh`, `SIFC.sh`, and `sh40.sh` (these are PBS scripts to run VASP) to match your VASP compilation environment.
2. **Alternative**: Replace these scripts with your own VASP scripts, ensuring the filenames remain identical.

### Usage
1. Place all raw structures requiring calculation into the `POSCARs` folder. (Name the POSCAR files in any way.)
2. Run the program using `bash` or `nohup` (for automated background processing) with a command like:

   ```bash
   bash BatchX1_template.sh > logfile.log 2>&1 & echo $!
   ```
   or
   ```bash
   nohup bash BatchX1_template.sh > logfile.log 2>&1 & echo $!
   ```
   if not succeed, the problem may refer to the full "BatchX.sh" path used in nohup, try this one
   ```
   nohup bash path/to/your/current/directory/BatchX1_template.sh > logfile.log 2>&1 & echo $!
   ```
   when you want to check/stop the task situation, use
   ```
   ps aux | grep {your username} 
   ```
   use kill + {pid} to terminate it.

### Configure/Compile Notes
- Ensure the current Python environment supports `phonopy` and `thirdorder`.
- Confirm that `vaspkit` can be called directly in the current environment.
- Edit `Config.sh` according to the provided guide.
- Run:
   ```bash
   bash configure.sh
   ```
  This generates `BatchX1_template.sh` tailored to your setup, along with a `template` directory. You can copy this directory for each project.
- Execute the `bash` or `nohup` command in the directory where `BatchX1.sh` exists.

### Usage Notes
1. Do **not** place `POSCAR` or `POTCAR` files in the `pr` folder.
2. All material structures to be calculated must be placed in the `POSCARs` folder as individual files. Naming is not required, but avoid duplicate names.
3. BatchX automatically identifies and classifies materials during calculation.
4. During optimization and self-consistent calculations, K-point settings use a `0.2` accuracy Monkhorst-Pack scheme via VASPKIT.
5. Supercell rules follow a reasonable empirical method, reflected in filenames (e.g., `SIFC-222`, `TIFC-333`).

---

## Additional Commands
Refer to the file `readme_first` for more command details.
