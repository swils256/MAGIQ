/******************************************************************************
sim2fitman_com_line.cpp

Project: sim2fitman
    Conversion routine for SIEMENS binary file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Command line interpreter routines.

Supports:
    sim2fitman.cpp

******************************************************************************/

#include "include/sim2fitman_prot.h"

/*****************************************************************************
   Routine for interpreting the command line arguments.
   Exit codes:   0 - No errors, both suppressed and unsuppressed output.
                 1 - No errors, only suppressed output.
                 2 - No errors, only unsuppressed ouput.
                -1 - Both -scale and -scaleby used ERROR.
                -2 - Command line not understood.
                -3 - No input file specified.
                -4 - No output file specified.   
                -5 - Too many filenames.
                -6 - No -ecc/-quality/-quecc specified (not used).
                -7 - -ecc/-quality/-quecc allready specified.
                -8 - Invalid -ecc/-quality/-quec parameter.
                -9 - -ir/irn allready set.
                -10 - -bs/-nbs allready set.
                -11 - ecc must be before ir/irn.
                -12 - Reference file allready specified.                
                -13 - No reference file specified.
                -14 - Invalid -scaleby parameter
                -15 - Invalid -rscaleby parameter
                -16 - Invalid -f (filter) parameter
                -17 - Invalid reference filename...same as input filename.
    Notes on functionality:
        Options are detected by the '-' character.  Otherwise the argument must 
        be a filename.
        There are a maximum of three sets of options, three filenames and the 
        structure of the expected command line is:

  >sim2fitman [general_opt] in_file [in_file_opt] ref_file [ref_file_opt] out_file         
******************************************************************************/
int command_line(Preprocess *preprocess, IOFiles *io_filenames, Procpar_info *procpar_info,
                int argc, char **argv, int *fid, int *arg_read, int *forced_swap,
                bool *overwrite, bool *verbose) {
    
    int i, argc_counter; 

    bool ir_set = false;        // The -ir set flag
    bool irn_set = false;       // The -irn set flag
    bool ioption_set = false;   // Any in_file option set flag
    
    bool rscale_set = false;    // The -scale or -scaleby set flag
    bool rbc_set = false;       // The -rbc set flag
    bool rif_set = false;       // The -rif set flag
    bool roption_set = false;   // Any ref_file option set flag
    
    bool only_suppressed = false;       // Only suppressed output.
    bool only_unsuppressed = false;     // Only unsuppressed output.
    
    long temp_long=0;           // Temporary olng variable.
    int num_filenames=0;        // Number of argument filenames given.
    int s_u_out = 0;
    char filename[3][256];      // Filename array.
    
    strcpy(filename[0], NO_FILENAME);
    strcpy(filename[1], NO_FILENAME);
    strcpy(filename[2], NO_FILENAME);
    
    // initialize the preprocess structure    
    for(i=0; i<2; i++){
        preprocess[i].fid_scale = NO;
        preprocess[i].scaleby = NO;
        preprocess[i].scale_factor = float(1.0);
        preprocess[i].pre_ecc = NO;
        preprocess[i].bc = NO;
        preprocess[i].file_type = BINARY;
        preprocess[i].data_zero_fill = NO;
        preprocess[i].comp_filter = float(0.0);
        preprocess[i].max_normalize = NO;
        preprocess[i].pre_quality = NO;
        preprocess[i].pre_quecc = NO;
        preprocess[i].pre_quecc_points = 0;
        preprocess[i].pre_delay_time = float(0.0); // delay in micro seconds
        preprocess[i].pre_quecc_if = 0;
        preprocess[i].input_file_type = BINARY_FILE;
        preprocess[i].ref_file_argument = 5;
        preprocess[i].csi_reorder = NO;
        preprocess[i].tilt = NO;
        preprocess[i].ecc_present = false;
    }
 
    // Check if any preprocessing is required
    argc_counter = 1;
    *fid = 0;
    
    while (argc_counter < argc) {
        if (argv[argc_counter][0] != '-'){
            // NO '-' detected...it's a filename.
            
            if(num_filenames>2){
               // To many filnames detected.  
                return -5; 
            }else{
               // Store filename.               
               strcpy(filename[num_filenames], argv[argc_counter]);                 
               num_filenames++;
            }

        }else{     
            // '-' detected...it's an option.
            if(!strcmp(argv[argc_counter], "-ecc") ||
                !strcmp(argv[argc_counter], "-quality") ||
                !strcmp(argv[argc_counter], "-quecc")){
            
		if (preprocess[0].ecc_present == true){
                    //-ecc/-quality/-quecc allready specified
                    return -7;
                }
                
                preprocess[0].ecc_present = true;
            
                if(!strcmp(argv[argc_counter], "-ecc")){
                    preprocess[*fid].pre_ecc = YES;
                    *fid = 1;
                    preprocess[*fid].pre_ecc = YES;              
                }
                
                if(!strcmp(argv[argc_counter], "-quality")){
                    preprocess[*fid].pre_quality = YES;
                    argc_counter++;
                    if(isNumber(argv[argc_counter])){                  
                        preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                        *fid = 1;
                        preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                        preprocess[*fid].pre_quality = YES;
                    }else{
                        return -8;
                    }
                        
                }
                
                if(!strcmp(argv[argc_counter], "-quecc")){
                    preprocess[*fid].pre_quecc = YES;
                    argc_counter++;
                    if(isNumber(argv[argc_counter])){
                        preprocess[*fid].pre_quecc_points = (atoi(argv[argc_counter]))*2;
                    }else{
                        return -8;
                    }
                    argc_counter++;
                    if(isNumber(argv[argc_counter])){
                        preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                        *fid = 1;                    
                        preprocess[*fid].pre_quecc_points = preprocess[0].pre_quecc_points;
                        preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                        preprocess[*fid].pre_quecc = YES;
                    }else{
                        return -8;
                    }
                }
                
            }//end if(ecc, quecc, quality)        
            else {  // Reading in the other options.
            
                // Short help version.
                if (strcmp(argv[argc_counter], "-h") == 0){
                    disp_help(HELP_SHORT); 
                    exit (0);
                    
                // Long help version.
                }else if (strcmp(argv[argc_counter], "-help") == 0){
                    disp_help(HELP_LONG);                
                    exit(0);
              
                 // -scale: suppressed file
                }else if (strcmp(argv[argc_counter], "-scale") == 0){
                    // Scale magnitude within +/- 1 from suppressed file.
                    ioption_set = true;
                    if (preprocess[0].scaleby == NO){
                        preprocess[0].fid_scale = YES;
                        preprocess[0].scale_factor = float(1.0);
                    } else {
                        // Do not use both -scale and -scaleby
                        return -1;
                    }

                // -rscale: unsuppressed reference file                    
                }else if (strcmp(argv[argc_counter], "-rscale") == 0){
                    // Scale magnitude within +/- 1 from reference (unsuppressed) file.
                    roption_set = true;
                    if (preprocess[1].scaleby == NO){
                        rscale_set = true;
                        preprocess[1].fid_scale = YES;
                        preprocess[1].scale_factor = float(1.0);
                    } else {
                        // Do not use both -rscale and -rscaleby
                        return -1;
                    }                
                    
                // -scaleby: suppressed file
                } else if (strcmp(argv[argc_counter], "-scaleby") == 0){
                    // Scale magnitude within specified factor
                    ioption_set = true;
                    if (preprocess[0].fid_scale == NO){                        
                        preprocess[0].scaleby = YES;
                        argc_counter++;
                        if(isNumber(argv[argc_counter])){
                            sscanf(argv[argc_counter], "%f", &preprocess[0].scale_factor);
                        }else{
                            return -14;
                        }                        
                    } else {
                        // Do not use both -scale and -scaleby
                        return -1;                    
                    }

                // -rscaleby: unsuppressed reference file
                } else if (strcmp(argv[argc_counter], "-rscaleby") == 0){
                    // Scale magnitude within specified factor
                    roption_set = true;
                    if (preprocess[1].fid_scale == NO){
                        rscale_set = true;
                        preprocess[1].scaleby = YES;
                        argc_counter++;
                        if(isNumber(argv[argc_counter])){
                            sscanf(argv[argc_counter], "%f", &preprocess[1].scale_factor);
                        }else{
                            return -15;
                        }                          
                    } else {
                        // Do not use both -rscale and -rscaleby
                        return -1;                    
                    }
                    
                // -f: filter
                } else if (!strcmp(argv[argc_counter], "-f")){                
                    argc_counter++;
                    if(isNumber(argv[argc_counter])){
                            sscanf(argv[argc_counter], "%f", &preprocess[0].comp_filter);
                    }else{
                            return -16;
                    }  
                                                            
                // -norm: unsuppressed reference file.
                } else if (strcmp(argv[argc_counter], "-norm") == 0){                
                    roption_set = true;
                    preprocess[1].max_normalize = YES;
                
                // -if: suppressed file.
                } else if (strcmp(argv[argc_counter], "-if") == 0){  
                    // Automatic filter
                    ioption_set = true;
                    preprocess[0].pre_quecc_if = YES;
                    
                // -rif: unsuppressed reference file.
                } else if (strcmp(argv[argc_counter], "-rif") == 0){                      
                    // Automatic filter 
                    roption_set = true;
                    rif_set = true;
                    preprocess[1].pre_quecc_if = YES;                    
                 
                // -bc: suppressed file.               
                } else if (strcmp(argv[argc_counter], "-bc") == 0){                
                    // Baseline correction
                    ioption_set = true;
                    preprocess[0].bc = YES;
                 
                // -rbc: unsuppressed reference file.   
                } else if (strcmp(argv[argc_counter], "-rbc") == 0){                
                    // Baseline correction
                    roption_set = true;
                    rbc_set = true;
                    preprocess[1].bc = YES;                    
                    
                } 
                
/* THIS DOES NOT APPLY TO SIEMENS....IGNORE EVERY [-ir] and [-irn] OPTION
                else if (strcmp(argv[argc_counter], "-ir") == 0){
                    // Identical reference_file with in_file                    
                    if (ir_set == true || irn_set == true){
                        // -ir/irn allready set
                        return -9;
                    }else if(strcmp(io_filenames->in[1], NO_FILENAME) !=0){
                        // Reference file allready specified.
                        return -12;
                    }else {
                        ir_set = true;                         
                        if(rscale_set || rbc_set || rif_set){
                            // Some reference file options allready set. 
                            cond_exit_21(); 
                        }
                        preprocess[1].fid_scale = preprocess[0].fid_scale;
                        preprocess[1].scale_factor = preprocess[0].scale_factor;
                        preprocess[1].scaleby = preprocess[0].scaleby;
                        preprocess[1].bc = preprocess[0].bc;
                        preprocess[1].pre_quecc_if = preprocess[0].pre_quecc_if;   
                        preprocess[1].comp_filter = preprocess[0].comp_filter;
                    }
                
                } else if (strcmp(argv[argc_counter], "-irn") == 0){                
                    // Identical reference_file with in_file no options set  
                    if (ir_set == true || irn_set == true){
                        // -ir/irn allready set
                        return -9;  
                    }else if(strcmp(io_filenames->in[1], NO_FILENAME) !=0){
                        // Reference file allready specified.
                        return -12;
                    }else{
                        irn_set = true;                        
                    }                    
                }
 * END OF [-ir] and [-irn] IGNORE. */               

                // -bs (byte swap): suppressed file.
                 else if (strcmp(argv[argc_counter], "-bs") == 0){ 
                    // Forced byte swapping by user.
                    ioption_set = true;
                    if (forced_swap[0] > 0){
                        // -bs/-nbs allready set.
                        return -10;
                    }else{
                        forced_swap[0] = 1;                        
                    }
                    
                // -rbs (byte swap): unsuppressed reference file.
                } else if (strcmp(argv[argc_counter], "-rbs") == 0){ 
                    // Forced byte swapping by user.
                    roption_set = true;
                    if (forced_swap[1] > 0){
                        // -rbs/-rnbs allready set.
                        return -10;
                    }else{
                        forced_swap[1] = 1;                        
                    }                    
                                                            
                // -nbs (NO byte swap): suppressed file.
                } else if (strcmp(argv[argc_counter], "-nbs") == 0){ 
                    // Forced NO byte swapping by user.
                    ioption_set = true;
                    if (forced_swap[0] > 0){
                        // -bs/-nbs allready set
                        return -10;
                    }else{
                        forced_swap[0] = 2;                        
                }
                 
                // -rnbs (NO byte swap): unsuppressed reference file.
                } else if (strcmp(argv[argc_counter], "-rnbs") == 0){ 
                    // Forced NO byte swapping by user.
                    roption_set = true;
                    if (forced_swap[1] > 0){
                        // -bs/-nbs allready set
                        return -10;
                    }else{
                        forced_swap[1] = 2;                        
                }
                    
                // -ow: Overwrite
                } else if (strcmp(argv[argc_counter], "-ow") == 0){     
                    *overwrite = true;
                    
                // -nv: No verbose
                } else if (strcmp(argv[argc_counter], "-nv") == 0){     
                    *verbose = false;                    
                
                // -ver: Version
                } else if (strcmp(argv[argc_counter], "-ver") == 0){     
                    print_version();   
                    exit(0);
                    
                } else {                
                    // Argument not understood.
                    *arg_read = argc_counter;
                    return -2;                               
                }
            }
        }//end if(arg == '-')
        argc_counter++;
    }// end while loop for arg check. 
    
    
    
    /**************************************************************************/            
    // Analyzing argument and filenames.    
    if (num_filenames == 3){        
        //Three filenames given
        if ((ir_set) || (irn_set)){
            // Reference file allready specified. 
            return -12;
        }else if(((!ir_set) && (!irn_set)) && preprocess[0].ecc_present == false){
            // No -ecc/-quality/-quecc specified
            return -6; 
        }else if(strcmp(filename[0], filename[1]) == 0){
            // Invalid reference filename...same as input filename.
            return -17;             
        }else{
            // OK..Two file output with 3 input filenames...keep going
            // Left in else statement for future use.          
            
        }                        
    }else if(num_filenames == 2){
        //Two file names given.
        if(((!ir_set) && (!irn_set)) && preprocess[0].ecc_present == false){
            //One file output.
            *fid = 1;                      
            if(!ioption_set && roption_set){
                // Assuming unsuppressed output.
                only_unsuppressed = true;
                printf("\n*Assuming need for unsuppressed output.\n");
            }else if(ioption_set && !roption_set){
                // Assuming suppressed output.
                only_suppressed = true;
                printf("\n*Assuming need for suppressed output.\n");
            }else{
                // Ask for suppressed or unsuppressed output. 
                s_u_out = cond_exit_23();
                if (s_u_out == 1){
                    only_suppressed = true;
                }else if(s_u_out == 2) {
                    only_unsuppressed = true;
                }else{
                    // OK..Two file output with 1 file input -no ecc...keep going
                    // Left in else statement for future use.                    
                }
            }
        }else if(((!ir_set) && (!irn_set)) && preprocess[0].ecc_present == true){
            // No output file specified.    
            return -4;             
        }else if(((ir_set) || (irn_set)) && preprocess[0].ecc_present == false){
            // No -ecc/-quality/-quecc specified
            return -6;             
        }else{
            // OK..Two file output with 2 input filenames + [-ir(n)]...keep going
            // Left in else statement for future use.
        }                
    }else if(num_filenames == 1) {
        //One file name given.
        if(((!ir_set) && (!irn_set)) && preprocess[0].ecc_present == true){
            // No reference file specified.
            return -13;            
        }else if(((ir_set) || (irn_set)) && preprocess[0].ecc_present == false){
            // No -ecc/-quality/-quecc specified
            return -6; 
        }else{
            // No output file specified.    
            return -4;             
        }                          
    }
   
    if (num_filenames !=0){
    
        // Input suppresses data filename
        strcpy(io_filenames->in[0], filename[0]);
        // Input suppressed procpar filename.     
        strcpy(procpar_info[0].file_name, filename[0]); 
        // Input suppressed procpar filename    
        if(preprocess[0].input_file_type==BINARY_FILE){
            strcpy(io_filenames->in_procpar, filename[0]);   
        }
         
        if(num_filenames == 2){
            // Two filenames given
            // -ir/-irn detected.
            // Input unsuppresses data filename same as suppressed.
            strcpy(io_filenames->in[1], io_filenames->in[0]); 
            // Input unsuppressed procpar filename.  
            strcpy(io_filenames->ref_procpar, io_filenames->in_procpar);
            // Input unsuppressed procpar filename. 
            strcpy(procpar_info[1].file_name, procpar_info[0].file_name);    
            // Output unsuppressed data filename                
            strcpy(io_filenames->out[0], filename[1]);                   
            strcpy(io_filenames->out[1], filename[1]);   
        }else{
            // Three filenames given 
            // Input unsuppresses data filename same as suppressed.
            strcpy(io_filenames->in[1], filename[1]); 
            // Input unsuppressed procpar filename.  
            strcpy(io_filenames->ref_procpar, filename[1]);
            // Input unsuppressed procpar filename. 
            strcpy(procpar_info[1].file_name, filename[1]);    
            // Output unsuppressed data filename                
            strcpy(io_filenames->out[0], filename[2]);                   
            strcpy(io_filenames->out[1], filename[2]);                           
        }    
    }
    
    // No input filename given   
    if (strcmp(io_filenames->in[0], NO_FILENAME) == 0){
        return -3;        
    }
    
    // No output filename given
    if (strcmp(io_filenames->out[0], NO_FILENAME) == 0){
        return -4;        
    }

    if(only_suppressed){
        // Only suppressed ouput.
        return 1;
    }else if(only_unsuppressed){
        // Only unsuppressed ouput.
        return 2;
    }else{    
        // Both output.
        return 0;
    }
} // end command_line(...)



