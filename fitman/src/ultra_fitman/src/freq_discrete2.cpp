// This file contains the function and derivative information
// for the damped sinusoid model function in the time domain

#include <math.h>
#include "fit.h"

void freq_exp(double t, double *a, Complex *ymod, Complex *dyda, int ma, int *link, 
			  Peak2 *peak2, int k, Fit_info *fit_info, Complex weight)

{
	int i, j;
	double dwell_time, freq_sf;
	register double DE, DEF, DEF1, DEF2, DEF3, DEF4, DEF5; 
	register double DEF6, DEF7, DEF8, DEF9, DEF10, DEF11; 
	register double EXP1, EC1, ES1, ECMEC, ESMES, ECS1, ECS2;
	register double COS1, COS2;
	register double SIN1, SIN2;
	register double WD1, WD2, ND, kD;
	register int N;

	ymod->real = 0.0;
	ymod->imag = 0.0;

	dwell_time = fit_info->dwell_time;
 	N = fit_info->zero_fill_to;
	k = -1* (k - (N/2) -1);

	kD = double(k);
	ND = double(N);
	freq_sf = 1.0/sqrt(ND);

	// since dyda[] is now a running total...
	// we must set it to zero to start every loop

	for (i=1; i<=ma; i++){
		dyda[link[i]].real = 0.0;
		dyda[link[i]].imag = 0.0;
	}
	
	
	j = 0;
	
	for (i=1; i<=ma; i+=6){

		// calculate some intermediate functions to optimize the calculation of the
		// derivatives!  Adding Absolute value bars around all occurances of (dwell_time-a[i+4])
		// (there are three) does not change the fit result...therefore either way is the same

		DEF = (2 * PI * ND * a[i] * a[i+4]) + (ND * a[i+3]);
		DEF1 = (PI * fabs(a[i+1]) * (dwell_time-a[i+4]) * ND - PI * fabs(a[i+1]) * dwell_time * ND * ND)/ND;
		DEF2 = (DEF + 2*PI*kD*(1-ND) + 2 * dwell_time * PI * ND * ND * a[i])/ND;
		EXP1 = exp(PI*fabs(a[i+1])*(dwell_time-a[i+4]));
		COS1 = cos((DEF + 2*PI*kD)/ND);
		SIN1 = sin((DEF + 2*PI*kD)/ND);
		COS2 = cos(2*dwell_time*PI*a[i]);
		SIN2 = sin(2*dwell_time*PI*a[i]);
		EC1 = exp(PI*fabs(a[i+1])*dwell_time) * cos(2.0*PI*kD/ND);
		ES1 = exp(PI*fabs(a[i+1])*dwell_time) * sin(2.0*PI*kD/ND);
		ECMEC = (exp(DEF1)*cos(DEF2)) - (EXP1*COS1);
		ESMES = (exp(DEF1)*sin(DEF2)) - (EXP1*SIN1);
		DE = ((COS2-EC1)*(COS2-EC1)) + ((SIN2-ES1)*(SIN2-ES1));
		ECS1 = (COS2-EC1)/DE;
		ECS2 = (SIN2-ES1)/DE;
		WD1 = PI*(fabs(a[i+1])/a[i+1])*(dwell_time-a[i+4]);
		WD2 = PI*(fabs(a[i+1])/a[i+1])*dwell_time;
		DEF3 = (PI * fabs(a[i+1]) * ECMEC) + (2 * ESMES * PI * a[i]);
		DEF4 = (PI * fabs(a[i+1]) * ESMES) - (2 * ECMEC * PI * a[i]);
		DEF5 = ((2 * PI * a[i+4] *ND) + (2 * PI * dwell_time * ND*ND))/ND;
		DEF6 = (-4*(COS2-EC1)*SIN2*PI*dwell_time) + (4*(SIN2-ES1)*COS2*PI*dwell_time);
		DEF7 = (exp(DEF1)*sin(DEF2)*DEF5) - (2*EXP1*SIN1*PI*a[i+4]);
		DEF8 = (-1*exp(DEF1)*cos(DEF2)*DEF5) + (2*EXP1*COS1*PI*a[i+4]);
		DEF9 = 2*PI*(dwell_time/DE);
		DEF10 = (-1.0*((WD1*ND)-(WD2*ND*ND))/ND) * exp(DEF1);
		DEF11 = (-2.0*(COS2-EC1)*WD2*EC1) - (2.0*(SIN2-ES1)*WD2*ES1);


		// calculate the function
		ymod->real += a[i+2] * freq_sf * (ECMEC*ECS1 + ESMES*ECS2);
		ymod->imag += a[i+2] * freq_sf * (ESMES*ECS1 - ECMEC*ECS2);

		if(link[i] != 0){
			// calculate the derivative wrt frequency (shift)

			dyda[link[i]].real += -1*a[i+2] * freq_sf *(DEF7*ECS1 + ECMEC*SIN2*DEF9 + ECMEC*(ECS1/DE)*DEF6 + DEF8*ECS2 - ESMES*COS2*DEF9 + ESMES*(ECS2/DE)*DEF6);

			dyda[link[i]].imag += -1*a[i+2] * freq_sf *(DEF8*ECS1 + ESMES*SIN2*DEF9 + ESMES*(ECS1/DE)*DEF6 - DEF7*ECS2 + ECMEC*COS2*DEF9 - ECMEC*(ECS2/DE)*DEF6);
		}

		if(link[i+1] != 0){
			// calculate the derivative wrt Lorentzian width

			dyda[link[i+1]].real += a[i+2] * freq_sf*((-1*(DEF10*cos(DEF2) + WD1*EXP1*COS1)*ECS1) - (ECMEC*WD2*EC1/DE) - (ECMEC*(COS2-EC1)/(DE*DE)*DEF11) - ((DEF10*sin(DEF2) + WD1*EXP1*SIN1)*ECS2) - (ESMES*WD2*ES1/DE) - (ESMES*(SIN2-ES1)/(DE*DE)*DEF11));

			dyda[link[i+1]].imag += a[i+2] * freq_sf*((-1*(DEF10*sin(DEF2) + WD1*EXP1*SIN1)*ECS1) - (ESMES*WD2*EC1/DE) - (ESMES*(COS2-EC1)/(DE*DE)*DEF11) + ((DEF10*cos(DEF2) + WD1*EXP1*COS1)*ECS2) + (ECMEC*WD2*ES1/DE) + (ECMEC*(SIN2-ES1)/(DE*DE)*DEF11));
		}

		if(link[i+2] != 0){
			// calculate the derivative wrt Amplitude

			dyda[link[i+2]].real += peak2[j].parameter[AMPLITUDE].modifier * freq_sf * (ECMEC*ECS1 + ESMES*ECS2);

			dyda[link[i+2]].imag += peak2[j].parameter[AMPLITUDE].modifier * freq_sf * (ESMES*ECS1 - ECMEC*ECS2);
		}

		if(link[i+3] != 0){
			// calculate the derivative wrt phase
			
			dyda[link[i+3]].real +=  -1 * a[i+2] * freq_sf * (ESMES*ECS1 - ECMEC*ECS2);
			
			dyda[link[i+3]].imag +=  a[i+2] * freq_sf * (ECMEC*ECS1 + ESMES*ECS2);
		}

		if(link[i+4] != 0){
			// calculate the derivative wrt delay time

			dyda[link[i+4]].real +=  -1 * a[i+2] * freq_sf * (DEF3*ECS1 + DEF4*ECS2);
			
			dyda[link[i+4]].imag +=  -1 * a[i+2] * freq_sf * (DEF4*ECS1 - DEF3*ECS2);
		}


		j++;
	}
}
