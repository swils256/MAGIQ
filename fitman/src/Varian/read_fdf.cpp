/******************************************************************************
read_fdf.cpp

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:

Supports:
    4t_cv.cpp
******************************************************************************/

#include "prot.h"

// MS includes
/*#include <io.h>*/
/*#include <process.h>*/

int read_fdf_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                    Data_file_header **main_header,
                    Data_block_header **block_header, Precision2 *switch_data, 
                    FILE **in_file, Precision1 *in_data, float **out_data, 
                    float **scratch_data, Procpar_info *procpar_info){
    
    int i, j, out_data_size, ch;
    float dum5, dum6;
    int dum7;
    char text_line[80], null_test_string[80], symbol[80];
    char dum1[80], dum2[80], dum3[80], dum4[80], dum9[80];
    double dum8;
    
    for (i=0; i<*fid+1; i++){
        
        if (preprocess[i].file_type == 0){
            
            in_file[i] = fopen(file->in[i], "rb");
            
            if (&in_file[i] == NULL) {
                printf("Can't open FDF data file.\n");
                exit(4);
            }
            
            // read header at top of input file
            
            fgets(text_line, 80, in_file[i]);
            sscanf(text_line, "%s", null_test_string);
            
            if ( i == 0){
                while (strcmp(&text_line[0], "\n")){
                    fgets(text_line, 80, in_file[i]);
                    sscanf(text_line, "%s%s", null_test_string, symbol);
                    
                    if(!strcmp(symbol, "Created")){
                        sscanf(text_line, "%s%s%s%s%s%s%s%s%s%s", dum1, dum1, dum1, dum1, dum1, dum1,
                        dum2, dum3, dum4, dum9);
                        strcat(dum1, " ");
                        strcat(dum1, dum2);
                        strcat(dum1, " ");
                        strcat(dum1, dum3);
                        strcat(dum1, " ");
                        strcat(dum1, dum4);
                        strcat(dum1, " ");
                        strcat(dum1, dum9);
                        strcpy(procpar_info->date, dum1);
                        strcpy(symbol, "");
                    }
                    
                    if(!strcmp(symbol, "nucfreq[]")){
                        sscanf(text_line, "%s%s%s%s%lf,%f", dum1, dum2, dum3, dum4, &dum8, &dum6);
                        procpar_info->main_frequency = dum8;
                    }
                    
                    if(!strcmp(symbol, "span[]")){
                        sscanf(text_line, "%s%s%s%s%f", dum1, dum2, dum3, dum4, &dum5);
                        procpar_info->span = (double)dum5;
                    }
                    
                    if(!strcmp(symbol, "rank")){
                        sscanf(text_line, "%s%s%s%i%s", dum1, dum2, dum3, &dum7, dum4);
                        main_header[i][1].ntraces.number = (long)dum7;
                    }
                    
                    if(!strcmp(symbol, "bits")){
                        sscanf(text_line, "%s%s%s%i%s", dum1, dum2, dum3, &dum7, dum4);
                        main_header[i][1].ebytes.number = (long)dum7/(long)8;
                    }
                    
                    if(!strcmp(symbol, "matrix[]")){
                        sscanf(text_line, "%s%s%s%s%i", dum1, dum2, dum3, dum4, &dum7);
                        main_header[i][1].np.number = (long)dum7*(int)2;
                        procpar_info->num_points = (int)dum7*(int)2;
                    }
                }
            }
            
            // Set information output in Fitman header
            
            procpar_info->acquision_time = (float)((procpar_info->num_points/2)* (1/(procpar_info->span*procpar_info->main_frequency)));
            procpar_info->num_transients = 1;
            procpar_info->te = (float)0.0;
            procpar_info->tm = (float)0.0;
            block_header[0][1].scale.number = short(1);
            
            out_data_size = main_header[i][1].np.number;
            
            // check if zero filling and set memory accordingly
            if ((preprocess->data_zero_fill) > main_header[i][0].np.number)
                out_data_size = preprocess->data_zero_fill;//second index changed from 1 to 0 for unix compile
            
            out_data[i] = (float *)malloc(out_data_size * sizeof(float));
            scratch_data[i] = (float *)malloc(out_data_size * sizeof(float));
            
            in_data[i].lo = (long *)malloc(main_header[i][0].np.number*sizeof(long));//second index changed from 1 to 0 for unix compile
            switch_data[i].lo = (long *)malloc(main_header[i][0].np.number*sizeof(long));//second index changed from 1 to 0 for unix compile
            
            // Look for the next null character (=0) to mark the start of the data
            
            do {
                ch = getc(in_file[i]);
            } while(ch != 0);
            
            //			fseek(in_file[i], 5, SEEK_CUR);
            
            fread(in_data[i].fl, main_header[i][0].np.number *
            main_header[i][0].ebytes.number, 1, in_file[i]);//second index changed from 1 to 0 for unix compile
            
            // If data is single precision (short), shift it into the "long"
            // array ".lo".  This allows for overflow checking after combination
            // of fids to make new data.
            
            if (main_header[i][1].ebytes.number == 2) {
                for (j=main_header[i][0].np.number-1; j>=0; j--) {
                    in_data[i].lo[j] = in_data[i].sh[j];//second index changed from 1 to 0 for unix compile
                }
            }
            
            for (j=0; j<int((main_header[i][0].np.number)*sizeof(float)); j+=4) {//second index changed from 1 to 0 for unix compile
                switch_data[i].character[j] = in_data[i].character[j];
                switch_data[i].character[j+1] = in_data[i].character[j+1];
                switch_data[i].character[j+2] = in_data[i].character[j+2];
                switch_data[i].character[j+3] = in_data[i].character[j+3];
            }
        }
    }
    
    return 1;
    
}
