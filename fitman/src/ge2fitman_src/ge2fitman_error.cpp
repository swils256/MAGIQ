/******************************************************************************
 ge2fitman_error.cpp

 Project: ge2fitman
 Conversion routine for GE binary raw P-file to NMR286 / Fitman text format
 Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

 File description:
 Error handling routines.

 Supports:
 ge2fitman.cpp
 ******************************************************************************/

#include "include/ge2fitman_prot.h"

/******************************************************************************
 Filter output from zero sets.
 ******************************************************************************/
void filter_zero_set(FILE **in_file, InFile_struct *infile_struct,
                    Preprocess *preprocess, int *fid, bool verbose,
                    Procpar_info *procpar_info, int *s_u_out){
    
    //All sets are zero...nothing to output.
    if (infile_struct[1].num_datasets == 0){
        //If the number of suppressed sets in the ref file is zero, do not output it.
        exit_30(in_file);
    }
    
    //The two files (sup & unsup) don not have the same number of channel.
    if(procpar_info[0].num_channels != procpar_info[1].num_channels){
        exit_32(in_file);
    }
    
    
    //Three cases, depending on what is requested fro output/
    //Both, suppressed on unsuppressed.
    switch(*s_u_out){
        //Both sets requested.
        case 0:  
            //No suppressed set present....ecc requested
            if ((infile_struct[1].num_datasets - infile_struct[1].num_unsup_sets) == 0 &&
                infile_struct[1].num_unsup_sets != 0){                                
                *s_u_out=2;
                if (verbose){
                    printf("\n!WARNING\n");
                    printf("* The the input file contains no suppressed set...\n");
                    if (preprocess[0].ecc_present == true){
                        undo_ecc(preprocess, fid);
                        printf("* Ignoring ecc/quality/quecc and reference file switches.\n");
                    }
                    printf("* Only unsuppressed part is processed.\n");
                }
                return;
            }                  
            //No unsuppressed set present.
            else if((infile_struct[1].num_datasets - infile_struct[1].num_unsup_sets) != 0 &&
                infile_struct[1].num_unsup_sets == 0){
	      if(procpar_info[0].num_channels == 1){
	      //Input file is single channel...ok to process.
                    *s_u_out=1;
                    if (verbose){
                        printf("\n!WARNING\n");
                        printf("* The reference file contains no unsuppressed (water) set...\n");
                        if (preprocess[0].ecc_present == true){
                            undo_ecc(preprocess, fid);
                            printf("* Ignoring ecc/quality/quecc and reference file switches.\n");  
                        }
                        printf("* Only suppressed part is processed.\n");
                    }                   
                }else{
                    //Input file is multichannel....cannot process due to zero water set.
		  exit_28(in_file);
                }
                return;
            }
            return;
        //Supressed sets requested.
        case 1:             
            if(procpar_info[0].num_channels > 1){
                //Input file is multichannel....cannot process due to zero water set.
              
	      //commented out by jd, Jan 27, 2010
	      //exit_28(in_file);

	      //printf("did not exit_28\n");
	      return;
            }                       
            else if((infile_struct[1].num_datasets - infile_struct[1].num_unsup_sets) == 0 &&
                    infile_struct[1].num_unsup_sets != 0){
                //No suppressed set present.
                exit_31(in_file);      
                return;
            }
            return;            
        //Unsupressed sets requested.
        case 2:
            //No unsuppressed set present.
            if((infile_struct[1].num_datasets - infile_struct[1].num_unsup_sets) != 0 &&
                infile_struct[1].num_unsup_sets == 0){
                exit_29(in_file);        
                return;
            }
    }//end switch(*s_u_out)    
}//end filter_zero_set()





/******************************************************************************
 Argument less then 3 error.
 ******************************************************************************/
void exit_01(FILE **in_file){
    close_infiles(in_file);
    disp_help(HELP_SHORT);
    exit(-1);
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
                exit(-3);
            }
        }else{
            printf("\n*Overwriting existing output data file...\n");
        }
    }
    else {
        printf("\n!EXITING.\n\n");
        exit(-3);
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
    exit(-6);
}//end exit_06()

/******************************************************************************
 Error reading file header.
 ******************************************************************************/
void exit_07(FILE **in_file, char *filename){
    printf("\n!ERROR reading file header from:\n");
    printf("   \"%s\"\n", filename);
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-7);
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
    exit(-9);
}//end exit_09()

/******************************************************************************
 Invalid file size detected.
 ******************************************************************************/
void exit_10(FILE **in_file, char *filename, InFile_struct *infile_struct){
    printf("\n!ERROR - invalid file size detected for file:\n");
    printf("   \"%s\"\n", filename);
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-10);
}//end exit_10()

/******************************************************************************
 No input file specified.
 ******************************************************************************/
void exit_11(FILE **in_file){
    printf("\n!ERROR\n");
    printf("* No input file specified.\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-11);
}//end exit_11()

/******************************************************************************
 No output file specified.
 ******************************************************************************/
void exit_12(FILE **in_file){
    printf("\n!ERROR\n");
    printf("* No output file specified.\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-12);
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
        exit(-21);
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
    exit(-22);
}//end exit_22()

/******************************************************************************
 Sup, unsup or no output.
 ******************************************************************************/
int cond_exit_23(){
    int s_u_out;
    
    // Asking for suppressed or unsuppressed output.
    printf("\n*Would you like suppressed, unsuppressed, both or no ouput ");
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
    exit(-23);
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
    exit(-24);
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
 ERROR -  No water set for multichannel files
 ******************************************************************************/
void exit_28(FILE **in_file){
    printf("\n!ERROR. \n* The reference contains no unsuppressed (water) set.\n");
    printf("* Phase of FIDs per channel for multi-channel files cannot be \n");
    printf("* obtained without a water set.\n");
    printf("* Use reference files that contain unssuppressed (water) set(s).\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-28);
}//end exit_28()

/******************************************************************************
 ERROR -  No water set for ref file when only unsuppressed output requested.
 ******************************************************************************/
void exit_29(FILE **in_file){
    printf("\n!ERROR. \n* The reference file contains no unsuppressed (water) set.\n");
    printf("* Nothing to output.\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-29);
}//end exit_29()

/******************************************************************************
 ERROR -  All sets are zer...nothing to output.
 ******************************************************************************/
void exit_30(FILE **in_file){
    printf("\n!ERROR. \n* This file contains no data sets.\n");
    printf("* Nothing to output.\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-30);
}//end exit_30()

/******************************************************************************
 ERROR -  No suppressed set for input file when only suppressed output requested.
 ******************************************************************************/
void exit_31(FILE **in_file){
    printf("\n!ERROR. \n* The input file contains no suppressed set.\n");
    printf("* Nothing to output.\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-31);
}//end exit_31()

/******************************************************************************
 ERROR -  The two files have different number of channels.
 ******************************************************************************/
void exit_32(FILE **in_file){
    printf("\n!ERROR. \n* The input file and reference file have different number of channels.\n");
    printf("* Cannot process.\n");
    printf("!EXITING.\n\n");
    close_infiles(in_file);
    exit(-32);
}//end exit_32()
