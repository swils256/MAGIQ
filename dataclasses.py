# DATA OBJECTS USED IN PINTS AND BARSTOOL

# ---- System Libraries ---- #
import sys
import os
import datetime as dt
import time
import glob
import platform
import struct

from PyQt5 import QtCore, QtGui, QtWidgets, uic
import subprocess as subproc

import multiprocessing as mp

from collections import defaultdict

from itertools import groupby

# ---- Math Libraries ---- #
import scipy as sp
import scipy.signal as spsg

import numpy as np
import math
from pyfftw.interfaces import scipy_fftpack as fftw

# ---- Data Classes ---- #
class Experiment:
	def __init__(self):

		# General Experiment Information
		self.name = ''
		self.author = ''
		self.date = ''
		self.description = ''
		self.type = ''

		# Metabolite Information
		self.insysfiles = []
		self.metabolites = []

		# Experimental Parameters Information
		self.b0 = 297.2				# default b0 is 7T
		self.obs_iso = '1H'			# proton spectroscopy by default
		self.acq_time = 341E-3		# default acq_time is 341 msec
		self.dwell_time = 0.000166 	# default dwell_time is 0.000166
		self.TE = 0					# echo time

		# Experimental Parameters for Simulation
		self.A_90s = []										# amplitudes for pulse calibration
		self.A_180s = []
		self.RF_OFFSET = 4.7								# default is 4.7 ppm (center frequency of excitation pulse)
		self.inpulse90file = 'pints/pulses/P10.P10NORM.pta'		# RF pulse files
		self.inpulse180file = 'pints/pulses/HS4_R25.HS4_R25.pta'
		self.PULSE_90_LENGTH = 0							# RF pulse lengths
		self.PULSE_180_LENGTH = 0
		self.A_180 = 1.0									# To store calibrated RF amplitudes
		self.A_90 = 1.0
		self.fudge_factor = 0								# SLR fudge factor
		self.tolppm = 0.0015								# binning parameters
		self.tolpha = 50.0
		self.ppmlo = 0.0
		self.ppmhi = 10.0

		# Experimental Data
		self.data = self.tree()

		# Relationships for .CST and .GES Files
		self.shift_linked_metabs = []
		self.amp_linked_metabs = []
		self.cst_groups = []

		self.LW_limit = 15
		self.LW_linkall = False

		self.splitNAA = False

	def tree(self): return defaultdict(self.tree)

	def getMetabolitesNum(self):
		return sp.size(metabolites)

	def getGyratio(self):
		if self.obs_iso == '1H':
			gyratio = 42576.0
		elif self.obs_iso == '13C':
			gyratio = 67262.0
		elif self.obs_iso == '19F':
			gyratio = 251662.0
		elif self.obs_iso == '23Na':
			gyratio = 70761.0
		elif self.obs_iso == '31P':
			gyratio = 108291.0

		return gyratio

	def getTime(self):
		return sp.arange(0, self.acq_time, self.dwell_time)

	def getFs(self):
		return 1/self.dwell_time

class Pulse:
	def __init__(self, inpulsefile, pulse_length):

		self.waveform = []

		# read pulse (magnitude of pulse is in mT)
		siemens_file = open(inpulsefile, 'r')
		for line in siemens_file:
			if "AMPINT" in line:
				self.AMPINT = float(line.split('\t')[1])
			elif "POWERINT" in line:
				self.POWERINT = float(line.split('\t')[1])
			elif "ABSINT" in line:
				self.ABSINT = float(line.split('\t')[1])
			elif ";" in line:
				mag = float(line.split('\t')[0]) * 1E-3
				phase = float(line.split('\t')[1])
				self.waveform.append(mag * np.exp(1j * phase))
		self.waveform.pop(-1) # delete last element
		self.waveform = np.array(self.waveform)
		siemens_file.close()

		# define paramaters
		self.pulsestep = pulse_length / len(self.waveform)

class RefSignal:
	def __init__(self, signal, n, fs, t, b0):
		self.n = n
		self.signal = signal[0:n]
		self.fs = fs
		self.t = t
		self.b0 = b0

class Metabolite:
	def __init__(self):

		# General Metabolite Information
		self.name = ''

		# Metabolite Data
		self.peak = []
		self.ppm = []		# i.e. shift
		self.width_L = []
		self.area = []		# i.e. amplitude
		self.phase = []
		self.phase = []
		self.delay = []
		self.width_G = []
		
		self.crlb = []
		
		# Metabolite Properties
		self.A_m = 1.0	# scaling factor for FID
		self.T2 = 0.0	# T2 relaxation in tissue

		# Properties Specifically for Fitting
		self.T1_GM = 0.0 # T1 relaxation in gray matter
		self.T1_WM = 0.0 # T1 relaxation in white matter
		self.T2_GM = 0.0 # T2 relaxation in gray matter
		self.T2_WM = 0.0 # T2 relaxation in white matter
		self.protons = 0.0 # number of protons

		# A calibration variable
		self.var = 0.0

	def name_short(self):
		return self.name.split('_')[0]

	def num_peaks(self):
		return sp.size(self.area)

	def getFID(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb):

		# b0 should be float [MHz]
		# t should be a numpy array

		# FUDGE FACTOR DUE TO FT1=0.000498 ... something in FITMAN doesn't quite add up?!
		# if pfactor != 0:
		# 	pfactor = pfactor + 4.98

		ppmtoHz = b0    # conversion between ppm and Hz is the main field

		# generate exponentially decaying sinusoids for each peak
		sinusoids = sp.empty([self.num_peaks(), sp.size(t)], dtype=complex)
		for i in range (0, self.num_peaks()):

			# ---- MODEL BASED ON FITMAN ---- #
			c_k = self.area[i] * afactor
			w_k = -(-self.ppm[i] + sfactor) * ppmtoHz
			a_k = lb if sp.size(self.width_L) == 0 else self.width_L[i] + lb
			b_k = 0 if sp.size(self.width_G) == 0 else self.width_G[i]
			phi_k = sp.deg2rad(self.phase[i]) + pfactor	# radians
			t_0 = dfactor if sp.size(self.delay) == 0 else self.delay[i]

			sinusoids[i,] = c_k * sp.exp(1j*(2*sp.pi*w_k*(t+t_0)+phi_k)) * sp.exp(-sp.pi*a_k*np.abs(t+t_0)) * sp.exp(-np.power(sp.pi,2)/(4*np.log(2))*np.power(b_k,2)*np.power(t+t_0,2))


		# ---- OLD MODEL BASED ON VESPA ---- #
		# 	A_k = self.area[i] * afactor
		# 	w_k = 2 * sp.pi * ppmtoHz * (self.ppm[i] - sfactor)
		# 	phi_k = sp.deg2rad(self.phase[i]) + pfactor
		# 	sinusoids[i,] = A_k * sp.exp(-1j*(w_k*t) + 1j*(phi_k))

		# ---- NOTE: BOTH MODELS ARE CONSISTENT ... CAN USE EITHER ONE ---- #

		# generate FID
		FID = sp.sum(sinusoids, axis=0)

		# scale FID by A_m
		FID = self.A_m * FID

		# scale FID by T2 effects (only if a T2 value is specified)
		FID = sp.exp(-(t+TE*10**(-3))/self.T2) * FID if self.T2 > 0 else FID

		# # add line broadening
		# FID = sp.exp(-sp.pi*lb*t) * FID

		return FID

	def getSpec(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb, fs):
		n = sp.size(self.getFID(TE, b0, t, sfactor, afactor, pfactor, dfactor, lb))
		f = sp.arange(+n/2,-n/2,-1)*(fs/n)*(1/b0)

		return (-f, fftw.fftshift(fftw.fft(self.getFID(TE, b0, t, sfactor, afactor, pfactor, dfactor, lb))))

	def energy_FID(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb):
		return np.sum(np.power(np.absolute(self.getFID(TE, b0, t, sfactor, afactor, pfactor, dfactor, lb)), 2))

	def energy_spec(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb):
		return np.sum(np.power(np.absolute(fftw.fftshift(fftw.fft(self.getFID(TE, b0, t, sfactor, afactor, pfactor, dfactor, lb)))), 2))

	def sumAmp(self):
		return np.sum(self.area)

	def calcRatio(self, ref_value):
		return np.sumAmp()/ref_value

class Macromolecule:
	def __init__(self, name, shift, line_type, lw, area, phase):

		self.name = name
		self.line_type = line_type
		self.lw = lw
		self.A_m = 1.0
		self.T2 = 0.0

		self.ppm = [shift]
		self.area = [area]
		self.phase = [phase]

	def name_short(self):
		return self.name

	def getFID(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb):
		# b0, lb should be floats (MHz, Hz)
		# t should be a numpy array

		# FUDGE FACTOR DUE TO FT1=0.000498 ... something in FITMAN doesn't quite add up?!
		# if pfactor != 0:
		# 	pfactor = pfactor + 4.98

		ppmtoHz = b0    # conversion between ppm and Hz is the main field

		lw  = self.lw
		A_m = self.A_m
		A_k = self.area[0] * afactor
		w_k = 2 * sp.pi * ppmtoHz * (self.ppm[0] - sfactor)
		phi_k = self.phase[0] + pfactor

		if self.line_type == 'L':
			FID = A_m * A_k * sp.exp(1j*(w_k*t) + 1j*(phi_k)) * sp.exp(-sp.pi*lw*t)
		elif self.line_type == 'G':
			FID = A_m * A_k * sp.exp(1j*(w_k*t) + 1j*(phi_k)) * sp.exp(-np.power(sp.pi,2)/(4*np.log(2)) * np.power(lw,2) * np.power(t,2))

		return FID * sp.exp(-sp.pi*lb*t)

	def getSpec(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb, fs):
		n = sp.size(self.getFID(TE, b0, t, sfactor, afactor, pfactor, lb))
		f = sp.arange(+n/2,-n/2,-1)*(fs/n)*(1/b0)

		return (-f, fftw.fftshift(fftw.fft(self.getFID(TE, b0, t, sfactor, afactor, pfactor, dfactor, lb))))

	def energy_FID(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb):
		return np.sum(np.power(np.absolute(self.getFID(TE, b0, t, sfactor, afactor, pfactor, lb)), 2))

	def energy_spec(self, TE, b0, t, sfactor, afactor, pfactor, dfactor, lb):
		return np.sum(np.power(np.absolute(fftw.fftshift(fftw.fft(self.getFID(TE, b0, t, sfactor, afactor, pfactor, dfactor, lb)))), 2))

class CSTGroup:
	def __init__(self, typeCST, name, members, minCST, maxCST):
		self.typeCST = typeCST
		self.name = name

		self.members = members

		self.maxCST = maxCST
		self.minCST = minCST

		self.ref_value = 0
		self.ref_T2 = 0

class OutputFile:
	def __init__(self, filename):
		self.filename = filename
		self.metabolites = self.tree()
		self.metabolites_list = []
		self.loadOutputFile()

	def loadOutputFile(self):
		print '======================================='
		print 'Reading data from: ' + self.filename + ' ...'

		in_file = open(self.filename,'r')
		
		output = self.tree()
		crlb   = self.tree()
		constraints_file_flag = False
		for (i, line) in enumerate(in_file):
			if "NUMBER_PEAKS" in line:
				self.num_peaks = filter(None, line.replace('\r','').replace('\n','').split('\t'))[1]
				print self.num_peaks
			elif "noise_STDEV_real" in line:
				self.noise_STDEV_real = float(filter(None, line.split('\t'))[1].replace('\r','').replace('\n',''))
				print self.noise_STDEV_real
			elif "noise_STDEV_imag" in line:
				self.noise_STDEV_imag = float(filter(None, line.split('\t'))[1].replace('\r','').replace('\n',''))
				print self.noise_STDEV_imag
			elif i > 14 and i < int(self.num_peaks) + 15:
				peak = int(filter(None, line.replace('\r','').replace('\n','').split(' '))[0])
				output[peak] = filter(None, line.replace('\r','').replace('\n','').split(' '))
			elif i > 14 and i > int(self.num_peaks) + 17 and i < 2*int(self.num_peaks) + 18:
				peak = int(filter(None, line.replace('\r','').replace('\n','').replace(';','').split(' '))[0])
				crlb[peak] = filter(None, line.replace('\r','').replace('\n','').replace(';','').split(' '))
			elif ";PEAK#" in line or ";Peak #" in line:
				constraints_file_flag = True
			elif "Constraints_File_Ends" in line:
				constraints_file_flag = False
			elif constraints_file_flag == True:
				if (";" in line) and not("\t" in line):
					current_metabolite = line.replace(';', '').replace('\r','').replace('\n','')
					self.metabolites_list.append(current_metabolite)
					self.metabolites[current_metabolite] = Metabolite()
					self.metabolites[current_metabolite].name = current_metabolite
				else:
					if not(line[0] == ';') and len(line.replace('\r','').replace('\n','')) > 0:
						self.metabolites[current_metabolite].peak.append(int(line.split('\t')[0]))

		print self.metabolites_list

		for metabolite in self.metabolites_list:
			for peak in self.metabolites[metabolite].peak:
				self.metabolites[metabolite].ppm.append(float(output[peak][1]))
				self.metabolites[metabolite].width_L.append(float(output[peak][2]))
				self.metabolites[metabolite].area.append(float(output[peak][3]))
				self.metabolites[metabolite].phase.append(sp.rad2deg(float(output[peak][4])))
				self.metabolites[metabolite].delay.append(float(output[peak][5]))
				self.metabolites[metabolite].width_G.append(float(output[peak][6]))
				if float(output[peak][3]) == 0:
					self.metabolites[metabolite].crlb.append(np.nan)
				else:
					self.metabolites[metabolite].crlb.append((float(crlb[peak][3])/float(output[peak][3])) * 100)

				# print metabolite, peak, self.metabolites[metabolite].ppm[-1], self.metabolites[metabolite].width_L[-1], \
				# self.metabolites[metabolite].area[-1], self.metabolites[metabolite].phase[-1], self.metabolites[metabolite].delay[-1], \
				# self.metabolites[metabolite].width_G[-1], self.metabolites[metabolite].crlb[-1]

		print '======================================='

		# this attribute allows user to reference output data structure directly via peak number 
		# (instead of indexing by metabolite)
		self.output = output

	def tree(self): return defaultdict(self.tree)

class DatFile:
	def __init__(self, filename):
		self.filename = filename
		self.loadDatFile()

	def loadDatFile(self):
		print '======================================='
		print 'Reading dat from ', self.filename, ' ...'		
	
		in_file = open(self.filename,'r')

		self.n = 0
		self.fs = 0
		self.b0 = 0
		dat = []

		for (i, line) in enumerate(in_file):
			if i == 0:
				self.n = int(line.replace(' ', '').replace('\n', ''))/2
			elif i == 2:
				self.fs = 1/float(line.replace(' ', '').replace('\n', ''))
			elif i == 3:
				self.b0 = float(line.replace(' ', '').replace('\n', ''))
			elif i == 11:
				pass
			elif i > 11:
				dat.append(float(line.replace(' ', '').replace('\n', '')))

		real = sp.array(dat)[0::2]
		imag = sp.array(dat)[1::2]
		print 'n', self.n
		print 'Real', real, sp.size(real)
		print 'Imag', imag, sp.size(imag)
		self.signal = real+1j*imag

		self.t = sp.arange(0, self.n, 1) * (1/self.fs)
		print '======================================='

	def energy_FID(self):
		return np.sum(np.power(np.absolute(self.signal),2))

	def getSpec(self):
		n = sp.size(self.signal)
		f = sp.arange(-n/2,+n/2, 1)*(self.fs/n)*(1/self.b0)
		return (f, fftw.fftshift(fftw.fft(self.signal)))

class RDAFile:
	def __init__(self, filename, **kwargs):
		self.filename = filename
		self.kwargs = kwargs
		self.load_rda()

	def load_rda(self):

		filename = self.filename
		kwargs = self.kwargs

		try:
			f = open(filename, "rb")
		except IOError as e:
			print "Could not load {} -- exiting".format(filename)
			return

		flags = dict()
		defaults= {'scale_fid': True}
		for name in defaults.keys():
			flags[name] = kwargs.get(name, defaults[name])

		# Read header of RDA file
		rawfid = f.read()
		hstart = rawfid.find(">>> Begin of header <<<") + len(">>> Begin of header <<<\n") + 1
		hend = rawfid.find(">>> End of header <<<")
		hstring = rawfid[hstart:hend]
		hlist = hstring.split("\r\n")
		hlist2 = [h.split(": ") for h in hlist]
		fid_hdr = dict(hlist2[h] for h in range(0, len(hlist2)-1, 1))
		fid_data = rawfid[hend + len(">>> End of header <<<\n") + 1:]
		f.close()

		# Convert raw spectral data and scale
		element_size = 16  # complex double
		element_count = len(fid_data) // element_size
		format = "dd"

		try:
			fid_data = struct.unpack(format * element_count, fid_data)
		except struct.error:
			print "Unexpected input encountered while reading raw data"
			return

		fid_data = [complex(fid_data[w], fid_data[w+1]) for w in range(0, len(fid_data), 2)] 

		fid_data_type = "complex128"
		fid_data = np.fromiter(fid_data, fid_data_type)

		# Some acquisition parameters from header
		larmor = float(fid_hdr['MRFrequency'])
		fid_date = dt.datetime.strptime(fid_hdr['StudyDate'], '%Y%m%d').strftime('%d%b%y')
		fid_nt = int(fid_hdr["NumberOfAverages"].rstrip('.0'))
		fid_dt = float(fid_hdr["DwellTime"]) / 1e6
		# fid_time = np.arange(fid_dt, (len(fid_data) + 1) * fid_dt, fid_dt)

		# Reorder data by size of CSI grid (SVS has grid size of 1 x 1)
		vect_size = int(fid_hdr['VectorSize'])
		fid_time = np.arange(fid_dt, (vect_size + 1) * fid_dt, fid_dt)
		fid_data = fid_data.reshape([len(fid_data)/vect_size, vect_size])
		spec_data = np.zeros(fid_data.shape, dtype=complex)

		final_scale = np.ones(fid_data.shape[0])
		for i_csi in range(fid_data.shape[0]):
			if flags['scale_fid']:
				scale = np.ones(fid_data.shape[1])
				for p in range(48):
					data_pt = fid_data[i_csi, p]
					if np.abs(data_pt) > 10:
						while np.abs(data_pt) > 10:
							scale[p] = scale[p] / 10
							data_pt = data_pt / 10
						final_scale[i_csi] = min(scale)
					elif np.abs(data_pt) < 1:
						while np.abs(data_pt) < 1:
							scale[p] = scale[p] * 10
							data_pt = data_pt * 10
						final_scale[i_csi] = max(scale)
			fid_data[i_csi,:] = fid_data[i_csi,:] * final_scale[i_csi]
			spec_data[i_csi,:], freq = self.fid_to_spec(fid_data[i_csi,:], fid_time)

		csi_size = np.array([fid_hdr['CSIMatrixSize[0]'], fid_hdr['CSIMatrixSize[1]'], fid_hdr['CSIMatrixSize[2]'], vect_size], dtype=int)
		csi_size = csi_size[csi_size > 1]  # Remove singleton dimensions
		# fid_data = fid_data.reshape(csi_size)
		# spec_data = spec_data.reshape(csi_size)
		freq = -freq
		ppm = freq / larmor + 4.7


		vox_size = np.array([fid_hdr["PixelSpacingRow"], fid_hdr["PixelSpacingCol"],
							  fid_hdr["PixelSpacing3D"]],'f8')
		fid_pvec = np.array([fid_hdr["VOIPositionSag"], fid_hdr["VOIPositionCor"],
							  fid_hdr["VOIPositionTra"]],'f8')
		fid_pvec = [-fid_pvec[0], -fid_pvec[1], fid_pvec[2]]
		fid_rvec = np.array([fid_hdr["RowVector[0]"], fid_hdr["RowVector[1]"],
							  fid_hdr["RowVector[2]"]],'f8')
		fid_cvec = np.array([fid_hdr["ColumnVector[0]"], fid_hdr["ColumnVector[1]"],
							  fid_hdr["ColumnVector[2]"]],'f8')
		fid_nvec = np.cross(fid_rvec, fid_cvec)

		R_fid = np.c_[fid_rvec, fid_cvec, fid_nvec]  # concatenate column vectors
		R_fid[:2,2] = -R_fid[:2,2]
		R_fid[2,:2] = -R_fid[2,:2]
		
		angle = np.pi/2
		R_z = np.c_[[np.cos(angle), np.sin(angle), 0],[-np.sin(angle), np.cos(angle), 0], [0, 0, 1]]
		R_fid = np.dot(R_z, R_fid)

		self.patient = fid_hdr["PatientName"]
		self.institute = fid_hdr['InstitutionName']
		self.date = fid_date
		self.larmor = larmor
		self.fid = fid_data
		self.TE = float(fid_hdr['TE'])
		self.TR = float(fid_hdr['TR'])
		self.time = fid_time
		self.spec = spec_data
		self.freq = freq
		self.ppm = ppm
		self.vect_size = vect_size
		self.ConvS = final_scale
		self.vox_center = fid_pvec
		self.n_averages = fid_nt
		self.vox_size = vox_size
		self.vox_affine = R_fid

	def fid_to_spec(self, fid_data, time):
	    spec = sp.fftpack.fftshift(sp.fftpack.fft(fid_data)) 
	    freq = sp.fftpack.fftshift(sp.fftpack.fftfreq(fid_data.size, time[1] - time[0])) 
	    return spec, freq