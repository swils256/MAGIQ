#!/usr/bin/python

import numpy as np
import pdb


def autozoom(img, *karg):
    if len(karg) == 1:
        k1 = karg[0][0]
        k2 = karg[0][1]
        k = [k1, k2]
    elif len(karg) == 0:
        s1 = np.sum(img,0)
        s2 = np.sum(img,1)
        k1 = np.nonzero(s2)[0]
        k2 = np.nonzero(s1)[0]
        k = [k1, k2]
    else:
        print "Error using AUTOZOOM"
        return
    zoom = np.squeeze(img[:,k[1]])
    zoom = np.squeeze(zoom[k[0],:])
    return zoom, k
