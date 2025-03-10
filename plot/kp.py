import numpy as np
import matplotlib.pyplot as plt
f=np.loadtxt('BTE.KappaTensorVsT_RTA')
#f.size
#f.shape
#f
print(f.size)
print(f.shape)
#print(f)
plt.figure(figsize=(8,6))
#plt.grid()
plt.plot(f[1:,0],f[1:,1],"-o",ms=6,label='Lattice thermal conductivity')
plt.xlabel('Temperature (K)',size=16)
plt.ylabel('$\kappa_l$ (Wm$^{-1}$K$^{-1}$)',size=16)
plt.legend(loc=1,fontsize=8)
#plt.show()
plt.savefig('KappavsT_RTA-1.png',dpi=500)