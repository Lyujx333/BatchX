import numpy as np
import matplotlib.pyplot as plt
f=np.loadtxt('BTE.KappaTensorVsT_sg')
plt.figure(figsize=(8,6))
#plt.grid()
plt.plot(f[1:,0],f[1:,1],"-o",ms=6,label='Lattice thermal conductivity\n per unit mean free path\n in the small grain limit')
plt.xlabel('Temperature (K)',size=16)
plt.ylabel('$\kappa_l$/$\lambda$ (Wm$^{-1}$K$^{-1}$nm$^{-1}$)',size=16)
plt.legend(loc=5,fontsize=8)
#plt.show()
plt.savefig('Kappa_lambdavsT_sg-1.png',dpi=500)
