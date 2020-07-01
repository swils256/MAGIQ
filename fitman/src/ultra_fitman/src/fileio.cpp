/*                          FILEIO.CPP

This module contains all functions for file handling:
Read  NMR286 text and binary format
Read  Contraints file
Read  Peak guess file
Write Peak guess file                              */

#include <stdio.h>
#include <string.h>
//#include <malloc.h>
#include <stdlib.h>

//revised by jd, Oct. 21, 2009
//#include <iostream.h>
//#include <fstream.h>
#include <iostream>
#include <fstream>
//end of revised code


//#include <parse.h>
#include "parse.h" //V

//#include <fit.h>
#include "fit.h" //V

//#include <fileio.h>
#include "fileio.h" //V

//added by jd, Oct. 21, 2009 
using namespace std;
//end of added code

//******************************
//* Read NMR Text Format
//******************************

int read_nmr_text(char *filename, Point ** data_passed, NMR_Header *header){

	char	text_line[80];
	int	i;
	int	number_points;
	Point	*data;

	// Declare input stream object
        ifstream input(filename, ios::in);

	if (!input) {/*file does not exist*/

	  //added to debug
	  cout << "file does not exist" << endl;
                    }

	else {

	  //added to debug
	  cout << "file exists" << endl;

	  if(input.fail()){

            //added to debug
	    cout << "input.fail" << endl;

	    return(FALSE);}

 		input		>> header->si
				>> header->nrecs
				>> header->dw
				>> header->sf
				>> header->ns;
    		input.getline(text_line, 80);
	    	input.getline(text_line, 80);
		strncpy(header->machineid, text_line, 29);
		header->machineid[28]=0;
		input.getline(text_line, 80);
		
		printf("%s\n",text_line);
		
		strncpy(header->date, text_line, 30);
		header->date[29]=0;
    		input.getline(text_line, 80);
		strncpy(header->comment1, text_line, 40);

		
		printf("%s\n",text_line);

	
		header->comment1[39]=0;
	    	input.getline(text_line, 80);
		strncpy(header->comment2, text_line, 40);
		header->comment2[39]=0;
    		input.getline(text_line, 80);
	    	input.getline(text_line, 80);
    		input.getline(text_line, 80);

		header->de = 0.0f;
		header->sf *= 1000000.0;
		number_points = header->si/2;

	

		data = (Point *)malloc(sizeof(Point)*(long)header->si/2L);


 	   	if(data != NULL){

			for(i=0;i<(header->si/2);i++){
				input	>> data[i].y.real
					>> data[i].y.imag;
				if(input.eof())
					return(FALSE);
			}



			// Set time domain x values
			for(i=0; i<number_points; i++)
				data[i].x = header->de + (float)i*(float)header->dw;
		}
	


 	   	input.close();

	
		*data_passed = data;

    		return(TRUE);
    	}
	return(FALSE);
}




//******************************
//* Read NMR Binary Format
//******************************

int read_nmr_binary(char *filename, Point **data_passed, NMR_Header *nmr_rec){

	int	i, number_points;
	Point	*data;
	float	temp_real,
temp_imag;


	/***  Read Data File In  ****/


	// Declare input stream object
	#ifdef _MSC_VER
              fstream input(filename, ios::in|ios::binary);
        #else
              fstream input(filename, ios::in);
	#endif

	if (!input) {/*file does not exist*/}

	else {
	

		if(input.fail())
			return(FALSE);

		// Read binary header
		input.read((char *)nmr_rec, sizeof(NMR_Header));
		number_points = nmr_rec->si / 2;


		data = (Point *)malloc(sizeof(Point)*number_points);


		// Set file pointer to start of data
		input.seekp(nmr_rec->offsets[7] * SECSIZE, ios::beg);


		if(nmr_rec->dstatus>=32 && nmr_rec->dstatus < 64){
	
//Changed unsigned char to just char in 4 places line 135, 136, 143, 147
			for(i=0; i<number_points; i++){
				input.read((char *)&temp_real, sizeof(float));
				input.read((char *)&temp_imag, sizeof(float));
				data[i].y.real = temp_real;
				data[i].y.imag = temp_imag;
			}
		}
		else if(nmr_rec->dstatus < 32){
			for(i=0; i<number_points; i++){
				input.read((char *)&temp_real, sizeof(float));
				data[i].y.real = temp_real;
			}
		
			for(i=0; i<number_points; i++){
				input.read((char *)&temp_imag, sizeof(float));
				data[i].y.imag = temp_imag;
			}
		}


		// Set time domain x values
		for(i=0; i<number_points; i++)
			data[i].x = nmr_rec->de + (float)i*(float)nmr_rec->dw;


		input.close();

		*data_passed = data;
		return(TRUE);
	}
	return(FALSE);

}


void error_message(char *message_string, int level){

	switch(level){

		case INFO	:
		case WARNING	:	printf("%s\n",message_string);
					break;
		case FATAL	:	printf("%s\n",message_string);
					exit(1);
					break;

	}

}

//*********************************
//*  Convert string to uppercase
//*********************************
char *string_to_upper( char *string){
	int i=0;

	while(string[i]){
		string[i] = toupper(string[i]);
		i++;
	}

	return(string);
}



#define PARAMETERS	1
#define VARIABLES	2
#define PEAKS		3

//******************************
//* Read Initial Guess Text
//******************************

Error read_guess_file(char *filename, Peak2 **peak_passed, Fit_info *fit_info, CVariable *variable){


	// Initial Guess file parameters

	int current_peak=0;
	Error error={0,0,0};

	char	token[255];
	char	element[50];
	short	section=0;
	double	temp_double;
	int	parameter_index;
	double  reference_frequency;
	Peak2	*peak;
	int	i,j;
	int	index;

	ifstream input(filename, ios::in );

	if (!input) {/*file does not exist*/}

	else {
	
	peak = *peak_passed;

		if(input.fail()){
			error.code = -1;
			return(error);
		}

		// Search for Guess File Label
		do{
			input >> token;
		}while(!input.eof() && strncmp(token, "****_Guess_File_Begins_****", 20) != 0);

		// If Guess File label not found assume file is guess file and start at beginning
		if(strncmp(token, "****_Guess_File_Begins_****", 20)!=0){
			//input.seekg(0);
//COMENTED OUT
			input.close();
			input.open(filename, ios::in);
	
	}


		#ifdef _DEBUG
			printf("  Shift      Width L   Amplitude    Phase     Delay   Width G  \n");
			printf("--------------------------------------------------------------\n");
		#endif
		// Get reference_frequency from variables
		variable->get_value("REFERENCE_FREQUENCY", reference_frequency);


		// Initialize shift units as ppm

		if(fit_info->shift_units_guess == PPM){	// shift units PPM
			variable->update_variable("PPM",1.0);
		   	variable->update_variable("HERTZ",1.0e6/reference_frequency);
		}
		else{								// shift units HERTZ
		   	variable->update_variable("PPM",reference_frequency/1.0e6);
	   		variable->update_variable("HERTZ",1.0);
		}


		while( !input.eof() ){
			input >> token;

	
			if(input.eof())
				break;

			string_to_upper(token);

			if( token[0] == ';' || token[0] == 0){	// if remark or blank line
				input.getline(token,255);
				continue;
			}
			if( token[0] == '*'){	// check for control line
				if(strncmp(token, "****_GUESS_FILE_ENDS_****", 25)==0)
					break;    // If end of guess file exit
			}

			if(token[0] == '['){					// if section heading
				if(strcmp(token, "[PARAMETERS]")==0){
					section = PARAMETERS;
					error.line =	-2;
					error.element = 0;
				}

				if(strcmp(token, "[VARIABLES]")==0){
					section = VARIABLES;
					error.line = -1;
					error.element = 0;
				}

				if(strcmp(token, "[PEAKS]")==0){
					section = PEAKS;
					if(!peak){
						peak =new Peak2[fit_info->number_peaks_guess];

						fit_info->number_peaks = fit_info->number_peaks_guess;

						for(i=0;i<fit_info->number_peaks_guess;i++){
							peak[i].number_parameters = NUMBER_PARAMETERS;
							peak[i].parameter = new Parameter2[peak[i].number_parameters];
							// Initialize link types
							peak[i].parameter[SHIFT].link_type			= OFFSET;
							peak[i].parameter[SHIFT].modifier			= 0.0;
							peak[i].parameter[WIDTH_LORENZ].link_type	= OFFSET;
							peak[i].parameter[WIDTH_LORENZ].modifier	= 0.0;
							peak[i].parameter[WIDTH_GAUSS].link_type	= OFFSET;
							peak[i].parameter[WIDTH_GAUSS].modifier		= 0.0;
							peak[i].parameter[AMPLITUDE].link_type		= RATIO;
							peak[i].parameter[AMPLITUDE].modifier		= 1.0;
							peak[i].parameter[PHASE].link_type			= OFFSET;
							peak[i].parameter[PHASE].modifier			= 0.0;
							peak[i].parameter[DELAY_TIME].link_type		= OFFSET;
							peak[i].parameter[DELAY_TIME].modifier		= 0.0;
							// Initialize Standard Deviations to zero
							for(j=0; j< peak[i].number_parameters; j++){
								peak[i].parameter[j].linked					= i;
								peak[i].parameter[j].standard_deviation		= 0.0;
							}
						}

					}
				}
				continue;
			}

			switch(section){

	
				case PARAMETERS	:	error.element++;
							//******* Read Fit Parameters *********
							index=-1;
							while(index < NUMBER_FIT_PARAMETERS_GUESS && strcmp(token,fit_info->fit_parameter_guess[++index].label));

							// If Parameter Label Found update fit info data
							if(index < NUMBER_FIT_PARAMETERS_GUESS){
								if(fit_info->fit_parameter_guess[index].argument_type[0] == 'M'){
									*(fit_info->fit_parameter_guess[index].pointer.i[0]) |= 1 << (int)fit_info->fit_parameter_guess[index].argument_type[1];
								}
								else{
									for(i=0;i<fit_info->fit_parameter_guess[index].number_arguments;i++){
										input >> token;
										error.element++;
										string_to_upper(token);
										switch (fit_info->fit_parameter_guess[index].argument_type[0]){
											case 'I' :	if((error.code = parse_item(token, variable, *(fit_info->fit_parameter_guess[index].pointer.i[i])))!=0)
													return(error);
													break;
											case 'S' :	strcpy(fit_info->fit_parameter_guess[index].pointer.s[i], token);
													break;
											case 'D' :	if((error.code = parse_item(token, variable, *(fit_info->fit_parameter_guess[index].pointer.d[i])))!=0)
														return(error);
													break;
										}
									}
								}
							}
							// Update Constraints File shift units
							if(!strcmp(fit_info->fit_parameter_guess[index].label,"SHIFT_UNITS")){
								if(!strcmp(fit_info->shift_units_guess , "HERTZ")){
									variable->update_variable("PPM",reference_frequency/1.0e6);
									variable->update_variable("HERTZ",1.0);
								}
								else{
									variable->update_variable("PPM",1.0);
									variable->update_variable("HERTZ",1.0e6/reference_frequency);
								}
							}
							break;

				case VARIABLES	:	input >> element;
							error.element+=2;
							if((error.code = parse_item(string_to_upper(element), variable, temp_double))!=0)
								return(error);
							// If variable does not already exist create
							variable->put_variable(string_to_upper(token), temp_double);
							break;
				case PEAKS	:	error.element = 1;
							strcpy(element,token);
							if((error.code = parse_item(element, variable,
temp_double))!=0)
								return(error);
							current_peak = (int)temp_double - 1;
							error.line = current_peak;
							if(current_peak >= fit_info->number_peaks){
								error.code = 3;     // return error
							}
							for(parameter_index=0;
parameter_index<peak[current_peak].number_parameters; parameter_index++){
								error.element++;
								input >> element;
								error.code = parse_item(string_to_upper(element), variable,
peak[current_peak].parameter[parameter_index].value);
								// if shift parameter change to Hertz depending on default units
								if(parameter_index == SHIFT && !strcmp(fit_info->shift_units_guess, "PPM"))
									peak[current_peak].parameter[parameter_index].value *= (reference_frequency /
1000000.0);
								if(error.code)
									return(error);
								#ifdef _DEBUG
									printf(" %10.3f ", peak[current_peak].parameter[parameter_index].value);
								#endif
							}


							#ifdef _DEBUG
								printf("\n");
							#endif
							current_peak++;
							break;
			} //END SELECT (or SWITCH)

		}



		input.close();

		*peak_passed = peak;

		return(error);
	}
	error.code = -1;
	return(error);

} // end read_guess_file



/*#define FIX_ALL_SHIFT		2
#define FIX_ALL_L_WIDTH		4
#define FIX_ALL_G_WIDTH		8
#define FIX_ALL_DELAY_TIME	16
#define FIX_ALL_PHASE		32
#define FIX_ALL_AMPLITUDE	64*/
  //ALL THESE DEFN's HAVE BEEN COMMENTED OUT


//******************************
//* Read Constraints Text
//******************************

Error read_constraints_file(char *filename, Peak2 **peak_passed, Fit_info *fit_info, CVariable *variable){

	// Constraints file parameters

	int current_peak=0;
	Error error={0,0,0};

	char	token[255];
	char	element[50];
	int	index;
	short	section=0;
	double	temp_double;
	long	fix_all=0, fix_all_parameters[NUMBER_PARAMETERS], check_fix_all; // fix status DWORD

	// Link setup variables
    	int	operator_code;
        char	constant_string[64];
	char	link_label[32];
	int	i, j;
	int	parameter_index;
	double  reference_frequency;
	Peak2	*peak;

	// Variable Object declaration
	CVariable parameter[NUMBER_PARAMETERS];

	for(i=0;i<NUMBER_PARAMETERS;i++)
		parameter[i].initialize(MAX_NUMBER_LINKS);

	// Initialize fix_all_parameters array

	for(i=0; i<NUMBER_PARAMETERS; i++)
		fix_all_parameters[i] = 1 << i;

	ifstream input(filename, ios::in);


	if (!input) {/*file does not exist*/}

	else {

		if(input.fail()){
			error.code = -1;
			return(error);
		}

		// Search for Constraints File Label
		do{
			input.getline(token,255);
		}while( !input.eof() && strncmp(token, "****_Constraints_File_Begins_****", 33) != 0);

		// If Constraints File label not found assume file is constraints file and start at beginning
		if(strncmp(token, "****_Constraints_File_Begins_****", 33)!=0){
			//input.seekg(0);
			input.close();
			input.open(filename, ios::in);
			if (!input) {/*file does not exist*/
				error.code = -1;
				return(error);
			}
			else { /*Don't exactly know what to put here.  I guess code will just go on.*/}
		}


		peak = *peak_passed;

		#ifdef _DEBUG
			printf("\n  Shift      Width L   Amplitude    Phase     Delay   Width G  \n");
			printf("--------------------------------------------------------------\n");
		#endif

		// Get reference_frequency from variables
		variable->get_value("REFERENCE_FREQUENCY", reference_frequency);


		// Initialize shift units as ppm
		if(fit_info->shift_units_constraints == PPM){	// shift units PPM
			variable->update_variable("PPM",1.0);
		   	variable->update_variable("HERTZ",1.0e6/reference_frequency);
		}
		else{						// shift units HERTZ
		   	variable->update_variable("PPM",reference_frequency/1.0e6);
	 	  	variable->update_variable("HERTZ",1.0);
		}


		// Primer Read
		input >> token;


		while( !input.eof() ){


			string_to_upper(token);

			if( token[0] == ';' || token[0] == 0){	// if remark or blank line
				input.getline(token,255);
				input >> token;
				continue;
			}

			if( token[0] == '*'){	// check for control line
				if(strncmp(token, "****_CONSTRAINTS_FILE_ENDS_****", 30)==0)
					break;    // If end of contraints file exit
			}


			if(token[0] == '['){					// if section heading
				if(strcmp(token, "[PARAMETERS]")==0){
					section = PARAMETERS;
					error.element=0;
					error.line = -2;
				}

				if(strcmp(token, "[VARIABLES]")==0){
					section = VARIABLES;
					error.element=0;
					error.line = -1;
				}

				if(strcmp(token, "[PEAKS]")==0){
					section = PEAKS;
					error.element=0;
					if(!peak){
						peak =new Peak2[fit_info->number_peaks];
						for(i=0;i<fit_info->number_peaks;i++){
							peak[i].number_parameters = NUMBER_PARAMETERS;
							peak[i].parameter = new Parameter2[peak[i].number_parameters];
							peak[i].parameter[SHIFT].link_type			= OFFSET;
							peak[i].parameter[WIDTH_LORENZ].link_type	= OFFSET;
							peak[i].parameter[WIDTH_GAUSS].link_type	= OFFSET;
							peak[i].parameter[AMPLITUDE].link_type		= RATIO;
							peak[i].parameter[PHASE].link_type			= OFFSET;
							peak[i].parameter[DELAY_TIME].link_type		= OFFSET;
							// Initialize Upper Bound
							peak[i].parameter[SHIFT].max_bound			= 9e99;
							peak[i].parameter[WIDTH_LORENZ].max_bound	= 9e99;
							peak[i].parameter[WIDTH_GAUSS].max_bound	= 9e99;
							peak[i].parameter[AMPLITUDE].max_bound		= 9e99;
							peak[i].parameter[PHASE].max_bound			= 9e99;
							peak[i].parameter[DELAY_TIME].max_bound		= 9e99;
							// Initialize Lower Bound
							peak[i].parameter[SHIFT].min_bound			= -9e99;
							peak[i].parameter[WIDTH_LORENZ].min_bound	= -9e99;
							peak[i].parameter[WIDTH_GAUSS].min_bound	= -9e99;
							if(fit_info->positive_amplitudes)
								peak[i].parameter[AMPLITUDE].min_bound		= 0;
							else
								peak[i].parameter[AMPLITUDE].min_bound		= -9e99;
							peak[i].parameter[PHASE].min_bound			= -9e99;
							peak[i].parameter[DELAY_TIME].min_bound		= -9e99;
							// Initialize Standard Deviations to zero
							peak[i].parameter[SHIFT].standard_deviation			= 0.0;
							peak[i].parameter[WIDTH_LORENZ].standard_deviation	= 0.0;
							peak[i].parameter[WIDTH_GAUSS].standard_deviation	= 0.0;
							peak[i].parameter[AMPLITUDE].standard_deviation		= 0.0;
							peak[i].parameter[PHASE].standard_deviation			= 0.0;
							peak[i].parameter[DELAY_TIME].standard_deviation	= 0.0;
						}

					}

	
				}

				input >> token;
				continue;
			}

			switch(section){

			case PARAMETERS	:	error.element++;
						//******* Read Fit Parameters *********
						index=-1;
						while(index < NUMBER_FIT_PARAMETERS_CONSTRAINTS && strcmp(token,fit_info->fit_parameter_con[++index].label));

						// If Parameter Label Found update fit info data
						if(index < NUMBER_FIT_PARAMETERS_CONSTRAINTS){
							if(fit_info->fit_parameter_con[index].argument_type[0] == 'M'){
								*(fit_info->fit_parameter_con[index].pointer.i[0]) |= 1 << (int)fit_info->fit_parameter_con[index].argument_type[1];
							}
							else{
								for(i=0;i<fit_info->fit_parameter_con[index].number_arguments;i++){
									input >> token;
									error.element++;
									string_to_upper(token);
									switch (fit_info->fit_parameter_con[index].argument_type[0]){
										case 'I' :	if((error.code = parse_item(token, variable, *(fit_info->fit_parameter_con[index].pointer.i[i])))!=0)
													return(error);
												break;
										case 'S' :	strcpy(fit_info->fit_parameter_con[index].pointer.s[i], token);
												break;
										case 'D' :	if((error.code = parse_item(token, variable, *(fit_info->fit_parameter_con[index].pointer.d[i])))!=0)
													return(error);
												break;
									}
								}
							}
						}
						// Update Constraints File shift units
						if(!strcmp(fit_info->fit_parameter_con[index].label,"SHIFT_UNITS")){
							if(!strcmp(fit_info->shift_units_constraints , "HERTZ")){
								variable->update_variable("PPM",reference_frequency/1.0e6);
								variable->update_variable("HERTZ",1.0);
							}
							else{
								variable->update_variable("PPM",1.0);
								variable->update_variable("HERTZ",1.0e6/reference_frequency);
							}
						}

						input >> token;
						break;
			case VARIABLES	:	error.element+=2;

						input >> element;

						if((error.code = parse_item(string_to_upper(element), variable, temp_double))!=0)
							return(error);

						// If variable does not already exist create
						variable->put_variable(string_to_upper(token), temp_double);

						input >> token;
						break;
			case PEAKS	:	// Get Peak Number
						error.element = 1;
						strcpy(element,token);
						if((error.code = parse_item(element, variable, temp_double))!=0)
							return(error);
						current_peak = (int)temp_double - 1;
						error.line = current_peak;
						if(current_peak >= fit_info->number_peaks){
							error.code = 3;     // return peak # too large
							return(error);
						}
						input >> element;

						for(parameter_index=0;
parameter_index<peak[current_peak].number_parameters;
parameter_index++){

							error.element=parameter_index+1;


							if(element[0] == '@'){
								peak[current_peak].parameter[parameter_index].linked = FIXED;
								peak[current_peak].parameter[parameter_index].modifier	= 0.0;
							}
							else{
								if((error.code = get_link(element, link_label, operator_code, constant_string))!=0)
									return(error);
								// Parse the string giving the modifier
					 			if((error.code = parse_item(string_to_upper(constant_string), variable,temp_double))!=0)
									return(error);
								// Set modifier value base on operator
								if(peak[current_peak].parameter[parameter_index].link_type == OFFSET &&
(operator_code == MULTIPLY || operator_code == DIVIDE)){
									error.code =5;
									return(error);
								}
								if(peak[current_peak].parameter[parameter_index].link_type == RATIO &&
(operator_code == PLUS || operator_code == MINUS)){
									error.code =5;
									return(error);
								}

								switch(operator_code){
									case NONE	:	peak[current_peak].parameter[parameter_index].modifier	=
 (peak[current_peak].parameter[parameter_index].link_type == OFFSET) ?
0.0 : 1.0;
												break;
									case PLUS	:	peak[current_peak].parameter[parameter_index].modifier	= temp_double;
												break;
									case MINUS	:	peak[current_peak].parameter[parameter_index].modifier	= -temp_double;
												break;
									case MULTIPLY 	:	peak[current_peak].parameter[parameter_index].modifier	= temp_double;
												break;
									case DIVIDE	:	peak[current_peak].parameter[parameter_index].modifier	= 1.0/temp_double;
												break;
								}

								// if shift parameter convert to Hertz units
								if(parameter_index == SHIFT)
									peak[current_peak].parameter[parameter_index].modifier *= !strcmp(fit_info->shift_units_constraints , "PPM") ?
(reference_frequency/1000000.0) : 1.0;


								// If link variable does not exist set link variable
								if(!parameter[parameter_index].get_value(link_label, temp_double)){

									if(!parameter[parameter_index].put_variable(link_label, (double)current_peak)){
										error.code = 4;
										return(error);
									}
									// Set link to itself
									peak[current_peak].parameter[parameter_index].linked = current_peak;

								}
								else{
									peak[current_peak].parameter[parameter_index].linked = (int)temp_double;
								}
							}


							input >> element;

							// Get parameter limits if specified
							while( element[0] == '<' ||
element[0] == '>'){

								switch(element[0]){
									case '<' :	// Parse the string giving the modifier
										 	if((error.code = parse_item(string_to_upper(element+1), variable,temp_double))!=0)
												return(error);
											peak[current_peak].parameter[parameter_index].max_bound = temp_double;
											if(parameter_index == SHIFT)
												peak[current_peak].parameter[parameter_index].max_bound *= !strcmp(fit_info->shift_units_constraints , "PPM") ?
(reference_frequency/1000000.0) : 1.0;

											break;
									case '>' :	if((error.code = parse_item(string_to_upper(element+1), variable,temp_double))!=0)
												return(error);
											peak[current_peak].parameter[parameter_index].min_bound = temp_double;
											if(parameter_index == SHIFT)
												peak[current_peak].parameter[parameter_index].min_bound *= !strcmp(fit_info->shift_units_constraints , "PPM") ?
(reference_frequency/1000000.0) : 1.0;

											break;

								} //ENDSWITCH
								
								input >> element;
								
								if(input.eof())
									break;
							} //ENDWHILE



							#ifdef _DEBUG
								printf("%d (%.2f) | ",peak[current_peak].parameter[parameter_index].linked,
peak[current_peak].parameter[parameter_index].modifier);
							#endif
						}
//ENDFOR
						#ifdef _DEBUG
							printf("\n");
						#endif
  						    	strcpy(token, element);

						break;

			}
//ENDSWITCH

		}

		// check to see if any parameters are fixed by FIX_ALL options
		check_fix_all = 0;
		for (i=0; i< peak[0].number_parameters; i++){
			check_fix_all = fit_info->fix_all & fix_all_parameters[i];
			if (check_fix_all == fix_all_parameters[i]){
				for (j=0; j<fit_info->number_peaks; j++){
					peak[j].parameter[i].linked = FIXED;
					peak[j].parameter[i].modifier = 0.0;
				}
//ENDFOR
			}
//ENDIF
		}
//ENDFOR

		input.close();
		*peak_passed = peak;
		return(error);
	}//ENDELSE

	error.code = -1;
	return(error);
} // end read_constraints_file





//*******************************
//**** Write Covariance File ****
//*******************************
int write_covariance_file(char *filename, double **covariance, Fit_info *fit_info){

	fstream output(filename, ios::out);

	char parameter_label[6][32]=	{"SHIFT",
"WIDTH_LORENZ",
"AMPLITUDE",
"PHASE",
"DELAY_TIME",
"WIDTH_GAUSS"};

	int i,j;
	char temp_string[80];


	if(output.fail())
		return(1);

	output.width(20);
	output << " ";


	for(i=1;i<=fit_info->total_fit_parameters;i++){

		sprintf(temp_string,"%s_%03d",parameter_label[(fit_info->lista[i]-1)%NUMBER_PARAMETERS],
(int)(fit_info->lista[i]/NUMBER_PARAMETERS)+1);
		output.width(20);
		output	<< temp_string;

	}
	output << "\x00d\x00a";



	for(i=1;i<=fit_info->total_fit_parameters;i++){
		sprintf(temp_string,"%s_%03d",parameter_label[(fit_info->lista[i]-1)%NUMBER_PARAMETERS], (int)(fit_info->lista[i]/NUMBER_PARAMETERS)+1);
		output.width(20);
		output	<< temp_string;


		for(j=1;j<=fit_info->total_fit_parameters;j++){
			output.width(20);
			output	<< covariance[fit_info->lista[i]][fit_info->lista[j]];
		}
		output << "\x00d\x00a";

	}


	output.close();

	return(0);
}




//****************************************
//**** Write Guess/Constraints File ******
//****************************************
int write_guess_file(char *filename, Peak2 *peak, double **covariance, Fit_info *fit_info, CVariable *variable){

	int i,j;
	int index;
	double reference_frequency;
	double scale_shift=1.0;

	char	variable_label[80];
	double	variable_value;
	int	number_variables;
	char	temp_string[255];
	char	el[3];


	#ifdef _MSC_VER
		fstream output(filename, ios::out | ios::binary);
	#else
		fstream output(filename, ios::out);
	#endif

	if(output.fail())
		return(1);


	strcpy(fit_info->shift_units_guess, fit_info->output_shift_units);
	strcpy(fit_info->shift_units_constraints, fit_info->output_shift_units);

	if(!strcmp(fit_info->output_file_system, "UNIX")){
		strcpy(el,"\n");
	}
	else{
		strcpy(el,"\r\n");
	}

	// Label Guess File
	output	<< "****_Guess_File_Begins_****  <--- Do not remove this line"
<< el;


	// Get reference_frequency from variables
	variable->get_value("REFERENCE_FREQUENCY", reference_frequency);

	// Set output shift units scale factor
	if(!strcmp(fit_info->output_shift_units, "PPM"))
		scale_shift = 1.0e6/reference_frequency;


	// Write [Parameters] section of constaints file

	output << el << "[Parameters]" << el;

	for(index=0;index<NUMBER_FIT_PARAMETERS_GUESS;index++){
		if(fit_info->fit_parameter_guess[index].argument_type[0] == 'M'){
			if(*(fit_info->fit_parameter_guess[index].pointer.i[0]) & (1 << (int)fit_info->fit_parameter_guess[index].argument_type[1]))
				output	<< fit_info->fit_parameter_guess[index].label
<< el;
		}
		else{
			output	<< fit_info->fit_parameter_guess[index].label;
			for(i=0;i<fit_info->fit_parameter_guess[index].number_arguments;i++){
				switch (fit_info->fit_parameter_guess[index].argument_type[0]){
					case 'I' :	output	<< "\t\t"
<< *(fit_info->fit_parameter_guess[index].pointer.i[i]);
							break;
					case 'S' :	output	<< "\t\t"
<< fit_info->fit_parameter_guess[index].pointer.s[i];
							break;
					case 'D' :	output	<< "\t\t"
<< *(fit_info->fit_parameter_guess[index].pointer.d[i]);
							break;
				}
			}
			output	<< el;
		}
	} //ENDFOR



	// write output information
	output	<< "reference_frequency\t\t";
	output.precision(7);
	output	<< reference_frequency
<< el;

	output	<< "chi_squared\t\t"
<< fit_info->chi_squared
<< el;

	output	<< "noise_STDEV_real\t\t"
<< fit_info->noise_std.real
<< el;

	output	<< "noise_STDEV_imag\t\t"
<< fit_info->noise_std.imag
<< el;


	// Write Variables Section
	output << el << "[Variables]" << el;


	// Write Peaks Section
	output << el << "[Peaks]" << el;
	output << el << "; Peak#    Shift    Width_L(Hz)  Amplitude     Phase(rad)  Delay_Time(s)   Width_Gauss(Hz)" << el;

	for(i=0;i<fit_info->number_peaks;i++){
		output << "   ";
		output.width(3);
		output << (i+1)
<< " ";
		for(j=0;j<peak[i].number_parameters;j++){
			output.width(11);
			if(j == SHIFT)
				output	<< peak[i].parameter[j].value *
scale_shift;
			else
				output	<< peak[i].parameter[j].value;
			output	<< "  ";
		}
		output << el;

	}

	output << el << "; Cramer-Rao Lower Bounds (Standard Deviations)" << el << el;

	for(i=0;i<fit_info->number_peaks;i++){
		output << ";  ";
		output.width(3);
		output << (i+1)
<< " ";

		for(j=0;j<peak[i].number_parameters;j++){
			output << "     ";
			output.width(8);
			if(j == SHIFT)
				output	<< peak[i].parameter[j].standard_deviation *
scale_shift;
			else
				output	<< peak[i].parameter[j].standard_deviation;
			output	<< "  ";
		}
		output << el;

	}
//ENDFOR
	
	// Label End of Guess File
	output	<< "****_Guess_File_Ends_****  <--- Do not remove this line"
<< el;

	// Label Constraints File
	output	<< "****_Constraints_File_Begins_****  <--- Do not remove this line"
<< el << el;

//*************************************
//***    Write Constraints File
//*************************************

	// Write {Variables] section of constraints file

	output << "[Variables]" << el;

	number_variables = variable->get_number_variables();

	for(i=0;i<number_variables;i++){
		variable->get_variable(i, variable_label, variable_value);
		output	<< variable_label
<< "\t\t"
<< variable_value
<< el;
	}

	// Write [Parameters] section of constaints file

	output << el << "[Parameters]" << el;

	for(index=0;index<NUMBER_FIT_PARAMETERS_CONSTRAINTS;index++){
		if(fit_info->fit_parameter_con[index].argument_type[0] == 'M'){
			if(*(fit_info->fit_parameter_con[index].pointer.i[0]) & (1 << (int)fit_info->fit_parameter_con[index].argument_type[1]))
				output	<< fit_info->fit_parameter_con[index].label
<< el;
		}
		else{
			output	<< fit_info->fit_parameter_con[index].label;
			for(i=0;i<fit_info->fit_parameter_con[index].number_arguments;i++){
				switch (fit_info->fit_parameter_con[index].argument_type[0]){
					case 'I' :	output	<< "\t\t"
<< *(fit_info->fit_parameter_con[index].pointer.i[i]);
							break;
					case 'S' :	output	<< "\t\t"
<< fit_info->fit_parameter_con[index].pointer.s[i];
							break;
					case 'D' :	output	<< "\t\t"
<< *(fit_info->fit_parameter_con[index].pointer.d[i]);
							break;
				}
			}
			output	<< el;
		}
	}
//ENDFOR


	// Write [Peaks] section of constaints file

	ifstream constraints(fit_info->filename_constraints, ios::in);
	if (!constraints) { /*file does not exist*/ return(1); }

	else {

		if(constraints.fail())
			return(1);

		// Get to Constraints portion of file
		do{
			constraints.getline(temp_string,255);
		}while( !constraints.eof() && strncmp(temp_string, "****_Constraints_File_Begins_****", 33) != 0);

		// If Constraints File label not found assume file is constraints file and start at beginning
		if(strncmp(temp_string, "****_Constraints_File_Begins_****", 33)!=0){
			//constraints.seekg(0);
			constraints.close();
			constraints.open(fit_info->filename_constraints, ios::in);
		}


		// Now that we're at the beginning of the constraints file get to [Peaks] section

		// Get to [Peaks] section of file
		do{
			constraints.getline(temp_string,255);
			string_to_upper(temp_string);
		}while( !constraints.eof() && strncmp(temp_string, "[PEAKS]", 6) != 0);

		output << el << "[Peaks]" << el;

		// Copy contraints file to output guess files line by line

		while( !constraints.eof() ){
			constraints.getline(temp_string,255);
			// If end of constraints portion break out
			if(strncmp(temp_string, "****_Constraints_File_Ends_****", 30)==0)
				break;    // If end of contraints file exit

			output	<< temp_string
<< el;

		}

		constraints.close();

		output	<< "****_Constraints_File_Ends_****  <--- Do not remove this line"
<< el;

		output.close();

		return(0);
	}

} // end write_guess_file



int get_link(char *string, char *link_label, int &operator_code, char *constant_modifier){

	int index_link_label=0,
		index_string=0;

	if(string[index_string]=='{'){
		while(string[index_string++] != '}')
			link_label[index_link_label++] = string[index_string];
		link_label[index_link_label-1] = 0;

		switch(string[index_string]){
			case 0	 :	operator_code = NONE;
					break;
			case '*' :	operator_code = MULTIPLY;
					break;
			case '/' :	operator_code = DIVIDE;
					break;
			case '+' :
			case '-' :	operator_code = PLUS;
					break;
			//revised by jd		
			//default	 :  return(11);     // invalid link operator
		        default :       operator_code = NONE;
		                        break;
			//end of revised code
		}
	}
	if(string[index_string]==0)
		constant_modifier[0] = 0;
	else
		strcpy(constant_modifier, (string+index_string+(operator_code == PLUS ? 0 : 1)));

	return(0);    // successful completion
}




// Overload function parameter 2 -> (double)

int parse_item(char *string, CVariable *vars, double &value){

	char temp_string[255]="-1*";


	if(!string[0]){		// if string empty return value=0
		value = 0.0;
		return(0);
	}
	else{
		if(strncmp(string, "-(", 2)==0){
			strcat(temp_string, (string+1));
			strcpy(string, temp_string);
		}

		if(strncmp(string, "+(", 2)==0){
			string++;
		}

		CParse  parse(string, vars);
		value = (double)parse.answer();
		return(parse.get_error());
	}

}


// Overload function parameter 2 -> (int)

int parse_item(char *string, CVariable *vars, int &value){

	char temp_string[255]="-1*";

	if(!string[0]){ // if string empty return value=0
		value = 0;
		return(0);
	}
	else{
		if(strncmp(string, "-(", 2)==0){
			strcat(temp_string, (string+1));
			strcpy(string, temp_string);
		}
		if(strncmp(string, "+(", 2)==0){
			string++;
		}
		CParse  parse(string, vars);
		value = (int)parse.answer();
		return(parse.get_error());
	}
}
