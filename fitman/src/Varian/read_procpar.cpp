/******************************************************************************
read_propcar.cpp

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:
    This file reads in information from the procpar file which is associated with
    the file being converted to Fitman format.  This information is stored in the
    structure called procpar_info

Supports:
    4t_cv.cpp
******************************************************************************/

#include "prot.h"


int read_procpar(Procpar_info *procpar_info, char *procpar_string) {
    
    FILE *in_file = NULL;
    //char in_line[255];                  // The line read
   char in_line[50000];
   char *token = NULL;                 // String token.
  
   //added
   token = (char *)(5000*sizeof(char)); 

   int i;
   i = 0;
  
    // Open the input (un)suppressed data file    
    in_file = fopen(procpar_string, "rb");           
    if (in_file == NULL) {
        printf("Can't open procpar file.\n");                
        exit(4);
    }   
   
    // Read in first line   
    fgets(in_line, 255, in_file);
    if(ferror(in_file)){
        printf("Error reading file.\n");                
        exit(4);        
    }

    // this loop reads up to the first white space of each line into variable token
    // token is then compared to keywords until a match is found
    // the value of the keyword is then assigned to the procpar_info structure

    while(!feof(in_file)){
    //while( !feof(in_file) && (in_line[3] != '/')  ){

      //      if( in_line[3] != '/'){

      //added
      i++;
      //printf("i = %d\n", i);
      //fflush(stdout);
      
      //added
      //printf("%s \n", in_line);

        // Get token from in_line
        token = strtok(in_line, " \t\n");                       
    
	//added
	//printf("%s\n",token);

	/*
	if(i == 3228)
	  {
	    fflush(stdout);
	    exit(0);
	  }
	*/
	//added
        //printf("token before = %s\n",token);

        if(strcmp(token, "at")==0){
            
            // once a parameter is located, there are 11 values preceeding the value that
            // the parameter was set at.  These 11 values describe things like min and max
            // settings, but are uninteresting to us, so they are discarded
         
            // Read new line

	    //REVISED
            //fgets(in_line, 255, in_file);
	    fgets(in_line, 5000, in_file);

            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
	    /*
	    printf("\n okay here \n");

	    if(i == 3228)
	      {
		fflush(stdout);
		exit(0);
	      }
	    */
            // Get token from in_line
            token = strtok(in_line, " \n");

	    //REVISED
	    
	    token = strtok(NULL, " \n");

	    //added
            //printf("token = %s\n",token);
                        
            procpar_info->acquision_time = strtod(token, NULL);
	    
	    //added
	    //printf("procpar_info->acquision_time = %.8f\n",procpar_info->acquision_time);

        } 

        else if(strcmp(token, "date")==0){
                        
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \"");
	    token = strtok(NULL, "\"");                          
            strcpy(procpar_info->date, token);
            
        } else if(strcmp(token, "filter")==0){
             // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->filter = strtod(token, NULL);
            
        } else if(strcmp(token, "nt")==0){            
             // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");
            procpar_info->num_transients = strtol(token, NULL, 10);
            
        } else if(strcmp(token, "np")==0){
             // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");
            procpar_info->num_points = strtol(token, NULL, 10);            
            
        } else if(strcmp(token, "sfrq")==0){
             // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->main_frequency = strtod(token, NULL);
            
        } else if(strcmp(token, "tof")==0){
         // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->offset_frequency = strtod(token, NULL);            
            
        } else if(strcmp(token, "te")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->te = strtod(token, NULL);            
            
        } else if(strcmp(token, "tm")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->tm = strtod(token, NULL); 
            
        } else if(strcmp(token, "gain")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->gain = strtod(token, NULL); 
            
        } else if(strcmp(token, "pos1")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->pos1 = strtod(token, NULL); 
            
        } else if(strcmp(token, "pos2")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->pos2 = strtod(token, NULL); 
            
        } else if(strcmp(token, "pos3")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->pos3 = strtod(token, NULL); 
            
        } else if(strcmp(token, "vox1")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->vox1 = strtod(token, NULL); 
            
        } else if(strcmp(token, "vox2")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->vox2 = strtod(token, NULL); 
            
        } else if(strcmp(token, "vox3")==0){
            // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->vox3 = strtod(token, NULL); ;
            
        } else if(strcmp(token, "vtheta")==0){
           // Read new line
            fgets(in_line, 255, in_file);
            if(ferror(in_file)){
                printf("Error reading file.\n");                
                exit(4);        
            }
            
            // Get token from in_line
            token = strtok(in_line, " \n");
	    token = strtok(NULL, " \n");  
            procpar_info->vtheta = strtod(token, NULL); 
            
        } 
        
	//ok here

        // Read new line
        
	//REVISED
	//fgets(in_line, 255, in_file);
	fgets(in_line, 5000, in_file);

        if(ferror(in_file)){
            printf("Error reading file.\n");                
            exit(4);        
        }

	//}	

    }// end while


    

     
    if(in_file!=NULL){

      printf("okay\n");
      fflush(stdout);
      fclose(in_file);
    }    

 
    

    return 2;
}
