#include <malloc.h>
#include <stdio.h>
#include <math.h>
#include "fit.h"


void mrqcof(Point *point,Complex *sig,double *a,int ma,int lista[],int mfit,
			double **alpha,double *beta,void (*funcs)(double,double *,Complex *,
			Complex *, int, int *, Peak2 *, int, Fit_info *, Complex), int *link, 
			Peak2 *peak2,Fit_info *fit_info, Complex *weight)
{
#ifdef _DEBUG
	FILE *test;   //DEBUG
#endif
	
	int k,j,i;
   Complex  *dyda, ymod, sig2i, wt, dy;
    
   dyda = (Complex *)new Complex[ma+1];

   for (j = 1; j<=mfit; j++){
      for (k = 1; k<=j; k++) alpha[j][k] = 0.0;
      beta[j] = 0.0;
   }

#ifdef _DEBUG
   test=fopen("c:\\temp\\fit.txt", "wt");
#endif

   
   fit_info->chi_squared = 0.0;
	
    
	for (i=fit_info->first_point; i<=fit_info->last_point; i++){

		(*funcs)(point[i].x, a, &ymod, dyda, ma, link, peak2, i, fit_info, weight[i]);
		
		if(sig[i].real > 0.0000000001 && sig[i].imag > 0.0000000001){
			sig2i.real = (weight[i].real * weight[i].real) / (sig[i].real * sig[i].real);
			sig2i.imag = (weight[i].imag * weight[i].imag) / (sig[i].imag * sig[i].imag);
		} else {
			sig2i.real = (weight[i].real * weight[i].real) / (0.0000000001 * 0.0000000001);
			sig2i.imag = (weight[i].imag * weight[i].imag) / (0.0000000001 * 0.0000000001);
		}

#ifdef _DEBUG
		fprintf(test,"%f %f\n", ymod.real, ymod.imag);
#endif

		dy.real = point[i].y.real - ymod.real;
		dy.imag = point[i].y.imag - ymod.imag;
     
		for (j=1; j<=mfit; j++){
			wt.real = dyda[lista[j]].real * sig2i.real;
			wt.imag = dyda[lista[j]].imag * sig2i.imag;

			for (k=1; k<=j; k++) 
				alpha[j][k] += (wt.real * dyda[lista[k]].real + wt.imag * dyda[lista[k]].imag);

			beta[j] += (dy.real * wt.real + dy.imag * wt.imag);
		}

		fit_info->chi_squared += (dy.real*dy.real*sig2i.real + dy.imag*dy.imag*sig2i.imag);
   
	}

#ifdef _DEBUG
	fclose(test);	
#endif


 	for (j=2; j<=mfit; j++) 
		for (k=1; k<=j-1; k++) alpha[k][j] = alpha[j][k];
   

	delete[] dyda;


}
