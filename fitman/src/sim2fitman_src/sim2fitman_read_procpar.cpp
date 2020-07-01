/******************************************************************************
sim2fitman_read_procpar.cpp

Project: sim2fitman
    Conversion routine for SIEMENS binary file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Procpar information reading routines from the input file headers.

Supports:
    sim2fitman.cpp

******************************************************************************/

#include "include/sim2fitman_prot.h"

/*****************************************************************************
   Exit codes:   0 - No errors.
                -1 - Error reading file header
                -2 - File version not recognized
                -3 - Invalid file size.
******************************************************************************/
int read_procpar(Procpar_info *procpar_info, char *procpar_string, FILE *in_file
                , bool *swap_bytes, InFile_struct *infile_struct
                , Data_file_header *main_header) {
     
    long date_stamp=0;       // Examination date stamp.
    float dwell=0;           // Dwell time.
    long calc_filesize=0;    // Calculated file size.
    long te_offset=0;        // Te field offset. 
    long tr_offset=0;        // Te field offset.
    long pulse_name_offset=0; // Te field offset.
    
    long header_size=0;      // The file header size;
    short temp_short;        // Temp short value;
    int temp_int;            // Temp int value;
    long temp_long;          // Temp long value.
    float temp_float;        // Temp float value;
    char input_str[255];     // Input string

    /********************************************************/
    char in_line[255];                      // The line read
    char date_temp[20];                     // Temporary date string
    char month_temp[3];                     // Temporary month string
    int  month_temp_int;                    // Temporary month integer
    char time_temp[20];                     // Temporary time string
    char *token = NULL;                     // String token.
    bool done_hdr = false;                  // Header reading flag.

    //added by jd
    //float high=1;  //default hard coded gain
    //float high=10;  //revised by jd, June 30, 2010

    /*
    // Open the input (un)suppressed data file    
    in_file = fopen(procpar_string, "rb");           
    if (in_file == NULL) {
        printf("Can't open procpar file.\n");                
        exit(4);
    }   
   */
//printf("File position before read %x\n", ftell(in_file));     
    
    // Read in first line   
    fgets(in_line, 255, in_file);
    if(ferror(in_file)){               
        return -1;        
    }
   
    // this loop reads up to the first white space of each line into variable token
    // token is then compared to keywords until a match is found
    // the value of the keyword is then assigned to the procpar_info structure
    
    
    while(!feof(in_file) && !done_hdr){              
        
        // Get token from in_line
        token = strtok(in_line, " \t\n");  
               
        // Check for end of header
        if(strcmp(token, ">>>")==0){
            token = strtok(NULL, "<<<");
            if(strcmp(token, "End of header ")==0){
                done_hdr = true;
                infile_struct->hdr_offset = ftell(in_file); 
//printf("File position at end %x\n", ftell(in_file));
            }
        }  
        
        // The number of points   
        else if(strcmp(token, "VectorSize:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            main_header->np.number = strtol(token, NULL, 10);  
            procpar_info->num_points = main_header->np.number;
        }
  
        // Nex value
        else if(strcmp(token, "NumberOfAverages:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            
	    //revised nex to int
	    //procpar_info->nex = strtod(token, NULL);
            procpar_info->nex = strtol(token, NULL, 10);   
        } 


        // Dwell time
        else if(strcmp(token, "DwellTime:")==0){
            dwell = 0;
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            dwell = strtod(token, NULL);   
            
	    // added by jd, Aug 13, 2009
	    procpar_info->dwell_time = dwell/1e6;

	    dwell = 1/dwell;
	    
	    //added by jd, Feb 3, 2010
	    //printf("dwell = %g\n", dwell);
	    //end of added code

        } 

        // Main frequency (In Hz)
        else if(strcmp(token, "MRFrequency:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->main_frequency = strtod(token, NULL);            
        } 

        // Hospital name
        else if(strcmp(token, "InstitutionName:")==0){
            // Get token from in_line            
	    token = strtok(NULL, "\r\n");
            strcpy(procpar_info->hospname, token);            
        } 
    
	// Patient name
        else if(strcmp(token, "PatientName:")==0){
            // Get token from in_line            
	    token = strtok(NULL, "\r\n");
            strcpy(procpar_info->patname, token);            
        }     
      
	// Pulse sequence name 
        else if(strcmp(token, "SequenceName:")==0){
            // Get token from in_line            
	    token = strtok(NULL, "\r\n");
            strcpy(procpar_info->psdname, token);            
        } 


        // Exam date stamp        
        else if(strcmp(token, "StudyDate:")==0){
            // Get token from in_line            
	    token = strtok(NULL, "\r\n");
            strcpy(date_temp,token);            
        } 
        
        // Exam date stamp        
        else if(strcmp(token, "StudyTime:")==0){
            // Get token from in_line            
	    token = strtok(NULL, "\r\n");
            strcpy(time_temp,token);            
        } 

        // Te value        
        else if(strcmp(token, "TE:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->te = strtod(token, NULL);
            //changed te to milliseconds
            procpar_info->te /= 1e3;            
        } 
          
        // Tr value
        else if(strcmp(token, "TR:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->tr = strtod(token, NULL);
            //changed te to milliseconds
            procpar_info->tr /= 1e3;            
        } 
       
     
        // Pos 1-3 values
        else if(strcmp(token, "PositionVector[0]:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->pos1 = strtod(token, NULL);            
        } 
        else if(strcmp(token, "PositionVector[1]:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->pos2 = strtod(token, NULL);            
        } 
        else if(strcmp(token, "PositionVector[2]:")==0){
            // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->pos3 = strtod(token, NULL);            
        }
	else if(strcmp(token, "VOIThickness:")==0){
	    // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
	  procpar_info->vox1 = strtod(token, NULL);

	  //printf("vox1 = %g\n",procpar_info->vox1);
        } 
	else if(strcmp(token, "VOIPhaseFOV:")==0){
	    // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->vox2 = strtod(token, NULL);

	    //printf("vox2 = %g\n",procpar_info->vox2);
            
        }
	else if(strcmp(token, "VOIReadoutFOV:")==0){
	    // Get token from in_line            
	    token = strtok(NULL, " \r\n");  
            procpar_info->vox3 = strtod(token, NULL);

	    //printf("vox3 = %g\n",procpar_info->vox3);
        }
	//end of added vox1,2,3 code
	/*printf("vox1 = %g\n",procpar_info->vox1);
	printf("vox2 = %g\n",procpar_info->vox2);
	printf("vox3 = %g\n",procpar_info->vox3);*/

    /*
    // Gain value
    temp_long = 0;
    if (read_field(in_file, (char *) &temp_long
                      , sizeof(temp_long)
                      , GAIN_OFFSET, sizeof(long), *swap_bytes)<0){
              return -1;    
    }
    procpar_info->gain = temp_long;
    
    //added by jd
    //printf("gain = %g\n",procpar_info->gain);
    //end of added code
    
    */

        // Read new line
        fgets(in_line, 255, in_file);
        if(ferror(in_file)){              
            return -1;        
        }   
        
//printf("File position after read %x\n", ftell(in_file)); 
        
    }//end while
    
    //Fixing date/time stamp
    //Going from yyyymmdd, hhmmss  --> Month Day Time Year
    month_temp[0] = date_temp[4];
    month_temp[1] = date_temp[5];
    month_temp[2] = '\0';
    month_temp_int = strtol(month_temp, NULL, 10);   
    switch (month_temp_int){
        case 1: strcpy(procpar_info->ex_datetime, "Jan"); break;
        case 2: strcpy(procpar_info->ex_datetime, "Feb"); break;
        case 3: strcpy(procpar_info->ex_datetime, "Mar"); break;   
        case 4: strcpy(procpar_info->ex_datetime, "Apr"); break;   
        case 5: strcpy(procpar_info->ex_datetime, "May"); break;   
        case 6: strcpy(procpar_info->ex_datetime, "Jun"); break;   
        case 7: strcpy(procpar_info->ex_datetime, "Jul"); break;   
        case 8: strcpy(procpar_info->ex_datetime, "Aug"); break;   
        case 9: strcpy(procpar_info->ex_datetime, "Sep"); break;   
        case 10: strcpy(procpar_info->ex_datetime, "Oct"); break;   
        case 11: strcpy(procpar_info->ex_datetime, "Nov"); break;   
        case 12: strcpy(procpar_info->ex_datetime, "Dec"); break;
        default : strcpy(procpar_info->ex_datetime, "   ");
    }        
    procpar_info->ex_datetime[3] = ' ';
    procpar_info->ex_datetime[4] = date_temp[6];
    procpar_info->ex_datetime[5] = date_temp[7];
    procpar_info->ex_datetime[6] = ' ';
    
    //revised by jd, July 2, 2010
    /*
    procpar_info->ex_datetime[7] = time_temp[0];
    procpar_info->ex_datetime[8] = time_temp[1];
    procpar_info->ex_datetime[9] = ':';
    procpar_info->ex_datetime[10] = time_temp[2];
    procpar_info->ex_datetime[11] = time_temp[3];
    procpar_info->ex_datetime[12] = ':';    
    procpar_info->ex_datetime[13] = time_temp[4];
    procpar_info->ex_datetime[14] = time_temp[5];
    procpar_info->ex_datetime[15] = ' ';
    */
    
    /*
    procpar_info->ex_datetime[16] = date_temp[0];
    
    
    procpar_info->ex_datetime[17] = date_temp[1];
    procpar_info->ex_datetime[18] = date_temp[2];
    procpar_info->ex_datetime[19] = date_temp[3];
    */
    procpar_info->ex_datetime[7] = date_temp[0];
    procpar_info->ex_datetime[8] = date_temp[1];
    procpar_info->ex_datetime[9] = date_temp[2];
    procpar_info->ex_datetime[10] = date_temp[3];

    //procpar_info->ex_datetime[20] = '\0';
    procpar_info->ex_datetime[11] = '\0';
    
    // Offset frequency (In Hz)
    procpar_info->offset_frequency = 0;      
    // Number of transients
    procpar_info->num_transients = 1;
    // Vtheta value
    procpar_info->vtheta = 0;
    // Acquisition time
    procpar_info->acquision_time = (float)(procpar_info->num_points*dwell);

    //added by jd, Feb 3, 2010
    //printf("procpar_info->acquision_time = %f\n", procpar_info->acquision_time);
    //end of added code
       
    // Vox 1-3 values
    //changed back to user input voxel sizes
    /*procpar_info->vox1 = 2.00;
    procpar_info->vox2 = 2.00;
    procpar_info->vox3 = 2.00;*/    
    //Vox_1
    /*printf("\n* Please enter VOXEL information.\n");
    printf("*       VOX_1 (2.00): ");
    gets(input_str);
    if (strcmp(input_str, "")!=0){  
        temp_float = strtod(input_str, NULL);
	while (!isNumber(input_str) || isNAN(temp_float)){
            printf("*          Invalid value ... try again: ");
            gets(input_str);  
            temp_float = strtod(input_str, NULL);
    	}
    	procpar_info->vox1 = temp_float;
    }
    //Vox_2
    printf("*       VOX_2 (2.00): ");
    gets(input_str);
    if (strcmp(input_str, "")!=0){ 
        temp_float = strtod(input_str, NULL);  
	while (!isNumber(input_str)|| isNAN(temp_float)){
            printf("*          Invalid value ... try again: ");
            gets(input_str);              
            temp_float = strtod(input_str, NULL);     
    	}
    	procpar_info->vox2 = temp_float;
    }
    //Vox_3
    printf("*       VOX_3 (2.00): ");
    gets(input_str);
    if (strcmp(input_str, "")!=0){   
        temp_float = strtod(input_str, NULL);
	while (!isNumber(input_str) || isNAN(temp_float)){
            printf("*          Invalid value ... try again: ");
            gets(input_str);  
            temp_float = strtod(input_str, NULL);
    	}
    	procpar_info->vox3 = temp_float;
    }
    */
    // Gain value
    //changed back to user input of gain
    /*
    procpar_info->gain = high;

    printf("hard coded gain = %g\n",procpar_info->gain);
    */
    procpar_info->gain = 0;
    printf("\n* Please enter GAIN information.\n");
    printf("*       GAIN (0.00): ");
    //gets(input_str);
    //update gets to fgets since gets is deprecated, DW 2020
    if (fgets(input_str, sizeof input_str, stdin)) {
    	input_str[strcspn(input_str, "\n")] = '\0';
    }
    if (strcmp(input_str, "")!=0){   
        temp_float = strtod(input_str, NULL);
	while (!isNumber(input_str) || isNAN(temp_float)){
            printf("*          Invalid value ... try again: ");
            //gets(input_str);
            //update gets to fgets since gets is deprecated
            // - Dickson Wong, Jun 2020  
	    if (fgets(input_str, sizeof input_str, stdin)) {
	    	input_str[strcspn(input_str, "\n")] = '\0';
	    }
            temp_float = strtod(input_str, NULL);
    	}
    	procpar_info->gain = temp_float;
    }    
    
    
    
//THESE VALUES ARE HARDCODED FOR SIEMENS.
    // Number of total point sets ... it is allways one.
    infile_struct->num_datasets = 1;    
    // Point size...this is hard coded for now...assumed to be 16.
    main_header->ebytes.number = 16;  
    // Total raw data size.
    //infile_struct->total_data_size = (int)temp_long;     
            
    // Veryfying the file structure.
    fseek(in_file, 0, SEEK_END);
    header_size = infile_struct->hdr_offset;
    infile_struct->file_size = ftell(in_file);
    calc_filesize = (main_header->ebytes.number * procpar_info->num_points) 
		    * (infile_struct->num_datasets) + header_size;
    if (infile_struct->file_size!=calc_filesize){
        return -3;                      // Invalid file size detected;
    }     
  
//END HARCODING
 
    return 0;
    
} // end read_propcar()

/******************************************************************************/
int read_field(FILE * in_file, char *var_pointer, int var_size
                             , long int hdr_field_offset, int hdr_field_size
                             , bool swap_bytes){
                                                                
    fseek(in_file, hdr_field_offset, SEEK_SET); 
    if((fread(var_pointer, 1, hdr_field_size , in_file))!=hdr_field_size){                
        return -1;      // Return error if could not read properly.
    }
    
    // Debugging
    // printHex(var_pointer, var_size);
    
    if (swap_bytes){
        swapBytes(var_pointer, var_size);
    }
    
    // Debugging
    // printHex(var_pointer, var_size);
    
    
    return 0;
    
}// end read_field()


