/******************************************************************************
sim2fitman_prot.h

Project: sim2fitman
    Conversion routine for SIEMENS binary file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Prototype definition file for conversion structures.

Supports:
    sim2fitman.cpp

Contributors: 

Updates (yy/mm/dd):
    - 2005/08/31    - Ver 1.0
    - 2006/02/13    - Ver 1.1 .. Changed compilation to static for better compatibility.
 ******************************************************************************/

#include <stdio.h>
#include <errno.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>


#define VERSION             "1.1"
#define TRUE                1
#define FALSE               0
#define YES                 1
#define NO                  0
#define BINARY              0
#define BINARY_FILE         0
#define FDF_FILE            1
#define TEXT_FILE           2
#define TEXT                0
#define read_ok             04
#define exists              00
#define PI                  3.141592653589793
#define MAX_PHASE_ENCODES   100

#define NO_DATE             "No Date Available"
#define NO_FILENAME         "No Filename Available"
#define NO_HOSP_NAME        "No Hospital Name Available"
#define NO_PATIENT_NAME     "No Patient Name Available"
#define NO_PULSE_SEQ_NAME   "No Pulse Sequence Name Available"

#define LITTLE_END          0              // Little endian architetcture system
#define BIG_END             1              // Big endian architetcture system


// Definitions for argument handling.
#define FIRST_ARG_NUM          1           // The number of the first argument.
#define MAX_GEN_OPT_NUM        3           // Maximum number of general options.
#define MAX_INFILE_OPT_NUM     6           // Maximum number of input file options.
#define MAX_REFFILE_OPT_NUM    6           // Maximum number of reference file options.

// Help version definitions.
#define HELP_SHORT              0           // Short version.
#define HELP_LONG               1           // Long version.

#define swapVarBytes(x) swapBytes((char *)&x, sizeof(x))


typedef union con1 {
    long number;
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
    long_char nblocks;      // number of blocks in file
    long_char ntraces;      // number of traces per block
    long_char np;           // number of elements (complex pairs) per trace
    long_char ebytes;       // number of bytes per element (complex pair)
    long_char tbytes;       // number of bytes per trace
    long_char bbytes;       // number of bytes per block
    short_char transf;      // transposed storage flag
    short_char status;      // status of whole file
    long_char spare1;       // reserved for future use
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


// Make sure all character arrays in the structure have length of
// multiples of four....otherwise we get memory access error 
// when copying the structure.
// Also the structure size has to be divisable by 4.
// And finally the 'doubles' have to line up to an address
// divisibale by 8.
// "Dummy" padding variables are used to fill the space.
typedef struct {
    float   acquision_time;
    char    ex_datetime[52];    // Exam date/time 
    char    file_name[260];
    float   filter;
    int     num_transients;
    int     num_points;         // Number of complex pairs (Re + Im)
    double  main_frequency;
    double  offset_frequency;
    float   te;
    float   tr;
    float   gain;
    float   pos1;
    float   pos2;
    float   pos3;
    float   vox1;
    float   vox2;
    float   vox3;
    char    padding_1[4];       // Just padding...NOT USED.
    double  span;
    float   vtheta;				// Used when reading in FDF files
    char    hospname[36];       // Hospital name
    char    patname[28];        // Patient name
    char    psdname[40];        // Pulse sequence name
    float   nex;                // Nex value
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
    int     fid_scale;			// NO for no scaling, YES for scaling
    float   scale_factor;		// factor to multiply data
    int     scaleby;			// NO for no scaling, YES for scaling
    int     pre_ecc;			// NO for no ecc, YES for ecc
    int     bc;					// NO for no baseline correct,...
								// YES for baseline correct
    int     file_type;			// 0 for binary, 1 for text
    int     data_zero_fill;             // specifies point to zero fill to 8
    float   comp_filter;		// specifies point to zero fill to 8
    int     max_normalize;              // specifies point to zero fill to 8
    int     pre_quality;		// NO for no quality, YES for quality
    int     pre_quecc;			// NO for no quecc, YES for quecc
    int     pre_quecc_points;           // specifies point to zero fill to 8
    float   pre_delay_time;		// specifies point to zero fill to 8
    int     pre_quecc_if;		// specifies point to zero fill to 8
    int     input_file_type;            // specifies input file type
    int     ref_file_argument;          // argument of argv[] which is reference file
    int     csi_reorder;		// argument of argv[] which is reference file
    int     tilt;			// removes DC following self ECC or ...
    bool    ecc_present;                // specifies if -ecc or -quality or -quecc is needed.
    // QUECC correction
} Preprocess;

typedef struct  {
    char    in[2][256];			// input FIDs
    char    out[2][256];		// resultant output FIDs
    char    in_procpar[256];	// procpar associated with input FID
    char    ref_procpar[256];	// procpar associated with ref FID
    char    PE_table[256];		// PE table used for CSI K-space ordering
} IOFiles;

typedef struct  {
    int     index_r;
    int     index_c;
} PE_index;

typedef struct {
    int     num_datasets;       // The total number of FID datasets, baseline excluded.
    int     num_unsup_sets;     // The numer of unsuppressed FID sets  .
    int     file_size;          // Input file size.
    int     total_data_size;    // Total raw data size;    
    char    version[4];         // Input datafile version.
    long int hdr_offset;        // Header offset value;
} InFile_struct;

typedef struct {                  // 0-Little endian, 1-Big endian
    int      systemStruct;        // System architecture.
    int      fileStruct;          // File structure.
} Endian_Check;

// sim2fitman_com_line.cpp
int command_line(Preprocess *preprocess, IOFiles *file, Procpar_info *procpar_info,
                    int argc, char **argv, int *fid, int *arg_read, int *forced_swap,
                    bool *overwrite, bool *verbose);


// sim2fitman_read_procpar.cpp
int read_procpar(Procpar_info *procpar_info, char *procpar_string, FILE *in_file
                , bool *swap_bytes, InFile_struct *infile_struct
                , Data_file_header *main_header);
int read_field(FILE * in_file, char *var_pointer, int var_size 
                , long int hdr_field_offset, int hdr_field_size
                , bool swap_bytes);

// sim2fitman_fmtext_o.cpp
int read_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                Data_file_header *main_header, 
                Data_block_header *block_header, Precision2 *switch_data,
                FILE **in_file, Precision1 *in_data, float **out_data, 
                float **scratch_data, int swap_bytes, InFile_struct *infile_struct);
void fwrite_asc(char *outfile_name, float *data, Data_file_header *main_header,
                Data_block_header *block_header, int index1,
                Procpar_info *procpar_info, Preprocess *preprocess);

// sim2fitman_preproc.cpp
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


// sim2fitman_sup.cpp
bool isNumber(char *string);
int isBigEndian();
void endianCheck_system(Endian_Check *endian_check, bool verbose);
int endianCheck_file(FILE *in_file, Endian_Check *endian_check, bool *swap_bytes
                    ,char *filename, bool verbose);
void swapBytes(char *theVarChar, int size);
bool promptYN();
int promptSUBN();
int isNAN(float float_value);
void disp_help(int version);
void init(Data_file_header *main_header, Data_block_header *block_header
                , Procpar_info	*procpar_info, Preprocess *preprocess
                , IOFiles *io_filenames, InFile_struct *infile_struct);
void check_outfile(IOFiles *io_filenames, bool overwrite, int s_u_out);
void infile_stats(Procpar_info *procpar_info, InFile_struct *infile_struct
                , Data_file_header *main_header);
void print_version();
void close_infiles(FILE **in_file);
void printHex(char *theThing, int size);

// sim2fitman_error.cpp
void exit_01(FILE **in_file);
void exit_02(FILE **in_file, char *filename);
void cond_exit_03(char *filename, int s_u_out);
void exit_04(FILE **in_file, char *argument);
void exit_05(FILE **in_file);
void exit_06(FILE **in_file, char *filename);
void exit_07(FILE **in_file, char *filename);
void exit_08(char *filename);
void exit_09(FILE **in_file, char *filename, InFile_struct *infile_struct);
void exit_10(FILE **in_file, char *filename, InFile_struct *infile_struct);
void exit_11(FILE **in_file);
void exit_12(FILE **in_file);
void exit_13(FILE **in_file);
void exit_14(FILE **in_file);
void exit_15(FILE **in_file);
void exit_16(FILE **in_file);
void exit_17(FILE **in_file);
void exit_18(FILE **in_file);
void exit_19(FILE **in_file);
void exit_20(FILE **in_file);
void cond_exit_21();
void exit_22(FILE **in_file);
int cond_exit_23();
void exit_24(FILE **in_file, int num);
void exit_25(FILE **in_file);
void exit_26(FILE **in_file);
void exit_27(FILE **in_file);
void exit_28(FILE **in_file);

