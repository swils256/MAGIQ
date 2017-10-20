/******************************************************************************
fmtext_o.cpp

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:
    I/O functions.

Supports:
    4t_cv.cpp
	
Updates (yy/mm/dd):
    - 2009/06/05 - Jacob Penner added main_header[i][0].status.number 201 to fread(in_data... loop below
	- 2012/01/25 - Carl Helmick(Dalhousie) added fix for extracting and printing the filename instead of full-filepath if longer than 32-chars.  
******************************************************************************/

#include "prot.h"

// MS includes
/*#include <io.h>*/
/*#include <process.h>*/

#include <string.h>  //needed to truncate filepath or extract filename from filepath...

//2012-01-25 (Carl Helmick) ------------------
// Added below defines for extracting filename from path
#define IS_WINDOWS 0
#if defined(__WIN32__) || defined(__WIN32) || defined(WIN32) || defined(__MINGW32__) || defined(__BORLANDC__)
	#define IS_WINDOWS 1
#endif
//end of added-code 2012-01-25 ---------------

void fwrite_asc(char *outfile_name, float *data, Data_file_header *main_header,
                Data_block_header *block_header, int index1,
                Procpar_info *procpar_info, Preprocess *preprocess) {
    
    FILE	*of = NULL;
    int		j, number_output_points;
	char *fnptr = NULL;
    
    if (( of = fopen(outfile_name, "w+")) == NULL) {
        
        printf("cannot open %s !\n", outfile_name);
        
    } else {
        fprintf(of, "%d\n", procpar_info->num_points);
        fprintf(of, "1\n");
        fprintf(of, "%.8f\n", (procpar_info->acquision_time/(procpar_info->num_points/2)));
        fprintf(of, "%.7lf\n", (procpar_info->main_frequency + (procpar_info->offset_frequency/1e6)));
        fprintf(of, "%d\n", procpar_info->num_transients);
	
		//2012-01-25 (Carl Helmick) -----------------------------------------------------------
		// Assuming procpar_info->file_name is a filepath w/path-separator as / for Unix&Mac OR \ for Windows.
		// then find address of rightmost path-separator and increment by one.  If cannot find path-separator
		// then output only the rightmost 32 characters from the path string. 
        if (strlen(procpar_info->file_name)>32) {
			if (IS_WINDOWS) 
				fnptr = strrchr(procpar_info->file_name, '\\') + 1;
			else
				fnptr = strrchr(procpar_info->file_name, '/') + 1;					
			if (fnptr == NULL || strlen(fnptr) > 32) {
				//cannot determine filename in path or filename is longer than 32-chars, then truncate filename to rightmost 32-chars in filepath.
				fnptr = &procpar_info->file_name[0] + (strlen(procpar_info->file_name)-32);
			}
			printf("---> filename from path [%s] = %s\n", procpar_info->file_name, fnptr);
			fprintf(of, "%s\n", fnptr);
		} else {
			//if the filepath is shorter than 32-characters, then print the whole thing...
			fprintf(of, "%s\n", procpar_info->file_name);
		}
		//end of added-code 2012-01-25 ----------------------------------------------------------
		
		fprintf(of, "%s\n", procpar_info->date);
        fprintf(of, "MachS=%d ConvS=%.2e V1=%.3f V2=%.3f V3=%.3f vtheta=%.1f\n",
        block_header->scale.number, preprocess->scale_factor, procpar_info->vox1,
        procpar_info->vox2, procpar_info->vox3, procpar_info->vtheta);
        fprintf(of, "TE=%.3f s TM=%.3f s P1=%.5f P2=%.5f P3=%.5f Gain=%.2f\n",
        procpar_info->te, procpar_info->tm, procpar_info->pos1, procpar_info->pos2,
        procpar_info->pos3, procpar_info->gain);
        fprintf(of, "SIMULTANEOUS\n");
        fprintf(of, "0.0\n");
        fprintf(of, "EMPTY\n");
        
        // check if zero filling
        
        number_output_points = main_header->np.number;
        if (preprocess->data_zero_fill > main_header->np.number)
            number_output_points = preprocess->data_zero_fill;
        
        for (j=0; j<number_output_points; j+=2) {
            fprintf(of, "%f\n", *(data+j));
            fprintf(of, "%f\n", *(data+j+1));
        }
        
         
        if(of!=NULL){
            fclose(of);
        }    
    
    }
}


int read_csi_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                    Data_file_header **main_header,
                    Data_block_header **block_header, Precision2 *switch_data, 
                    FILE **in_file, Precision3 *csi_orig[100][100], 
                    Precision4 *csi_final[100][100], 
                    Precision4 *final_data[32][32],
                    int *pe_table, PE_info *pe_info){
    
    int i, j, k, out_data_size, min_pe_table_value = 0, actual_number_pe =0;
    PE_index pe_index[MAX_PHASE_ENCODES][MAX_PHASE_ENCODES];
    Precision4	init_precision4;
    
    init_precision4.lo = 0;
    
    for (i=0; i<*fid+1; i++){
        
        if (preprocess[i].file_type == 0){
            
            in_file[i] = fopen(file->in[i], "rb");
            
            if (&in_file[i] == NULL) {
                printf("Can't open suppressed FID data file.\n");
                exit(4);
            }
            
            // read header at top of input file
            
            if (fread(&main_header[0][0], 32, 1, in_file[i]) != 1) {
                printf("Error reading suppressed header information\n");
                exit(5);
            }
            //main_header_swap(main_header, 0);    removed for unix compile
            
            out_data_size = main_header[0][0].np.number; //second index changed from 1 to 0 for unix compile
            
            //initialize data array
            
            for (i=0; i<main_header[0][0].nblocks.number; i++){//second index changed from 1 to 0 for unix compile
                
                for (j=0; j<main_header[0][0].ntraces.number; j++){//second index changed from 1 to 0 for unix compile
                    
                    
                    if (main_header[0][0].status.number == 69 || main_header[i][0].status.number == 2073){ //second index changed from 1 to 0 for unix compile
                        csi_orig[i][j] = (Precision3 *)malloc(out_data_size * sizeof(Precision3));
                        csi_final[i][j] = (Precision4 *)malloc(out_data_size * sizeof(Precision4));
                    } else if (main_header[0][0].status.number == 73){ //second index changed from 1 to 0 for unix compile
                        csi_orig[i][j] = (Precision3 *)malloc(out_data_size * sizeof(Precision3));
                        csi_final[i][j] = (Precision4 *)malloc(out_data_size * sizeof(Precision4));
                    }
                }
            }
            
            
            //read data into array csi_orig
            
            for (i=0; i<main_header[0][0].nblocks.number; i++){//second index changed from 1 to 0 for unix compile
                
                fread(&block_header[0][0], 28, 1, in_file[0]);
                // block_header_swap(block_header, 0);  removed for unix compile
                
                for (j=0; j<main_header[0][0].ntraces.number; j++){ //second index changed from 1 to 0 for unix compile
                    
                    if (main_header[0][0].status.number == 69 || main_header[i][0].status.number == 2073){ //second index changed from 1 to 0 for unix compile
                        fread(csi_orig[i][j], main_header[0][0].np.number *
                        main_header[0][0].ebytes.number, 1, in_file[0]);
                    } else if (main_header[0][0].status.number == 73){
                        fread(csi_orig[i][j], main_header[0][0].np.number *
                        main_header[0][0].ebytes.number, 1, in_file[0]);
                    } else{
                        printf("Unknown data type: see main_header->status\n");
                        exit(6);
                    }
                }
            }
            
            // Swap bytes and store in csi_final temporarilly  - changed for unix compile
            
            for (i=0; i<main_header[0][0].nblocks.number; i++){  //second index changed from 1 to 0 for unix compile
                
                for (j=0; j<main_header[0][0].ntraces.number; j++){  //second index changed from 1 to 0 for unix compile
                    
                    for (k=0; k<int((main_header[0][0].np.number)*sizeof(long)); k+=4) {  //second index changed from 1 to 0 for unix compile
                        
                        csi_final[i][j]->character[k] = csi_orig[i][j]->character[k];
                        csi_final[i][j]->character[k+1] = csi_orig[i][j]->character[k+1];
                        csi_final[i][j]->character[k+2] = csi_orig[i][j]->character[k+2];
                        csi_final[i][j]->character[k+3] = csi_orig[i][j]->character[k+3];
                    }
                    
                    
                }
            }
            
            
            // Initialize identification structure
            
            for (i=0; i<main_header[0][0].nblocks.number; i++){ //second index changed from 1 to 0 for unix compile
                
                for (j=0; j<main_header[0][0].ntraces.number; j++){  //second index changed from 1 to 0 for unix compile
                    
                    pe_index[i][j].index_r = pe_table[i];
                    pe_index[i][j].index_c = pe_table[j];
                    
                }
            }
            
            // Determine maximum PE step to shift index
            
            for (i=0; i<pe_info->number_pe; i++){
                
                if (pe_table[i] < min_pe_table_value){
                    min_pe_table_value = pe_table[i];
                }
            }
            
            min_pe_table_value = abs(min_pe_table_value);
            pe_info->actual_number_pe = min_pe_table_value*2;
            
            
            // initialize final data array
            
            for (i=0; i<pe_info->actual_number_pe; i++){
                
                for (j=0; j<pe_info->actual_number_pe; j++){
                    final_data[i][j] = (Precision4 *)malloc(out_data_size * sizeof(Precision4));
                }
            }
            
            // initialize final data array with zeros
            
            for (i=0; i<pe_info->actual_number_pe; i++){
                
                for (j=0; j<pe_info->actual_number_pe; j++){
                    
                    for (k=0; k<int((main_header[0][0].np.number)); k++) {  //second index changed from 1 to 0 for unix compile
                        
                        *(final_data[i][j]+k) = init_precision4;
                    }
                }
            }
            
            // Reorganize FID data (Sum FIDs from same k-space co-ordinates)
            
            for (i=0; i<main_header[0][0].nblocks.number; i++){  //second index changed from 1 to 0 for unix compile
                
                for (j=0; j<main_header[0][0].ntraces.number; j++){  //second index changed from 1 to 0 for unix compile
                    
                    for (k=0; k<int((main_header[0][0].np.number)); k++) {  //second index changed from 1 to 0 for unix compile
                        
                        
                        (*(final_data[pe_index[i][j].index_r+min_pe_table_value]
                        [pe_index[i][j].index_c+min_pe_table_value]+k)).lo +=
                        (*(csi_final[i][j]+k)).lo;
                    }
                }
            }
            
            // Swap bytes back to UNIX format  - changed for unix compile
            
            for (i=0; i<pe_info->actual_number_pe; i++){
                
                for (j=0; j<pe_info->actual_number_pe; j++){
                    
                    for (k=0; k<int((main_header[0][0].np.number)*sizeof(long)); k+=4) {  //second index changed from 1 to 0 for unix compile
                        
                        csi_final[i][j]->character[k] = final_data[i][j]->character[k];
                        csi_final[i][j]->character[k+1] = final_data[i][j]->character[k+1];
                        csi_final[i][j]->character[k+2] = final_data[i][j]->character[k+2];
                        csi_final[i][j]->character[k+3] = final_data[i][j]->character[k+3];
                    }
                    
                    
                }
            }
        }
    }
    
     
    if(in_file[0]!=NULL){
            fclose(in_file[0]);
    }        
    
    return 1;
    
}

void write_csi_data(char *outfile_name, Precision4 *csi_final[100][100],
Data_file_header **main_header, Data_block_header **block_header,
PE_info *pe_info) {
    
    FILE	*of = NULL;
    int		i, j;
    short_char temp_short_variable;
    
    if (( of = fopen(outfile_name, "wb+")) == NULL) {
        
        printf("cannot open %s !\n", outfile_name);
        
    } else {
        
        main_header[0][0].nblocks.number = pe_info->actual_number_pe;
        main_header[0][0].ntraces.number = pe_info->actual_number_pe;
        main_header[0][0].bbytes.number = main_header[0][0].ntraces.number * main_header[0][0].tbytes.number
        + main_header[0][0].spare1.number * 28;
        
        /*main_header[0][0].nblocks.character[0]=main_header[0][1].nblocks.character[0];
         main_header[0][0].nblocks.character[1]=main_header[0][1].nblocks.character[1];
         main_header[0][0].nblocks.character[2]=main_header[0][1].nblocks.character[2];
         main_header[0][0].nblocks.character[3]=main_header[0][1].nblocks.character[3];
        
         main_header[0][0].ntraces.character[0]=main_header[0][1].ntraces.character[0];
         main_header[0][0].ntraces.character[1]=main_header[0][1].ntraces.character[1];
         main_header[0][0].ntraces.character[2]=main_header[0][1].ntraces.character[2];
         main_header[0][0].ntraces.character[3]=main_header[0][1].ntraces.character[3];
        
         main_header[0][0].bbytes.character[0]=main_header[0][1].bbytes.character[0];
         main_header[0][0].bbytes.character[1]=main_header[0][1].bbytes.character[1];
         main_header[0][0].bbytes.character[2]=main_header[0][1].bbytes.character[2];
         main_header[0][0].bbytes.character[3]=main_header[0][1].bbytes.character[3];
         */
        block_header[0][0].lvl.number = 0.0;
        block_header[0][0].tlt.number = 0.0;
        
        /*block_header[0][0].lvl.character[0]=block_header[0][1].lvl.character[0];
         block_header[0][0].lvl.character[1]=block_header[0][1].lvl.character[1];
         block_header[0][0].lvl.character[2]=block_header[0][1].lvl.character[2];
         block_header[0][0].lvl.character[3]=block_header[0][1].lvl.character[3];
         
         block_header[0][0].tlt.character[0]=block_header[0][1].tlt.character[0];
         block_header[0][0].tlt.character[1]=block_header[0][1].tlt.character[1];
         block_header[0][0].tlt.character[2]=block_header[0][1].tlt.character[2];
         block_header[0][0].tlt.character[3]=block_header[0][1].tlt.character[3];
         */
        fwrite(&main_header[0][0], 32, 1, of);
        
        //read data into array csi_orig
        
        temp_short_variable.number = 0;
        
        for (i=0; i<pe_info->actual_number_pe; i++){
            
            temp_short_variable.number += 1;
            
            block_header[0][0].index.character[0] = temp_short_variable.character[0];
            block_header[0][0].index.character[1] = temp_short_variable.character[1];
            
            fwrite(&block_header[0][0], 28, 1, of);
            
            for (j=0; j<pe_info->actual_number_pe; j++){
                
                fwrite(csi_final[i][j], main_header[0][0].np.number *
                main_header[0][0].ebytes.number, 1, of);//second index changed from 1 to 0 for unix compile
            }
        }
        
        putc(atoi("\r"), of);
        
         
        if(of!=NULL){
            fclose(of);
        }    
    
    }
}




int read_nmr_text(char *filename, float **out_data, Header *header, float **scratch_data, int fn){
    
    FILE *input_file = NULL;
    char text_line[80];
    int i;
    
    
    
    input_file = fopen(filename, "rt");
    
    
    if(!input_file){
        printf("Error opening : %s\n\r", filename);
        return(FALSE);
    }
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%d", &(header->number_points));
    
    out_data[fn] = (float *)malloc(header->number_points * sizeof(float));
    scratch_data[fn] = (float *)malloc(header->number_points * sizeof(float));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%d", &(header->number_components));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%f", &(header->dwell_time));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%lf", &(header->frequency));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%d", &(header->number_scans));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%d", &(header->machine_id));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%s", &(header->date));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%s", &(header->comment1));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%s", &(header->comment2));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%s", &(header->aquisition_type));
    
    fgets(text_line, 80, input_file);
    sscanf(text_line, "%f", &(header->increment));
    
    fgets(header->reserved, 80, input_file);
    
    if(strncmp(header->aquisition_type, "SIM", 3)==0){
        for(i=0;i<(header->number_points);i+=2){
            fgets(text_line, 80, input_file);
            sscanf(text_line, "%f", (out_data[fn]+i));
            fgets(text_line, 80, input_file);
            sscanf(text_line, "%f", (out_data[fn]+i+1));
        }
    }
    else{
        for(i=0;i<(header->number_points/2);i++){
            fgets(text_line, 80, input_file);
            sscanf(text_line, "%f", (out_data[fn]+i));
        }
        for(i=0;i<(header->number_points/2);i++){
            fgets(text_line, 80, input_file);
            sscanf(text_line, "%f", (out_data[fn]+header->number_points/2+i));
        }
    }
 
    if(input_file!=NULL){
            fclose(input_file);
    }    
    
    return(TRUE);
}


int read_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                Data_file_header **main_header,Data_block_header **block_header, 
                Precision2 *switch_data, FILE **in_file,
                Precision1 *in_data, float **out_data, float **scratch_data,
                Endian_Check *endianCheck){
    
    int i, j, out_data_size;
    
    for (i=0; i<*fid+1; i++){
        if (preprocess[i].file_type == 0){
            
            in_file[i] = fopen(file->in[i], "rb");
            
            if (in_file[i] == NULL) {
                printf("Can't open suppressed FID data file.\n");
                exit(4);
            }
            // read header at top of input file
            if ( i == 0){                
                if (fread(&main_header[i][0], 32, 1, in_file[i]) != 1) {
                    printf("Error reading suppressed header information\n");
                    exit(5);
                }                                                 
            } else {                
                if (fread(&main_header[i][0], 32, 1, in_file[i]) != 1) {
                    printf("Error reading unsuppressed header information\n");
                    exit(5);
                }                   
            }
            
            //Detecting file structure.  Using the status number for checking.
            if(main_header[i][0].status.number == 69 ||
               main_header[i][0].status.number == 73 ||
               main_header[i][0].status.number == 2073){
                   // System and file are the same
                   if(endianCheck->systemStruct==LITTLE_END){                        
                        if (i==0)
                            printf("*The input suppressed data file seems to have 'Little-Endian' structure.\n");                        
                        else
                            printf("*The input unsuppressed data file seems to have 'Little-Endian' structure.\n");                                                                     
                   }else{                         
                        if (i==0)
                            printf("*The input suppressed data file seems to have 'Big-Endian' structure.\n");                        
                        else
                            printf("*The input unsuppressed data file seems to have 'Big-Endian' structure.\n");                                                                                         
                   }
                   endianCheck->fileStruct=endianCheck->systemStruct;
                   printf("*No byte swaping needed.\n\n");
            }else{ // System and file are different...need byte swaping
                    if(endianCheck->systemStruct==LITTLE_END){
                        endianCheck->fileStruct=BIG_END;
                        if (i==0)
                            printf("*The input suppressed data file seems to have 'Big-Endian' structure.\n");                        
                        else
                            printf("*The input unsuppressed data file seems to have 'Big-Endian' structure.\n");
                   }else{
                        endianCheck->fileStruct=LITTLE_END;
                        if (i==0)
                            printf("*The input suppressed data file seems to have 'Little-Endian' structure.\n");                        
                        else
                            printf("*The input unsuppressed data file seems to have 'Little-Endian' structure.\n");
                   }
                   printf("*Byte swaping applied.\n\n");
                   main_header_swap(main_header, i);                     
            }
                         
            out_data_size = main_header[i][0].np.number; //changed second index from 1 to 0 for unix compile
            
            // check if zero filling and set memory accordingly
            if ((preprocess->data_zero_fill) > main_header[i][0].np.number)
                out_data_size = preprocess->data_zero_fill;   //changed second index from 1 to 0 for unix compile
            
            out_data[i] = (float *)malloc(out_data_size * sizeof(float));
            scratch_data[i] = (float *)malloc(out_data_size * sizeof(float));
            in_data[i].lo = (long *)malloc(main_header[i][0].np.number*sizeof(long));//changed second index from 1 to 0 for unix compile
            switch_data[i].lo = (long *)malloc(main_header[i][0].np.number*sizeof(long));//changed second index from 1 to 0 for unix compile
            fread(&block_header[i][0], 28, 1, in_file[i]);
            
            // Block header byte swap if needed.
            if(endianCheck->systemStruct != endianCheck->fileStruct){
                 block_header_swap(block_header, i);
            }
                                    
            // For debugging
            // printf("main_header[i][0].status.number = %i \n", main_header[i][0].status.number);
            // printf("main_header[i][1].status.number = %i \n", main_header[i][1].status.number);
            // printf("main_header[i][0].ebytes.number = %i \n", main_header[i][0].ebytes.number);
            // printf("main_header[i][1].ebytes.number = %i \n", main_header[i][1].ebytes.number);
            // printf("main_header[i][0].np.number = %i \n", main_header[i][0].np.number);
            // printf("main_header[i][1].np.number = %i \n", main_header[i][1].np.number);
             
            if (main_header[i][0].status.number == 69 ){   //changed second index from 1 to 0 for unix compile
                fread(in_data[i].lo, main_header[i][0].np.number * //changed second index from 1 to 0 for unix compile
                main_header[i][0].ebytes.number, 1, in_file[i]);
            } else if (main_header[i][0].status.number == 73 || main_header[i][0].status.number == 2073
							|| main_header[i][0].status.number == 201 ){											// added by Jacob Penner on June 5, 2009
															//changed second index from 1 to 0 for unix compile
                fread(in_data[i].fl, main_header[i][0].np.number * //changed second index from 1 to 0 for unix compile
                main_header[i][0].ebytes.number, 1, in_file[i]);  //changed second index from 1 to 0 for unix compile
            } else{
                printf("Unknown data type: see main_header->status\n");
                exit(6);
            }                        
            
            // Swap data bytes if needed.
            if(endianCheck->systemStruct == endianCheck->fileStruct){
                // Do not swap the data bytes.
                for (j=0; j<int((main_header[i][0].np.number)*sizeof(long)); j+=4) {                
                    switch_data[i].character[j] = in_data[i].character[j];
                    switch_data[i].character[j+1] = in_data[i].character[j+1];             
                    switch_data[i].character[j+2] = in_data[i].character[j+2];
                    switch_data[i].character[j+3] = in_data[i].character[j+3];               
                }                
            }else{ // Do swap the data bytes
                 for (j=0; j<int((main_header[i][0].np.number)*sizeof(long)); j+=4) {                
                    switch_data[i].character[j] = in_data[i].character[j+3];
                    switch_data[i].character[j+1] = in_data[i].character[j+2];             
                    switch_data[i].character[j+2] = in_data[i].character[j+1];
                    switch_data[i].character[j+3] = in_data[i].character[j];               
                }                                                 
            }                            
                          
            // If data is single precision (short), shift it into the "long"
            // array ".lo".  This allows for overflow checking after combination
            // of fids to make new data.            
            if (main_header[i][0].ebytes.number == 2) {  //changed second index from 1 to 0 for unix compile
                for (j=main_header[i][0].np.number-1; j>=0; j--) {  //changed second index from 1 to 0 for unix compile
                    in_data[i].lo[j] = in_data[i].sh[j];
                }
            }		              
        }
    }
    
    return 1;
    
}

int read_PE_table(char *filename, int *pe_table, PE_info *pe_info){
    
    FILE *input_file = NULL;
    char text_line[80];
    int i;
    
    input_file = fopen(filename, "rt");
    
    if(!input_file){
        printf("Error opening : %s\n\r", filename);
        return(FALSE);
    }
    
    fgets(text_line, 80, input_file);
    
    i=0;
    
    while(!feof(input_file)){
        fgets(text_line, 80, input_file);
        sscanf(text_line, "%i", &pe_table[i]);
        i++;
    }
    
    pe_info->number_pe = (i-1);
    
 
    if(input_file!=NULL){
            fclose(input_file);
    }    
    
    return(TRUE);
}