// Function Fit

#include <stdio.h>
#include <math.h>
#include <string.h>
#include "fit.h"

int fit(Point *point, Complex *sig, Peak2 *peak2, double **covar, Fit_info 
		*fit_info, Complex *weight)
{
	
	int k, itst, mcai, i, ma, j, mfit, *lista, *link, iteration_counter;
	double *a, **alpha, alamda, ochisq;

	// check to see if the minimum # of iterations between chisquared comparisons
	// is less than the maximum # of iterations

	if (fit_info->minimum_iterations >= fit_info->maximum_iterations){
		output_trap(4,"\n\nFATAL ERROR ... \n\nSet min iterations < max iterations.\n", 0,0,0,0,0,0,0,0,0);
	}
		
	output_trap(1,"\nInitializing variables...", 0,0,0,0,0,0,0,0,0); 
			

	ma = peak2[0].number_parameters * fit_info->number_peaks;
	mfit = 0;
	alamda = (float)(-1.0);

	lista = ivector(1, ma);
	alpha = dmatrix(1, ma, 1, ma);
	a = dvector(1, ma);
	link = ivector(1, ma);	
	
	
// determine the parameter values for the entire model
// these values are put into the vector a in the following order
// shift, Lorentzian width, amplitude, phase, delay_time, Gaussian width
// determine the linking for the entire model
// the master parameter that each parameter is linked to is put into the vector link 
// in the following order shift, width, amplitude, phase, delay_time
// if a parameter is fixed link is assigned zero

	for (j=0; j<fit_info->number_peaks; j++){

		for (i=0; i<peak2[j].number_parameters; i++){

			if (i != WIDTH_GAUSS) a[peak2[j].number_parameters*j+i+1] 
				= peak2[j].parameter[i].value;

			else a[peak2[j].number_parameters*j+i+1] 
				= peak2[j].parameter[i].value * peak2[j].parameter[i].value;			

				
			if (peak2[j].parameter[i].linked != -1) link[peak2[j].number_parameters*j+i+1] 
				= (peak2[j].parameter[i].linked * peak2[j].number_parameters) +i+1; 
	
			else link[peak2[j].number_parameters*j + i+1] = 0;

		}			
	}

	
// determine the number of parameters that are actually fit (mfit)
// this corresponds to the number of "master" peaks
// it also lists these parameters in the vector lista
// therefore, the first mfit values in lista correspond to the index of 
// the vector a for the the mfit adjusted parameters

	j = 1;

	for (k=0; k<fit_info->number_peaks; k++){ 

		for (i=0; i<peak2[k].number_parameters; i++){

			if(peak2[k].parameter[i].linked==k){
				mfit++;		
				lista[j] = (peak2[k].number_parameters*k) + (i+1);
				fit_info->lista[j] = lista[j];
				j++;
			}
		}
	}
		
	fit_info->total_fit_parameters = mfit;


	output_trap(1,"Done!\n\n", 0,0,0,0,0,0,0,0,0); 
	output_trap(1,"Beginning iterative Marquardt fit...\n", 0,0,0,0,0,0,0,0,0); 
	
    if (!strcmp(fit_info->domain, "TIME_DOMAIN")){	
		if (!mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,dam_exp2,&alamda,link,peak2,fit_info,weight)) 
			return (FALSE);
	} else if (!strcmp(fit_info->domain, "FREQUENCY_DOMAIN")){
		if (!mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,freq_exp,&alamda,link,peak2,fit_info,weight))
			return (FALSE);	
	} else if (!strcmp(fit_info->domain, "T2_DOMAIN")){
		mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,T2_function,&alamda,link,peak2,fit_info,weight);
	} else if (!strcmp(fit_info->domain, "T1_DOMAIN")){
		mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,T1_function,&alamda,link,peak2,fit_info,weight);
	}
	
	itst = 0;
	mcai = 0;
	iteration_counter = 1;

	ochisq = fit_info->chi_squared;

	while (itst < fit_info->minimum_iterations 
		&& iteration_counter <= fit_info->maximum_iterations
		&& mcai < fit_info->max_con_alambda_inc){

		output_trap(2,"", iteration_counter,fit_info->chi_squared,alamda,0,0,0,0,0,0); 
		


#ifdef _DEBUG

	output_trap(1,"  shift     width_L   width_G   amplitude  phase     delay\n", 0,0,0,0,0,0,0,0,0); 

	for (i=1; i<= ma; i+=6){
		output_trap(3,"",0,0,0,a[i],a[i+1],sqrt(a[i+5]),a[i+2],a[i+3],a[i+4]); 
	}

#endif


		output_trap(1,"\n\n", 0,0,0,0,0,0,0,0,0); 

		iteration_counter++;

//		ochisq = fit_info->chi_squared;  move this above while statement
		
		if (!strcmp(fit_info->domain, "TIME_DOMAIN")){	
			if (!mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,dam_exp2,&alamda,link,peak2,fit_info,weight)) 
				return (FALSE);
		} else if (!strcmp(fit_info->domain, "FREQUENCY_DOMAIN")){
			if (!mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,freq_exp,&alamda,link,peak2,fit_info,weight))
				return (FALSE);	
		} else if (!strcmp(fit_info->domain, "T2_DOMAIN")){
			mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,T2_function,&alamda,link,peak2,fit_info,weight);
		} else if (!strcmp(fit_info->domain, "T1_DOMAIN")){
			mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,T1_function,&alamda,link,peak2,fit_info,weight);
		}
		
/*		if (fit_info->chi_squared > ochisq){
			itst = 0;
		}
		else if (fabs((ochisq - fit_info->chi_squared)/ochisq*100) < fit_info->tolerence){
		//			ochisq - fit_info->chi_squared != 0.0){
				itst++;
		}	*/

		if (fit_info->chi_squared <= ochisq){
			if(fabs((fit_info->chi_squared-ochisq)/ochisq*100) < fit_info->tolerence)
				itst++;
			ochisq = fit_info->chi_squared;
			mcai = 0;
		}
		if (fit_info->chi_squared > ochisq){
			if(fabs((fit_info->chi_squared-ochisq)/ochisq*100) < fit_info->tolerence){
				itst++;
			}else{
				itst = 0;
			}
			
			mcai++;
		}
	}
	


	alamda = (float)0.0;
	

	if (!strcmp(fit_info->domain, "TIME_DOMAIN")){	
		if (!mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,dam_exp2,&alamda,link,peak2,fit_info,weight)) 
			return (FALSE);
	} else if (!strcmp(fit_info->domain, "FREQUENCY_DOMAIN")){
		if (!mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,freq_exp,&alamda,link,peak2,fit_info,weight))
			return (FALSE);	
	} else if (!strcmp(fit_info->domain, "T2_DOMAIN")){
		mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,T2_function,&alamda,link,peak2,fit_info,weight);
	} else if (!strcmp(fit_info->domain, "T1_DOMAIN")){
		mrqmin(point,sig,a,ma,lista,mfit,covar,alpha,T1_function,&alamda,link,peak2,fit_info,weight);
	}


	if (iteration_counter == fit_info->maximum_iterations+1){ 
		output_trap(1,"\nWARNING:  Maximum number if iterations has been reached.\n", 0,0,0,0,0,0,0,0,0); 
		output_trap(1,"          Current parameter values have been retained.\n", 0,0,0,0,0,0,0,0,0); 
	}

	if (mcai == fit_info->max_con_alambda_inc){ 
		output_trap(1,"\nWARNING:  Maximum number of futile alambda increases were executed.\n", 0,0,0,0,0,0,0,0,0); 
		output_trap(1,"          Current parameter values have been retained.\n", 0,0,0,0,0,0,0,0,0); 
	}


	for (i=1; i<= ma; i+=6){

		// determine the proper error for the Gaussian width term
		if (a[i+5] != 0)	
			covar[i+5][i+5] = pow((sqrt(fabs(covar[i+5][i+5]))/a[i+5])*sqrt(fabs(a[i+5])),2);
		else	
			covar[i+5][i+5] = 0.0;
	}


#ifdef _DEBUG
	
	output_trap(1,"\nCramer-Rao Lower Bounds (Standard Deviations):\n\n", 0,0,0,0,0,0,0,0,0); 
	output_trap(1,"  shift     width_L   width_G   amplitude  phase     delay\n", 0,0,0,0,0,0,0,0,0); 

	for (i=1; i<= ma; i+=6){
		
		output_trap(3,"",0,0,0,sqrt(fabs(covar[i][i])),sqrt(fabs(covar[i+1][i+1])),sqrt(fabs(covar[i+5][i+5])),
						sqrt(fabs(covar[i+2][i+2])),sqrt(fabs(covar[i+3][i+3])),sqrt(fabs(covar[i+4][i+4]))); 
	}

#endif

	

// now that the fitting is complete, we need to reassign the values of the 
// parameters contained in the vector a[] back into the peak structure
// we also assign the proper errors to each parameter
// if parameter is linked as an offset absolute error is the same as master
// if parameter is linked as a ratio the relative error for that parameter is
// the same as the relative error in the master peak


	for (j=0; j<fit_info->number_peaks; j++){

		for (i=0; i<peak2[j].number_parameters; i++){
			
			// assign values
			
			if (i != WIDTH_GAUSS) peak2[j].parameter[i].value 
				= a[peak2[j].number_parameters*j+i+1];
			
			else peak2[j].parameter[i].value 
				= sqrt(fabs(a[peak2[j].number_parameters*j+i+1]));

			// assign errors
			
			if (peak2[j].parameter[i].link_type == OFFSET && peak2[j].parameter[i].linked != FIXED)
				peak2[j].parameter[i].standard_deviation = 
					sqrt(fabs(covar[(peak2[j].parameter[i].linked*6)+i+1]
					[(peak2[j].parameter[i].linked*6)+i+1]));

			if (peak2[j].parameter[i].link_type == RATIO && peak2[j].parameter[i].linked != FIXED){
	
			//  The Cramer-Rao standard deviation of the amplitudes (or any parameter that
		    //  is linked as a ratio is calculated as the Cramer-Rao standard deviation of 
			//  the parameter multiplied by the ratio modifier.  This is analogous to the
			//  calculation of the peak areas which is given by the parameter value multiplied
			//  by the ratio modifier.

				peak2[j].parameter[i].standard_deviation = peak2[j].parameter[i].modifier * 
					sqrt(fabs(covar[(peak2[j].parameter[i].linked*6)+i+1][(peak2[j].parameter[i].linked*6)+i+1]));
			
			/*	percent_error = sqrt(fabs(covar[(peak2[j].parameter[i].linked*6)+i+1]
					[(peak2[j].parameter[i].linked*6)+i+1])) / 
					peak2[peak2[j].parameter[i].linked].parameter[i].value;
					
				peak2[j].parameter[i].standard_deviation = peak2[j].parameter[i].value * 
					percent_error;*/

			}
		}
	}


 	free_dmatrix(alpha, 1, ma, 1, ma);
	free_ivector(lista, 1, ma);
	free_ivector(link, 1, ma);
	free_dvector(a, 1, ma);

return(TRUE);

 }
