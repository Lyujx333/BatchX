import matplotlib.pyplot as plt
from pymatgen.io.vasp.outputs import Vasprun
from pymatgen.electronic_structure.plotter import BSDOSPlotter,BSPlotter,BSPlotterProjected,DosPlotter

# read vasprun.xml，get band and dos information
bs_vasprun = Vasprun("vasprun.xml",parse_projected_eigen=True,parse_potcar_file=False)
bs_data = bs_vasprun.get_band_structure(line_mode=True)

dos_vasprun=Vasprun("vasprun.xml")
dos_data=dos_vasprun.complete_dos

# set figure parameters, draw figure
banddos_fig = BSDOSPlotter(bs_projection='elements', dos_projection='elements', vb_energy_range=5, fixed_cb_energy=5,fig_size=(16,12),font='Arial',bs_legend=None)
banddos_fig.get_plot(bs=bs_data, dos=dos_data)
plt.savefig('banddos_fig.png')