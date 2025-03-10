from pymatgen.io.vasp import Vasprun
from pymatgen.electronic_structure.plotter import DosPlotter
import matplotlib.pyplot as plt

v = Vasprun('vasprun.xml')
cdos = v.complete_dos
dos = cdos.get_spd_dos()
plotter = DosPlotter()
plotter.add_dos_dict(dos)
plotter.show(xlim=[-15, 5], ylim=[0, 4])
plt.savefig('spd_dos.png')

