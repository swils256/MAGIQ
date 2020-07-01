/******************************************************************************
ge2fitman_read_procpar.cpp

Project: ge2fitman
    Conversion routine for GE binary raw P-file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Procpar information reading routines from the input file headers.

Supports:
    ge2fitman.cpp
******************************************************************************/

#include "include/ge2fitman_prot.h"

#include <iostream>
#include <ctime>    // for compiling on Windows (ctime is outside of std namespace)
                    // - Dickson Wong, Jun 2020

/*****************************************************************************
   Exit codes:   0 - No errors.
                -1 - Error reading file header
                -2 - File version not recognized
                -3 - Invalid file size.
******************************************************************************/
int read_procpar(Procpar_info *procpar_info, char *procpar_string, FILE *in_file
                , bool *swap_bytes, InFile_struct *infile_struct
                , Data_file_header *main_header) {
     
    long    date_stamp=0;           // Examination date stamp.
    float   dwell=0;                // Dwell time.
    long    calc_filesize=0;        // Calculated file size.
    
    long    hospname_offset=0;      // Hospital name field offset. 
    long    patname_offset=0;       // Patient name field offset. 
    long    ex_datetime_offset=0;   // Exam date/time field offset. 
    long    te_offset=0;            // Te field offset. 
    long    tr_offset=0;            // Tr field offset.
    long    pulse_name_offset=0;    // Pulse name field offset.
    
    long    header_size=0;          // The file header size;
    short   temp_short;             // Temp short value;
    int     temp_int;               // Temp int value;
    
    //revised Sept 8, 2010
    //long    temp_long;              // Temp long value.
    int temp_long;
    unsigned long long int temp_long2; //added by jd, Sept 20, 2010

    float   temp_float;             // Temp float value;
    
    int     fid_set_size;           //One fid size (num point * complex pair size)

    int     ver=0;
    
    
    using namespace std;
    
    // Reading in file stats.
    
    // File version        
    if (read_field(in_file, (char *) &temp_float
                      , sizeof(temp_float)
                      , RDBM_REV_OFFSET, sizeof(float), *swap_bytes)<0){
      /* added by jd July 9, 2009 */
      printf("%f\n",temp_float);

      return -1;    
    }
    //printf("temp_float = %f*\n", temp_float);
    // If input file version not 08 or 09 or 11 or 12 exit. 
    if (temp_float == 7){
        //RDBM:7, File ver:08
        sprintf(infile_struct->version, "08");
    }else  if (temp_float == 8){
        //RDBM:8, File ver:09
        sprintf(infile_struct->version, "09");
    }else  if (temp_float == 9){
        //RDBM:9, File ver:11
        sprintf(infile_struct->version, "11");
    }else  if (temp_float == 11){
        //RDBM:11, File ver:12
        sprintf(infile_struct->version, "12");
	
    // added by jd, July 10, 2009
    }else if (temp_float > 20){

      //printf("JOHNNY BOY\n");
      //printf("temp_float = %f*\n", temp_float);	
      sprintf(infile_struct->version, "20.006001");
      ver = 20;

    }else if ((temp_float > 13) && (temp_float < 20)){

      //printf("JOHNNY BOY\n");
      printf("temp_float = %f*\n", temp_float);	
      sprintf(infile_struct->version, "20.006001");
      ver = 14;

    }else{
         sprintf(infile_struct->version, "NA");
         return -2;   
    }
    
    
    // Header size 
    if(strcmp(infile_struct->version, "08")==0 ||
        strcmp(infile_struct->version, "8")==0){
        header_size = HEADER_SIZE_8X;
        hospname_offset = HOSP_NAM_OFFSET_8x;
        patname_offset = PAT_NAM_OFFSET_8x;
        ex_datetime_offset =  EXAM_DATE_OFFSET_8x;
        te_offset = TE_OFFSET_8x;
        tr_offset = TR_OFFSET_8x;
        pulse_name_offset = PULSE_NAM_OFFSET_8x;
    }else if(strcmp(infile_struct->version, "09")==0 ||
        strcmp(infile_struct->version, "9")==0){
        header_size = HEADER_SIZE_9X;
        hospname_offset = HOSP_NAM_OFFSET_9x_11x;
        patname_offset = PAT_NAM_OFFSET_9x_11x;
        ex_datetime_offset =  EXAM_DATE_OFFSET_9x_11x;
        te_offset = TE_OFFSET_9x;
        tr_offset = TR_OFFSET_9x;
        pulse_name_offset = PULSE_NAM_OFFSET_9x;
    }else if (strcmp(infile_struct->version, "11")==0){
        header_size = HEADER_SIZE_11X;
        hospname_offset = HOSP_NAM_OFFSET_9x_11x;
        patname_offset = PAT_NAM_OFFSET_9x_11x;
        ex_datetime_offset =  EXAM_DATE_OFFSET_9x_11x;
        te_offset = TE_OFFSET_11x;
        tr_offset = TR_OFFSET_11x;
        pulse_name_offset = PULSE_NAM_OFFSET_11x;
    }else if (strcmp(infile_struct->version, "12")==0){
      header_size = HEADER_SIZE_12X; //66072
        hospname_offset = HOSP_NAM_OFFSET_12x; //61851
        patname_offset = PAT_NAM_OFFSET_12x; //62062
        ex_datetime_offset =  EXAM_DATE_OFFSET_12x; //61568
        te_offset = TE_OFFSET_12x; //65032
        tr_offset = TR_OFFSET_12x; //65024
        pulse_name_offset = PULSE_NAM_OFFSET_12x; //65374
    }

    // added by jd, July 10, 2009
    else if (strcmp(infile_struct->version, "20.006001")==0){
    //else if (ver == 20){
      //printf("Tigger!\n");

      
      //printf("infile_struct->version = 20.006001\n");
     
      printf("version = %s\n", infile_struct->version);
      //temp fix: header_size = HEADER_SIZE_20X;

      //added Sept 8, 2010
      //header_size = 145908;
      //header_size = 149788;

      hospname_offset = HOSP_NAM_OFFSET_20x;  
      patname_offset = PAT_NAM_OFFSET_20x;
      ex_datetime_offset =  EXAM_DATE_OFFSET_20x;
      te_offset = TE_OFFSET_20x;
      tr_offset = TR_OFFSET_20x;
      pulse_name_offset = PULSE_NAM_OFFSET_20x;
    }

    else if (strcmp(infile_struct->version, "14.3")==0){
    
      //printf("Tigger!\n");

      //printf("version = %s\n", infile_struct->version);
      //header_size = HEADER_SIZE_20X;
      header_size = 145908;
 
      hospname_offset = HOSP_NAM_OFFSET_20x;  
      patname_offset = PAT_NAM_OFFSET_20x;
      ex_datetime_offset =  EXAM_DATE_OFFSET_20x;
      te_offset = TE_OFFSET_20x;
      tr_offset = TR_OFFSET_20x;
      pulse_name_offset = PULSE_NAM_OFFSET_20x;
      printf("14.3******************\n");
    }
 
    // Number of total point sets (excluding the baseline...dummy set).
    temp_short = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
    //if (ver == 20){
      //printf("NFRAMES_OFFSET_20x\n");
      if (read_field(in_file, (char *) &temp_short
		     , sizeof(temp_short)
		     ,  NFRAMES_OFFSET_20x, sizeof(short), *swap_bytes)<0){
	return -1;    
      } 
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
    //else if (ver != 20){
      //printf("NFRAMES_OFFSET\n"); 
      if (read_field(in_file, (char *) &temp_short
		     , sizeof(temp_short)
                          ,  NFRAMES_OFFSET, sizeof(short), *swap_bytes)<0){
	//printf("jack\n");
	return -1;    
      }
    }
    infile_struct->num_datasets = temp_short;

    //printf("infile_struct->num_datasets = %d\n", infile_struct->num_datasets);

    // Number of unsuppressed (water) point sets.
    temp_float = 0;
    //temp_int = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("NUM_WTR_FID_OFFSET_20x\n");
      if (read_field(in_file, (char *) &temp_float
		     , sizeof(temp_float)
                          , NUM_WTR_FID_OFFSET_20x, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      //printf("NUM_WTR_FID_OFFSET\n");
      if (read_field(in_file, (char *) &temp_float
                          , sizeof(temp_float)
		     , NUM_WTR_FID_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    // added by jd, Feb 3, 2010
    //printf("temp_float = %f\n", temp_float);
    // end of added code

    infile_struct->num_unsup_sets = (int) temp_float; 

    // added by jd, July 10, 2009
    //printf("num_unsup_sets = %d\n", (int) temp_float);
    // end of added code
    
   // Point size.
    temp_short = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("POINTSIZE_OFFSET_20x\n");
      if (read_field(in_file, (char *) &temp_short
		     , sizeof(temp_short)
		     , POINTSIZE_OFFSET_20x, sizeof(short), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      //printf("POINTSIZE_OFFSET\n");
      if (read_field(in_file, (char *) &temp_short
		     , sizeof(temp_short)
		     , POINTSIZE_OFFSET, sizeof(short), *swap_bytes)<0){
	return -1;    
      }
    }

    // Number of bytes per complex pair (element)
    //main_header->ebytes.number = (long) temp_short*2;  
    main_header->ebytes.number = (long) temp_short*2;


    //try hard coding this like in SIEMENS
    //by jd, Feb 3, 2010
    //main_header->ebytes.number = 16;
    
    //main_header->ebytes.number should be 4 for a long integer
    //revised by jd, Feb 22, 2010
    //main_header->ebytes.number = 4;

    //added by jd, Feb 3, 2010
    //printf("temp_short = %ld\n", temp_short);
    //printf("temp_short = %d\n", temp_short);

    // added by jd, July 10, 2009
    //printf("HELLO main_header->ebytes.number = %d\n", main_header->ebytes.number);
    // end of added code


   // Total raw data size.
    temp_long2 = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("RAW_PASS_SIZE_OFFSET_20x\n");
      if (read_field(in_file, (char *) &temp_long2
		     , sizeof(temp_long2)
		     , RAW_PASS_SIZE_OFFSET_20x, sizeof(unsigned long long int), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      //printf("RAW_PASS_SIZE_OFFSET\n");
      if (read_field(in_file, (char *) &temp_long2
		     , sizeof(temp_long2)
                          , RAW_PASS_SIZE_OFFSET, sizeof(unsigned long long int), *swap_bytes)<0){
	return -1;    
      }
    }

    infile_struct->total_data_size = (int)temp_long2; 

    //printf("temp_long2 = %lld\n",temp_long2);

    //printf("beforeinfile_struct->total_data_size = %d\n",infile_struct->total_data_size);

    // added by jd, July 10, 2009
    /*
    printf("sizeof(long) = %d\n", sizeof(long));
    printf("sizeof(short) = %d\n", sizeof(short));
    printf("sizeof(int) = %d\n", sizeof(int));
    printf("sizeof(float) = %d\n", sizeof(float));

    printf("total_data_size = %ld\n", temp_long);
    */
    // end of added code


    //added by jd, Feb 17, 2009
    //after comparing with matlab output
    //header_size = 149788;
    //header_size = HEADER_SIZE_12X;
    //header_size = 149788;
    
    //temp fix: header_size = HEADER_SIZE_20X;


    //revised Sept 8, 2010
    //header_size = 145908;
    //header_size = 149788; 

    //try calculating total_data_size like in SIEMENS
    //infile_struct->total_data_size = (int)temp_long;
    

    //COMMENTED GOOD PART OUT
    
    //revised by jd, Feb 22, 2010
    //to match data size with matlab m file output
    /*infile_struct->total_data_size = (main_header->ebytes.number * procpar_info->num_points) 
		    * (infile_struct->num_datasets) + header_size;
		    */

    //MOVED BELOW TO BETA POINT
        
    // The number of points        
    temp_short = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("XRES_OFFSET_20x\n");
      if (read_field(in_file, (char *) &temp_short
                          , sizeof(temp_short)
		     , XRES_OFFSET_20x, sizeof(short), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      //printf("XRES_OFFSET\n");
      if (read_field(in_file, (char *) &temp_short
                          , sizeof(temp_short)
		     , XRES_OFFSET, sizeof(short), *swap_bytes)<0){
	return -1;    
      }
    }

    procpar_info->num_points = temp_short;
    main_header->np.number = temp_short;
    fid_set_size = procpar_info->num_points * main_header->ebytes.number;
  
    //BETA POINT
    /*
    printf("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");

    printf("main_header->ebytes.number = %d\n", main_header->ebytes.number);
    printf(" procpar_info->num_points = %d\n", procpar_info->num_points);
    printf("infile_struct->num_datasets = %d\n", infile_struct->num_datasets);
     printf("header_size = %d\n", header_size);
    printf("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");
    */
    
    //infile_struct->total_data_size = (main_header->ebytes.number * procpar_info->num_points) * (infile_struct->num_datasets) + header_size;

    //printf("infile_struct->total_data_size = %d\n",infile_struct->total_data_size);

    //int intotal_data_size;
    //scanf("%d",&intotal_data_size);

    /*temp fix:*/ //infile_struct->total_data_size = 131072;
    
    //revised Sept 8, 2010
    //infile_struct->total_data_size = 4980736;;
    //infile_struct->total_data_size = 280860;

    //infile_struct->total_data_size = 131072;
	    	   
    //printf("PREheader_size = %d\n", header_size);


    //infile_struct->total_data_size = 149788;

    //printf("infile_struct->total_data_size = %d\n", infile_struct->total_data_size);
    //end of hard coding


    //added by jd, Feb 22, 2010
    /*
    printf("####################################\n");
    printf("infile_struct->version = %s\n", infile_struct->version);
    printf("infile_struct->total_data_size = %d\n", infile_struct->total_data_size);
    printf("main_header->np.number = %d\n",main_header->np.number);
    printf("procpar_info->num_points = %d\n", procpar_info->num_points);
    printf("main_header->ebytes.number = %d\n", main_header->ebytes.number);
    printf("fid_set_size = %d\n", fid_set_size);
    printf("infile_struct->num_datasets = %d\n", infile_struct->num_datasets);
    printf("####################################\n");
    */
    //end of added code 

    //Get number of channels.    
    //Total data size / number of all FIDs per channel.
    //revised Sept 8, 2010
    /*
    procpar_info->num_channels = (infile_struct->total_data_size) / 
                                 (fid_set_size*(infile_struct->num_datasets+1));    
    */

    //added Sept 9, 2010
    /*
    printf("infile_struct->total_data_size = %d\n",infile_struct->total_data_size);
    printf("fid_set_size = %d\n",fid_set_size);
    printf("infile_struct->num_datasets+1 = %d\n",infile_struct->num_datasets+1);
    */
    int numchan;
    printf("Please enter number of channels in coil: ");
    scanf("%d",&numchan);

    if (numchan == 2)
      {
	infile_struct->total_data_size = 131072;
        header_size = 149788;
      }
    else if (numchan == 8)
      {
	infile_struct->total_data_size = 262144;
	//infile_struct->total_data_size = 4202496;
	header_size = 145908;
      }
    else if (numchan == 1)
      {
	//infile_struct->total_data_size = 262144;
	infile_struct->total_data_size = 4202496;
	header_size = 149788;
      }

    
    procpar_info->num_channels = (infile_struct->total_data_size) / 
                                 (fid_set_size*(infile_struct->num_datasets+1));    
    
    printf("procpar_info->num_channels = %d\n",procpar_info->num_channels);

    procpar_info->num_channels = numchan;

    printf("fid_set_size = %d\n",fid_set_size);
    printf("infile_struct->num_datasets = %d\n",infile_struct->num_datasets);
    printf("procpar_info->num_channels = %d\n",procpar_info->num_channels);

    //COMMENTED GOOD PART OUT
    //added by jd, Feb 18, 2010
    //procpar_info->num_channels = 4;
    
    //procpar_info->num_channels = 2;
    //procpar_info->num_channels = 8;
    //added by jd, Feb 19, 2010
    //printf("procpar_info->num_channels = %d\n", procpar_info->num_channels);

    
    // Veryfying the file structure.
    fseek(in_file, 0, SEEK_END);
    infile_struct->file_size = ftell(in_file);

    //printf("infile_struct->file_size = %d\n", infile_struct->file_size);

    //revised since there is only one suppressed set and no unsuppressed sets!
    //also from running Matlab code, I noted that there are 8 channels
    //and a header size of 149788
    //by jd, Feb 18, 2010
    //UNCOMMENTED BACK TO ORIGINAL
    /*
    printf("CALC_FILESIZE VARIABLES BEGIN:\n");
    printf("main_header->ebytes.number = %d\n", main_header->ebytes.number);
    printf("procpar_info->num_points = %d\n", procpar_info->num_points);
    printf("infile_struct->num_datasets = %d\n", infile_struct->num_datasets);
    printf("procpar_info->num_channels = %d\n", procpar_info->num_channels);
    printf("CALC_FILESIZE VARIABLES END:\n");
    */
    //revised to suit no unsuppressed data set, only 1 suppressed set
    //by jd, Feb 22, 2010
    /*calc_filesize = ((2*main_header->ebytes.number * procpar_info->num_points) 
		    * (infile_struct->num_datasets + 1) * procpar_info->num_channels)
                    + header_size;
    */
    calc_filesize = ((2*main_header->ebytes.number * procpar_info->num_points) 
		    * (infile_struct->num_datasets + 0) * procpar_info->num_channels)
                    + header_size;
    //printf("calc_filesize = %ld\n", calc_filesize);
    //revised back by jd, Feb 19, 2010
    /*
    calc_filesize = ((main_header->ebytes.number * procpar_info->num_points) 
		    * (infile_struct->num_datasets + 0) * procpar_info->num_channels)
		                     + header_size;
    */
    //COMMENTED GOOD PART OUT
    /*calc_filesize = ((main_header->ebytes.number * procpar_info->num_points) 
		    * (infile_struct->num_datasets + 1) * procpar_info->num_channels)
                    + header_size;
    */
    /*
    printf("main_header->ebytes.number = %d\n", main_header->ebytes.number);
    printf("procpar_info->num_points = %d\n", procpar_info->num_points);
    printf("infile_struct->num_datasets = %d\n", infile_struct->num_datasets);
    printf("procpar_info->num_channels = %d\n", procpar_info->num_channels);
    printf("header_size = %d\n", header_size);

    printf("calc_filesize = %ld\n", calc_filesize);
    printf("infile_struct->file_size = %ld\n", infile_struct->file_size);
    */

    //temp fix:
    /*
    if (infile_struct->file_size!=calc_filesize){

      //added by jd, Feb 18, 2010

      
      printf("infile_struct->file_size = %d\n", infile_struct->file_size);
      printf("calc_filesize = %d\n", calc_filesize);

      printf("main_header->ebytes.number = %d\n", main_header->ebytes.number);
      


      printf("Invalid file size detected!!!!!\n");
      

      return -3;                      // Invalid file size detected;
    }         	
    */
    
    // Dwell time
    dwell = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n"); 
      if (read_field(in_file, (char *) &dwell
		     , sizeof(dwell)
		     , DWELL_OFFSET_20x, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &dwell
		     , sizeof(dwell)
		     , DWELL_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    int inn;
    //printf("beforedwell = %g\n", dwell);
    //scanf("%d",&inn);

    float dwellin;

    if(dwell != 0)  //added by jd
      dwell = 1/dwell;
    else{
      printf("A bandwidth of 0 was read.\n");
      printf("Please enter bandwidth in Hz.\n");
      scanf("%f",&dwellin);
      dwell = 1/dwellin;
    }

    //added by jd, Feb 3, 2010
    //printf("afterdwell = %g\n", dwell);
    //end of added code
    
    // Acquisition time
    procpar_info->acquision_time = (float)(procpar_info->num_points*dwell);
  
    //printf("procpar_info->acquision_time = %f\n", procpar_info->acquision_time);
    
  
    // Main frequency (In Hz)
    temp_long = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &temp_long
		     , sizeof(temp_long)
		     , MAIN_FREQ_OFFSET_20x, sizeof(long), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &temp_long
		     , sizeof(temp_long)
		     , MAIN_FREQ_OFFSET, sizeof(long), *swap_bytes)<0){
	return -1;    
      }
    }

    procpar_info->main_frequency = (double)temp_long;  

    //std::cout << procpar_info->main_frequency << std::endl;

    //printf("procpar_info->main_frequency = %g\n", procpar_info->main_frequency);


    // Offset frequency (In Hz)
    procpar_info->offset_frequency = 0;         
    
    // Number of transients (acuisitions or NEX) value for suppressed 
    // May be unexpected value as it's read from a user field (user4)...fix later.
    temp_float = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &temp_float
		     , sizeof(temp_float)
		     , NEX_OFFSET_20x, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &temp_float
		     , sizeof(temp_float)
		     , NEX_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    procpar_info->num_transients = (int) temp_float;
     
    //printf("procpar_info->num_transients = %d\n", procpar_info->num_transients);

    // Hospital name
    if (read_field(in_file, (char *) &procpar_info->hospname
                      , sizeof(procpar_info->hospname)
                      , hospname_offset, 33, false)<0){
              return -1;    
    }

    //printf("procpar_info->hospname = %s\n", procpar_info->hospname);

    // Patient name
    if (read_field(in_file, (char *) &procpar_info->patname
                      , sizeof(procpar_info->patname)
                      , patname_offset, 25, false)<0){
              return -1;    
    }

    //printf("procpar_info->patname = %s\n", procpar_info->patname);
          
    // Pulse sequence name 
    if (read_field(in_file, (char *) &procpar_info->psdname
                      , sizeof(procpar_info->psdname)
                      , pulse_name_offset , 33, false)<0){
              return -1;    
    }    

    //printf("procpar_info->psdname = %s\n", procpar_info->psdname);

    // Exam date/time stamp
    date_stamp = 0;
    if (read_field(in_file, (char *) &date_stamp
                      , sizeof(date_stamp)
                      , ex_datetime_offset, sizeof(int), *swap_bytes)<0){
              return -1;    
    }
    //implicit conversion between time type and long type
    // - Dickson Wong, Jun 2020
    std::time_t ds_t = date_stamp;
    strncpy(procpar_info->ex_datetime, ctime(&ds_t)
                                     , strlen(ctime(&ds_t))-1);
    procpar_info->ex_datetime[strlen(ctime(&ds_t))-1] = '\0';
   

    //printf("procpar_info->ex_datetime = %s\n", procpar_info->ex_datetime);

    // Vox 1-3 values
    procpar_info->vox1 = 0;
    procpar_info->vox2 = 0;
    procpar_info->vox3 = 0;

    //added by jd, Feb 3, 2010
    int vox1index, vox2index, vox3index;
    vox1index = 0;
    vox2index = 0;
    vox3index = 0;
    //end of added code
    
    //added by jd, Feb 3, 2010
    if (strcmp(infile_struct->version, "20.006001")==0){
      vox1index = read_field(in_file, (char *) &procpar_info->vox1
			     , sizeof(procpar_info->vox1)
			     , VOX1_OFFSET, sizeof(float), *swap_bytes);
    }
    
    //printf("vox1index = %d\n", vox1index);
    //printf("procpar_info->vox1 = %f\n", procpar_info->vox1);

    //end of added code
    
    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");

      if (vox1index <0){  
	return -1;    
      }
    }
   

    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->vox1
		     , sizeof(procpar_info->vox1)
		     , VOX1_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }


    //added by jd, Feb 17, 2010
    procpar_info->vox1=(float)(procpar_info->vox1);
    //printf("procpar_info->vox1 = %f\n", procpar_info->vox1);
    

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &procpar_info->vox2
		     , sizeof(procpar_info->vox2)
		     , VOX2_OFFSET, sizeof(float), *swap_bytes)<0){

	

	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->vox2
		     , sizeof(procpar_info->vox2)
		     , VOX2_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    //added by jd, Feb 17, 2010
    procpar_info->vox2=(float)(procpar_info->vox2);
    //printf("procpar_info->vox2 = %f\n", procpar_info->vox2);

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &procpar_info->vox3
		     , sizeof(procpar_info->vox3)
		     , VOX3_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->vox3
		     , sizeof(procpar_info->vox3)
		     , VOX3_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    //std::cout << procpar_info->vox3 << std::endl;

    //added by jd, Feb 17, 2010
    procpar_info->vox3=(float)procpar_info->vox3;
    //printf("procpar_info->vox3 = %f\n", procpar_info->vox3);

    // Vtheta value
    procpar_info->vtheta = 0;     

    // Te value
    temp_int=0;

    //revised by jd, Feb 4, 2010
    /*
    if (read_field(in_file, (char *) &temp_int
                      , sizeof(temp_int)
                      , te_offset, sizeof(int), *swap_bytes)<0){
              return -1;    
    }
    */
    if (read_field(in_file, (char *) &temp_int
                      , sizeof(temp_int)
                      , TE_OFFSET_20x, sizeof(int), *swap_bytes)<0){
              return -1;
    }
    //end of revised code

    procpar_info->te=(float) temp_int/1e3;

    //printf("procpar_info->te = %g\n", procpar_info->te);
          
    // Tr value
    temp_int=0;

    //revised by jd, Feb 4, 2010
    /*
    if (read_field(in_file, (char *) &temp_int
                      , sizeof(temp_int)
                      , tr_offset, sizeof(int), *swap_bytes)<0){
              return -1;    
    }
    */
    if (read_field(in_file, (char *) &temp_int
                      , sizeof(temp_int)
                      , TR_OFFSET_20x, sizeof(int), *swap_bytes)<0){
              return -1;    
    }
    //end of revised code

    procpar_info->tr=(float) temp_int/1e3;
       
    //printf("procpar_info->tr = %g\n", procpar_info->tr);
    

    // Pos 1-3 values
    procpar_info->pos1 = 0;
    procpar_info->pos2 = 0;
    procpar_info->pos3 = 0;

    //added by jd, Feb 4, 2010
    int pos1index;
    pos1index = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      pos1index = read_field(in_file, (char *) &procpar_info->pos1
			     , sizeof(procpar_info->pos1)
			     , POS1_OFFSET_20x, sizeof(float), *swap_bytes);
    }
    
    if (strcmp(infile_struct->version, "20.006001")==0){
      if (pos1index < 0){
	return -1;
      }
    }   
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->pos1
		     , sizeof(procpar_info->pos1)
		     , POS1_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    //printf("pos1index = %d\n", pos1index);
    //printf("procpar_info->pos1 = %f\n", procpar_info->pos1);
    //end of added code
    
    //commented out by jd, Feb 4, 2010
    
    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &procpar_info->pos1
		     , sizeof(procpar_info->pos1)
		     , POS1_OFFSET_20x, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->pos1
		     , sizeof(procpar_info->pos1)
		     , POS1_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    
    
    //added by jd, Feb 4, 2010
    int pos2index;
    pos2index = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      pos2index = read_field(in_file, (char *) &procpar_info->pos2
			     , sizeof(procpar_info->pos2)
			     , POS2_OFFSET_20x, sizeof(float), *swap_bytes);
    }

     if (strcmp(infile_struct->version, "20.006001")==0){
      if (pos2index < 0){
	return -1;
      }
    }   
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->pos2
		     , sizeof(procpar_info->pos2)
		     , POS2_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    //printf("pos2index = %d\n", pos1index);
    //printf("procpar_info->pos2 = %f\n", procpar_info->pos2);
    //end of added code

     //commented out by jd, Feb 4, 2010
    /*
    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &procpar_info->pos2
		     , sizeof(procpar_info->pos2)
		     , POS2_OFFSET_20x, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->pos2
		     , sizeof(procpar_info->pos2)
		     , POS2_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    */

    //std::cout << procpar_info->pos2 << std::endl;

    //printf("procpar_info->pos2 = %f\n", procpar_info->pos2);

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n"); 
      if (read_field(in_file, (char *) &procpar_info->pos3
		     , sizeof(procpar_info->pos3)
		     , POS3_OFFSET_20x, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &procpar_info->pos3
		     , sizeof(procpar_info->pos3)
		     , POS3_OFFSET, sizeof(float), *swap_bytes)<0){
	return -1;    
      }
    }

    //printf("procpar_info->pos3 = %f\n", procpar_info->pos3);

    // R1 value
    temp_long = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      if (read_field(in_file, (char *) &temp_long
		     , sizeof(temp_long)
		     , R1_OFFSET, sizeof(int), *swap_bytes)<0){
	return -1;    
      }
    }
    procpar_info->R1 = (float)temp_long;

    //printf("procpar_info->R1 = %g\n", procpar_info->R1);

    // R2 value
    temp_long = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      if (read_field(in_file, (char *) &temp_long
		     , sizeof(temp_long)
		     , R2_OFFSET, sizeof(int), *swap_bytes)<0){
	return -1;    
      }
    }
    procpar_info->R2 = (float)temp_long;

    //printf("procpar_info->R2 = %g\n", procpar_info->R2);
    
    // Gain value
    temp_long = 0;

    if (strcmp(infile_struct->version, "20.006001")==0){
      //printf("jim\n");
      if (read_field(in_file, (char *) &temp_long
		     , sizeof(temp_long)
		     , GAIN_OFFSET, sizeof(int), *swap_bytes)<0){
	return -1;     
      }
    }
    else if (strcmp(infile_struct->version, "20.006001")!=0){
      if (read_field(in_file, (char *) &temp_long
		     , sizeof(temp_long)
		     , GAIN_OFFSET, sizeof(int), *swap_bytes)<0){
	return -1;    
      }
    }

    procpar_info->gain = (float)temp_long;
    
    //std::cout << procpar_info->gain << std::endl;
    //printf("procpar_info->gain = %g\n", procpar_info->gain);


    //    procpar_info->filter = float_parameter_value;  

    return 0;
    
} // end read_propcar()

/******************************************************************************/
int read_field(FILE * in_file, char *var_pointer, int var_size
                             , long int hdr_field_offset, int hdr_field_size
                             , bool swap_bytes){
        
  //added by jd, Feb 3, 2010                                      
  char pause;
  //end of added code
                  
    fseek(in_file, hdr_field_offset, SEEK_SET); 
    if((fread(var_pointer, 1, hdr_field_size , in_file))!=hdr_field_size){                
      //added by jd, Feb 3, 2010
      printf("(fread(var_pointer, 1, hdr_field_size , in_file))!=hdr_field_size)\n");
      //scanf("%s", pause);
      //end of added code 

        return -1;      // Return error if could not read properly.
    }

    //added by jd, Feb 3, 2010
    //for stepping through the code
    //scanf("%c", &pause);

    // Debugging
    // printHex(var_pointer, var_size);
    
    if (swap_bytes){
        swapBytes(var_pointer, var_size);
    }
    
    // Debugging
    // printHex(var_pointer, var_size);
    
    
    return 0;
    
}// end read_field()


