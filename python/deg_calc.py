# author: Jumpei Takami
# > python deg__calc.py [input] [output]
# [data type] input:gc_map u float(4byte) / ouput:byte(1byte) 

if __name__ == '__main__':
        import numpy as np
        import sys
        import math
        import gc
        
        argvs = sys.argv
        f = open(argvs[1],'rb')
        X = np.fromfile(f,dtype = np.float32, count = -1)
        f.close()
        
        X = X.byteswap()
        res = np.round(np.rad2deg(X))
        del X
        gc.collect()
        res = np.absolute(res)
        #res[res == 90] = 0
        res = res.astype('int16')
        res = res.byteswap()
        res.tofile(argvs[2], sep="", format="% d")
