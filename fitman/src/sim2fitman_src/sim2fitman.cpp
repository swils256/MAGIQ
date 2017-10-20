/******************************************************************************
sim2fitman.cpp

Project: sim2fitman
    Conversion routine for SIEMENS binary file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Main executable

NOTE:
    This code is ported from the GE (ge2fitman) routine, and although many
    of the features are redundant and not used, are left in to save time
    during coding, however they are disabeled.  
    One example is the [-ir] and [-irn] options.

Contributors:    

Updates (yy/mm/dd):
    - 2005/08/31    - Ver 1.0
    - 2006/02/13    - Ver 1.1 .. Changed compilation to static for better compatibility.
******************************************************************************/

#include <float.h>
#include <limits.h>
//added

#include "include/sim2fitman_prot.h"

int main(int argc, char *argv[]){
    
    // Although we obtained a SIEMENS scanner header file, with it's own structure
    // ("POOL_HEADER") the header structures below were left in inherently in
    // the program from 4t_cv.
    // Beacuse the program was ported from 4t_cv.cpp and these structures are
    // used throughout the program, fields are simply read from the header 
    // section.  See the sim2fitman_prot.h file for offsets.
    Data_file_header  	main_header[2];      // Our file header.
    Data_block_header	block_header[2];     // Our data header.                                         
    Procpar_info	procpar_info[2];    // Procpar info structures sup & unsup.
    Preprocess		preprocess[2];      // Preprocess structures for sup & unsup.
    IOFiles		io_filenames;       // I/O files structure.
    InFile_struct       infile_struct[2];   // Input file structures.
    
    Precision1		in_data[2];         // In data structures for sup & usup.
    Precision2		switch_data[2];     // Switch data structures for sup & usup.
    
    float               *out_data[2];       // Out data array
    float               *scratch_data[2];   // Temporary data used for preprocessing.
        
    Endian_Check        endian_check;       // Structure used for endian checking

    FILE                *in_file[2];        // Input file pointers
    long                maxval=16384;       // Maximum float value
    int                 i, j;		    // Counters
    int                 fid=0;              // FID existance
    int                 exit_code=0;        // General exit code for functions.
    int                 arg_read=0;          // The number of arguments read.
    int                 forced_swap[2] = {0, 0}; 
                                            // If forced swapping needed for sup, unsup.
                                                // 0 - no force swapping applied
                                                // 1 - force byte swap
                                                // 2 - force NO byte swap  
    int                 s_u_out = 0;        // Which file to output?
                                                // 0 - Both
                                                // 1 - Suppressed
                                                // 2 - Unsuppressed
    
    bool                swap_bytes = true;  // Swap bytes big/little endian indicator. 
    bool                verbose = true;     // Verbose output on console.
    bool                overwrite = false;  // Overwrite output file.
  
    //added
    int fidlimit;
    
    // Initializing input files.
    in_file[0]=NULL;
    in_file[1]=NULL;    
    
    // Minimum number of arguments
    if (argc <= 1) {
        exit_01(in_file);        
    }                   
    
    // Initialize procpar structures   
    init(main_header, block_header, procpar_info, preprocess, &io_filenames, infile_struct);        
    
    // Interpret the command line and determine what preprocessing is
    // to be done on each file
    exit_code = command_line(preprocess, &io_filenames, procpar_info 
                                       , argc, argv , &fid, &arg_read
                                       ,forced_swap, &overwrite, &verbose); 
    if(exit_code == -1){
        // Both -scale and -scaleby used.
        exit_05(in_file);         
    }else if(exit_code == -2){
        // Command line not understood.
        exit_04(in_file, argv[arg_read]);         
    }else if(exit_code == -3){
        // No input file specified.
        exit_11(in_file);     
    }else if(exit_code == -4){
        // No otput file specified.
        exit_12(in_file);
    }else if(exit_code == -5){
        // Too many filenames given.
        exit_13(in_file);             
    }else if(exit_code == -6){
        // No -ecc/-quality/-quecc specified
        exit_14(in_file);         
    }else if(exit_code == -7){
        // -ecc/-quality/-quecc allready specified
        exit_15(in_file);            
    }else if(exit_code == -8){
        // Invalid -ecc/-quality/-quec parameter.
        exit_19(in_file);  
    }else if(exit_code == -9){
        // -ir/-irn allready set
        exit_16(in_file);         
    }else if(exit_code == -10){
        // -bs/-nbs allready set
        exit_17(in_file);         
    }else if(exit_code == -11){
        // ecc must be before ir/irn
        exit_18(in_file);         
    }else if(exit_code == -12){
        // Reference file allready specified.
        exit_20(in_file);             
    }else if(exit_code == -13){
        // Reference file allready specified.
        exit_22(in_file);         
    }else if(exit_code == 1){
        // Only suppressed output.
        s_u_out = 1;         
    }else if(exit_code == 2){
        // Only unsuppressed output.
        s_u_out = 2;         
    }else if(exit_code == -14){
        // Invalid -scaleby parameter
        exit_25(in_file);       
    }else if(exit_code == -15){
        // Invalid -rscaleby parameter
        exit_26(in_file);       
    }else if(exit_code == -16){
        // Invalid -f (filter) parameter
        exit_27(in_file);       
    }else if(exit_code == -17){
        // Invalid reference filename...same as input filename.
        exit_28(in_file);       
    }
    
    // Check the output file names.
    check_outfile(&io_filenames, overwrite, s_u_out);        
        
    // Open the input (un)suppressed data file    
    in_file[0] = fopen(io_filenames.in[0], "rb");           
    if (in_file[0] == NULL) {
        exit_02(in_file, io_filenames.in[0]);
    }
    
    // Check system architecture. 
    endianCheck_system(&endian_check, verbose);
    
    if (forced_swap[0]==1){
        // Forced byte swapping applied by user.
        if (verbose){
            printf("*Forced byte swapping applied.\n");
        }
        swap_bytes = TRUE;
    }else if(forced_swap[0]==2){
        // Forced NO byte swapping applied by user.
        if (verbose){
            printf("*Forced NO byte swapping applied.\n");
        }
        swap_bytes = false;
    }else{
        // Endian checking for suppressed input file to determine byte swapping.
        exit_code = endianCheck_file(in_file[0], &endian_check, &swap_bytes
                                               , io_filenames.in[0], verbose);
        if (exit_code < 0){
            exit_07(in_file, io_filenames.in_procpar); 
        }
    }
    
    // Read the important procpar information that is required for the Fitman
    // header and the processing of spectra 
    // Exit codes:  -1 - Error reading file header
    //              -2 - File version not recognized
    exit_code = read_procpar(&procpar_info[0], io_filenames.in_procpar, in_file[0] 
                                     , &swap_bytes, &infile_struct[0], &main_header[0]);
    
    // Number of unsuppressed (water) point sets in suppressed file.    
    infile_struct[0].num_unsup_sets = 0;  
    
    if (exit_code < 0){
        if (exit_code == -1){
            exit_07(in_file, io_filenames.in_procpar);            
        }else if (exit_code == -2){
            exit_09(in_file, io_filenames.in_procpar,&infile_struct[0]);                                   
        }else if (exit_code == -3){
            exit_10(in_file, io_filenames.in_procpar,&infile_struct[0]);                                   
        }                
    }else if ((preprocess[0].pre_quecc_points < 1 || 
              preprocess[0].pre_quecc_points/2 > procpar_info[0].num_points) &&
			  preprocess[0].pre_quecc == YES){
            // Invalid number of points specified for QUECC.
            exit_24(in_file, procpar_info[0].num_points);                  
    }
    
    // If different files used for suppressed and unsuppressed, open second P-file.

    // added by jd, August 13, 2009
    // Read the important procpar information that is required for the Fitman
    // header and the processing of spectra 
    // Exit codes:  -1 - Error reading file header
    //              -2 - File version not recognized
    //exit_code = read_procpar(&procpar_info[1], io_filenames.in_procpar, in_file[0] 
    //                                     , &swap_bytes, &infile_struct[1], &main_header[1]);
    // end of added code

    if(strcmp(io_filenames.in[0], io_filenames.in[1])!=0 &&
       strcmp(io_filenames.in[1], "No Filename Available")!=0){
        // Open the input unsuppressed data file    
        in_file[1] = fopen(io_filenames.in[1], "rb");           
        if (in_file[1] == NULL) {
            exit_02(in_file, io_filenames.in[1]);            
        }
         if (forced_swap[1]==1){
            // Forced byte swapping applied by user.
            swap_bytes = TRUE;
        }else if(forced_swap[1]==2){
            // Forced NO byte swapping applied by user.
            swap_bytes = false;
        }else{        
            // Endian checking for unsuppressed input file.
            if (endianCheck_file(in_file[1], &endian_check, &swap_bytes
                                           ,io_filenames.in[1], verbose)<0){
                exit_07(in_file, io_filenames.ref_procpar);
            }
        }              
    }
    
    // Input file stats.
    if (verbose && (s_u_out == 0 || s_u_out == 1)){
        // Print if suppressed or both are requested.
        printf("\n*Input file statistics:\n");
        infile_stats(&procpar_info[0], &infile_struct[0], &main_header[0]);
    }
    
    //printf("Fid = %d\n",fid);

    if (fid == 1){

        if(!strcmp(io_filenames.in[0], io_filenames.in[1])){
            // Same file used for suppressed and unsuppressed. 


	  // added by jd, May 5, 2009
	  //printf("same file used for suppressed and unsuppressed\n");
	  //printf("*************************************************\n\n");
 
            main_header[1]=main_header[0];
            block_header[1]=block_header[0];
            procpar_info[1]=procpar_info[0];                 
            infile_struct[1]=infile_struct[0];
            forced_swap[1]=forced_swap[0];
            in_file[1]=in_file[0];
            // Reference input file stats.
            if (verbose && s_u_out == 2){
                // Print if only unsuppressed is requested.
                infile_struct[1].num_unsup_sets = 1;  
                printf("\n*Input reference file statistics:\n");
                infile_stats(&procpar_info[1], &infile_struct[1], &main_header[1]); 
            }
        } else {

	  // added by jd, August 13, 2009
	  printf("Different files used for suppressed and unsuppressed.\n");

            // Different files used for suppressed and unsuppressed.
            exit_code = read_procpar(&procpar_info[1], io_filenames.ref_procpar, in_file[1] 
                                            , &swap_bytes, &infile_struct[1], &main_header[1]);
            
            // Number of unsuppressed (water) point sets in suppressed file.    
            infile_struct[1].num_unsup_sets = 1; 

            if (exit_code < 0){
                if (exit_code == -1){
                    exit_07(in_file, io_filenames.ref_procpar);            
                }else if (exit_code == -2){
                    exit_09(in_file, io_filenames.ref_procpar,&infile_struct[1]);                                   
                }else if (exit_code == -3){
                    exit_10(in_file, io_filenames.ref_procpar,&infile_struct[1]);                                   
                }                
            }                       
            // Reference input file stats.
            //if (verbose){
                printf("\n*Input reference file statistics:\n");
                infile_stats(&procpar_info[1], &infile_struct[1], &main_header[1]);
		//}
        }
    }
    
    // Read in required data
    if (verbose){
        printf("\n*Reading data files...\n");
    }

    fidlimit = 0;

    //revised by jd, August 17, 2010
    /*
    if(strcmp(io_filenames.in[0], io_filenames.in[1])!=0 &&
       strcmp(io_filenames.in[1], "No Filename Available")!=0){
      fidlimit = fid+1;
    }
    else
      fidlimit = fid;
    */
    if(strcmp(io_filenames.in[0], io_filenames.in[1])!=0 &&
       strcmp(io_filenames.in[1], "No Filename Available")!=0){
      fidlimit = fid+1;
      //printf("A: fidlimit = fid+1\n");
    }
    else if(s_u_out==2){  //only unsuppressed data
      fidlimit = fid+1;
      //printf("B: fidlimit = fid+1\n");
    }
    else{  
      fidlimit = fid;
      //printf("C: fidlimit = fid\n");
    }
    //end of revised code
    

	/*
      read_data(&fid, preprocess, &io_filenames, main_header, block_header, switch_data, in_file,
               in_data, out_data, scratch_data, swap_bytes, infile_struct);
	*/
      read_data(&fidlimit, preprocess, &io_filenames, main_header, block_header, switch_data, in_file,
               in_data, out_data, scratch_data, swap_bytes, infile_struct);
	
    // This part was inherently left in from 4t_cv.
    // Did not see reason for taking it out as could have gotten away only with
    // switch_data[].    
   
    


    //revised by jd, May 7, 2009
    //for (i=0; i<fid+1; i++){ 
       
    for (i=0; i<fidlimit; i++){
    
    
    
    //for (i=0; i<fid+1; i++){
      
       for (j=0; j<main_header[i].np.number*2; j++) 
            {                
	      out_data[i][j] = switch_data[i].fl[j];

	      
		
		//added by jd for debugging, May 7, 2009
		//printf("point %d: %f\n", i, out_data[i][j]);

              scratch_data[i][j] = switch_data[i].fl[j];

	      

                // For debugging
		/*printf("FLT_EPSILON = %g\n",FLT_EPSILON);
                printf("FLT_MAX = %g\n",FLT_MAX);
		if(i==1){
                printf("switch data = %f \n", switch_data[i].fl[j]);
                printf("out_data = %f \n", out_data[i][j]);
		printf("scratch_data = %f \n", scratch_data[i][j]);
		}*/
           }        
    }
    
        
    // Preprocess FIDs based on what was requested on command line    
    if (verbose){
        printf("\n*Processing data...\n");
    }
    //pre_process(&fid, preprocess, procpar_info, out_data, scratch_data);
    pre_process(&fidlimit, preprocess, procpar_info, out_data, scratch_data);

    printf("After preprocess!\n");

    //deleted a for loop that was unnecessary
    //by jd, July 14, 2010

    //added by jd for debugging, May 7, 2009
    //printf("ok after pre_process.\n");

    // Write out data in ASCII format.
    if (verbose){
        printf("\n*Writting data...\n");
    }
    
    // Screen outputs
    if (verbose){
        printf("\n*Written data file(s): \n");
    }
    if (s_u_out == 0 || s_u_out == 1){
       // Suppressed output.
       fwrite_asc(io_filenames.out[0], out_data[0], &main_header[0], &block_header[0], 1,
                  &procpar_info[0], &preprocess[0]);       
       if (verbose){ 
            printf("  >>Suppressed   : \"%s\"\n", io_filenames.out[0]);   
       }
    }
    if (s_u_out == 0 || s_u_out == 2){
        // Unsuppressed output.
        fwrite_asc(io_filenames.out[1], out_data[1], &main_header[1], &block_header[1], 1,
                  &procpar_info[1], &preprocess[1]); 
        if (verbose){ 
            printf("  >>Unuppressed  : \"%s\"\n", io_filenames.out[1]);
        }
    }    

    printf("\n\n");

    // Close input files
    for (i=0; i<2; i++){
        if(in_file[i]!=NULL){
            fclose(in_file[i]);
        }
    }
    
    free(in_data[0].lo);
    free(switch_data[0].lo);    
    free(out_data[0]);
    free(scratch_data[0]);
    
    if (fid==1){
        free(in_data[1].lo);
        free(switch_data[1].lo);
        free(out_data[1]);
        free(scratch_data[1]);
    }
    
    return(0);
    
} // end main(...)
