#include <stdio.h>
//#include <fit.h>
#include "fit.h"
#include <math.h>


// Declare prototype
void fourier(double *data, int nn, int isign);


//***********************
//*       FFT
//***********************

int fft(Point *data, int number_points){

	double *spectrum;
	int i;
	int number_points_by_2;

	spectrum = new double[sizeof(double)*(number_points*2+2)];
		
	if(spectrum == NULL)
		return(FALSE);

	for(i=0;i<number_points;i++){
	   spectrum[i*2+1]   = data[i].y.real;
	   spectrum[i*2+2] = data[i].y.imag;
	}

	fourier(spectrum, number_points, 1);

	number_points_by_2 = number_points/2;

/* Flip halves */
	for(i=0;i<number_points_by_2;i++){
	   data[i].y.real      = spectrum[(i+number_points_by_2)*2+1];
	   data[i].y.imag      = spectrum[(i+number_points_by_2)*2+2];
	}
	for(i=number_points_by_2;i<number_points;i++){
	   data[i].y.real      = spectrum[(i-number_points_by_2)*2+1];
	   data[i].y.imag      = spectrum[(i-number_points_by_2)*2+2];
	}

	printf("\nHalves deleted");

	delete[] spectrum;
	return(TRUE);
}



/*++++++++++++++++++++++++++++++++++*/
/* four1.c    single precision      */
/*++++++++++++++++++++++++++++++++++*/

#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

void fourier(double *data, int nn, int isign){

	int n,mmax,m,j,istep,i;
	double wtemp,wr,wpr,wpi,wi,theta;
	double tempr,tempi;

	n=nn << 1;
	j=1;

	for (i=1;i<n;i+=2) {
		if (j > i) {
			SWAP(data[j],data[i]);
			SWAP(data[j+1],data[i+1]);
		}
		m=n >> 1;
		while (m >= 2 && j > m) {
			j -= m;
			m >>= 1;
		}
		j += m;
	}
	mmax=2;

	while (n > mmax) {

		istep=mmax<<1;
		theta=6.28318530717959/(isign*mmax);
		wtemp=sin(0.5*theta);
		wpr = -2.0*wtemp*wtemp;
		wpi=sin(theta);
		wr=1.0;
		wi=0.0;

		for (m=1;m<mmax;m+=2) {

			for (i=m;i<=n;i+=istep) {
				j=i+mmax;
				tempr=(wr*data[j]-wi*data[j+1]);
				tempi=(wr*data[j+1]+wi*data[j]);
				data[j]=data[i]-tempr;
				data[j+1]=data[i+1]-tempi;
				data[i] += tempr;
				data[i+1] += tempi;
			}

	
			wr=(wtemp=wr)*wpr-wi*wpi+wr;
			wi=wi*wpr+wtemp*wpi+wi;
		}
		mmax=istep;
	}

}

#undef SWAP






//***************************
//*       Phase Data
//***************************

// Phase		in degrees
// DelayTime	in milliseconds


int PhaseData(Point *Input, Point *Output, int N, double Phase, double DelayTime){

	int i;
	double Phase_rad;
	double DelayTime_rad_Hz;



	Phase_rad		= -Phase * PI / 180.0;
	DelayTime_rad_Hz	= DelayTime / 1000.0 * 2 * PI;

	for(i=0;i<N;i++){

		Output[i].y.real =	Input[i].y.real * cos(Phase_rad + DelayTime_rad_Hz*Input[i].x) - 
							Input[i].y.imag * sin(Phase_rad + DelayTime_rad_Hz*Input[i].x);

		Output[i].y.imag =	Input[i].y.imag * cos(Phase_rad + DelayTime_rad_Hz*Input[i].x) +
							Input[i].y.real * sin(Phase_rad + DelayTime_rad_Hz*Input[i].x);


	}


	return(TRUE);
}




double Magnitude(Complex c){


	return(sqrt(c.real*c.real + c.imag*c.imag));


}


Complex signal_function(Peak2 *peak, double time){
   
	double	argument,
			decay;
	static Complex signal;

	time		+=	peak->parameter[DELAY_TIME].value;
	argument	=	time * peak->parameter[SHIFT].value * 2.0 * PI + peak->parameter[PHASE].value;

	decay	= exp(-PI * peak->parameter[WIDTH_LORENZ].value * time - PI * (PI / (4.0 * log(2.0)))
			* peak->parameter[WIDTH_GAUSS].value * peak->parameter[WIDTH_GAUSS].value * time * time);


	signal.real = (double)(peak->parameter[AMPLITUDE].value * decay * cos(argument));
	signal.imag = (double)(peak->parameter[AMPLITUDE].value * decay * sin(argument));

	return(signal);

}
//  + start_time 


//***************************
//*       Window Data
//***************************

// 	dwell_time in seconds
//  number_lb  in Hertz;


int WindowExp(Point *data, int number_points, double dwell_time, double number_lb){

	int i;


	if(number_lb != 0){
		for(i=0; i<number_points; i++){
			data[i].y.real=data[i].y.real*(float)exp(-1*PI*(double)i
				*dwell_time*number_lb);
			data[i].y.imag=data[i].y.imag*(float)exp(-1*PI*(double)i
				*dwell_time*number_lb);
		}
	}

	return(TRUE);

}




int WindowQSin(Point *data, double dwell_time, int start_point, int end_point){

	int i;
	double end_time;

	end_time = (double)(end_point-start_point)*dwell_time;


	for(i=0; i<end_point; i++){
		if(i < (start_point-1)){
			data[i].y.real = 0;
			data[i].y.imag = 0;
		}
		else{
			data[i].y.real *= sin((2.0*PI*dwell_time*(double)i)/(double)(4.0*end_time))
								* sin((2.0*PI*dwell_time*(double)i)/(4.0*end_time));
			data[i].y.imag *= sin((2.0*PI*dwell_time*(double)i)/(4.0*end_time))
								* sin((2.0*PI*dwell_time*(double)i)/(4.0*end_time));
		}
	}

	return(TRUE);
}
