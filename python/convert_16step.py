# author: Jumpei Takami, Synspective Inc.
# > python convert_16step.py 
# [dtype] input:float(4byte) / ouput:byte(1byte)

if __name__ == '__main__':

        import numpy as np
        import sys
        from numpy import matlib as npml
        import math

        argvs = sys.argv
        f = open(argvs[1],'rb')
        X = np.fromfile(f,dtype = np.float32, count = -1)
        f.close()

        X = X.byteswap()
        d_phi = (2*math.pi)/16
        X[X==0] = -10*math.pi/8
        res = np.floor_divide(X, d_phi) + 9
        # nodata
        res[res<0] = 0
        res[(res>=17) & (res < 255)] = 16
        res[(res>0) & (res<1)] = 1
        res = res.astype('uint8')
        res.tofile(argvs[2], sep="", format="%d")
