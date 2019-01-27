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

# ---- baseline correction ---- #
def baseline_corr(data_complex):
	# take the mean of the last eighth of the data
	dc_offset = np.mean(data_complex[-np.size(data_complex)/8:])
	data_processed = data_complex - dc_offset
	return data_processed

# ---- normalization ---- #
def normalize(data_complex):
	# Determine the magnitude of the largest point (use the 1st 100 points in case echo is not centered)

	max_magnitude = np.max(np.abs(data_complex[0:100]))
	data_processed = np.real(data_complex) / max_magnitude + 1j*np.imag(data_complex) / max_magnitude
	return data_processed

# ---- quality and ecc correction ---- #
def quality(data_complex, data_complex_water):
	# Quality correction is simply dividing the data spectrum
	# reference spectrum assuming the reference is on resonance
	# and the reference signals have the same phase.

	data_processed = data_complex / normalize(data_complex_water)
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

def quecc(data_complex, data_complex_water, quecc_points, t):
	# Apply QUALITY
	data_processed_quality = quality(data_complex, data_complex_water)
	
	# Apply ECC
	data_processed_ecc     = ecc(data_complex, data_complex_water)
	
	# Find filter to eliminate hard edge between 
	# QUALITYed points and ECCed points
	last_point_quality = np.abs(data_processed_quality[quecc_points])
	last_point_ecc     = np.abs(data_processed_ecc[quecc_points+1])
	last_point_t       = t[quecc_points]
	alpha = -np.log(last_point_ecc/last_point_quality) / (sp.pi * last_point_t)

	# Apply filter
	data_processed_quality = data_processed_quality * np.exp(-sp.pi*alpha*t)

	# Join arrays
	data_processed = []
	for i, data in enumerate(data_processed_quality):
		if i > quecc_points:
			data_processed.append(data_processed_ecc[i])
		else:
			data_processed.append(data)

	return data_processed