def Genwriteb(smat, filename):
	print(smat.dtype)
	smat.byteswap().tofile(filename,sep="", format="%f")

	
def Gen_flt32b_read(filename, n0,n1):
	f = open(filename,'rb')
	X = np.fromfile(f,dtype = np.float32, count = -1)
	f.close()
	X = X.byteswap()
	X.shape = (n0,n1)
	return X

if __name__ == '__main__':
	import numpy as np
	import sys
	from numpy import matlib as npml
	import math
	argvs = sys.argv
	argc = len(argvs)
	if (argc != 6):
		print('input six parameters!')
		print('1:power data name')
		print('2:pixel number of the range direction')
		print('3:pixel number of the azimuth direction')
		print('4:calibration Factor')
		print('5:output')
	else:
		power_mat = Gen_flt32b_read(argvs[1],int(argvs[3]),int(argvs[2]))
		calFactor = float(argvs[4])
		power_mat[power_mat == 0] = 1
		db = 10 * np.log10(power_mat) + calFactor
		db[db == calFactor] = 0
		Genwriteb(db,argvs[5])
		print("the process finished successfully")