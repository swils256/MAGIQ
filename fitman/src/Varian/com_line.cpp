/******************************************************************************
com_line.cpp

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:
    This function interprets the command line to determine what processing needs
    to be done on each data file.

Supports:
    4t_cv.cpp
******************************************************************************/

#include "prot.h"

// MS includes
//#include <io.h>


int command_line(Preprocess *preprocess, IOFiles *file, Procpar_info *procpar_info,
int argc, char **argv, int *fid) {
    
    int i, argc_counter;
    int found_extension = 0;
    FILE *check_file;
    char *temp_extension;       // temp file extension pointer (.dat) for output
    char prompt;                // prompt for overwrite
    
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
    }
    
    if(!strcmp(argv[3], "-fdf")){
        preprocess[0].input_file_type = FDF_FILE;
    }
    
    if(!strcmp(argv[3], "-text")){
        preprocess[0].input_file_type = TEXT_FILE;
    }
    
    if(!strcmp(argv[3], "-csi_reorder")){
        preprocess[i].csi_reorder = YES;
    }
    
    strcpy(file->in[0], argv[1]);
    strcpy(procpar_info[0].file_name, argv[1]);
    
    //added
    char tempfile0[5000];

    strcpy(tempfile0, file->in[0]);
    //end of added


    if(preprocess[0].input_file_type==BINARY_FILE) strcat(file->in[0], "/fid");   
    //if(preprocess[0].input_file_type==BINARY_FILE) strcat(file->in[0], "/fid.txt");


    // Check if suppressed data file is OK
    check_file = fopen(file->in[0], "rb");

    if (check_file == NULL) {

      //added

      strcpy(file->in[0], tempfile0); 
      
      if(preprocess[0].input_file_type==BINARY_FILE) strcat(file->in[0], "/fid.txt");

      check_file = fopen(file->in[0], "rb");
      //end of added
      
      if (check_file == NULL) {

	printf("Suppressed data file either does not exist, or cannot be read.\n");

        exit(3);
      } }
    fclose(check_file);    
    
    strcpy(file->out[0], argv[2]);    
    
    // Check to see if ecc correction is requested
    for (i=1; i<argc; i++){
        if (!strcmp(argv[i], "-ecc") || !strcmp(argv[i], "-quality") || !strcmp(argv[i], "-quecc")){
            // 10/05/2005 - Added checking routine for .dat extension
            //              for the suppressed output file
            //              It checks all case versions of .dat
            switch (found_extension){
                case 0:
                    temp_extension = strstr(file->out[0], ".dat");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".daT");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".dAt");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".dAT");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".Dat");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".DaT");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".DAt");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[0], ".DAT");
                    if (temp_extension!=NULL) break;
            }
            if (temp_extension==NULL){
                strcat(file->out[0], "_s.dat");
            }
            else{
                strcpy(temp_extension, "_s.dat");
            }
        }
    }    
    
    // Check if suppressed output file already exists
    if ((check_file =  fopen(file->out[0], "r")) != NULL) {
        // 10/05/2005 - Added overwitting option for output datafiles
        printf("\n*Data file : ");
        printf(" \"%s\" ", file->out[0]);
        printf("already exists. \n*Would you like to overwrite (y/n) <ENTER>? "); 
        printf("> ");
        scanf("%c", &prompt);
        fflush(NULL);
        if (prompt=='y' || prompt=='Y'){
            printf("*Overwitting datafiles...\n");
        }else {
            printf("\n*Remove/delete existing datafiles: ");
            printf("\"%s\"\n", file->out[0]);
            printf("*then reprocess input file...exitting...\n\n");
            exit(3);
        }
	fclose(check_file);  
    }
      
    
    
    if(preprocess[0].input_file_type==BINARY_FILE){
        strcpy(file->in_procpar, argv[1]);

        //need to make it work for both cases!
        //strcat(file->in_procpar, "/procpar");
	strcat(file->in_procpar, "/procpar.txt");
        
        // Check if suppressed procpar file is OK
        check_file = fopen(file->in_procpar, "r");

	//added by jd
	printf("file->in_procpar %s: ",file->in_procpar);

        if (check_file == NULL) {
            printf("Input procpar file either does not exist, or cannot be read.\n");
            exit(2);
        }
        fclose(check_file);
        
    }
    
    // check if any other preprocessing is required
    argc_counter = 2;
    *fid = 0;
    
    while (argc_counter < argc-1) {
        
        argc_counter++;
        
        if(!strcmp(argv[argc_counter], "-ecc") ||
        !strcmp(argv[argc_counter], "-quality") ||
        !strcmp(argv[argc_counter], "-quecc")){
            
            if(!strcmp(argv[argc_counter], "-ecc")){
                preprocess[*fid].pre_ecc = YES;
                argc_counter++;
                preprocess[*fid].ref_file_argument= argc_counter;
                *fid = 1;
                preprocess[*fid].ref_file_argument= argc_counter;
                preprocess[*fid].pre_ecc = YES;
                strcpy(file->in[1], argv[argc_counter]);
                if(preprocess[0].input_file_type == BINARY_FILE){
                    strcat(file->in[1], "/fid");
                }
            }
            if(!strcmp(argv[argc_counter], "-quality")){
                preprocess[*fid].pre_quality = YES;
                argc_counter++;
                preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                preprocess[*fid].ref_file_argument= argc_counter+1;
                *fid = 1;
                preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                argc_counter++;
                preprocess[*fid].ref_file_argument= argc_counter;
                preprocess[*fid].pre_quality = YES;
                strcpy(file->in[1], argv[argc_counter]);
                if(preprocess[0].input_file_type == BINARY_FILE){
                    strcat(file->in[1], "/fid");
                }
            }
            if(!strcmp(argv[argc_counter], "-quecc")){
                preprocess[*fid].pre_quecc = YES;
                argc_counter++;
                preprocess[*fid].pre_quecc_points = atoi(argv[argc_counter]);
                argc_counter++;
                preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                preprocess[*fid].ref_file_argument= argc_counter+1;
                *fid = 1;
                preprocess[*fid].pre_quecc = YES;
                preprocess[*fid].pre_quecc_points = preprocess[0].pre_quecc_points;
                preprocess[*fid].pre_delay_time = float(atof(argv[argc_counter]));
                argc_counter++;
                preprocess[*fid].ref_file_argument= argc_counter;
                strcpy(file->in[1], argv[argc_counter]);
                
		/*
		if(preprocess[0].input_file_type == BINARY_FILE){
                    strcat(file->in[1], "/fid");
		*/
		if(preprocess[0].input_file_type == BINARY_FILE){
                    strcat(file->in[1], "/fid.txt");
                }
            }
            
            // Check if unsuppressed data file is OK
            
            check_file = fopen(file->in[1], "rb");
            if (check_file == NULL) {
                printf("Unuppressed data file either does not exist, or cannot be read.\n");
                exit(2);
            }
            fclose(check_file);
            
            
            if(preprocess[0].input_file_type == BINARY_FILE){
                strcpy(file->ref_procpar, argv[argc_counter]);
                strcat(file->ref_procpar, "/procpar");
                
                // Check if unsuppressed procpar file is OK
                
                check_file = fopen(file->ref_procpar, "r");
                if (check_file == NULL) {
                    printf("Reference procpar file either does not exist, or cannot be read.\n");
                    exit(2);
                }
                fclose(check_file);
                
                
                strcpy(procpar_info[1].file_name, argv[argc_counter]);
            }
            
            strcpy(file->out[1], argv[2]);
            temp_extension = NULL;
            // 10/05/2005 - Added checking routine for .dat extension
            //              for the UNsuppressed output file
            //              It checks all case versions of .dat            
             switch (found_extension){
                case 0:
                    temp_extension = strstr(file->out[1], ".dat");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".daT");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".dAt");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".dAT");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".Dat");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".DaT");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".DAt");
                    if (temp_extension!=NULL) break;
                    temp_extension = strstr(file->out[1], ".DAT");
                    if (temp_extension!=NULL) break;
            }
            if (temp_extension==NULL){              // no extension found
                strcat(file->out[1], "_uns.dat");
            }
            else{                                   // replace/fix extension
                strcpy(temp_extension, "_uns.dat");
            }

            // Check if unsuppressed output file already exists
           /* 
            if ((check_file =  fopen(file->out[1], "r")) != NULL) {
                 // 10/05/2005 - Added overwitting option for output datafiles

                printf("\n*Unsuppresed data file : ");
                printf(" \"%s\" ", file->out[1]);
                printf("already exists. \n*Would you like to overwrite (y/n) <ENTER>? "); 
                printf("> ");
                scanf("%c", &prompt);
                //fflush(stdin);
                if (prompt=='y' || prompt=='Y'){
                    printf("*Overwitting unsuppressed datafile...\n");
                }else {
                    printf("\n*Remove/delete existing unsuppressed datafile: ");
                    printf("\"%s\"\n", file->out[1]);
                    printf("*then reprocess input file...exitting...\n\n");
                 exit(3);
                }
            }
            fclose(check_file);
            */
        } else {
            
            if (!strcmp(argv[argc_counter], "-scale")){
                
                if (preprocess[*fid].scaleby == NO){
                    preprocess[*fid].fid_scale = YES;
                    preprocess[*fid].scale_factor = float(1.0);
                } else {
                    printf(" Use only -scale or -scaleby, not both!\n");
                    exit(2);
                }
                
            } else if (!strcmp(argv[argc_counter], "-scaleby")){
                
                if (preprocess[*fid].fid_scale == NO){
                    preprocess[*fid].scaleby = YES;
                    argc_counter++;
                    sscanf(argv[argc_counter], "%f", &preprocess[*fid].scale_factor);
                } else {
                    printf(" Use only -scale or -scaleby, not both!\n");
                    exit(2);
                }
                
            } else if (!strcmp(argv[argc_counter], "-norm")){
                
                preprocess[*fid].max_normalize = YES;
                
            } else if (!strcmp(argv[argc_counter], "-if")){
                
                preprocess[*fid].pre_quecc_if = YES;
                
            } else if (!strcmp(argv[argc_counter], "-f")){
                
                argc_counter++;
                sscanf(argv[argc_counter], "%f", &preprocess[*fid].comp_filter);
                
            } else if (!strcmp(argv[argc_counter], "-bc")){
                
                preprocess[*fid].bc = YES;
                
            } else if (!strcmp(argv[argc_counter], "-tilt")){
                
                preprocess[*fid].tilt = YES;
                
            } else if (!strcmp(argv[argc_counter], "-t")){
                
                preprocess[*fid].file_type = 1;
                
            } else if (!strcmp(argv[argc_counter], "-b")){
                
                preprocess[*fid].file_type = 0;
                
            } else if (!strcmp(argv[argc_counter], "-zf")){
                
                argc_counter++;
                sscanf(argv[argc_counter], "%i", &preprocess[0].data_zero_fill);
                sscanf(argv[argc_counter], "%i", &preprocess[1].data_zero_fill);
                preprocess[0].data_zero_fill = preprocess[0].data_zero_fill *2;
                preprocess[1].data_zero_fill = preprocess[1].data_zero_fill *2;
                
            } else if (!strcmp(argv[argc_counter], "-fdf")){
                printf("\n Converting FDF file type.\n");
                
            } else if (!strcmp(argv[argc_counter], "-text")){
                printf("\n Reading Text file type.\n");
                
            } else if (!strcmp(argv[argc_counter], "-csi_reorder")){
                printf("\n Reordering CSI data.\n");
                
                //input PE table file
                argc_counter++;
                strcpy(file->PE_table, argv[argc_counter]);                                

            } else {                
                printf(" Command line argument not understood... skipping to next argument\n");
                exit(2);
            }
        }        
    }        
    return 1;
} // end command_line(...)
