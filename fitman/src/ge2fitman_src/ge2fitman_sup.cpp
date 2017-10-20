/******************************************************************************
ge2fitman_sup.cpp

Project: ge2fitman
    Conversion routine for GE binary raw P-file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Support routines.

Supports:
    ge2fitman.cpp
******************************************************************************/

#include "include/ge2fitman_prot.h"

/*****************************************************************************
    Endian checking for the system that the program runs on.
******************************************************************************/
void endianCheck_system(Endian_Check *endian_check, bool verbose){

    //Check for system architecture.
    if(isBigEndian()){
        endian_check->systemStruct = BIG_END;
        if (verbose){
            printf("\n*This system seems to have 'Big-Endian' architecture.\n");         
        }
    }
    else{
        endian_check->systemStruct = LITTLE_END;
        if (verbose){
            printf("\n*This system seems to have 'Little-Endian' architecture.\n");   
        }
    }   
}

/*****************************************************************************
    Endian checking for the input files.
    Exit codes:   0 - No errors.
                -1 - Error reading file header
******************************************************************************/
int endianCheck_file(FILE *in_file, Endian_Check *endian_check, bool *swap_bytes
                                                        ,char *filename, bool verbose){
    float revision_num;

   
    // Check for file architecture
    // This is done with the assumption that the revision number (first header field)
    // is greater than 1.  If bytes are read in the wrong order this value
    // will result in < 1. (In Jul 2005 this value read > 8).
    fseek(in_file, 0, SEEK_SET); 
    if((fread(&revision_num, 1, sizeof(revision_num) , in_file))!=sizeof(revision_num)){
        return -1;      // Return error if could not read properly.
    }
    
    if(revision_num<1){      // Need swap byte...system and file doesn't match.
        if(endian_check->systemStruct == LITTLE_END){ 
            if (verbose){
                printf("\n*The input data file:\n  \"%s\"\n",filename);  
                printf("*seems to have 'Big-Endian' structure.\n");
            }
            endian_check->fileStruct = BIG_END;
        }else{                        
            if (verbose){
                printf("\n*The input data file:\n  \"%s\"\n",filename);  
                printf("*seems to have 'Little-Endian' structure.\n");
            }
            endian_check->fileStruct = LITTLE_END;
        }
        if (verbose){
            printf("  Byte swapping applied.\n");
        }
        *swap_bytes = true;                
    }else{                   // No need for byte swaping...system and file match.
        if(endian_check->systemStruct == LITTLE_END){
            if (verbose){
                printf("\n*The input data file:\n  \"%s\"\n",filename);  
                printf("*seems to have 'Little-Endian' structure.\n");            
            }
            endian_check->fileStruct = LITTLE_END;
        }else{
            if (verbose){
                printf("\n*The input data file:\n  \"%s\"\n",filename);  
                printf("*seems to have 'Big-Endian' structure.\n");           
            }
            endian_check->fileStruct = BIG_END;
        }
        if (verbose){
            printf("  Byte swapping NOT applied.\n");
        }
        *swap_bytes = false;        
        
    }
    return 0;    
}

/******************************************************************************
  Checks system architecture.
  Exit codes:   0 - Little endian.
                1 - Big endian.
******************************************************************************/
int isBigEndian() {
    short word = 0x4321;
    if((*(char *)& word) != 0x21 ){
        return 1;
    }else{
        return 0;
    }
}// end isBigEndian()

/******************************************************************************
  Checks character for numbers (digit or hex).
******************************************************************************/
/* NOT NEEDED
int getNumChannels(char *filename) {
    char *input;
    long value;
    
    input = NULL;
    printf(" Enter the number of channels for \n \"%s\"\n >: ");
    gets(input);
    value = strtol(input, NULL, 10);
    while(value<1 || value==LONG_MAX){
        printf("\n   *** Invalid value. ***"); 
        printf("\n Please enter an integer greater then zero : \n"); 
        gets(input);
        value = strtol(input, NULL, 10);
    }
    return((int) value);    
}
*/


/******************************************************************************
  Gets the number of channels.
******************************************************************************/
bool isNumber(char *string) {
    int i=0;
    
    if (string != NULL){
        while(string[i]!='\0'){
            if(string[i]=='.'){
            }
            else if(string[i]=='-'){
                if(i>0){
                    return false;
                }                
            }else if(!(isdigit((char) string[i]))){
                return false;
            }
            i++;
        }
        if (i==1 && string[0]=='-'){
            return false;
        }else if (i==1 && string[0]=='.'){
            return false;
        }else{
            return true;
        }
    }else{
        return false;
    }
    
}// end isNumber()

/*****************************************************************************
    Swapping bytes with given sized variables.
*****************************************************************************/
void swapBytes(char *theVarChar, int size){
        char tempChar;
        int i;
 /*  
    printf("Before: ");
    for (i=0; i<size; i++){               
        printf("%x", theVarChar[i]);
    }
    printf("\n");
   */ 
        
    for (i=0; i<(size/2); i++){
        tempChar = theVarChar[i];
        theVarChar[i]=theVarChar[size-i-1];
        theVarChar[size-i-1]=tempChar;    

    }

/*           
    printf("After: ");
    for (i=0; i<size; i++){
        printf("%x", theVarChar[i]);
    }    
    printf("\n");
 */  
}//end swapBytes()

/******************************************************************************
       YES/NO prompt routine.
******************************************************************************/
bool promptYN(){
    
    char option, junk;
    do {         
        printf(" [y/n] <ENTER>: ");         
        option = getc(stdin);
        do{
            junk=getc(stdin);                       
        }while(junk!='\n');
                
        switch(option) { 
            case 'y': 
            case 'Y': 
                return true; 
            break; 
            case 'n': 
            case 'N': 
                return false; 
            break; 
            default: 
                printf("\n   *** Invalid option. ***"); 
                printf("\nPlease enter either 'y' or 'n'...\n"); 
                break; 
        } 
    }while (1);   
}//end promptYN()

/******************************************************************************
   Suppressed/Unsuppressed/No ouput.
******************************************************************************/
int promptSUBN(){
    
    char option, junk;
    do {         
        printf(" [s/u/b/n] <ENTER>: ");         
        option = getc(stdin);
        do{
            junk=getc(stdin);                       
        }while(junk!='\n');
                
        switch(option) { 
            case 's': 
            case 'S': 
                return 1; 
            break; 
            case 'u': 
            case 'U': 
                return 2; 
            break; 
            case 'b': 
            case 'B': 
                return 0; 
            break; 
            case 'n': 
            case 'N': 
                return -1; 
            break; 
            default: 
                printf("\n   *** Invalid option. ***"); 
                printf("\nPlease enter either 's', 'u', 'b' or 'n'...\n"); 
            break; 
        } 
    }while (1);   
}//end promptSUN()


/******************************************************************************
  Initializes structures.
******************************************************************************/
void init(Data_file_header *main_header, Data_block_header *block_header
                , Procpar_info	*procpar_info, Preprocess *preprocess
                , IOFiles *io_filenames, InFile_struct *infile_struct){
    int i, j;
        
    // Initializing procpar structure    
    for(i=0; i<2; i++){
        
        // Procpar initiation
        procpar_info[i].acquision_time = 0;
        procpar_info[i].filter = 0;
        procpar_info[i].num_transients = 1;
        procpar_info[i].num_points = 0;
        procpar_info[i].main_frequency = 0;
        procpar_info[i].offset_frequency = 0;
        procpar_info[i].te = 0;
        procpar_info[i].tr = 0;
        procpar_info[i].gain = 0;
        procpar_info[i].pos1 = 0;
        procpar_info[i].pos2 = 0;
        procpar_info[i].pos3 = 0;
        procpar_info[i].vox1 = 0;
        procpar_info[i].vox2 = 0;
        procpar_info[i].vox3 = 0;
        procpar_info[i].span = 0.0;
        procpar_info[i].vtheta = 0;
        procpar_info[i].num_channels = 1;
        
        // The following 'for' loops just fill up the char* arrays with \0
        // so the ther will be no "memory access error"
        // later when the structures are copied.
        for (j=0; j<sizeof(procpar_info[i].padding_1);j++){
            procpar_info[i].padding_1[j]='\0';            
        }        
//printf("padding_1[%d]: %p\n", i,procpar_info[i].padding_1);  
         
        for (j=0; j<sizeof(procpar_info[i].ex_datetime);j++){
            procpar_info[i].ex_datetime[j]='\0';            
        }
        strcpy(procpar_info[i].ex_datetime, NO_DATE);        
//printf("ex_datetime[%d]: %p\n", i,procpar_info[i].ex_datetime);        
        
        for (j=0; j<sizeof(procpar_info[i].file_name);j++){
            procpar_info[i].file_name[j]='\0';            
        }
        strcpy(procpar_info[i].file_name, NO_FILENAME);
//printf("file_name[%d]: %p\n", i,procpar_info[i].file_name);        
        
        for (j=0; j<sizeof(procpar_info[i].hospname);j++){
            procpar_info[i].hospname[j]='\0';            
        }
        strcpy(procpar_info[i].hospname, NO_HOSP_NAME);
//printf("hospname[%d]: %p\n", i,procpar_info[i].hospname);
        
        for (j=0; j<sizeof(procpar_info[i].patname);j++){
            procpar_info[i].patname[j]='\0';            
        }
        strcpy(procpar_info[i].patname, NO_PATIENT_NAME);
//printf("patname[%d]: %p\n", i,procpar_info[i].patname);        
        
        for (j=0; j<sizeof(procpar_info[i].psdname);j++){
            procpar_info[i].psdname[j]='\0';            
        }
        strcpy(procpar_info[i].psdname, NO_PULSE_SEQ_NAME);
//printf("psdname[%d]: %p\n", i,procpar_info[i].psdname);        
        
        // Preprocess init
        preprocess[i].fid_scale=0;
        preprocess[i].scale_factor=0;
        preprocess[i].scaleby=0;
        preprocess[i].pre_ecc=0;
        preprocess[i].bc=0;
        preprocess[i].file_type=0;
        preprocess[i].data_zero_fill=0;
        preprocess[i].comp_filter=0;
        preprocess[i].max_normalize=0;
        preprocess[i].pre_quality=0;
        preprocess[i].pre_quecc=0;
        preprocess[i].pre_quecc_points=0;
        preprocess[i].pre_delay_time=0;
        preprocess[i].pre_quecc_if=0;
        preprocess[i].input_file_type=0;
        preprocess[i].ref_file_argument=0;
        preprocess[i].csi_reorder=0;
        preprocess[i].tilt=0;
        
        //Data file header (Main header) init
        main_header[i].nblocks.number=0;
        main_header[i].ntraces.number=0;
        main_header[i].np.number=0;
        main_header[i].ebytes.number=0;
        main_header[i].tbytes.number=0;
        main_header[i].bbytes.number=0;
        main_header[i].transf.number=0;
        main_header[i].status.number=0;
        main_header[i].spare1.number=0;
        
        //Data block header (Block header) init
        block_header[i].scale.number=0;
        block_header[i].status.number=0;
        block_header[i].index.number=0;
        block_header[i].spare3.number=0;
        block_header[i].ctcount.number=0;
        block_header[i].lpval.number=0;
        block_header[i].rpval.number=0;
        block_header[i].lvl.number=0;
        block_header[i].tlt.number=0;   
        
        // Input file structures init.
        infile_struct[i].num_datasets = 0;
        infile_struct[i].num_unsup_sets = 0;
        infile_struct[i].file_size = 0;
        infile_struct[i].total_data_size = 0;
        for (j=0; j<sizeof(infile_struct[i].version);j++){
            infile_struct[i].version[j]='\0';            
        }        
    }
    
    // Initializing io_filenames
    strcpy(io_filenames->in[0], NO_FILENAME);
    strcpy(io_filenames->in[1], NO_FILENAME);
    strcpy(io_filenames->out[0], NO_FILENAME);
    strcpy(io_filenames->out[1], NO_FILENAME);
    strcpy(io_filenames->in_procpar, NO_FILENAME);
    strcpy(io_filenames->ref_procpar, NO_FILENAME);
    strcpy(io_filenames->PE_table, NO_FILENAME);
    
    
}// end inti_struct()

/*****************************************************************************
  Displays help screen.  
******************************************************************************/
void disp_help(int version){
   
    if (version == HELP_SHORT) { // Short version.
        printf("\nUsage:\n");
        printf(">> ge2fitman [-options] in_file [-in_file_options]...\n");
        printf("             [reference_file][-ref_file_options]out_file\n\n");
        printf("   -options:\n");
        printf("       -h, -help, -nv, -ow, -ver\n\n");
        printf("   -in_file_options:\n");
        printf("       -scale /or/ -scaleby scale_factor, -bc,\n");
        printf("       -if, -bs, -nbs, -ir, -irn\n");
        printf("       -(ecc /or/ ...\n");
        printf("         quality delay_time(us) /or/ ...\n");
        printf("         quecc quality_points(real+imag) delay_time(us))\n"); 
        printf("         reference_file\n\n");
        printf("   -ref_file_options:\n");
        printf("       -rscale /or/ -rscaleby scale_factor, -rbc, -f filter_factor,\n");
        printf("       -rif, -rbs, -rnbs, -norm\n\n");

  
    }else { // Long version.
        printf("\nConversion routine for GE binary raw P-file to NMR286/Fitman text format.\n\n");
        printf("Usage:\n");
        printf(">> ge2fitman [-options] in_file [-in_file_options]...\n");
        printf("             [reference_file][-ref_file_options]out_file\n\n");
        //printf("\nUsage:\n>> ge2fitman [-options] in_file [-in_file_options][reference_file][-ref_file_options]out_file\n\n");
        
        printf("   in_file          Input suppressed data file.\n");
        printf("   reference_file   Input unsuppressed data file.\n");       
        printf("   out_file         Output suppressed and unsuppressed datafile name.\n");
        printf("                        -It is entered only once.\n");
        printf("                        -A \"*_s.dat\" and \"*_uns.dat\" will be appended to the\n");
        printf("                         suppressed and unsuppressed filenames respectively.\n\n");
        //printf("                        -Must be specifed last.\n\n");
        
        printf("   -options:\n");
        printf("       -h       Help screen, short version.\n");
        printf("       -help    This help screen.\n");
        printf("       -nv      No verbose.\n");
        printf("       -ow      Overwrite both output files.\n");
        printf("       -ver     Program version.\n\n");
        
        printf("   -in_file_options:\n");
        printf("       -scale                   Scale magnitude within +/- 1.\n");
        printf("       -scaleby scale_factor    Scale by specified factor.\n");        
        printf("       -bc                      Baseline correction. Using last 32 points.\n");
        printf("       -if                      Automatic exponential filter.\n");
        printf("                                 -Only applies to [-quecc].\n");
        printf("       -bs                      Forced byte swapping on in_file.\n");
        printf("       -nbs                     Forced NO byte swapping on in_file.\n");
        printf("       -ecc                     Eddy current correction.\n");
        printf("       -quality delay_time(us)  Quality deconvolution.\n");
        printf("       -quecc quality_points(real+imag) delay_time(us)\n");
        printf("                                 Combined ECC/QUALITY.\n\n");
        printf("       -ir                      Identical reference_file with in_file.\n");
        printf("                                  -Reference_file name may be omitted.\n");
        printf("                                  -All ref_file options are set as in_file, \n");
        printf("                                   with their respective equivalent, except\n");
        printf("                                   [-ecc], [-quality], [-quecc] and [-norm].\n");
        printf("       -irn                     Identical reference_file; no options.\n");
        printf("                                  -Reference_file name may be omitted.\n");
        printf("                                  -No ref_file options are set.\n");
        
        printf("   -ref_file_options:\n");
        printf("       -rscale                  Scale magnitude within +/- 1.\n");
        printf("       -rscaleby scale_factor   Scale by specified factor.\n");        
        printf("       -rbc                     Baseline correction. Using last 32 points.\n");
        printf("       -f filter_factor         Filter.\n");
        printf("       -rif                     Automatic exponential filter.\n");
        printf("                                  -Only applies to [-quecc].\n");
        printf("       -rbs                     Forced byte swapping on reference_file.\n");
        printf("       -rnbs                    Forced NO byte swapping on reference_file.\n");
        printf("       -norm                    Normalize amplitude of first time domain point\n");
        printf("                                   to 1.\n\n");        
        
        printf("   Note:\n");  
        printf("       -The following options cannot be used simultaneously:\n");
        printf("          1)   [-scale] and [-scaleby]\n");
        printf("          2)   [-rscale] and [-rscaleby]\n");
        printf("          3)   [-bs] and [-nbs]\n");
        printf("          4)   [-rbs] and [-rnbs]\n");
        printf("          5)   [-ir] and [-irn]\n");
        printf("          6)   [-ecc] and [-quality] and [-quecc]\n\n");
        printf("       -If [-ir] or [-irn] is used, ref_file options may still be applied.\n");
        printf("          In this case default reference file options are overridden.\n\n");
        printf("       -With [-ecc], [-quality] or [-quecc] the following options\n");
        printf("          should be set to obtain valid data:\n");
        printf("             -[-if], [-rif] and [-norm]\n");
        printf("             -A reference file or [-ir] or [-irn] must also be specified.\n\n");       
        printf("       -[-(r)if] must be specified for suppressed and unsuppressed file \n");
        printf("          separately, unless [-ir] or [-irn] is specified.\n\n");
        printf("       -Options must be separated with white space.\n\n");
        
        printf("   WARNING:\n");   
        printf("       -Filtering applied with negative delay time assumes data is an echo.\n\n");                
    }
   
}//end disp_help()


/******************************************************************************
   Check output files.
   Exit codes:   0 - No errors.
*******************************************************************************/
void check_outfile(IOFiles *io_filenames, bool overwrite, int s_u_out){
    int found_extension = 0;
    char *fname_suffix;       // temp file extension pointer (.dat) for output
    int i;                      // counter
    char sup_ext[5] = {'\0','\0','\0','\0','\0'};
    char sup_suf[5] = {'\0','\0','\0','\0','\0'};
    char uns_ext[5] = {'\0','\0','\0','\0','\0'};
    char uns_suf[5] = {'\0','\0','\0','\0','\0'};
    
    int filename_length[2] = {0,0};    // Filename length
    //char prompt;                // prompt for overwrite
    //char temp_argument[256];    // for temporary argument holding.
    FILE *check_file = NULL;    // Output file pointer.
    
    filename_length[0] = strlen(io_filenames->out[0]);
    filename_length[1] = strlen(io_filenames->out[1]);
    
    if(filename_length[0]>=5){
        for(i=0;i<4;i++){		//reading in possible extension
            sup_ext[i] = tolower(io_filenames->out[0][filename_length[0]-(4-i)]);        
        }
    }
    
    if(filename_length[0]>=5){
        for(i=0;i<4;i++){		//reading in possible extension unsuppressed   
            uns_ext[i] = tolower(io_filenames->out[1][filename_length[1]-(4-i)]);
        }
    }
    
    // Suppressed suffix checking
    if(strcmp(sup_ext, ".dat")==0){     //with extension
        if(filename_length[0]>=9){
            if(io_filenames->out[0][filename_length[0]-(6)]=='_'){
                // possible "_s"
                for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                    sup_suf[i] = tolower(io_filenames->out[0][filename_length[0]-(6-i)]);
                }
            }else{
                // possible "_uns"
                for(i=0;i<4;i++){           //reading in possible suffix for suppressed
                    sup_suf[i] = tolower(io_filenames->out[0][filename_length[0]-(8-i)]);
                }
            }
        }else
        if(filename_length[0]>=7){
            // possible "_s"
            for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                sup_suf[i] = tolower(io_filenames->out[0][filename_length[0]-(6-i)]);
            }
        }        
    }else{                              //without extension
        if(filename_length[0]>=5){
            if(io_filenames->out[0][filename_length[0]-(2)]=='_'){
                // possible "_s"
                for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                    sup_suf[i] = tolower(io_filenames->out[0][filename_length[0]-(2-i)]);
                }
            }else{
                // possible "_uns"
                for(i=0;i<4;i++){           //reading in possible suffix for suppressed
                    sup_suf[i] = tolower(io_filenames->out[0][filename_length[0]-(4-i)]);
                }
            }
        }else
         if(filename_length[0]>=3){
            for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                sup_suf[i] = tolower(io_filenames->out[0][filename_length[0]-(2-i)]);
            }
        }                
    }
       
    // Unsuppressed suffix checking
    if(strcmp(uns_ext, ".dat")==0){     //with extension
        if(filename_length[1]>=9){
            if(io_filenames->out[1][filename_length[1]-(6)]=='_'){
                // possible "_s"
                for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                    uns_suf[i] = tolower(io_filenames->out[1][filename_length[1]-(6-i)]);
                }
            }else{
                // possible "_uns"
                for(i=0;i<4;i++){           //reading in possible suffix for suppressed
                    uns_suf[i] = tolower(io_filenames->out[1][filename_length[1]-(8-i)]);
                }
            }
        }else
        if(filename_length[1]>=7){
            // possible "_s"
            for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                uns_suf[i] = tolower(io_filenames->out[1][filename_length[1]-(6-i)]);
            }
        }        
    }else{                              //without extension
        if(filename_length[1]>=5){
            if(io_filenames->out[1][filename_length[1]-(2)]=='_'){
                // possible "_s"
                for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                    uns_suf[i] = tolower(io_filenames->out[1][filename_length[1]-(2-i)]);
                }
            }else{
                // possible "_uns"
                for(i=0;i<4;i++){           //reading in possible suffix for suppressed
                    uns_suf[i] = tolower(io_filenames->out[1][filename_length[1]-(4-i)]);
                }
            }
        }else
         if(filename_length[0]>=3){
            for(i=0;i<2;i++){           //reading in possible suffix for suppressed
                uns_suf[i] = tolower(io_filenames->out[1][filename_length[1]-(2-i)]);
            }
        }                
    }
    
    if (s_u_out == 0 || s_u_out == 1){
        // Suppressed file setup.
        
        if(strcmp(sup_ext, ".dat")==0){  //extension found                             
            if(strcmp(sup_suf, "_uns")==0){         //"_uns" suffix found
                fname_suffix = &io_filenames->out[0][filename_length[0]-8];                
            }else if(strcmp(sup_suf, "_s")==0){     //"_s" suffix found
                fname_suffix = &io_filenames->out[0][filename_length[0]-6];                
            }else{                                  //no "_s" suffix
                fname_suffix = &io_filenames->out[0][filename_length[0]-4];                                
            }
        }else{                          //no extension found
            if(strcmp(sup_suf, "_uns")==0){         //"_uns" suffix found
                fname_suffix = &io_filenames->out[0][filename_length[0]-4];                
            }else if(strcmp(sup_suf, "_s")==0){     //"_s" suffix found
                fname_suffix = &io_filenames->out[0][filename_length[0]-2];                
            }else{                                  //no "_s" suffix
                fname_suffix = &io_filenames->out[0][filename_length[0]];                                
            }            
        }
             
        strcpy(fname_suffix, "_s.dat");
        
        if (!overwrite){
            // Check if output file(s) already exists    
            if ((check_file =  fopen(io_filenames->out[0], "r")) != NULL) {
                // Ouput file allready exists.
                // This is actually a conditional exit function.
                // If the user wants to overwtite, it will not exit.        
                cond_exit_03(io_filenames->out[0], s_u_out);
            }
        }
        
        if(check_file!=NULL){    
            fclose(check_file);
        }
    }// End suppressed part.

    if (s_u_out == 0 || s_u_out == 2){
        // Unsuppressed file setup.
        fname_suffix = NULL;               
        
        if(strcmp(uns_ext, ".dat")==0){  //extension found            
            if(strcmp(uns_suf, "_uns")==0){         //"_uns" suffix found
                fname_suffix = &io_filenames->out[1][filename_length[1]-8];                
            }else if(strcmp(uns_suf, "_s")==0){     //"_s" suffix found
                fname_suffix = &io_filenames->out[1][filename_length[1]-6];                
            }else{                                  //no "_uns" suffix
                fname_suffix = &io_filenames->out[1][filename_length[1]-4];                                
            }
        }else{                          //no extension found
            if(strcmp(uns_suf, "_uns")==0){         //"_uns" suffix found
                fname_suffix = &io_filenames->out[1][filename_length[1]-4];                
            }else if(strcmp(uns_suf, "_s")==0){     //"_s" suffix found
                fname_suffix = &io_filenames->out[1][filename_length[1]-2];                
            }else{                                  //no "_uns" suffix
                fname_suffix = &io_filenames->out[1][filename_length[1]];                                
            }            
        }
             
        strcpy(fname_suffix, "_uns.dat");
  
        if(s_u_out == 2){
            // Only unsuppressed part output.
            if (!overwrite){
               // Check if output ussuppressed file already exists    
                if ((check_file =  fopen(io_filenames->out[1], "r")) != NULL) {
                    // Ouput file allready exists.
                    // This is actually a conditional exit function.
                    // If the user wants to overwtite, it will not exit.        
                    cond_exit_03(io_filenames->out[1], s_u_out);
                }
            }
    
    
            if(check_file!=NULL){    
                fclose(check_file);
            }        
        }                
    }   
}// check_outfile()

/******************************************************************************
   Display input file statistics.
*******************************************************************************/
void infile_stats(Procpar_info *procpar_info, InFile_struct *infile_struct
                  , Data_file_header *main_header){
    
    char *filename_pointer = NULL;      // Filename pointer.
    char *token = NULL;                 // Filename token.
    char *malloc_to_free = NULL;        // Pointer to original memory address
                                        //  to free, to avoid memory leak.
    
    token = (char *)malloc((strlen(procpar_info->file_name)+1) * sizeof(char));
    malloc_to_free = token;
                      
    // File name
    strcpy(token, procpar_info->file_name);
    token = strtok(token, "/\\");
    while (token!= NULL){
        filename_pointer = token;
        token = strtok(NULL, "/\\");
    }
    
    printf("*--------------------------------------------------------------\n");
    printf("   File name..................................\t: %s\n", filename_pointer);
    printf("      ~ version...............................\t: %s\n", infile_struct->version);
    printf("      ~ size...........................(bytes)\t: %d\n", infile_struct->file_size);
    printf("   Number of channels.........................\t: %d\n", procpar_info->num_channels);
    printf("   Total data size w/o baseline sets...(bytes)\t: %d\n", infile_struct->total_data_size);
    printf("   PER CHANNEL INFORMATION:\n");
    printf("   Number of complex pairs per set............\t: %d\n", procpar_info->num_points);
    printf("       Real size.......................(bytes)\t: %d\n", main_header->ebytes.number/2);
    printf("       Imaginary size..................(bytes)\t: %d\n", main_header->ebytes.number/2);
    printf("   Set size............................(bytes)\t: %d\n"
                        , procpar_info->num_points * main_header->ebytes.number);
    printf("   Number of unsuppressed sets................\t: %d\n", infile_struct->num_unsup_sets);
    printf("   Number of suppressed sets..................\t: %d\n"
                        , infile_struct->num_datasets - infile_struct->num_unsup_sets);
    printf("   Total num. of sets per channel w/o baseline\t: %d\n", infile_struct->num_datasets);
    printf("*--------------------------------------------------------------\n");
    
    free(malloc_to_free);
}

/******************************************************************************
  Version print.
******************************************************************************/
void print_version(){
        
    printf("ge2fitman version %s\n", VERSION); 
    printf("Copyright (C) 2005-2006 Robarts Research Institute\n");
    printf("                        Imaging Research Laboratories\n\n");
    
}//end print_version()

/******************************************************************************
  Close input files.
******************************************************************************/
void close_infiles(FILE **in_file){
    int i;
    
    for (i=0; i<2; i++){
        if(in_file[i]!=NULL){
            fclose(in_file[i]);
        }
    }        
}//end close_infiles()

/******************************************************************************
  Debugging routine.  Prints hex values of given variables.
******************************************************************************/  
void printHex(char *theThing, int size){
    char *addr;
    
    addr = theThing;
    for (int i=0; i<size; i++){
        printf("address: %p \t- value: %02X\n", addr+i, theThing[i]);
        //printf("%02X", theThing[i]);
    }       
    printf("\n");
}//end printHex()
