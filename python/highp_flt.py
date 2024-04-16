# author: Jumpei Takami, Synspective Inc.
# date: 2021/10/09
# ref1: http://labs.eecs.tottori-u.ac.jp/sd/Member/oyamada/OpenCV/html/py_tutorials/py_imgproc/py_transforms/py_fourier_transform/py_fourier_transform.html
# ref2: https://watlab-blog.com/2020/03/22/2d-fft/

def Genwriteb(smat, filename):
	print(smat.dtype)
	smat.byteswap().tofile(filename,sep="", format="%f")
	
def Gen_cpx64b_read(filename, n0,n1):
	f = open(filename,'rb')
	X = np.fromfile(f,dtype = np.complex64, count = -1)
	f.close()
	X = X.byteswap()
	X.shape = (n0,n1)
	return X
			
def lowpflt2d(s,d1,d2,Lmax):
	num1 = s.shape[0]
	num2 = s.shape[1]
	fftnum1 = np.power(2,int(np.ceil(np.log2(num1))))
	fftnum2 = np.power(2,int(np.ceil(np.log2(num2))))
	L1 = d1*fftnum1
	L2 = d2*fftnum2
	dn1 = 1./L1
	dn2 = 1./L2
	N1 = 1./d1
	N2 = 1./d2
	freq1 = (np.arange(fftnum1)-fftnum1/2)*dn1
	freq1.shape = (fftnum1,1)
	freq2 = (np.arange(fftnum2)-fftnum2/2)*dn2	
	ni = 1./Lmax
	print(ni)
	freq1mat = npml.repmat(freq1,1,fftnum2)
	freq2mat = npml.repmat(freq2,fftnum1,1)
	dist = np.sqrt(np.power(freq1mat,2)+np.power(freq2mat,2))
	del freq1mat
	del freq2mat
	w_mat = 1./2.*(1.+np.cos(math.pi*dist/ni))
	w_mat[np.where(dist/ni>1.)] = 0.0
	del dist
	fs = np.fft.fft2(s,s=[fftnum1,fftnum2])
	shft_w = np.fft.ifftshift(w_mat)
	del w_mat
	flt_fs  = fs*shft_w
	flt_s = np.fft.ifft2(flt_fs,s=[fftnum1,fftnum2])
	del flt_fs
	del s
	flt_s = flt_s[0:num1,0:num2]
	return np.array(flt_s,dtype=np.complex64)

if __name__ == '__main__':
	import numpy as np
	import sys
	from numpy import matlib as npml
	import math
	argvs = sys.argv
	argc = len(argvs)
	if (argc != 8):
		print("input seven parameters!")
		print("1:interferometric phase data name")
		print("2:pixel number of the range direction")
		print("3:pixel number of the azimuth direction")
		print("4:pixel spacing of the range direction [m]")
		print("5:pixel spacing of the azimuth direction [m]")
		print("6:maximum wavelength to filter [m]")
		print("7:output file path")
		sys.exit(1)
	else:
		print(argvs)
		phase_mat = Gen_cpx64b_read(argvs[1],int(argvs[3]),int(argvs[2]))
		d1 = float(argvs[5])
		d2 = float(argvs[4])
		Lmax = float(argvs[6])
		
		atm_phase = lowpflt2d(phase_mat,d1,d2,Lmax)		
		corr_mat = phase_mat*np.conj(atm_phase/np.absolute(atm_phase))
		del atm_phase
		del phase_mat
		Genwriteb(corr_mat,argvs[7])
		print("the process finished successfully")
		sys.exit(0)
	

