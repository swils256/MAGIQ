#include <stdio.h>
#include <math.h>
#include "fit.h"


int mrqmin(Point *point,Complex *sig,double *a,int ma,int *lista,int mfit,
			double **covar,double **alpha,void (*funcs)(double ,double *,Complex *, 
			Complex *, int, int *,Peak2 *,int, Fit_info *, Complex), double *alamda, 
			int *link, Peak2 *peak2, Fit_info *fit_info, Complex *weight)

{
	
   int k, kk, j, ihit, i;
   static double *beta, *da, *atry, **oneda, ochisq;



   if (*alamda < 0.0){
      oneda = dmatrix(1, mfit, 1, 1);
      atry = dvector(1, ma);
      da = dvector(1, ma);
      beta = dvector(1, ma);
      kk = mfit + 1;

      for (j=1; j<=ma; j++){
		ihit = 0;
		for (k=1; k<=mfit; k++)
			if (lista[k] == j) ihit++;
		if (ihit == 0)
			lista[kk++]=j;
		else if (ihit >1) nrerror("Bad LISTA permutation in MRQMIN - 1");
      }

      if (kk != ma+1) nrerror("Bad LISTA permutation in MRQMIN - 2");
  
	  *alamda = 0.001;

      mrqcof(point,sig,a,ma,lista,mfit,alpha,beta,*funcs,link,peak2,fit_info,weight);

      ochisq = fit_info->chi_squared;
   }

   for (j=1; j<=mfit; j++){
      for (k=1; k<=mfit; k++) 
		  covar[j][k] = alpha[j][k]; //fills up first row
      covar[j][j] = alpha[j][j] * (1.0+(*alamda)); //adjusts element in row that intesects with diagonal
      oneda[j][1] = beta[j];
   }
   

   if (!gaussj(covar,mfit,oneda,1)){ 
	   return (FALSE);
   }	
 

   for (j=1; j<=mfit; j++)
      da[j] = oneda[j][1];
   
	if (*alamda == 0.0){	
		covsrt(covar,ma,lista,mfit);
		free_dvector(beta,1,ma);
		free_dvector(da,1,ma);
		free_dvector(atry,1,ma);
		free_dmatrix(oneda,1,mfit,1,1);
		return (TRUE);
	}
   
	   for (j=1; j<=ma; j++) atry[j]=a[j];
   
   for (j=1; j<=mfit; j++)
      atry[lista[j]] = a[lista[j]]+da[j];


   
   //update all linked parameters

	for (j = 0; j< fit_info->number_peaks; j++){

		for (i=0; i<peak2[j].number_parameters; i++){

			if (peak2[j].parameter[i].linked != FIXED){

				if (peak2[j].parameter[i].link_type == OFFSET){

					// Aug 17, 2004 - Bug reported by Tim Devito (Lawson)
					// Incorrect linking of Gaussian widths - essentially the offset modifier was being added to the square of the Gaussian width term
					// rather then directly to the width term
					// Fix - determine if offset modifier was being applied to Gaussian linked parameter - if not, no change
					// - if yes, then take the square root of Gaussian term, add the modifier, then square the result.
					
					// Additional bug reported by Tim Devito following the above fix: chi_squared being calculated with nan
					// Fix - The calculation of atry for the Gaussian widths involves taking the sqrt of the atry value so that
					// the offset can be added correctly.  However Gaussian widths can mathematically be calculated as positive or
					// negative - in the case where they are negative, must take the absolute value first - therefore, I have 
					// added the fabs funtion into the line below.
					
					
					if (i != WIDTH_GAUSS) {
						atry[peak2[j].number_parameters * j + i+1] = atry[link[peak2[j].number_parameters * j + i+1]] - peak2[peak2[j].parameter[i].linked].parameter[i].modifier + peak2[j].parameter[i].modifier;

					} else {	
						atry[peak2[j].number_parameters * j + i+1] = (sqrt(fabs(atry[link[peak2[j].number_parameters * j + i+1]]))- peak2[peak2[j].parameter[i].linked].parameter[i].modifier + peak2[j].parameter[i].modifier) * (sqrt(fabs(atry[link[peak2[j].number_parameters * j + i+1]])) - peak2[peak2[j].parameter[i].linked].parameter[i].modifier + peak2[j].parameter[i].modifier);
					}


				} else {

					atry[peak2[j].number_parameters * j + i+1] = atry[link[peak2[j].number_parameters * j + i+1]] / peak2[peak2[j].parameter[i].linked].parameter[i].modifier * peak2[j].parameter[i].modifier;
				}	
			}
		}
		
		// check to see if the delay time becomes very very small (< 1 micro second)...
		// if it does...set it to zero

		if (sqrt(atry[peak2[j].number_parameters * j + DELAY_TIME + 1] * atry[peak2[j].number_parameters * j + DELAY_TIME + 1]) < 0.000001)
			atry[peak2[j].number_parameters * j + DELAY_TIME + 1] = 0.0;
	
		// check to see if the phase becomes very very small (< 0.0057 degrees)...
		// if it does...set it to zero

		if ( sqrt(atry[peak2[j].number_parameters * j + PHASE + 1]*atry[peak2[j].number_parameters * j + PHASE + 1]) < 0.0001)
			atry[peak2[j].number_parameters * j + PHASE + 1] = 0.0;
	
		// check to see if Gaussian width is negative...if it is, make it positive
		// this only affects the derivative wrt Gaussian width...all other term which
		// incorporate the Gaussian width square it.

 		if ( atry[peak2[j].number_parameters * j + WIDTH_GAUSS + 1] < 0) atry[peak2[j].number_parameters * j + WIDTH_GAUSS + 1] = -1.0 * atry[peak2[j].number_parameters * j + WIDTH_GAUSS + 1];
	
	}

   
   mrqcof(point,sig,atry,ma,lista,mfit,covar,da,*funcs,link,peak2,fit_info,weight);
   
   if (fit_info->chi_squared < ochisq){
		*alamda *= fit_info->alambda_dec;
		ochisq = fit_info->chi_squared;
		for (j=1; j<=mfit; j++){
			for (k=1; k<=mfit; k++) alpha[j][k] = covar [j][k];
			beta[j] = da[j];
		}

		for (j=1; j<=ma; j++) a[j] = atry[j];
      
   } 
   
   else {
      *alamda *= fit_info->alambda_inc;
//      fit_info->chi_squared = ochisq; should not be set until later
   }
   return (TRUE);
}