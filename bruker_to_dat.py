import datetime

# ---- Math Libraries ---- #
import scipy as sp
import scipy.signal as spsg

import numpy as np
import math
from pyfftw.interfaces import scipy_fftpack as fftw

# ---- Plotting Libraries ---- #
import matplotlib as mpl;
mpl.use("Qt5Agg")
from matplotlib.backends.backend_qt5agg import (
	FigureCanvasQTAgg as FigureCanvas,
	NavigationToolbar2QT as NavigationToolbar)
import matplotlib.pyplot as plt

# ---- Data Classes ---- #
from dataclasses import *

# ---- Pre-Processing Functions ---- #
from preproc import *

def writeDAT(bruker_fid, out_name, suffix=''):
	if not(suffix is ''):
		out_name = out_name + '_' + suffix + '.dat'
	else:
		out_name = out_name + '.dat'

	now = datetime.datetime.now()
	
	data_real = np.real(bruker_fid.signal)
	data_imag = -np.imag(bruker_fid.signal)

	o = open(out_name, 'w')
	o.write(str(np.size(data_real) + np.size(data_imag)) + '\n')
	o.write('1\n')
	o.write(str(bruker_fid.DigDw/1000.) + '\n')
	o.write(str(bruker_fid.FrqRef) + '\n')
	o.write('1\n')
	o.write(bruker_fid.file_dir + '/fid\n')
	o.write(now.strftime("%Y %m %d") + '\n')
	o.write('MachS=0 ConvS=' + str(bruker_fid.ConvS) + ' ')
	o.write('V1=' + str(bruker_fid.VoxArrSize[0]) + ' ' + 'V2=' + str(bruker_fid.VoxArrSize[1]) + ' ' + 'V3=' + str(bruker_fid.VoxArrSize[2]) + '\n')
	o.write('TE=' + str(bruker_fid.EchoTime / 1000.) + ' s ')
	o.write('TR=' + str(bruker_fid.RepetitionTime / 1000.) + ' s ')
	o.write('P1=' + str(bruker_fid.VoxArrPosition[0]) + ' P2=' + str(bruker_fid.VoxArrPosition[1]) + ' P3=' + str(bruker_fid.VoxArrPosition[2]) + ' Gain=' + str(bruker_fid.EncChanScaling) + '\n')
	o.write('SIMULTANEOUS\n0.0\n')
	o.write('EMPTY\n')

	for i, p in enumerate(bruker_fid.signal):
		o.write(str(data_real[i]) + '\n')
		o.write(str(data_imag[i]) + '\n')
	o.close()
unsup_file = BrukerFID(raw_input('Unsup file: '))
sup_file   = BrukerFID(raw_input('Sup file: '))
out_name   = raw_input('Output file: ')

print ''
quecc_points = int(raw_input('QUECC points: '))

# save unsup file as dat
writeDAT(unsup_file, out_name, 'uns')

# save raw file as dat
writeDAT(sup_file, out_name, 'raw')

# apply quecc
sup_file.signal = quecc(sup_file.signal, unsup_file.signal, getWaterLW(unsup_file.signal, unsup_file.t), sup_file.t, quecc_points)

# save as dat
writeDAT(sup_file, out_name)