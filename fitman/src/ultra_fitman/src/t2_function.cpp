// This file contains the function and derivative information
// for the damped sinusoid model function in the time domain

#include <math.h>
#include "fit.h"

void T2_function(double t, double *a, Complex *ymod, Complex *dyda, int ma, int *link, 
				 Peak2 *peak2, int k, Fit_info *fit_info, Complex weight)

{
	int i,j;
	register double freq_con, M_C_E, M_S_E;

	j = 0 ;
	
	ymod->real = 0.0;
	ymod->imag = 0.0;

	// since dyda[] is now a running total...
	// we must set it to zero to start every loop

	for (i=1; i<=ma; i++){
		dyda[link[i]].real = 0.0;
		dyda[link[i]].imag = 0.0;
	}
	
	freq_con = 2*PI/(fit_info->number_peaks) * 
		(k-(fit_info->number_peaks/2)-1.0);
	
	for (i=1; i<=ma; i+=6){

		// calculate some intermediate functions to optimize the calculation of the
		// derivatives!

		M_C_E = a[i+2]/sqrt(fit_info->number_peaks)*cos(freq_con*((i+5)/6-(fit_info->number_peaks/2)-1.0) + a[i+3]) * 
			exp(-1.0*a[k*6]*a[i+1]);
		M_S_E = a[i+2]/sqrt(fit_info->number_peaks)*sin(freq_con*((i+5)/6-(fit_info->number_peaks/2)-1.0) + a[i+3]) * 
			exp(-1.0*a[k*6]*a[i+1]);

		// calculate the function
		ymod->real += M_C_E;
		ymod->imag += M_S_E;

		if(link[i+1] != 0){
			// calculate the derivative wrt T2
			dyda[link[i+1]].real += -1.0 * a[k*6] * M_C_E;
			dyda[link[i+1]].imag += -1.0 * a[k*6] * M_S_E;
		}
		
		if(link[i+2] != 0){
			// calculate the derivative wrt M0
			dyda[link[i+2]].real += peak2[j].parameter[IMAGE_M0].modifier * M_C_E;
			dyda[link[i+2]].imag += peak2[j].parameter[IMAGE_M0].modifier * M_S_E;
		}

		if(link[i+3] != 0){
			// calculate the derivative wrt phase
			dyda[link[i+3]].real +=  -1.0 * M_S_E;
			dyda[link[i+3]].imag +=   M_C_E;
		}
	
		j++;
	}
}
