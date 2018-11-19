import scipy as sp
import scipy.signal as spsg
import numpy as np
import math

# ---- water fitting ---- #
def water_peak_func(t, A, lb):
	return A * sp.exp(-sp.pi*lb*t)

def getWaterLW(data_complex_water, t_water):
	popt, pcov = sp.optimize.curve_fit(water_peak_func, t_water, np.abs(data_complex_water), bounds=(0, [1E9, 20]))
	return popt[1]

# ---- quality and ecc correction ---- #
def quecc(data_complex, data_complex_water, lw_water, t, quecc_points):
	data_processed_quality = quality(data_complex, data_complex_water, lw_water, t)
	data_processed_ecc     = ecc(data_complex, data_complex_water)

	scaling_factor = np.abs(data_processed_ecc[0])/np.abs(data_processed_quality[0])

	data_processed = []
	for i in range(0, np.size(data_processed_quality)):
		if i < quecc_points:
			data_processed.append(data_processed_quality[i] * scaling_factor)
		else:
			data_processed.append(data_processed_ecc[i])

	return data_processed

def quality(data_complex, data_complex_water, lw_water, t):
	# Quality correction is simply dividing the data spectrum
	# reference spectrum assuming the reference is on resonance
	# and the reference signals have the same phase

	# Multiplication by the damping term of the reference restores
	# the original linewidth.

	data_processed = data_complex / data_complex_water
	data_processed = data_processed * sp.exp(-np.pi * lw_water * t)

	return data_processed

def ecc(data_complex, data_complex_water):
	# Eddy current correction is simply a subtraction of the 
	# water reference signal phase from the suppressed data.
	
	data_processed = data_complex

	dat_phase = np.angle(data_complex)
	ref_phase = np.angle(data_complex_water)
	dat_phase = dat_phase - ref_phase

	for i, phase in enumerate(dat_phase):
		data_processed[i] = np.abs(data_complex[i])*sp.exp(1j*dat_phase[i])

	return data_processed