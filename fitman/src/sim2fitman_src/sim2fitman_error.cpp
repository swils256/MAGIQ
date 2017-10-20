/******************************************************************************
sim2fitman_error.cpp

Project: sim2fitman
    Conversion routine for SIEMENS binary file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Error handling routines.

Supports:
    sim2fitman.cpp

******************************************************************************/

#include "include/sim2fitman_prot.h"

/******************************************************************************
  Argument less then 3 error.
******************************************************************************/
void exit_01(FILE **in_file){    
    close_infiles(in_file);
    disp_help(HELP_SHORT);
    exit (-1);
}//end exit_01()


/******************************************************************************
  Cannot open input file.
******************************************************************************/
void exit_02(FILE **in_file, char *filename){
    printf("\n!ERROR: Cannot open input data file: \n  \"%s\" \n", filename);
    printf("*EXITING!\n\n");
    close_infiles(in_file);
    exit(-2);    
}//end exit_02()

/******************************************************************************
  Ouput file allready exists.
******************************************************************************/
void cond_exit_03(char *filename, int s_u_out){
       
    // Overwiting option for output data files
    if(s_u_out == 0 || s_u_out == 1){
        printf("\n*Suppressed data file : \n");
    }else{
        printf("\n*Unuppressed data file : \n");
    }
    printf(" \"%s\" ", filename);
    printf(" ... already exists. \n*Would you like to overwrite "); 
    if (promptYN() == true){
        if(s_u_out == 0){
            printf("\n!!! WARNING: \n");
            printf("    BOTH THE 'suppressed' AND 'unsuppressed'\n");
            printf("    DATA FILES WILL BE OVERWRITTEN!\n");
            printf("*Proceed? ");
            if (promptYN() == true){
                printf("\n*Overwriting existing output data file(s)...\n");
            }else {            
                printf("\n!EXITING.\n\n");
                exit (-3);
            }
        }else{                        
            printf("\n*Overwriting existing output data file...\n");
        }
    }
    else {        
        printf("\n!EXITING.\n\n");
        exit (-3);            
    }
}//end cond_exit_03()

/******************************************************************************
  Command line not understood.
******************************************************************************/
void exit_04(FILE **in_file, char *argument){
    printf("\n!ERROR. \n* Command line argument \"%s\"", argument);
    printf(" not understood.\n");    
    close_infiles(in_file);
    disp_help(HELP_SHORT);
    exit(-4);    
}//end exit_04()

/******************************************************************************
  Error - use -scale or -scaleby, not both.
******************************************************************************/
void exit_05(FILE **in_file){
    printf("\n!ERROR\n* Cannot use [-(r)scale] or [-(r)scaleby] simultaneously for the same input.\n!EXITING.\n\n");    
    close_infiles(in_file);
    exit(-5);    
}//end exit_05()

/******************************************************************************
  Error reading data.
******************************************************************************/
void exit_06(FILE **in_file, char *filename){
    printf("\n!ERROR\n*Cannot read data from:\n");
    printf("  \"%s\"", filename);
    printf("\n!EXITING.\n\n");
    close_infiles(in_file);
    exit (-6);
}//end exit_06()

/******************************************************************************
  Error reading file header.
******************************************************************************/
void exit_07(FILE **in_file, char *filename){
    printf("\n!ERROR reading file header from:\n");
    printf("   \"%s\"\n", filename);
    printf("!EXITING.\n\n");       
    close_infiles(in_file);
    exit (-7);
}//end exit_07()

/******************************************************************************
  Cannot open output file.
******************************************************************************/
void exit_08(char *filename){
    printf("\n!ERROR: Cannot open output data file: \n  \"%s\" \n", filename);
    printf("*EXITING!\n\n");
    exit(-8);    
}//end exit_08()

/******************************************************************************
  Input file version not recognized.
******************************************************************************/
void exit_09(FILE **in_file, char *filename, InFile_struct *infile_struct){
    printf("\n!ERROR - unrecognized input file version \'%s\' for file:\n"
                                        , infile_struct->version);
    printf("   \"%s\"\n", filename);
    printf("!EXITING.\n\n");   
    close_infiles(in_file);
    exit (-9);
}//end exit_09()

/******************************************************************************
  Invalid file size detected.
******************************************************************************/
void exit_10(FILE **in_file, char *filename, InFile_struct *infile_struct){
    printf("\n!ERROR - invalid file size detected for file:\n");
    printf("   \"%s\"\n", filename);
    printf("!EXITING.\n\n");   
    close_infiles(in_file);
    exit (-10);
}//end exit_10()

/******************************************************************************
  No input file specified.
******************************************************************************/
void exit_11(FILE **in_file){
    printf("\n!ERROR\n");
    printf("* No input file specified.\n");
    printf("!EXITING.\n\n");   
    close_infiles(in_file);
    exit (-11);
}//end exit_11()

/******************************************************************************
  No output file specified.
******************************************************************************/
void exit_12(FILE **in_file){
    printf("\n!ERROR\n");
    printf("* No output file specified.\n");
    printf("!EXITING.\n\n");   
    close_infiles(in_file);
    exit (-12);
}//end exit_12()

/******************************************************************************
  ERROR - too many filenames, or no ECC specified.
******************************************************************************/
void exit_13(FILE **in_file){
    printf("\n!ERROR. \n* Too many file names given.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-13);    
}//end exit_13()

/******************************************************************************
  ERROR - no ECC specified.
******************************************************************************/
void exit_14(FILE **in_file){
    printf("\n!ERROR. \n* No [-ecc], [-quality] or [-quecc] specified.\n");   
    //printf("* Must be specified before output filename.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-14);    
}//end exit_14()

/******************************************************************************
  ERROR -  ECC allready specified.
******************************************************************************/
void exit_15(FILE **in_file){
    printf("\n!ERROR. \n* Cannot use [-ecc] and/or [-quality] and/or [-quecc] simultaneously.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-15);    
}//end exit_15()

/******************************************************************************
  ERROR -  -ir/-irn allready specified.
******************************************************************************/
void exit_16(FILE **in_file){
    printf("\n!ERROR. \n* Cannot use [-ir] and [-irn] simultaneously.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-16);    
}//end exit_16()

/******************************************************************************
  ERROR -  -bs/-nbs allready specified.
******************************************************************************/
void exit_17(FILE **in_file){
    printf("\n!ERROR. \n* Cannot use [-(r)bs] and [-(r)nbs] simultaneously for the same input file.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-17);    
}//end exit_17()

/******************************************************************************
  ERROR -  ecc must be before -ir/-irn
******************************************************************************/
void exit_18(FILE **in_file){
    printf("\n!ERROR. \n* [-ir] or [-irn] must be used after [-ecc], [-quality] or [-quecc].\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-18);    
}//end exit_18()

/******************************************************************************
  ERROR -  Invalid -ecc/-quality/-quec option.
******************************************************************************/
void exit_19(FILE **in_file){
    printf("\n!ERROR. \n* Invalid or missing [-quality] or [-quecc] option.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-19);    
}//end exit_19()

/******************************************************************************
  ERROR -  Reference file allready specified.
******************************************************************************/
void exit_20(FILE **in_file){
    printf("\n!ERROR. \n* Invalid [-ir] or [-irn] option.\n");  
    printf("* Reference unsuppressed filename allready specified.\n");  
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-20);    
}//end exit_20()

/******************************************************************************
  Some reference file otption allready set.
******************************************************************************/
void cond_exit_21(){
       
    // Overwiting reference file options ?
    printf("\n!!! WARNING: \n");
    printf("    Some reference file options are allready specified.\n");
    printf("    Would you like to override them"); 
    if (promptYN() == false){ 
        printf("\n    Either specify [-ir] before reference file options\n");
        printf("    or use [-irn].\n");
        printf("\n!EXITING.\n\n");       
        exit (-21);
    }
}//end cond_exit_21()

/******************************************************************************
  No output file specified.
******************************************************************************/
void exit_22(FILE **in_file){
    printf("\n!ERROR\n");
    printf("* No reference file specified.\n");
    printf("!EXITING.\n\n");   
    close_infiles(in_file);
    exit (-22);
}//end exit_22()

/******************************************************************************
  Sup, unsup or no output.
******************************************************************************/
int cond_exit_23(){
    int s_u_out;
    
    // Asking for suppressed or unsuppressed output.
    printf("\n*Would you like suppressed, unsuppressed or no ouput "); 
    s_u_out = promptSUBN();
    if (s_u_out == 1){        
        // Only suppressed ouput.
        return 1;
    } else if(s_u_out == 2) {        
        // Only unsuppressed ouput.
        return 2;
    }else if(s_u_out == 0) {        
        // Both ouput.
        return 0;
    }
    printf("\n!EXITING.\n\n");
    exit (-23);                   
}//end cond_exit_23()


/******************************************************************************
  Invalid number of points specified for QUECC.
******************************************************************************/
void exit_24(FILE **in_file, int num){
    printf("\n!ERROR\n");
    printf("* Invalid number of points specified for [-quecc].\n");
    printf("* The valid point range is: 1 - %d\n", num);
    printf("!EXITING.\n\n");   
    close_infiles(in_file);
    exit (-24);
}//end exit_24()

/******************************************************************************
  ERROR -  Invalid -scaleby parameter
******************************************************************************/
void exit_25(FILE **in_file){
    printf("\n!ERROR. \n* Invalid or missing [-scaleby] option.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-25);    
}//end exit_25()

/******************************************************************************
  ERROR -  Invalid -rscaleby parameter
******************************************************************************/
void exit_26(FILE **in_file){
    printf("\n!ERROR. \n* Invalid or missing [-rscaleby] option.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-26);    
}//end exit_26()

/******************************************************************************
  ERROR -  Invalid -f (filter) parameter
******************************************************************************/
void exit_27(FILE **in_file){
    printf("\n!ERROR. \n* Invalid or missing [-f] option.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-27);    
}//end exit_27()


/******************************************************************************
  ERROR -  Invalid reference file specified
******************************************************************************/
void exit_28(FILE **in_file){
    printf("\n!ERROR. \n* Invalid reference file specified.\n");   
    printf("* The reference file cannot be the same as the input file.\n");   
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-28);    
}//end exit_28()

