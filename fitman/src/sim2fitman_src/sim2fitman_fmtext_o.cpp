/******************************************************************************
sim2fitman_fmtext_o.cpp

Project: sim2fitman
    Conversion routine for SIEMENS binary file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Read and write routines from input and to output files.

Supports:
    sim2fitman.cpp

******************************************************************************/

#include "include/sim2fitman_prot.h"


/******************************************************************************
  Read data from input files.
*******************************************************************************/
int read_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                Data_file_header *main_header,Data_block_header *block_header, 
                Precision2 *switch_data, FILE **in_file,
                Precision1 *in_data, float **out_data, float **scratch_data
                , int swap_bytes, InFile_struct *infile_struct){
    
    int		i, out_data_size;
    int     countFID=0;             // Counter for FID sets.
    int     countPoint=0;           // Counter for elements per FID.
    int     numSets=0;              // Number of FID sets.
    long    header_size=0;          // The file header size;
    long    baseline_set_size=0;    // Baseline (dummy) set size.
    long    unsup_set_size=0;       // Unsuppressed set size.
    float   temp_float;             // Temporary float value.
    double  *temp_double;           // Temporary double value array.
    
    // added by jd, Aug 13, 2009
    double *temp_double2;

    int k;

    //added by jd for debugging
    //printf("*fid = %d\n",*fid);

    //revised by jd, May 7, 2009
    //for (i=0; i<*fid+1; i++){
      
    //for (i=0; i<=*fid; i++){  //changed i<*fid+1 to i<=*fid
    for (i=0; i<*fid; i++){  //changed i<*fid+1 to i<=*fid

      //printf("preprocess[i].file_type = %d\n",preprocess[i].file_type);

      if (preprocess[i].file_type == 0){
      //if (preprocess[i].file_type == 0 || preprocess[i].file_type == 1){
            
            //  Number of pairs * (Real + Im) size.
            out_data_size =(int) main_header[i].np.number*2;         

            temp_double = (double *)malloc(out_data_size * sizeof(double));

	    // added by jd, Aug 13, 2009
	    temp_double2 = (double *)malloc(out_data_size * sizeof(double));
            
            out_data[i] = (float *)malloc(out_data_size * sizeof(float));
            scratch_data[i] = (float *)malloc(out_data_size * sizeof(float));

            in_data[i].fl = (float *)malloc(out_data_size * sizeof(float));
            switch_data[i].fl = (float *)malloc(out_data_size * sizeof(float));            
               
            // Initialize switch_data[i]
            for (countPoint=0; countPoint<out_data_size; countPoint+=2 ) {                
                switch_data[i].fl[countPoint]=0;            // Real part
                switch_data[i].fl[countPoint+1]=0;          // Im part
            } 
                
            // Header size  
            header_size = (&infile_struct[0])->hdr_offset;                             
            
            // Baseline (dummy) set size.
            //baseline_set_size = main_header[i].ebytes.number * main_header[i].np.number;
            
            // Unsuppressed set size.
            unsup_set_size = main_header[i].ebytes.number * main_header[i].np.number
                                                          * infile_struct[i].num_unsup_sets;
                
	    //printf("i = %d\n",i);

        
            if (i==0){

	      // added by jd, Aug 13, 2009
	      header_size = (&infile_struct[0])->hdr_offset;

                // Reading suppressed data.             
                fseek(in_file[i], header_size , SEEK_SET);
                //printf("File position before read %x\n", ftell(in_file[i]));

		// added by jd for debugging, May 5, 2009
		//printf("File position before read %x\n", ftell(in_file[i]));

                numSets = infile_struct[i].num_datasets 
                        - infile_struct[i].num_unsup_sets; 

		// added by jd for debugging, August 13, 2009
		//printf("numSets = %d\n", numSets);
 
            }
            else {
                // Reading unsuppressed data.
	      
	      // added by jd, Aug 13, 2009
	      header_size = (&infile_struct[1])->hdr_offset;

	      // added by jd for debugging, May 5, 2009
	      //printf("Reading unsuppressed data.\n");

	      
                fseek(in_file[i], header_size , SEEK_SET); 
                //printf("File position before read %x\n", ftell(in_file[i]));                 
		// added by jd for debugging, May 5, 2009
		//printf("File position before read %x\n", ftell(in_file[i]));

                numSets = infile_struct[i].num_unsup_sets;

		// added by jd for debugging, May 5, 2009
		//printf("numSets = %d\n", numSets);
		
            }               
            
            //printf("File position %x\n", ftell(in_file[0])); 
         
            for (countFID=0;countFID<numSets;countFID++){                                     
	      // added by jd for debugging, May 2, 2009
	      //printf("main_header[%d].ebytes.number/2 = %d\n",i,main_header[i].ebytes.number/2);


                //Reading data pairs.
     
	      // added by jd, August 13, 2009
	      //printf("main_header[i].ebytes.number/2 = %d\n",main_header[i].ebytes.number/2);

           
                //Need a for loop to read in double into float.
                //Did not want to change the in_data (float) structure to double
                if (main_header[i].ebytes.number/2 == 8){
                    //Data is double (bigger then float).
                    //So read in data one at a time.
                    //for(countPoint=0; countPoint < main_header[i].np.number*2; countPoint++){ 

		  // added by jd for debugging, May 5, 2009
		  //printf("main_header[%d].np.number*2 = %d\n",i,main_header[i].np.number*2);
		  // end of added code

		  //for(countPoint=0; countPoint < main_header[i].np.number*2; countPoint++){
		  
		  if (i == 0)
		    k = fread(temp_double, main_header[i].ebytes.number/2,
                                  main_header[i].np.number*2, in_file[i]);
		  else if (i == 1)
		    k = fread(temp_double2, main_header[i].ebytes.number/2,
                                  main_header[i].np.number*2, in_file[i]);

		  //added by jd for debugging
		  //printf("k = %d\n",k);

		// if(fread(temp_double, main_header[i].ebytes.number/2,
		//main_header[i].np.number*2, in_file[i]) 
                //                  != main_header[i].np.number*2){
                //
		//            exit_06(in_file, file->in[i]);
		
		if(k != main_header[i].np.number*2){
                            exit_06(in_file, file->in[i]);
			    }
		     else{
		       //printf("Data read %x\n", ftell(in_file[i])); 
		       //printHex((char *) &temp_double, 8);
		       //swapVarBytes(temp_double); 
		       
		       //added by jd, May 5, 2009
		       //printf("main_header[%d].np.number*2 = %d\n",i,main_header[i].np.number*2);
		       

		       for(countPoint=0; countPoint < main_header[i].np.number*2; countPoint++){

			 if (i == 0)
			 {
			 //swapVarBytes(temp_double[countPoint]);
			 in_data[i].fl[countPoint] = (float) temp_double[countPoint];
			 //printf("temp_double[%d] = %g\n",countPoint,temp_double[countPoint]);
			 //printf("in_data[%d].fl[%d] = %g\n",i,countPoint,in_data[i].fl[countPoint]);

			 //added print echo statement
			 //by jd, Feb 4, 2010
			 /*printf("in_data[%d].fl[%d] = %f\n",
				i, countPoint, in_data[i].fl[countPoint]);
			 */
				//end of added code

			 }
			 if (i == 1)
			 {
			     //swapVarBytes(temp_double[countPoint]);
			     in_data[i].fl[countPoint] = (float) temp_double2[countPoint];
			     //printf("temp_double2[%d] = %g\n",countPoint,temp_double2[countPoint]);
			     //printf("in_data[%d].fl[%d] = %g\n",i,countPoint,in_data[i].fl[countPoint]);
			     }
		       }
		       
		       //uncommented lines, May 2, 2009
			    
			    //}
		    //printf("Data read %x\n", ftell(in_file[i])); 
		    //    printHex((char *) &temp_double, 8);
		    //    swapVarBytes(temp_double); 
		    //    in_data[i].fl[countPoint] = (float) temp_double;
			    // }
		    	    
		       //printf("temp_double[1] = %g\n",temp_double[1]);
		       //printf("temp_double[100] = %g\n",temp_double[100]);

		       //printf("temp_double2[1] = %g\n",temp_double2[1]);
		       //printf("temp_double2[100] = %g\n",temp_double2[100]);

		     }
                }else{

		  //printf("i = %d\n", i);
                    //Data is smaller than double
                    //So read in data in one block
                    if(fread(in_data[i].fl, main_header[i].ebytes.number/2
                              , main_header[i].np.number*2, in_file[i]) 
                                            != main_header[i].np.number*2){
                            exit_06(in_file, file->in[i]);
                    }     
                }
                
                // Byte swaping each short element if needed.
                if(swap_bytes){
                    for (countPoint=0; countPoint < main_header[i].np.number*2; countPoint++ ) {
                        if (main_header[i].ebytes.number/2 == 2){
                            swapVarBytes(in_data[i].sh[countPoint]); 
                        }else if(main_header[i].ebytes.number/2 == 8){
                            swapVarBytes(temp_double[countPoint]);    
                            in_data[i].fl[countPoint] = (float) temp_double[countPoint];                            
                        }else{
                            swapVarBytes(in_data[i].lo[countPoint]); 
                        }
                    }
                }
                    
                // Transfering short to float if needed.
                // or long to float depending on the input data size.
                if (main_header[i].ebytes.number/2 == 2){
                    for (countPoint=(main_header[i].np.number*2)-1; countPoint>=0; countPoint--){                                                            
		      in_data[i].fl[countPoint] = (float)in_data[i].sh[countPoint];  			                                                                
		      // added by jd, May 2, 2009
		      //printf("main_header[%d].ebytes.number/2 == 2\n",i);
		      //printf("in_data[%d].fl[countPoint] = %f\n",i,in_data[i].fl[countPoint]);
		      // end of added code

                    }
                }else if (main_header[i].ebytes.number/2 == 4){
                    for (countPoint=0; countPoint<(main_header[i].np.number*2); countPoint++){                                                            
                        temp_float = (float)in_data[i].lo[countPoint];
                        in_data[i].fl[countPoint] = temp_float; 

			// added by jd for debugging, May 2, 2009
			//printf("main_header[%d].ebytes.number/2 == 4\n",i);
			//printf("in_data[%d].fl[countPoint] = %f\n",i,in_data[i].fl[countPoint]);
			// end of added code
                    }                    
                }                
   
                // printf("Set #%d\n", countFID+1);
                // Adding up the FID sets
                for (countPoint=0; countPoint<main_header[i].np.number*2; countPoint +=2 ) {                    
                    switch_data[i].fl[countPoint] += in_data[i].fl[countPoint];
                    switch_data[i].fl[countPoint+1] += in_data[i].fl[countPoint+1];

                  //printf("Set #%d, Point#%d (Real)= %g\n", countFID+1, (countPoint/2)+1, in_data[i].fl[countPoint]);
                  //printf("Set #%d, Point#%d (Im  )= %g\n",  countFID+1, (countPoint/2)+1,  in_data[i].fl[countPoint+1]);
                  
                  //printf("Set #%d, Summed point value#%d (Real)= %g\n", countFID+1, (countPoint/2)+1, switch_data[i].fl[countPoint]);
                  // printf("Set #%d, Summed point value#%d (Im  )= %g\n",  countFID+1, (countPoint/2)+1,  switch_data[i].fl[countPoint+1]);
          
                  //printf("%d\n", in_data[i].lo[countPoint]);
                  //printf("%d\n", in_data[i].lo[countPoint+1]);
		    

		    //printf("Set #%d, Point#%d (Real)= %g\n", countFID+1, (countPoint/2)+1, in_data[i].fl[countPoint]);
		    //printf("Set #%d, Point#%d (Im  )= %g\n",  countFID+1, (countPoint/2)+1,  in_data[i].fl[countPoint+1]);
                
		    //printf("Set #%d, Summed point value#%d (Real)= %g\n", countFID+1, (countPoint/2)+1, switch_data[i].fl[countPoint]);
		    //printf("Set #%d, Summed point value#%d (Im  )= %g\n",  countFID+1, (countPoint/2)+1,  switch_data[i].fl[countPoint+1]);
		
		    //printf("%d\n", in_data[i].lo[countPoint]);
		    //printf("%d\n", in_data[i].lo[countPoint+1]);
		    
                }                
                // printf("File position - after read %x\n", ftell(in_file[0]));
                //printf("\nFile position %x\n\n", ftell(in_file[0]));

		
		// uncommented existing lines, May 2, 2009 
		
                                
		//printf("File position - after read %x\n", ftell(in_file[0]));
		//printf("\nFile position %x\n\n", ftell(in_file[0]));

		
	    }//end for(countFID)             
      }
    }
    //printf("*************\n");
    //printf("ok here\n");
    
    free(temp_double);
    free(temp_double2);
    
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
    
    of = NULL;
    
    if (( of = fopen(outfile_name, "w+")) == NULL) {
        exit_08(outfile_name);        
    } else {
        // Line 1
        fprintf(of, "%d\n", procpar_info->num_points*2);
        // Line 2
        //revised to int        
        //fprintf(of, "%.8f\n",  procpar_info->nex);
        fprintf(of, "%d\n",  procpar_info->nex);
        // Line 3
        
	// revised by jd, Aug 13, 2009
	//fprintf(of, "%.8f\n", (procpar_info->acquision_time/procpar_info->num_points));
	fprintf(of, "%.8f\n", procpar_info->dwell_time);
	// end of added code

        // Line 4
        fprintf(of, "%.7lf\n", ((procpar_info->main_frequency +
                                 procpar_info->offset_frequency)));
        // Line 5
        fprintf(of, "%d\n", procpar_info->num_transients);
        // Line 6
        fprintf(of, "%s\n", strcat(strcat(procpar_info->hospname, ", ")
                          , procpar_info->patname)); 
        // Line 7    
	//revised by jd, July 2, 2010
	/*fprintf(of, "%s\n", strcat(strcat(procpar_info->ex_datetime, ", ")
                          , procpar_info->psdname)); 
	*/
	fprintf(of, " \"%s\"\n", procpar_info->ex_datetime); 
	//end of revised code

	// Line 8  	          
        fprintf(of, "MachS=%d ConvS=%.2e V1=%.3f V2=%.3f V3=%.3f vtheta=%.1f\n",       
        block_header->scale.number, preprocess->scale_factor, procpar_info->vox1,
        procpar_info->vox2, procpar_info->vox3, procpar_info->vtheta);
        // Line 9
        fprintf(of, "TE=%.3f s TR=%.3f s P1=%.5f P2=%.5f P3=%.5f Gain=%.2f\n",
        procpar_info->te, procpar_info->tr, procpar_info->pos1, procpar_info->pos2,
        procpar_info->pos3, procpar_info->gain);
        // Line 10
        fprintf(of, "SIMULTANEOUS\n");
        // Line 11
        fprintf(of, "0.0\n");
        // Line 12
        fprintf(of, "EMPTY\n");
       
	// added by jd, Aug 13, 2009
	//for (j=0; j<main_header->np.number*2; j+=2) {
	  //printf("%f\n", data[j]);
	  //printf("%f\n", data[j+1]);	
        //}


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



