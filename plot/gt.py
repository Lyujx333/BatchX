import numpy as np
import matplotlib.pyplot as plt
f=np.loadtxt('BTE.gruneisenVsT_total')
#f
plt.figure(figsize=(8,6))
#plt.grid()
#plt.plot(f[:,0],f[:,1],'-o',ms=6) #start from 50 K
plt.plot(f[1:,0],f[1:,1],'-o',ms=6,label='Total Gruneisen parameter\n (weighted sum of the\n mode contributions) as\n the function of temp')
plt.xlabel('Temperature (K)',size=16)
plt.ylabel('Total Gruneisen parameter ($\gamma$)',size=16)
plt.legend(loc=5,fontsize=8)
#plt.show()
plt.savefig('GrunvsT.png',dpi=500)