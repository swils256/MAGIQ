/******************************************************************************
prot.h

Project: 4t_cv
    Conversion routine for 4T Binary data to NMR286 / Fitman text format
    Copyright (c) November 1996 - Robert Bartha

File description:
    Prototype definition file for conversion structures

Supports:
    4t_cv.cpp

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
 ******************************************************************************/

#include <stdio.h>
#include <errno.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#define VERSION "1.0"
#define TRUE 1
#define FALSE 0
#define YES 1
#define NO 0
#define BINARY 0
#define BINARY_FILE 0
#define FDF_FILE 1
#define TEXT_FILE 2
#define TEXT 0
#define read_ok 04
#define exists 00
#define PI 3.141592653589793
#define MAX_PHASE_ENCODES 100
#define LITTLE_END 0              // Little endian architetcture system
#define BIG_END 1                 // Big endian architetcture system


typedef union con1 {

  //long number;
  int number;
    
    char character[4];
} long_char;

typedef union con2 {
    short number;
    char character[2];
} short_char;

typedef union con3 {
    float number;
    char character[4];
} float_char;

typedef union {
    short  *sh;
    long   *lo;
    float  *fl;
    char   *character;
} Precision1;

typedef union {
    short  *sh;
    long   *lo;
    float  *fl;
    char   *character;
} Precision2;

typedef union {
    short  sh;
    long   lo;
    float  fl;
    char   character[4];
} Precision3;

typedef union {
    short  sh;
    long   lo;
    float  fl;
    char   character[4];
} Precision4;


typedef struct {
    int number_pe;          // number of entries in the pe table
    int block_size;         // size of data blocks for output file
    int actual_number_pe;   // number of different pe steps
    
} PE_info;

typedef struct {
    long_char   nblocks;    // number of blocks in file
    long_char   ntraces;    // number of traces per block
    long_char   np;         // number of elements per trace
    long_char   ebytes;     // number of bytes per element
    long_char   tbytes;     // number of bytes per trace
    long_char   bbytes;     // number of bytes per block
    short_char  transf;     // transposed storage flag
    short_char  status;     // status of whole file
    long_char   spare1;     // reserved for future use
} Data_file_header;

typedef struct {
    short_char scale;       // scaling factor
    short_char status;      // status of data in block
    short_char index;       // block index
    short_char spare3;      // reserved for future use
    long_char  ctcount;     // completed transients in fids
    float_char lpval;       // left phase in phasefile
    float_char rpval;       // right phase in phasefile
    float_char lvl;         // level drift correction
    float_char tlt;         // tilt drift correction
} Data_block_header;


typedef struct {
    float   acquision_time;
    char    date[30];
    char    file_name[256];
    float   filter;
    int     num_transients;
    int     num_points;
    double  main_frequency;
    double  offset_frequency;
    float   te;
    float   tm;
    float   gain;
    float   pos1;
    float   pos2;
    float   pos3;
    float   vox1;
    float   vox2;
    float   vox3;
    double  span;
    float   vtheta;		// Used when reading in FDF files
} Procpar_info;

typedef struct{
    int     number_points;
    int     number_components;
    float   dwell_time;         // seconds
    double  frequency;          // MHz
    int     number_scans;
    char    machine_id[80];
    char    date[80];
    char    comment1[80];
    char    comment2[80];
    char    aquisition_type[80];
    float   increment;          // seconds
    char    reserved[80];    
} Header;

typedef struct {
    int     fid_scale;		// NO for no scaling, YES for scaling
    float   scale_factor;	// factor to multiply data
    int     scaleby;		// NO for no scaling, YES for scaling
    int     pre_ecc;		// NO for no ecc, YES for ecc
    int     bc;			// NO for no baseline correct,...
    // YES for baseline correct
    int     file_type;		// 0 for binary, 1 for text
    int     data_zero_fill;     // specifies point to zero fill to 8
    float   comp_filter;	// specifies point to zero fill to 8
    int     max_normalize;      // specifies point to zero fill to 8
    int     pre_quality;	// specifies point to zero fill to 8
    int     pre_quecc;		// specifies point to zero fill to 8
    int     pre_quecc_points;	// specifies point to zero fill to 8
    float   pre_delay_time;	// specifies point to zero fill to 8
    int     pre_quecc_if;	// specifies point to zero fill to 8
    int     input_file_type;	// specifies input file type
    int     ref_file_argument;  // argument of argv[] which is reference file
    int     csi_reorder;	// argument of argv[] which is reference file
    int     tilt;		// removes DC following self ECC or ...
    // QUECC correction
} Preprocess;

typedef struct  {
    char    in[2][256];         // input FIDs
    char    out[2][256];	// resultant output FIDs
    char    in_procpar[256];	// procpar associated with input FID
    char    ref_procpar[256];	// procpar associated with ref FID
    char    PE_table[256];	// PE table used for CSI K-space ordering
} IOFiles;

typedef struct  {
    int     index_r;
    int     index_c;
} PE_index;

typedef struct {                  // 0-Little endian, 1-Big endian
    int      systemStruct;        // System architecture.
    int      fileStruct;          // File structure.
} Endian_Check;

// com_line.cpp
int command_line(Preprocess *preprocess, IOFiles *file, Procpar_info *procpar_info,
                    int argc, char **argv, int *fid);
// read_procpar.cpp
int read_procpar(Procpar_info *procpar_info, char *procpar_string);

// fmtext_o.cpp
int read_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                Data_file_header **main_header, 
                Data_block_header **block_header, Precision2 *switch_data,
                FILE **in_file, Precision1 *in_data, float **out_data, 
                float **scratch_data, Endian_Check *endianCheck);
int read_nmr_text(char *filename, float **out_data, Header *header, 
                    float **scratch_data, int fn);
int read_csi_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                    Data_file_header **main_header,
                    Data_block_header **block_header, Precision2 *switch_data, 
                    FILE **in_file, Precision3 *csi_orig[100][100], 
                    Precision4 *csi_final[100][100], Precision4 *final_data[32][32],
                    int *pe_table, PE_info *pe_info);
int read_PE_table(char *filename, int *pe_table, PE_info *pe_info);
void write_csi_data(char *outfile_name, Precision4 *csi_final[100][100],
                    Data_file_header **main_header, 
                    Data_block_header **block_header, PE_info *pe_info);
void fwrite_asc(char *outfile_name, float *data, Data_file_header *main_header,
                Data_block_header *block_header, int index1,
                Procpar_info *procpar_info, Preprocess *preprocess);

// read_fdf.cpp
int read_fdf_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                    Data_file_header **main_header,  
                    Data_block_header **block_header, Precision2 *switch_data, 
                    FILE **in_file, Precision1 *in_data, float **out_data, 
                    float **scratch_data,Procpar_info *procpar_info);

// preproc.cpp
int pre_process(int *fid, Preprocess *preprocess, Procpar_info *procpar_info,
                float **out_data, float **scratch_data);
int scale(float *data, Procpar_info *procpar_info, Preprocess *preprocess);
int normalize(float *data, float *scratch, Procpar_info *procpar_info);
int ecc_correction(float *sup_data, float *unsup_data, Procpar_info *procpar_info,
                    Preprocess *preprocess);
int quality(float *sup_data, float *unsup_data, float *scratch, 
                Procpar_info *procpar_info, Preprocess *preprocess);
int quecc(float *sup_data, float *unsup_data, float *scratch, 
                Procpar_info *procpar_info, Preprocess *preprocess);
int zero_fill(float *sup_data, float *unsup_data, Procpar_info *procpar_info,
                 Preprocess *preprocess);
int filter(float *sup_data, float *unsup_data, Procpar_info *procpar_info,
                 Preprocess *preprocess);
int baseline_correct(float *data, Procpar_info *procpar_info);

// h_swap.cpp
int main_header_swap(Data_file_header **sup_main_header, int i);
int block_header_swap(Data_block_header **sup_block_header, int i);






