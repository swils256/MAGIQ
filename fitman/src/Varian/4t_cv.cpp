/******************************************************************************
4t_cv.cpp

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:
    Main executable

Contributors (name - year):    
  - Csaba Kiss - 2005

Updates (yy/mm/dd):
    - 1998/09/02 - increase array size for parameter_name to 255 
    - 2005/05/06 - Project reconstructed from older versions.
    - 2005/05/11 - DISABLED argv[3] options "-text", "-fdf", "-csi_reorder".
    - 2005/05/10 - Added screen outputs.
    - 2005/05/27 - Added memory alignment checking (big/little endian).
    - 2005/08/17 - Replaced stream functions with ANSI C functions for portability.
    - 2006/02/13 - Changed compilation to static for better compatibility.
                 - Introduced Version numbering (1.0)
	- 2009/06/05 - Jacob Penner added main_header[i][0].status.number 201 to out_data = switch_data loop below
	
 ******************************************************************************/

#include "prot.h"


// MS includes
/*#include <io.h>*/
/*#include <process.h>*/

int IsBigEndian();

int main(int argc, char *argv[]){
    
    Data_file_header	**main_header;
    Data_block_header	**block_header;
    
    Header              txt_header;
    
    Precision1		in_data[2];
    Precision2		switch_data[2];
        
    Procpar_info	procpar_info[2];
    Preprocess		preprocess[2];
    IOFiles		file;
    
    long                maxval=16384;
    int                 i, j, fn;
    int                 fid=0;

    FILE                *in_file[2];
    float               *out_data[2];
    float               *scratch_data[2];
    
    Endian_Check        endianCheck;         // Variable for endian checking
    
    // Initializing input files.
    in_file[0]=NULL;
    in_file[1]=NULL; 
    
    
    if (argc < 3) {
        printf("\n4t_cv version %s\n", VERSION); 
        printf("Copyright (C) 2000-2006 Robarts Research Institute\n");
        printf("                        Imaging Research Laboratories\n");
        printf("\n\nUsage: 4t_cv in_file out_file\n");
        printf("<-scale> <-scaleby scale_factor> <-bc> <-zf #_points> <nfids #s>\n\n");
        printf("<-ecc> reference_file \n");
        printf("<-scale> <-scaleby scale_factor> <-bc> <-zf #_points>\n\n");
        printf("<-quality> delay_time(us) reference_file \n");
        printf("<-norm> <-scale> <-scaleby scale_factor> <-bc> <-zf #_points> <-f FWHM>\n\n");
        printf("<-quecc> QUALITY_points(real+imag) delay_time(us) reference_file \n");
        printf("<-norm> <-scale> <-scaleby scale_factor> <-bc> <-zf #_points> <-(i)f FWHM> <nfids #uns>\n");
        printf("Note: <-if> must be specified for suppressed and unsuppressed file separately\n\n");
        printf("WARNING: Filtering applied with negative delay time assumes data is an echo.\n");
        exit(1);
    }
   
    //Check for system architecture.
    if(IsBigEndian()){
        endianCheck.systemStruct=BIG_END;
    }
    else{
        endianCheck.systemStruct=LITTLE_END;
    }
    
    // allocate memory for header structures          
    main_header = (Data_file_header **)malloc(2*sizeof(Data_file_header *));
    block_header = (Data_block_header **)malloc(2*sizeof(Data_block_header *));
    
    for (i=0; i<2; i++){
        main_header[i] = (Data_file_header *)malloc(2*sizeof(Data_file_header ));
        block_header[i] = (Data_block_header *)malloc(2*sizeof(Data_block_header ));
    }
    
    
    // Initialize procpar structure    
    for(i=0; i<2; i++){
        procpar_info[i].acquision_time = float(0.0);
        procpar_info[i].filter = float(0.0);
        procpar_info[i].num_transients = 1;
        procpar_info[i].num_points = 1024;
        procpar_info[i].main_frequency = 0.0;
        procpar_info[i].offset_frequency = 0.0;
        procpar_info[i].te = float(0.0);
        procpar_info[i].tm = float(0.0);
        procpar_info[i].gain = float(0.0);
        procpar_info[i].pos1 = float(0.0);
        procpar_info[i].pos2 = float(0.0);
        procpar_info[i].pos3 = float(0.0);
        procpar_info[i].vox1 = float(0.0);
        procpar_info[i].vox2 = float(0.0);
        procpar_info[i].vox3 = float(0.0);
        procpar_info[i].span = 0.0;
        procpar_info[i].vtheta = float(0.0);
    }
    
    for(i=0; i<2; i++){
        strcpy(procpar_info[i].date, "No Date Available");
        strcpy(procpar_info[i].file_name, "No Filename Available");
    }
    
    // Interpret the command line and determine what preprocessing is
    // to be done on each file

/* DISABLE argv[3] start...

    if(!strcmp(argv[3], "-text")){
        
        
        Precision1		*in_data[2];
        Precision2		*switch_data[2];
        float   		*out_data[2];
        float   		*scratch_data[2];
        
        fn = 0;
        read_nmr_text(argv[1], out_data, &txt_header, scratch_data, fn);
        
        procpar_info[0].acquision_time = (txt_header.number_points/2) * txt_header.dwell_time;
        strcpy(procpar_info[0].date, txt_header.date);
        strcpy(procpar_info[0].file_name, argv[1]);
        procpar_info[0].num_transients = txt_header.number_scans;
        procpar_info[0].num_points = txt_header.number_points;
        procpar_info[0].main_frequency = txt_header.frequency;
        procpar_info[0].offset_frequency = 0.0;
        procpar_info[0].te = 20.0;
        procpar_info[0].tm = 30.0;
        main_header[0][0].np.number = txt_header.number_points;  //changed second index from 1 to 0 for unix compile
        block_header[0][0].scale.number = 0;  //changed second index from 1 to 0 for unix compile
        
        command_line(&preprocess[0], &file, &procpar_info[0] , argc, argv, &fid);
        
        if(preprocess[fid].pre_ecc == YES || preprocess[fid].pre_quality == YES ||
        preprocess[fid].pre_quecc == YES){
            
            fn = 1;
            read_nmr_text(argv[preprocess[fid].ref_file_argument], out_data,
            &txt_header, scratch_data, fn);
            
            procpar_info[1].acquision_time = (txt_header.number_points/2) * txt_header.dwell_time;
            strcpy(procpar_info[1].date, txt_header.date);
            strcpy(procpar_info[1].file_name, file.in[1]);
            procpar_info[1].num_transients = txt_header.number_scans;
            procpar_info[1].num_points = txt_header.number_points;
            procpar_info[1].main_frequency = txt_header.frequency;
            procpar_info[1].offset_frequency = 0.0;
            procpar_info[1].te = 0.0;
            procpar_info[1].tm = 0.0;
            main_header[1][0].np.number = txt_header.number_points;  //changed second index from 1 to 0 for unix compile
            block_header[1][0].scale.number = 0;  //changed second index from 1 to 0 for unix compile
        }
        
        pre_process(&fid, preprocess, procpar_info, out_data, scratch_data);
        
        //		procpar_info[0].num_points = txt_header.number_points;
        //		procpar_info[1].num_points = txt_header.number_points;
        
        for (i=0; i<fid+1; i++){
            fwrite_asc(file.out[i], out_data[i], &main_header[i][0], &block_header[i][0], 1,
            &procpar_info[i], &preprocess[i]);// second index changed from 1 to 0 for unix compile
        }
        
        return(TRUE);
        
    }else if(!strcmp(argv[3], "-fdf")){
        
        
        Precision1		*in_data[2];
        Precision2		*switch_data[2];
        float   		*out_data[2];
        float   		*scratch_data[2];
        
        command_line(&preprocess[0], &file, &procpar_info[0] , argc, argv, &fid);
        
        read_fdf_data(&fid, preprocess, &file, main_header, block_header, switch_data, in_file,
        in_data, out_data, scratch_data, &procpar_info[0]);
        
        for (i=0; i<fid+1; i++){
            for (j=0; j<int((main_header[i][0].np.number)); j++)
                out_data[i][j] = switch_data[i][0].fl[j];// second index changed from 1 to 0 for unix compile
            
        }
        
        pre_process(&fid, preprocess, procpar_info, out_data, scratch_data);
        
        for (i=0; i<fid+1; i++){
            fwrite_asc(file.out[i], out_data[i], &main_header[i][0], &block_header[i][0], 1,
            &procpar_info[i], &preprocess[i]);// second index changed from 1 to 0 for unix compile
            
        }
        
        for (i=0; i<fid+1; i++){
            fclose(in_file[i]);
        }
        
        
        return(TRUE);
        
    }else if(!strcmp(argv[3], "-csi_reorder")){
        
        
        Precision1		*in_data[2];
        Precision2		*switch_data[2];
        float   		*out_data[2];
        float   		*scratch_data[2];
        
        command_line(&preprocess[0], &file, &procpar_info[0] , argc, argv, &fid);
        
        int pe_table[MAX_PHASE_ENCODES];
        PE_info	pe_info;
        
        read_PE_table(file.PE_table, pe_table, &pe_info);
        
        Precision3 *csi_orig[MAX_PHASE_ENCODES][MAX_PHASE_ENCODES];
        Precision4 *csi_final[MAX_PHASE_ENCODES][MAX_PHASE_ENCODES];
        Precision4	*final_data[32][32];
        
        read_csi_data(&fid, preprocess, &file, main_header, block_header, switch_data, in_file,
        csi_orig, csi_final, final_data, pe_table, &pe_info);
        
        write_csi_data(file.out[0], csi_final, main_header, block_header, &pe_info);
        
        
        return(TRUE);
        
    }else{
*/


        command_line(&preprocess[0], &file, &procpar_info[0] , argc, argv, &fid);   

	//ok here


//  } // DISABLE argv[3] end. Note: "command_line" above NOT disabled as it is needed.
        
    // Read the important procpar information that is required for the Fitman
    // header and the processing of spectra
    
    read_procpar(&procpar_info[0], file.in_procpar);

    /*
    fflush(stdout);
    exit(0);
    */ 
    
    if (fid == 1){
        read_procpar(&procpar_info[1], file.ref_procpar);
    }
    
    // Read in required data
    printf("\n*Reading data files...\n");
        //Check for system architecture.
    if(IsBigEndian()){
        printf("\n*This system seems to have 'Big-Endian' architecture\n\n");        
    }
    else{
        printf("\n*This system seems to have 'Little-Endian' architecture\n\n");     
    }
    read_data(&fid, preprocess, &file, main_header, block_header, switch_data, in_file,
    in_data, out_data, scratch_data, &endianCheck);
    
    
    // Change data from long to float
    
    for (i=0; i<fid+1; i++){
        
    // For debugging
    // printf("index i = %i \n", i);
    // printf("main_header[i][0].status.number = %i \n", main_header[i][0].status.number);
        
        if(main_header[i][0].status.number == 69  ){            
            for (j=0; j<int((main_header[i][0].np.number)); j++) //changed second index from 1 to 0 for unix compile
            {
                out_data[i][j] = (float)switch_data[i].lo[j];
                // For debugging
                /* if(j==0){
                    printf("switch data = %f \n", switch_data[i].lo[j]);
                    printf("out_data = %f \n", out_data[i][j]);
                } //end debug */
            }                        
        } else if (main_header[i][0].status.number == 73 || main_header[i][0].status.number == 2073
							|| main_header[i][0].status.number == 201){													/////// added by Jacob Penner on June 5, 2009
            for (j=0; j<int((main_header[i][0].np.number)); j++) //changed second index from 1 to 0 for unix compile
            {
                out_data[i][j] = switch_data[i].fl[j];
                // For debugging 
              /*  if(j==0){
                    printf("switch data = %f \n", switch_data[i].fl[j]);
                    printf("out_data = %f \n", out_data[i][j]);
                }// end debug */
            }
        }
    }
            
    // preprocess FIDs based on what was requested on command line    
    printf("\n*Processing data...\n");
    pre_process(&fid, preprocess, procpar_info, out_data, scratch_data);
    // Write out data in Fitman text format
    
    printf("\n*Writting data...\n");
    for (i=0; i<fid+1; i++){
        fwrite_asc(file.out[i], out_data[i], &main_header[i][0], &block_header[i][0], 1,
        &procpar_info[i], &preprocess[i]);//changed second index from 1 to 0 for unix compile
    }
    
    // 10/05/2005 - Added screen outputs
    printf("\n*Written data files: \n");
    printf("  >>Suppressed   : \"%s\"\n", file.out[0]);
    printf("  >>Unuppressed  : \"%s\"\n", file.out[1]);
    printf("\n\n");
    
    for (i=0; i<fid+1; i++){
         if(in_file[i]!=NULL){
            fclose(in_file[i]);
        }
    }
    
    free(in_data[0].lo);
    free(switch_data[0].lo);
    
    if (fid==1){
        free(in_data[1].lo);
        free(switch_data[1].lo);
    }
    
    //  free(in_data[0]);
    //  free(switch_data[0]);
    free(out_data[0]);
    free(scratch_data[0]);
    
    if (fid==1){
    //    free(in_data[1]);
    //   free(switch_data[1]);
        free(out_data[1]);
        free(scratch_data[1]);
    }
    
    free(main_header);
    free(block_header);
    
    return(TRUE);
    
} // end main(...)



/******************************************************************************/
int IsBigEndian() {
    short word = 0x4321;
    if((*(char *)& word) != 0x21 ){
        return 1;
    }else{
        return 0;
    }
}// end IsBigEndien()
