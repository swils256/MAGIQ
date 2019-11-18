# METAB QUANTIFICATION CALCULATION IN BARSTOOL

# ---- System Libraries ---- #
import sys
import os
import datetime
import time
import glob
import platform

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

# ==== NEW CODE ==== #
# Calculation consistent with:
#      Gasparovic, C., Song, T., Devier, D., Bockholt, H. J., Caprihan, A., Mullins, P. G., ... Morrison, L. A. (2006). 
#      Use of tissue water as a concentration reference for proton spectroscopic imaging. Magnetic Resonance in Medicine, 
#      55(6), 1219-1226. https://doi.org/10.1002/mrm.20901
def calc(sup_out, unsup_out, \
			vox_frac, n_avg_sup, n_avg_uns, scale_sup, scale_uns, \
			gain_sup, gain_uns, \
			metab_params, num_params, water_params, exp_params, \
			scanner_type):
	# sup_out      = suppressed output file (OutputFile object)
	# unsup_out    = unsuppressed output file (OutputFile object)
	# vox_frac     = [gm, wm, csf] voxel fractions (1d array)
	# metab_params = metabolite parameters (2d array [number of metabolites][number of parameter columns])
	#     0.  Metabolite
	#     1.  Number of protons for quantifiable singlet or whole signal sum
	#     2.  T1 values in GM (in sec)
	#     3.  T2 values in GM (in msec)
	#     4.  T1 values in WM (in sec)
	#     5.  T2 values in WM (in msec)
	#     6.  First Peak
	#     7.  Last Peak

	# water_params = water parameters (1d array [number of parameter columns])
	#	water	protons	T1_GM	T2_GM	T1_WM	T2_WM	T1_CSF	T2_CSF

	# exp_params   = experimental parameters (1d array [number of experiment columns])
	#	exp	TR	TE	Conc	ConcGM (alpha_GM)	ConcWM (alpha_WM)	ConcVox	ConcCSF (alpha_CSF)

	quant_result = tree()
	crlb_result  = tree()

	# Loop through all metabolites
	for i in range(0, num_params):

		for j in range (0, 8): print type(metab_params[i][j]),
		print ''
		for j in range (0, 8): print metab_params[i][j],
		print ''

		# Get metabolite name
		name = metab_params[i][0]

		# Get metabolite signal
		sum_alpha_M = 0
		crlbs       = []
		for peak in range(metab_params[i][6], metab_params[i][7]+1):
			if float(sup_out.output[peak][3]) == 0:
				crlbs.append(np.nan)
			else:
				crlbs.append((float(sup_out.crlbs[peak][3])/float(sup_out.output[peak][3])) * 100)
			print '     | ', peak, sup_out.output[peak][3], crlbs[-1]
			sum_alpha_M = sum_alpha_M + float(sup_out.output[peak][3])
		final_crlb = np.nanmean(crlbs)
		print ' | ', sum_alpha_M

		# Get water signal
		sum_alpha_W = float(unsup_out.output[1][3])
		print ' | ', sum_alpha_W

		# Calculate relaxation correction for metabolites
		relax_m = R_M(  vox_frac[0], \
						vox_frac[1], \
						metab_params[i][2], \
						metab_params[i][3], \
						metab_params[i][4], \
						metab_params[i][5], \
						exp_params[1], \
						exp_params[2])

		# Calculate relaxation correction for water
		relax_w = R_W(  vox_frac[0], \
						vox_frac[1], \
						vox_frac[2], \
						water_params[2], \
						water_params[3], \
						water_params[4], \
						water_params[5], \
						water_params[6], \
						water_params[7], \
						exp_params[1], \
						exp_params[2], \
						exp_params[4], \
						exp_params[5], \
						exp_params[7])

		term1 = float(sum_alpha_M) / float(sum_alpha_W)		# RATIO OF MEASURED SIGNALS
		term2 = float(relax_w) / float(relax_m)				# RELAXATION CORRECTION
		term3a = float(n_avg_uns) / float(n_avg_sup)		# CORRECTION FOR NUMBER OF AVERAGES
		term3b = float(water_params[1]) / float(metab_params[i][1])										# CORRECTION FOR NUMBER OF NUCLEI (protons)
		term3c = float((scale_uns * 10**(gain_uns/20.0))) / float((scale_sup * 10**(gain_sup/20.0)))	# CORRECTION FOR GAIN
		term4 = exp_params[3]								# CONCENTRATION OF PURE WATER

		if exp_params[6] == 0:
			# DILUTION CORRECTION FOR TISSUE CONCENTRATION
			# (Voxel concetration flag is off)
			term5 = 1 / (vox_frac[0] + vox_frac[1])
		else:
			# VOXEL CONCENTRATION
			term5 = 1

		print ' | ', term1, term2, term3a, term3b, term3c, term4, term5
		final_conc = term1*term2*term3a*term3b*term3c*term4*term5

		# Extra Correction (for Siemens Systems only)
		''' Extra correction to get Siemens data properly scaled (Siemens divides signal by n_averages
			prior to saving as RDA), Agilent does not (n_avg terms in scaled_sig originally for Agilent)
		'''
		if scanner_type == 'siemens':
			final_conc = final_conc * (float(n_avg_sup) / float(n_avg_uns))

		print ' | ', scanner_type, (float(n_avg_sup) / float(n_avg_uns))

		final_conc = final_conc * 1E3

		print name + ':\t', final_conc, 'mM'
		print name + ':\t', final_crlb, '%'
		print ''

		quant_result[name] = final_conc
		crlb_result[name]  = final_crlb

	return quant_result, crlb_result

def R_M(f_GM, f_WM, T1_GM, T2_GM, T1_WM, T2_WM, TR, TE):
	# f_GM = fraction of gray matter
	# f_WM = fraction of white matter
	# T1_GM = T1 of gray matter (sec)
	# T2_GM = T2 of gray matter (msec)
	# T1_WM = T1 of white matter (sec)
	# T2_WM = T2 of white matter (msec)
	# TR (msec); TE (msec)
	return (f_GM / (f_GM + f_WM)) * (1 - sp.exp(-(TR*1E-3)/T1_GM)) * sp.exp(-(TE*1E-3)/(T2_GM*1E-3)) + \
		   (f_WM / (f_GM + f_WM)) * (1 - sp.exp(-(TR*1E-3)/T1_WM)) * sp.exp(-(TE*1E-3)/(T2_WM*1E-3))

def R_W(f_GM, f_WM, f_CSF, T1_GM, T2_GM, T1_WM, T2_WM, T1_CSF, T2_CSF, TR, TE, alpha_GM, alpha_WM, alpha_CSF):
	# f_GM = fraction of gray matter
	# f_WM = fraction of white matter
	# f_CSF = fraction of CSF
	# T1_GM = T1 of gray matter (sec)
	# T2_GM = T2 of gray matter (msec)
	# T1_WM = T1 of white matter (sec)
	# T2_WM = T2 of white matter (msec)
	# T1_CSF = T1 of CSF (sec)
	# T2_CSF = T2 of CSF (msec)
	return f_GM  * alpha_GM * (1 - sp.exp(-(TR*1E-3)/T1_GM))  * sp.exp(-(TE*1E-3)/(T2_GM *1E-3)) + \
		   f_WM  * alpha_WM * (1 - sp.exp(-(TR*1E-3)/T1_WM))  * sp.exp(-(TE*1E-3)/(T2_WM *1E-3)) + \
		   f_CSF * alpha_CSF * (1 - sp.exp(-(TR*1E-3)/T1_CSF)) * sp.exp(-(TE*1E-3)/(T2_CSF*1E-3))

def tree(): return defaultdict(tree)

# ===== OLD CODE WITH CALCULATION FOR ORIGINAL BARSTOOL ==== #
# def calc(sup_out, unsup_out, \
# 			vox_frac, n_avg_sup, n_avg_uns, scale_sup, scale_uns, \
# 			gain_sup, gain_uns, \
# 			metab_params, num_params, water_params, exp_params, \
# 			scanner_type):
# 	# sup_out      = suppressed output file (OutputFile object)
# 	# unsup_out    = unsuppressed output file (OutputFile object)
# 	# vox_frac     = [gm, wm, csf] voxel fractions (1d array)
# 	# metab_params = metabolite parameters (2d array [number of metabolites][number of parameter columns])
# 	# water_params = water parameters (1d array [number of parameter columns])
# 	# exp_params   = experimental parameters (1d array [number of experiment columns])

# 	quant_result = tree()

# 	# Loop through all metabolites
# 	for i in range(0, num_params):

# 		for j in range(0, 8): print type(metab_params[i][j]),
# 		print ''
# 		for j in range(0, 8): print metab_params[i][j],
# 		print ''

# 		# Get metabolite name
# 		name = metab_params[i][0]

# 		# Get metabolite signal
# 		sum_alpha_M = 0
# 		for peak in range(metab_params[i][6], metab_params[i][7]+1):
# 			print '     | ', peak, sup_out.output[peak][3]
# 			sum_alpha_M = sum_alpha_M + float(sup_out.output[peak][3])

# 		print '     | M:', sum_alpha_M, n_avg_sup, metab_params[i][1], scale_sup, gain_sup, 10**(gain_sup/20.0), R_M(vox_frac[0], \
# 										vox_frac[1], \
# 										metab_params[i][2], \
# 										metab_params[i][3], \
# 										metab_params[i][4], \
# 										metab_params[i][5], \
# 										exp_params[1], \
# 										exp_params[2])
# 		print '         ', vox_frac[0], \
# 										vox_frac[1], \
# 										metab_params[i][2], \
# 										metab_params[i][3], \
# 										metab_params[i][4], \
# 										metab_params[i][5], \
# 										exp_params[1], \
# 										exp_params[2]

# 		# Correct metabolite signal
# 		sum_alpha_M = sum_alpha_M / n_avg_sup				# correct for number of averages
# 		sum_alpha_M = sum_alpha_M / metab_params[i][1]		# correct for number of protons
# 		sum_alpha_M = sum_alpha_M / scale_sup				# correct for scaling factor
# 		sum_alpha_M = sum_alpha_M / 10**(gain_sup/20.0)		# correct for gain
# 		sum_alpha_M = sum_alpha_M / R_M(vox_frac[0], \
# 										vox_frac[1], \
# 										metab_params[i][2], \
# 										metab_params[i][3], \
# 										metab_params[i][4], \
# 										metab_params[i][5], \
# 										exp_params[1], \
# 										exp_params[2])		# correct for relaxation
# 		print '         ', sum_alpha_M

# 		# Get water signal
# 		sum_alpha_W = float(unsup_out.output[1][3])

# 		print '     | W:', sum_alpha_W, n_avg_uns, water_params[1], scale_uns, gain_uns, 10**(gain_uns/20.0)#, R_W(vox_frac[0], \
# 		# 								vox_frac[1], \
# 		# 								vox_frac[2], \
# 		# 								water_params[2], \
# 		# 								water_params[3], \
# 		# 								water_params[4], \
# 		# 								water_params[5], \
# 		# 								water_params[6], \
# 		# 								water_params[7], \
# 		# 								exp_params[1], \
# 		# 								exp_params[2])
# 		print '         ', vox_frac[0], \
# 										vox_frac[1], \
# 										vox_frac[2], \
# 										water_params[2], \
# 										water_params[3], \
# 										water_params[4], \
# 										water_params[5], \
# 										water_params[6], \
# 										water_params[7], \
# 										exp_params[1], \
# 										exp_params[2]

# 		# Correct water signal
# 		sum_alpha_W = sum_alpha_W / n_avg_uns				# correct for number of averages
# 		sum_alpha_W = sum_alpha_W / water_params[1]			# correct for number of protons
# 		sum_alpha_W = sum_alpha_W / scale_uns				# correct for scaling factor
# 		sum_alpha_W = sum_alpha_W / 10**(gain_uns/20.0)		# correct for gain
# 		sum_alpha_W = sum_alpha_W / R_W(vox_frac[0], \
# 										vox_frac[1], \
# 										vox_frac[2], \
# 										water_params[2], \
# 										water_params[3], \
# 										water_params[4], \
# 										water_params[5], \
# 										water_params[6], \
# 										water_params[7], \
# 										exp_params[1], \
# 										exp_params[2])		# correct for relaxation

# 		print '         ', sum_alpha_W

# 		# Apply water signal correction for tissue concentration
# 		if exp_params[6] == 0:
# 			# Voxel concetration flag is off ... so we want tissue concentration
# 			C_tissue = vox_frac[0] + vox_frac[1]
# 			sum_alpha_W = sum_alpha_W * C_tissue
# 			print '         ', sum_alpha_W

# 		# Get water concentration
# 		if exp_params[6] == 0:
# 			# Voxel concentration flag is off ... so we want tissue water concentration
# 			water_conc =   vox_frac[0] * exp_params[3] * exp_params[4] \
# 						 + vox_frac[1] * exp_params[3] * exp_params[5]
# 			print '         ', water_conc
# 		else:
# 			# Voxel concentration flag is on ... so we want voxel water concentration
# 			water_conc =   vox_frac[0] * exp_params[3] * exp_params[4] \
# 						 + vox_frac[1] * exp_params[3] * exp_params[5] \
# 						 + vox_frac[2] * exp_params[3] * 1
# 			print '         ', water_conc

# 		# Calculate final concentration
# 		final_conc = (sum_alpha_M / sum_alpha_W) * water_conc

# 		# Extra Correction (for Siemens Systems only)
# 		''' Extra correction to get Siemens data properly scaled (Siemens divides signal by n_averages
# 			prior to saving as RDA), Agilent does not (n_avg terms in scaled_sig originally for Agilent)
# 		'''
# 		if scanner_type == 'siemens':
# 			final_conc = final_conc * (float(n_avg_sup) / float(n_avg_uns))

# 		final_conc = final_conc * 1E3

# 		print name + ':\t', final_conc, 'mM'
# 		print ''

# 		quant_result[name] = final_conc

# 	return quant_result

# def R_M(f_GM, f_WM, T1_GM, T2_GM, T1_WM, T2_WM, TR, TE):
# 	# f_GM = fraction of gray matter
# 	# f_WM = fraction of white matter
# 	# T1_GM = T1 of gray matter (sec)
# 	# T2_GM = T2 of gray matter (msec)
# 	# T1_WM = T1 of white matter (sec)
# 	# T2_WM = T2 of white matter (msec)
# 	# TR (msec); TE (msec)
# 	return f_GM * (1 - sp.exp(-(TR*1E-3)/T1_GM)) * sp.exp(-(TE*1E-3)/(T2_GM*1E-3)) + \
# 		   f_WM * (1 - sp.exp(-(TR*1E-3)/T1_WM)) * sp.exp(-(TE*1E-3)/(T2_WM*1E-3))

# def R_W(f_GM, f_WM, f_CSF, T1_GM, T2_GM, T1_WM, T2_WM, T1_CSF, T2_CSF, TR, TE):
# 	# f_GM = fraction of gray matter
# 	# f_WM = fraction of white matter
# 	# f_CSF = fraction of CSF
# 	# T1_GM = T1 of gray matter (sec)
# 	# T2_GM = T2 of gray matter (msec)
# 	# T1_WM = T1 of white matter (sec)
# 	# T2_WM = T2 of white matter (msec)
# 	# T1_CSF = T1 of CSF (sec)
# 	# T2_CSF = T2 of CSF (msec)
# 	print '              | ', f_GM, f_WM, f_CSF, T1_GM, T2_GM, T1_WM, T2_WM, T1_CSF, T2_CSF, TR, TE
# 	print '              | ', f_GM  * (1 - sp.exp(-(TR*1E-3)/T1_GM))  * sp.exp(-(TE*1E-3)/(T2_GM *1E-3))
# 	print '              | ', f_WM  * (1 - sp.exp(-(TR*1E-3)/T1_WM))  * sp.exp(-(TE*1E-3)/(T2_WM *1E-3))
# 	print '              | ', f_CSF * (1 - sp.exp(-(TR*1E-3)/T1_CSF)) * sp.exp(-(TE*1E-3)/(T2_CSF*1E-3))
# 	return f_GM  * (1 - sp.exp(-(TR*1E-3)/T1_GM))  * sp.exp(-(TE*1E-3)/(T2_GM *1E-3)) + \
# 		   f_WM  * (1 - sp.exp(-(TR*1E-3)/T1_WM))  * sp.exp(-(TE*1E-3)/(T2_WM *1E-3)) + \
# 		   f_CSF * (1 - sp.exp(-(TR*1E-3)/T1_CSF)) * sp.exp(-(TE*1E-3)/(T2_CSF*1E-3))

# def tree(): return defaultdict(tree)