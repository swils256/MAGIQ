// output file
// sends all output from the fitting algorithm through
// this file before it goes to the screen

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fit.h"

void output_trap(int output_type, char *message, int iteration_counter, 
				 double chi_squared,double alamda, double  shift, 
				 double width_L, double width_G,double amplitude, 
				 double phase, double delay)
{
	switch(output_type){

		case 1 :	printf(message);
					break;

		case 2 :	printf("\n%s %2d %17s %10.4E %10s %9.2e\n\n", "Iteration #", iteration_counter,
					"chi-squared:",chi_squared, "alamda:", alamda);
					break;
					
		case 3 :	printf("%9.4f %9.4f %9.4f %9.4f %9.4f %9.4f \n",shift,width_L,width_G,amplitude,phase,delay);
					break;

		case 4 :	printf(message);
					return;

		case 5 :	printf("\n%2d %s\n\n", iteration_counter, message);
					break;

		default :	printf("Output Error");
					break; 
	
	}
}
