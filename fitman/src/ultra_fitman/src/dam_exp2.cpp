// This file contains the function and derivative information
// for the damped sinusoid model function in the time domain

#include <math.h>
#include "fit.h"

void dam_exp2(double t, double *a, Complex *ymod, Complex *dyda, int ma, int *link, 
			  Peak2 *peak2, int k, Fit_info *fit_info, Complex window)

{
	int i, j;
	double COS, SIN, EXP, TIME, G_FWHM_C;
	double COS_EXP, SIN_EXP, Amp_pi_COS_EXP, Amp_pi_SIN_EXP, Amp_pi_COS_EXP_TIME, Amp_pi_SIN_EXP_TIME;

	ymod->real = 0.0;
	ymod->imag = 0.0;

	TIME = 0.0;
	COS = 0.0;
	SIN = 0.0;
	EXP = 0.0;
	G_FWHM_C = PI / (4 * log(2));

	// since dyda[] is now a running total...
	// we must set it to zero to start every loop

	for (i=1; i<=ma; i++){
		dyda[link[i]].real = 0.0;
		dyda[link[i]].imag = 0.0;
	}
	
	
	j = 0;
	
	for (i=1; i<=ma; i+=6){

		// calculate some intermediate functions to optimize the calculation of the
		// derivatives!

		// May 7, 97 ...function and derivatives were corrected so that the Gaussian
		// damping constant would be the FWHM following Fourier transform.
		// Until this time Gaussian damping function was exp(-PI * wG^2 * t^2)... this
		// lead to a correction factor of 0.9394372 to all Gaussian widths
		
		TIME = t + a[i+4];
		COS = cos( 2.0 * PI * a[i] * TIME + a[i+3]);
		SIN = sin( 2.0 * PI * a[i] * TIME + a[i+3]);
		EXP = exp( -1.0 * PI * a[i+1] * fabs(TIME) - PI * G_FWHM_C * a[i+5] * TIME * TIME); // G_FWHM_C added

		COS_EXP = COS * EXP;
		SIN_EXP = SIN * EXP;
		Amp_pi_COS_EXP = a[i+2] * PI * COS_EXP;
		Amp_pi_SIN_EXP = a[i+2] * PI * SIN_EXP;
		Amp_pi_COS_EXP_TIME = Amp_pi_COS_EXP * fabs(TIME);
		Amp_pi_SIN_EXP_TIME = Amp_pi_SIN_EXP * fabs(TIME);



		// calculate the function
		ymod->real += a[i+2] * COS_EXP; //* window.real;
		ymod->imag += a[i+2] * SIN_EXP; //* window.imag;

		if(link[i] != 0){
			// calculate the derivative wrt frequency (shift)
			dyda[link[i]].real += -2.0 * Amp_pi_SIN_EXP * TIME; // * window.real;
			dyda[link[i]].imag +=  2.0 * Amp_pi_COS_EXP * TIME; // * window.imag;
		}

		if(link[i+1] != 0){
			// calculate the derivative wrt Lorentzian width
			dyda[link[i+1]].real += -1.0 * Amp_pi_COS_EXP_TIME; // * window.real;
			dyda[link[i+1]].imag += -1.0 * Amp_pi_SIN_EXP_TIME; // * window.imag;
		}

		if(link[i+2] != 0){
			// calculate the derivative wrt Amplitude
			dyda[link[i+2]].real += peak2[j].parameter[AMPLITUDE].modifier * COS_EXP;
									//	* window.real;
			dyda[link[i+2]].imag += peak2[j].parameter[AMPLITUDE].modifier * SIN_EXP;
									//	* window.imag;
		}

		if(link[i+3] != 0){
			// calculate the derivative wrt phase
			dyda[link[i+3]].real +=  -1.0 * a[i+2] * SIN_EXP; // * window.real;
			dyda[link[i+3]].imag +=   1.0 * a[i+2] * COS_EXP; // * window.imag;
		}

		if(link[i+4] != 0){
			// calculate the derivative wrt delay time
			dyda[link[i+4]].real +=  -2.0 * Amp_pi_SIN_EXP * a[i] - Amp_pi_COS_EXP * a[i+1] 
				- 2.0 * Amp_pi_COS_EXP_TIME * G_FWHM_C * a[i+5]; // * window.real; // PI replaced in last term with G_FWHM_C
			dyda[link[i+4]].imag +=   2.0 * Amp_pi_COS_EXP * a[i] - Amp_pi_SIN_EXP * a[i+1] 
				- 2.0 * Amp_pi_SIN_EXP_TIME * G_FWHM_C * a[i+5]; // * window.imag; // PI replaced in last term with G_FWHM_C
		}

		if(link[i+5] != 0){
			// calculate the derivative wrt Gaussian width
			dyda[link[i+5]].real += -1.0 * Amp_pi_COS_EXP_TIME * fabs(TIME) 
										* G_FWHM_C; // * window.real;  // G_FWHM_C added  
			dyda[link[i+5]].imag += -1.0 * Amp_pi_SIN_EXP_TIME * fabs(TIME) 
										* G_FWHM_C; // * window.imag;	 // G_FWHM_C added
		}

		j++;
	}
}
