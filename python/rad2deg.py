# author: jumpei takami 
# > python rad2deg.py [input] [output]
# [data type] input:float(4byte) / ouput:float(4byte)

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
        res = res.astype('int16')
        res = res.byteswap()
        res.tofile(argvs[2], sep="", format="% d")
