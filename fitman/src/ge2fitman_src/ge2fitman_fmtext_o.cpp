/******************************************************************************
 ge2fitman_fmtext_o.cpp

 Project: ge2fitman
 Conversion routine for GE binary raw P-file to NMR286 / Fitman text format
 Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

 File description:
 Read and write routines from input and to output files.

 Supports:
 ge2fitman.cpp
 ******************************************************************************/

#include "include/ge2fitman_prot.h"


/******************************************************************************
 Read data from input files.
 *******************************************************************************/
int read_data(int *fid, Preprocess *preprocess, IOFiles *file,
				Data_file_header *main_header, Data_block_header *block_header,
				Precision2 *switch_data, FILE **in_file, Procpar_info *procpar_info,
				Precision1 *in_data, float **out_data, float **scratch_data
				, int swap_bytes, InFile_struct *infile_struct, bool verbose){
    
    int     i, out_data_size;
    int     countFID=0;             // Counter for FID sets.
    int     countChannel=0;         // Counter for Channel num.
    int     countPoint=0;           // Counter for elements per FID.
    int     numSets=0;              // Number of FID sets.
    int     dataSizeChannel=0;      // Total data size per Channel including the baseline set.
    long    baseline_set_size=0;    // Baseline (dummy) set size.
    long    unsup_set_size=0;       // Unsuppressed set size.
    long    header_size=0;          // The file header size;
    float   temp_float;             // Temporary float value.
    float   *phase;					// Phase value for each channel.


    //revised by jd, March 31, 2010
    //long *temp_long;
    int *temp_long;                  // Temporary integer value array
    
    //int *temp_double;
    //double *temp_double;
    //float *temp_double;            // Temporary double value array
    //char *temp_double;

    int k;

    int ii;
    
    bool    phaseIt = false;		// Phase flag.

    
    //Reading in data from multiple FID sets and multiple number of Channels.
    //fid: 0 - suppressed
    //     1 - unssppressed
    //Read unsuppressed (water) set first.

    // revised by jd, July 10, 2009
    //for (i=*fid; i>=0; i--){
     for (i=0; i<*fid; i++){  //changed i<*fid to i<=*fid
       //printf("i = %d\n", i);
    // end of added code

        if (preprocess[i].file_type == 0){
  

	  //printf("infile_struct->version = %s*\n", infile_struct->version);

            //  Number of pairs * (Real + Im) size.
            out_data_size =(int) main_header[i].np.number*2;
	    //out_data_size =(int) main_header[i].np.number;

	    //added by jd, Feb 4, 2010
	    
	    //revised by jd, March 31, 2010
	    //temp_long = (long *)malloc(out_data_size * sizeof(long));
	    temp_long = (int *)malloc(out_data_size * sizeof(int));


	    //temp_double = (int *)malloc(out_data_size * sizeof(int));
	    //temp_double = (double *)malloc(out_data_size * sizeof(double));
	    //temp_double = (char *)malloc(out_data_size * sizeof(char));
	    //temp_double = (double *)malloc(out_data_size * sizeof(double));
	    //temp_double = (float *)malloc(out_data_size * sizeof(float));

	    //end of added code

            out_data[i] = (float *)malloc(out_data_size * sizeof(float));
            scratch_data[i] = (float *)malloc(out_data_size * sizeof(float));
            
            in_data[i].fl = (float *)malloc(out_data_size * sizeof(float));
            switch_data[i].fl = (float *)malloc(out_data_size * sizeof(float));
            
	    //added by jd, Feb 19, 2010
	    in_data[i].lo = (long *)malloc(out_data_size * sizeof(long));
            switch_data[i].lo = (long *)malloc(out_data_size * sizeof(long));
	    
	    //printf("out_data_size = %d\n", out_data_size);

            // Initialize switch_data[i]
            for (countPoint=0; countPoint<out_data_size; countPoint+=2 ) {
                switch_data[i].fl[countPoint]=0;            // Real part
                switch_data[i].fl[countPoint+1]=0;          // Im part
            }
            
            // Header size
            if(strcmp(infile_struct->version, "08")==0 ||
            strcmp(infile_struct->version, "8")==0){
                header_size = HEADER_SIZE_8X;
            }else if(strcmp(infile_struct->version, "09")==0 ||
            strcmp(infile_struct->version, "9")==0){
                header_size = HEADER_SIZE_9X;
            }else if (strcmp(infile_struct->version, "11")==0){
                header_size = HEADER_SIZE_11X;
            }else if (strcmp(infile_struct->version, "12")==0){
	      // header_size = HEADER_SIZE_12X + 7*0x4c000; //Debug
	      header_size = HEADER_SIZE_12X;
	    }else if (strcmp(infile_struct->version, "20.006001")==0){
	      printf("20.006001\n");
	      
	      //revised Sept 8, 2010
	      //header_size = HEADER_SIZE_20X;
              header_size = 149788;

	    }else if (strcmp(infile_struct->version, "14.3")==0){
	      printf("14.3\n");
	      header_size = HEADER_SIZE_20X;
	    }

	    

	    //header_size = HEADER_SIZE_20X;

	    //temp fix: header_size = 149788;
	    
	    //revised Sept 8, 2010
	    //header_size = 145908;
	    header_size = 149788;

	    if (strcmp(infile_struct->version, "14.3")==0){
	      header_size = 145908;
	      printf("header_size = 145908\n");
	    }

	    //header_size = 149808;

	    //for debugging
	    /*
	    printf("header_size = %d\n", header_size);

	    printf("HEADER_SIZE_8X = %d\n",HEADER_SIZE_8X);
	    printf("HEADER_SIZE_9X = %d\n",HEADER_SIZE_9X);
	    printf("HEADER_SIZE_11X = %d\n",HEADER_SIZE_11X);
	    printf("HEADER_SIZE_12X = %d\n",HEADER_SIZE_12X);
	    printf("HEADER_SIZE_20X = %d\n",HEADER_SIZE_20X);
	    */

            // Baseline (dummy) set size.
            baseline_set_size = main_header[i].ebytes.number * main_header[i].np.number;
            
	    //printf("baseline_set_size = %d\n", baseline_set_size);

            // Unsuppressed set size.
            unsup_set_size = main_header[i].ebytes.number * main_header[i].np.number
	     * infile_struct[i].num_unsup_sets;
							

            //Total data size per Channel, baseline set included (baseline + unsup + sup)
            //dataSizeChannel = baseline_set_size * (1 +  infile_struct[i].num_datasets);
            
	    dataSizeChannel = baseline_set_size * (infile_struct[i].num_datasets);
	    //added for DEBUGGING purposes
	    //by jd, Jan 29, 2010
	    

	    //printf("infile_struct[%d].num_datasets = %d\n", i, infile_struct[i].num_datasets);

	    //DEBUGGING print echo statements
	    /*
	    printf("\n\n\n\n***************************************************\n");

	    printf("procpar_info[0].acquision_time = %f\n",procpar_info[0].acquision_time);
	    printf("procpar_info[0].ex_datetime = %s\n", procpar_info[0].ex_datetime );

	    printf("procpar_info[0].file_name = %s\n", procpar_info[0].file_name);
	    printf("procpar_info[0].filter = %f\n",procpar_info[0].filter);

	    printf("procpar_info[0].num_transients = %d\n",procpar_info[0].num_transients);

	    printf("procpar_info[0].num_points = %d\n",procpar_info[0].num_points);
	    printf("procpar_info[0].main_frequency = %g\n",procpar_info[0].main_frequency);

	    printf("procpar_info[0].offset_frequency = %g\n",procpar_info[0].offset_frequency);

	    printf("procpar_info[0].te = %f\n",procpar_info[0].te);

	    printf("procpar_info[0].tr = %f\n",procpar_info[0].tr);

	    printf("procpar_info[0].R1 = %f\n",procpar_info[0].R1);

	    printf("procpar_info[0].R2 = %f\n",procpar_info[0].R2);

	    printf("procpar_info[0].gain = %f\n",procpar_info[0].gain);

	    printf("procpar_info[0].pos1 = %f\n",procpar_info[0].pos1);

	    printf("procpar_info[0].pos2 = %f\n",procpar_info[0].pos2);

	    printf("procpar_info[0].pos3 = %f\n",procpar_info[0].pos3);

	    printf("procpar_info[0].vox1 = %f\n",procpar_info[0].vox1);

	    printf("procpar_info[0].vox2 = %f\n",procpar_info[0].vox2);

	    printf("procpar_info[0].vox3 = %f\n",procpar_info[0].vox3);

	    printf("procpar_info[0].padding_1 = %s\n",procpar_info[0].padding_1);
	    printf("procpar_info[0].span = %g\n",procpar_info[0].span);

	    printf("procpar_info[0].vtheta = %f\n",procpar_info[0].vtheta);

	    printf("***************************************************\n\n\n\n\n");

	    printf("dataSizeChannel = %d\n", dataSizeChannel);
	    */
            //printf("File position %x\n", ftell(in_file[0]));
            
	    //added by jd, Jan 27, 2010
	    if(i==0){
	      phase = (float *)malloc(procpar_info[0].num_channels * sizeof(float));

	      //added by jd, Jan 27, 2010
	      //printf("phase = %f\n", phase);
	      //end of added code
	      
				get_phase(phase, in_file, main_header, infile_struct, header_size, 
						file, swap_bytes, procpar_info);
				phaseIt = true;
				printf("\n*Adjusting phase(s).\n");
	      
				}
	    else {
	      


            if(i==1 && (procpar_info[0].num_channels>1 || procpar_info[1].num_channels>1)){
                //Initializing phase.
				phase = (float *)malloc(procpar_info[1].num_channels * sizeof(float));
				get_phase(phase, in_file, main_header, infile_struct, header_size, 
						file, swap_bytes, procpar_info);
				phaseIt = true;
				printf("\n*Adjusting phase(s).\n");
            }

	    //added by jd, June 16, 2010
	    else{
	      
	      phase = (float *)malloc(procpar_info[i].num_channels * sizeof(float));

	      //added by jd, Jan 27, 2010
	      //printf("phase = %f\n", phase);
	      //end of added code
	      phase = (float *)malloc(procpar_info[i].num_channels * sizeof(float));
	      
				get_phase(phase, in_file, main_header, infile_struct, header_size, 
						file, swap_bytes, procpar_info);
				phaseIt = true;
				printf("\n*Adjusting phase(s).\n");
	      

	    }


	    }

            //Read in data for countChannel number of Channels.
            //For ver 8,9,11 this is usually 1, for ver. 12x this is more.

	    //added by jd, Jan 27, 2010
	    //printf("Pprocpar_info[%d].num_channels = %d\n",i,procpar_info[i].num_channels);	    
	    //end of added code

            //revised by jd, Feb 3, 2010
	    /*
            for(countChannel=0; countChannel<procpar_info[i].num_channels; countChannel++){     
            */
	    /*
	    for(countChannel=0; countChannel<procpar_info[i].num_channels-1; countChannel++){ 
	    */

	    //revised by jd, March 31, 2010
	    

	    //revised Sept 9, 2010
	    /*
	    for(countChannel=0; countChannel<(procpar_info[i].num_channels-1); countChannel++){
	    */
	    for(countChannel=0; countChannel<procpar_info[i].num_channels; countChannel++){
 
	    //temp fix: for(countChannel=0; countChannel<=(2*(procpar_info[i].num_channels-1)); countChannel=countChannel+2){

	    //end of revised code

	      //added by jd, Feb 3, 2010
	      //printf("countChannel = %d\n", countChannel);
	      //fflush(stdout);
	      //end of added code
                        
	      //added by jd, Feb 18, 2010
	      //for debugging
	      /*
	      printf("&&&&&&&&&&&&&&&&&&&&\n");
	      printf("header_size = %d\n", header_size);
	      printf("baseline_set_size = %d\n", baseline_set_size);
	      printf("unsup_set_size = %d\n", unsup_set_size);
	      printf("dataSizeChannel = %d\n", dataSizeChannel);
	      printf("countChannel = %d\n", countChannel/2);
	      printf("procpar_info[%d].num_channels = %d\n", i, procpar_info[i].num_channels);
	      */
	      //end of added code
   
                if (i==0){
		  printf("Reading suppressed data \n");
                    // Reading suppressed data.
                    
		  //revised by jd, April 1, 2010
		  
		  fseek(in_file[i], header_size + baseline_set_size
		      + unsup_set_size + (dataSizeChannel*countChannel), SEEK_SET);


		  //fseek(in_file[i], header_size + unsup_set_size, SEEK_SET); //Debug
		  //printf("File position (suppressed) %x\n", ftell(in_file[i]));  //Debug
                    numSets = infile_struct[i].num_datasets - infile_struct[i].num_unsup_sets;

		    //printf("numSets = %d\n", numSets);
                }
                else {
                    // Reading unsuppressed data.
                  
		  //revised back to original fseek statement
		  //this change has no effect however because
		  //all the P-files only have 1 set of suppressed data
		  fseek(in_file[i], header_size + baseline_set_size + (dataSizeChannel*countChannel), SEEK_SET);
                  
		  //fseek(in_file[i], header_size, SEEK_SET); //Debug
                    //For debugging...used it to get all sets
                    //fseek(in_file[i], header_size , SEEK_SET); //Debug
                    //numSets = infile_struct[i].num_unsup_sets+1; //Debug
                    
		    //numSets = 1;

		    //printf("File position (unsuppresed) %x\n", ftell(in_file[i])); //Debug
                    //End debug
                    
		  //temp fix: numSets = infile_struct[i].num_unsup_sets;
		  numSets = infile_struct[i].num_datasets - infile_struct[i].num_unsup_sets;
                }
                
                //Read in data for countFID number of FIDs per Channel.
                for (countFID=0;countFID<numSets;countFID++){
                    //Reading data pairs.
                    
                    printf("\nFile position before read %x\n\n", ftell(in_file[i])); //Debug
                    
		    // added by jd, July 10, 2009
		    // for debugging
		    /*
		    printf("main_header[%d].np.number*2 = %d\n", i, main_header[i].np.number*2);
		    printf("main_header[%d].ebytes.number/2 = %d\n", i, main_header[i].ebytes.number/2);
		    */
		    // end of added code

		    if (i == 0){

		      k = fread(temp_long, main_header[i].ebytes.number/2
                                , main_header[i].np.number*2, in_file[i]);
		    }

		    if(k != main_header[i].np.number*2){
		      exit_06(in_file, file->in[i]);
			    }
		     else{
	 
		       for(countPoint=0; countPoint < main_header[i].np.number*2; countPoint++){
			
			 if (i == 0)
			 {
			 
			   in_data[i].lo[countPoint] = (long) (temp_long[countPoint]);

			   // for debugging  
			   //printf("in_data[%d].lo[%d] = %ld\n",i,countPoint,in_data[i].lo[countPoint]);
	
			 //end of added code

			 }

		       }
		     }

                    // Byte swaping each element if needed.
                    if(swap_bytes){
                        for (countPoint=0; countPoint < main_header[i].np.number*2; countPoint++ ) {
                            if (main_header[i].ebytes.number/2 == 2){
                                swapVarBytes(in_data[i].sh[countPoint]);
				//added by jd, Feb 17, 2010
			    }else if(main_header[i].ebytes.number/2 == 8){
                            swapVarBytes(temp_long[countPoint]);    
                            in_data[i].lo[countPoint] = (long) temp_long[countPoint];                 	
			    }else if(main_header[i].ebytes.number/2 == 4){
                            swapVarBytes(temp_long[countPoint]);    
                            in_data[i].lo[countPoint] = (long) temp_long[countPoint];                 	
                            }else{
                                swapVarBytes(in_data[i].lo[countPoint]);
                            }
                        }
                    }
                    
                     //Printing first 4 hex values of in_data
                     //printHex((char *)in_data[i].fl, 4); //debug
                     
		    
		    //added debug print statement
		    //by jd, Feb 17, 2010
		    printf("Mmain_header[i].ebytes.number/2 == %d\n", main_header[i].ebytes.number/2);

                    // Transfering short to float if needed.
                    // or long to float depending on the input data size.
                    if (main_header[i].ebytes.number/2 == 2){
                        for (countPoint=(main_header[i].np.number*2)-1; countPoint>=0; countPoint--){
                            in_data[i].fl[countPoint] = (float)in_data[i].sh[countPoint];
                        }
                    }else if (main_header[i].ebytes.number/2 == 4){
                        for (countPoint=0; countPoint<(main_header[i].np.number*2); countPoint++){
                            temp_float = (float)in_data[i].lo[countPoint];
                            in_data[i].fl[countPoint] = temp_float;
                        }
			//added by jd, Feb 17, 2010
			//for transfering double to float
                    }else if (main_header[i].ebytes.number/2 == 8){
                        for (countPoint=0; countPoint<(main_header[i].np.number*2); countPoint++){
			  //temp_float = (float)in_data[i].lo[countPoint];
                          temp_float = (float) temp_long[countPoint];

			  in_data[i].fl[countPoint] = temp_float;
			}
		    }
                    //Printing first 4 hex values of in_data
                    //printHex((char *)in_data[i].fl, 4); //debug
		    
		    //printf("\n(int)(countChannel/2) = %d\n",(int)(countChannel/2));
		    
                    if(phaseIt){
		      ///printf("I'm fixing phase for FID #%d and channel #%d\n", countFID+1, countChannel+1); //Debug
		      
		      //revised Sept 9, 2010
		      /*
		      printf("I'm fixing phase for FID #%d and channel #%d\n", countFID+1, (int)(countChannel/2)+1);
		      */
		      printf("I'm fixing phase for FID #%d and channel #%d\n", countFID+1, countChannel+1); //Debug

 
		      //added by jd, April 1, 2010
		      //printf("\nphase[%d] = %g\n",(int)(countChannel/2),phase[(int)(countChannel/2)]);

		      //revised by jd, April 1, 2010
		      //fix_phase(phase[(int)(countChannel/2)], main_header[i].np.number*2, in_data, i, countFID+1);

		      //revised Sept 9, 2010
		      /*
		      fix_phase(phase[(int)(countChannel/2)], main_header[i].np.number*2, in_data, i, countFID);
		      */
		      fix_phase(phase[countChannel], main_header[i].np.number*2, in_data, i, countFID+1);

			}
                    printf("Set #%d\n", countFID+1);

		    //Added finding maximum magnitude of signal for each channel
		    /*
		    double mag[4096];
		      
		    //temp fix:
		    
		    for (countPoint=0; countPoint<main_header[i].np.number*2; countPoint +=2 ) {
		      
		      mag[countPoint]  = sqrt(in_data[i].fl[countPoint]*in_data[i].fl[countPoint]+in_data[i].fl[countPoint+1]*in_data[i].fl[countPoint+1]);

			}

		    float max = 0;

		    for (countPoint=0; countPoint<main_header[i].np.number*2; countPoint +=2 ) {
		      if (mag[countPoint] > max)
			max = mag[countPoint];

			}

		    */
		    //end of added code

		    //printf("\nmax = %f\n", max);
		   

                    // Adding up the FID sets
                    /*for (countPoint=0; countPoint<main_header[i].np.number*2; countPoint +=2 ) {
		     */

		    //revised by jd, March 31, 2010
		    /*
		    for (countPoint=0; countPoint<main_header[i].np.number*2; countPoint +=2 ) {
		    */
		    for (countPoint=0; countPoint<main_header[i].np.number*2; countPoint +=2 ) {
		      
		      //use the following two assignments if performing non-weighted conversion of P-file

		      
                        switch_data[i].fl[countPoint] += in_data[i].fl[countPoint];
                        switch_data[i].fl[countPoint+1] += in_data[i].fl[countPoint+1];
		      
			//added by jd, April 1, 2010
			double mag2;


			//use the following three assignments if performing weighted conversion of P-file

			/*
			mag2 = max/1e6 * sqrt(in_data[i].fl[countPoint]*in_data[i].fl[countPoint]+in_data[i].fl[countPoint+1]*in_data[i].fl[countPoint+1]);

			switch_data[i].fl[countPoint] += mag2*cos(atan(in_data[i].fl[countPoint+1]/in_data[i].fl[countPoint]));

			switch_data[i].fl[countPoint+1] += mag2*sin(atan(in_data[i].fl[countPoint+1]/in_data[i].fl[countPoint]));
			*/		

			//end of added code

			//}
			  //Debugging print statements
                        //Prints raw points
                        /*printf("%f\n", in_data[i].fl[countPoint]);
                        printf("%f\n", in_data[i].fl[countPoint+1]);
                        */
                        //Print additional info
                        
			/*
			printf("Set #%d, Point#%d (Real)= %g\n", countFID+1, (countPoint/2)+1, in_data[i].fl[countPoint]);
                        printf("Set #%d, Point#%d (Im  )= %g\n",  countFID+1, (countPoint/2)+1,  in_data[i].fl[countPoint+1]);
			*/   
			
                        //Print summed points
			
			/*
                        printf("Set #%d, Summed point value#%d (Real)= %g\n", countFID+1, (countPoint/2)+1, switch_data[i].fl[countPoint]);
                        printf("Set #%d, Summed point value#%d (Im  )= %g\n",  countFID+1, (countPoint/2)+1,  switch_data[i].fl[countPoint+1]);
                        */
			
                        //Print all (long int) points
                
			/*
			printf("%d\n", in_data[i].lo[countPoint]);
                        printf("%d\n", in_data[i].lo[countPoint+1]);
                        */

			//End debug
                        
                    }                    
                    //printf("File position - after read %x\n", ftell(in_file[i]));                    
                }//end for(countFID)   //Going through individual FIDs                
            }//end for(countChannel)   //Going through each channel
        }//end if(file_type)
    }//end for(i)...*fid         //Unsuppressed and suppressed
    

     //added by jd, Feb 17, 2010
    free(temp_long);

    return 0;
}// end read_data()


/*****************************************************************************
 Routine for writing data to output file.
 ******************************************************************************/
void fwrite_asc(char *outfile_name, float *data, Data_file_header *main_header,
				Data_block_header *block_header, int index1,
				Procpar_info *procpar_info, Preprocess *preprocess) {
    
    FILE	*of;
    int		j;

    //added by jd, Jan 27, 2010
    int k;
    
    of = NULL;
    
    if (( of = fopen(outfile_name, "w+")) == NULL) {
        exit_08(outfile_name);
    } else {
        // Line 1 - Number of points
        fprintf(of, "%d\n", procpar_info->num_points*2);
        // Line 2 - Unused
        fprintf(of, "1\n");
        // Line 3 - Dwell time
        fprintf(of, "%.8f\n", (procpar_info->acquision_time/procpar_info->num_points));
        // Line 4 - Acquisition frequency
        fprintf(of, "%.7lf\n", ((procpar_info->main_frequency +
        procpar_info->offset_frequency)/1e7));
        // Line 5 - Number of acquisitons (transients or NEX)
        fprintf(of, "%d\n", procpar_info->num_transients);
        // Line 6 - Hospital, Patient
        fprintf(of, "%s\n", strcat(strcat(procpar_info->hospname, ", ")
        , procpar_info->patname));
        // Line 7 - Exam date, sequence name
        fprintf(of, "%s\n", strcat(strcat(procpar_info->ex_datetime, ", ")
        , procpar_info->psdname));
        // Line 8
        fprintf(of, "MachS=%d ConvS=%.2e V1=%.3f V2=%.3f V3=%.3f vtheta=%.1f\n",
        block_header->scale.number, preprocess->scale_factor, procpar_info->vox1,
        procpar_info->vox2, procpar_info->vox3, procpar_info->vtheta);
        // Line 9
        fprintf(of, "TE=%.3f(s) TR=%.3f(s) P1=%.5f P2=%.5f P3=%.5f\n",
        procpar_info->te, procpar_info->tr, procpar_info->pos1, procpar_info->pos2,
        procpar_info->pos3);
        // Line 10
        fprintf(of, "SIMULTANEOUS, TG/R1/R2=%.2f/%.2f/%.2f\n",
        procpar_info->gain, procpar_info->R1, procpar_info->R2);
        // Line 11
        fprintf(of, "0.0\n");
        // Line 12
        fprintf(of, "EMPTY\n");
        
	
        // Output data
        for (j=0; j<main_header->np.number*2; j+=2) {
            fprintf(of, "%f\n", data[j]);
            fprintf(of, "%f\n", data[j+1]);
        }
        if (of!=NULL){
            fclose(of);
        }
    }
}//end fwrite_asc()

/*****************************************************************************
 Routine for getting the phase of each channel.
 ******************************************************************************/
void get_phase(float *phase, FILE **in_file, Data_file_header *main_header,
                InFile_struct *infile_struct, long header_size, IOFiles *file,
                int swap_bytes, Procpar_info *procpar_info){
    int			counter;
	int			countFID=0;             // Counter for FID sets.
	int			countChannel=0;         // Counter for Channel num.
	int			countPoint=0;           // Counter for elements per FID.
	int			numSets=0;              // Number of FID sets.
	int			dataSizeChannel=0;      // Total data size per Channel including the baseline set.
	long		baseline_set_size=0;    // Baseline (dummy) set size.
	float		totalPhase=0;           // Total phase value for averaging.
	float		temp_float;             // Temporary float value.
	Precision1	data_points;			// Holds the first complex data point of each water set.


	data_points.fl = (float *)malloc(2 * sizeof(float));

	// Baseline (dummy) set size.

	//revised by jd, March 31, 2010
	//    baseline_set_size = main_header[1].ebytes.number * main_header[1].np.number;          
	baseline_set_size = main_header[0].ebytes.number * main_header[0].np.number;

 
    //Total data size per Channel, baseline set included (baseline + unsup + sup)

    //revised by jd, March 31, 2010
    //dataSizeChannel = baseline_set_size * (1 +  infile_struct[1].num_datasets);

	//revised by jd, April 6, 2010

	//it was this way in the original conversions that I sent out
	//dataSizeChannel = baseline_set_size * (1 +  infile_struct[0].num_datasets);	
	//this is new
	dataSizeChannel = baseline_set_size * (0 +  infile_struct[0].num_datasets);	

	//Read in data for countChannel number of Channels.
    //For ver 8,9,11 this is usually 1, for ver. 12x this is more.

	//revised by jd, April 6, 2010

	//it was this way in the original conversions that I sent out	
	//for(countChannel=0; countChannel<procpar_info[1].num_channels; countChannel++){
	for(countChannel=0; countChannel<procpar_info[0].num_channels; countChannel++){


		// Reading unsuppressed data.

      //revised by jd, March 31, 2010
      //fseek(in_file[1], header_size + baseline_set_size + (dataSizeChannel*countChannel), SEEK_SET);
      fseek(in_file[0], header_size + baseline_set_size + (dataSizeChannel*countChannel), SEEK_SET);


        //printf("File position during phase read (unsuppresed) %x\n", ftell(in_file[1])); //Debug
       

	// revised by jd, July 10, 2009

      //revised by jd, March 31, 2010
      //numSets = infile_struct[1].num_unsup_sets;
      numSets = infile_struct[0].num_datasets-infile_struct[0].num_unsup_sets;
      //it was this way in the original conversions that I sent out
      //numSets = 1;

	// end of revised code
        
		totalPhase=0;

        //Read in data for countFID number of FIDs per Channel.
        for (countFID=0;countFID<numSets;countFID++){
			//Reading data pairs.    
            //printf("\nFile position before read %x\n\n", ftell(in_file[1])); //Debug
             
	  //revised by jd, March 31, 2010
	  //if(fread(data_points.fl, main_header[1].ebytes.number/2, 2, in_file[1])!= 2){
	
	  //it was this way in the original conversions that I sent out
	  //if(fread(data_points.fl, main_header[0].ebytes.number/2, 2, in_file[1])!= 2){
	  if(fread(data_points.fl, main_header[0].ebytes.number/2, 2, in_file[0])!= 2){
	    //revised by jd

	    //it was this way in the original conversions that I sent out
	    //exit_06(in_file, file->in[1]);

	    exit_06(in_file, file->in[0]);
            }
			//This is only to compensate for next read for not reading in the full data set.

	  //revised by jd, March 31, 2010
	  /*fseek(in_file[1], header_size + baseline_set_size + 
				 ((countFID+1)*baseline_set_size) + (dataSizeChannel*countChannel), SEEK_SET);
	  */
	  fseek(in_file[0], header_size + baseline_set_size + 
				 ((countFID+1)*baseline_set_size) + (dataSizeChannel*countChannel), SEEK_SET);
            
            // Byte swaping each element if needed.
            if(swap_bytes){
				for (countPoint=0; countPoint < 2; countPoint++ ) {

				  //revised by jd, March 31, 2010
				  //if (main_header[1].ebytes.number/2 == 2){

				  if (main_header[0].ebytes.number/2 == 2){
						swapVarBytes(data_points.sh[countPoint]);
                     }else{
                        swapVarBytes(data_points.lo[countPoint]);
                     }
                }
           }
                    
           // Transfering short to float if needed.
           // or long to float depending on the input data size.

	    //revised by jd, March 31, 2010
	    /*
           if (main_header[1].ebytes.number/2 == 2){
				for (countPoint=1; countPoint>=0; countPoint--){
					data_points.fl[countPoint] = (float)data_points.sh[countPoint];
            
				}
           }else if (main_header[1].ebytes.number/2 == 4){
                for (countPoint=0; countPoint<2; countPoint++){
					temp_float = (float)data_points.lo[countPoint];
                    data_points.fl[countPoint] = temp_float;
                }
		    }
	    */
	     if (main_header[0].ebytes.number/2 == 2){
				for (countPoint=1; countPoint>=0; countPoint--){
					data_points.fl[countPoint] = (float)data_points.sh[countPoint];
            
				}
           }else if (main_header[0].ebytes.number/2 == 4){
                for (countPoint=0; countPoint<2; countPoint++){
					temp_float = (float)data_points.lo[countPoint];
                    data_points.fl[countPoint] = temp_float;
                }
		    }

			//Get phase info from first point of each water set per channel,
			//then avergae out for final phase value per channel.
			//If water FID is not existent, and number of channels is > 1 thenprogram exits.
			//See main program for error checking.    
			
	                phase[countChannel] = (float) atan2(data_points.fl[1], data_points.fl[0]);
			totalPhase = totalPhase + phase[countChannel];
			//printf("Phase for channel #%d and FID #%d : %f (Deg)\n", countChannel+1, countFID+1, phase[countChannel]*180/PI); //debug
               
		}//end for(countFID)   //Going through individual FID
		phase[countChannel] = totalPhase / countFID;
        //printf("Final average phase for channel #%d : %f (Deg)\n", countChannel+1, phase[countChannel]*180/PI); //debug        
	}//end for(countChannel)
	

	//revised by jd, April 6, 2010
	//printf("\n*Analyzing phase information for unsuppressed set.\n");
	printf("\n*Analyzing phase information for suppressed set.\n");

	printf("*Average phase per channel (Deg):\n");
	for(counter=0;counter<countChannel;counter++){
		printf("   Channel #%d \t: %f\n", counter+1, phase[counter]*180/PI);      	
	}

}//end get_phase()





/*****************************************************************************
 Routine for fixing the phase of each channel.
 ******************************************************************************/
void fix_phase(float phase_applied, int num_points, Precision1 *in_data, int fid,
				int countFID){
    int     countPoint=0;           // Counter for elements per FID.
    float   data_magnitude=0;       // Complex data magnitude.
    float   data_phase=0;           // The current phase.

	

    for (countPoint=0; countPoint<num_points; countPoint +=2 ){        
        data_magnitude = sqrt((pow(in_data[fid].fl[countPoint],2)+ pow(in_data[fid].fl[countPoint+1],2)));
   		data_phase = atan2(in_data[fid].fl[countPoint+1], in_data[fid].fl[countPoint]);
        
        //Debug
        //printf("in_data[%d] : %f\n", countPoint, in_data[fid].fl[countPoint]);  //debug
        //printf("in_data[%d] : %f\n", countPoint+1, in_data[fid].fl[countPoint+1]); //debug
        //printf("data_magnitude : %f\n", data_magnitude); //debug		
		//printf("data_phase     : %f\n", data_phase*180/PI); //debug		
        //printf("phase_applied  : %f\n", phase_applied); //debug
        
        data_phase = data_phase - phase_applied;
        
        //printf("data_phase (new) : %f\n", data_phase*180/PI); //debug
        
        in_data[fid].fl[countPoint] = data_magnitude * cos(data_phase);        
        in_data[fid].fl[countPoint+1] = data_magnitude * sin(data_phase);
		
    }                 
}
