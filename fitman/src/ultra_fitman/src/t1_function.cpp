// This file contains the function and derivative information
// for the damped sinusoid model function in the time domain

#include <math.h>
#include "fit.h"

void T1_function(double t, double *a, Complex *ymod, Complex *dyda, int ma, int *link, 
				 Peak2 *peak2, int k, Fit_info *fit_info, Complex weight)

{
	int i, j;
	double COS, SIN, EXP, DEN, NU;
	register double ESN_D, ECpi_D, ECN_D, ESpi_D; 
	register double AECN_D, AESpi_D, AESN_D, AECpi_D;
	register double fa, SIMP1, SIMP2, SIMP3, SIMP4;

	ymod->real = 0.0;
	ymod->imag = 0.0;

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

		fa  = 0.5 * a[i+1];
		NU  = PI * (a[i] - t);
		COS = cos((2.0 * PI * (a[i] ) * a[i+4]) + a[i+3]);
		SIN = sin((2.0 * PI * (a[i] ) * a[i+4]) + a[i+3]);
		EXP = exp( -2.0 * PI * fa * a[i+4]);
		DEN = (NU * NU) + (PI * PI * fa * fa);

		ESN_D = (EXP * SIN * NU) / DEN;
		ECN_D = (EXP * COS * NU) / DEN;
		ECpi_D = (EXP * COS * PI) / DEN;
		ESpi_D = (EXP * SIN * PI) / DEN;

		AESN_D = a[i+2] * ESN_D;
		AECN_D = a[i+2] * ECN_D;
		AECpi_D = a[i+2] * ECpi_D;
		AESpi_D = a[i+2] * ESpi_D;

		SIMP1 = PI * a[i+4];
		SIMP2 = PI / DEN;
		SIMP3 = PI * fa;
		SIMP4 = SIMP2 * SIMP3;

		// calculate the function
		ymod->real += -0.5 * (AESN_D - (AECpi_D * fa));
		ymod->imag += 0.5 * ((AESpi_D * fa) + AECN_D);

		if(link[i] != 0){
			// calculate the derivative wrt frequency (shift)

			dyda[link[i]].real += -1.0 * AECN_D * SIMP1 - 0.5 * AESpi_D + AESN_D * NU * SIMP2 
				- AESpi_D * SIMP1 * fa - AECN_D * SIMP4;

			dyda[link[i]].imag += -1.0 * AESN_D * SIMP1 + 0.5 * AECpi_D - AECN_D * NU * SIMP2 
				+ AECpi_D * SIMP1 * fa - AESN_D * SIMP4;
		}

		if(link[i+1] != 0){
			// calculate the derivative wrt Lorentzian width

			dyda[link[i+1]].real += AESN_D * SIMP1 + AESN_D * SIMP4 - AECpi_D * fa * SIMP1 
				+ 0.5 * AECpi_D - AECpi_D * SIMP4 * fa;

			dyda[link[i+1]].imag += -1.0 * AECN_D * SIMP1 - AECN_D * SIMP4 - AESpi_D * fa * SIMP1 
				+ 0.5 * AESpi_D - AESpi_D * SIMP4 * fa;
		}

		if(link[i+2] != 0){
			// calculate the derivative wrt Amplitude

			dyda[link[i+2]].real += -0.5 * peak2[j].parameter[AMPLITUDE].modifier 
				* (ESN_D - ECpi_D * fa);

			dyda[link[i+2]].imag += 0.5 * peak2[j].parameter[AMPLITUDE].modifier 
				* (ECN_D + ESpi_D * fa);
		}

		if(link[i+3] != 0){
			// calculate the derivative wrt phase
			
			dyda[link[i+3]].real +=  -0.5 * (AECN_D + AESpi_D * fa);
			
			dyda[link[i+3]].imag +=  -0.5 * (AESN_D - AECpi_D * fa);
		}

		if(link[i+4] != 0){
			// calculate the derivative wrt delay time

			dyda[link[i+4]].real +=  -1.0 * AECN_D * PI * a[i]  - AESpi_D * SIMP3 * a[i];
			
			dyda[link[i+4]].imag +=  -1.0 * AESN_D * PI * a[i]  + AECpi_D * SIMP3 * a[i];
		}


		j++;
	}
}
