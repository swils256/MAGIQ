/******************************************************************************
ge2fitman_prot.h

Project: ge2fitman
    Conversion routine for GE binary raw P-file to NMR286 / Fitman text format
    Copyright (c) 2005 - Csaba Kiss, Rob Bartha.

File description:
    Prototype definition file for conversion structures.

Supports:
    ge2fitman.cpp

Contributors: 

Updates (yy/mm/dd):
    - 2005/05/14    - Ver 1.0a.
    - 2005/08/15    - Ver 1.5 .. in-between versions include updates and fixes.
    - 2005/09/07    - Ver 1.6 .. Improved p-file version checking.
                                 Included 8x version p-file for processing.
    - 2005/09/16    - Ver 1.7 .. Fixed double fclose() bug.
                                 Changed output header.
    - 2005/09/16    - Ver 1.7 .. Fixed double fclose() bug.
                                 Changed output header.
    - 2005/12/16    - Ver 1.8 .. Implemented ver 12.x files
                                 Fixed zero water set issues.
   			         Changed lines 9 & 10 on the output.
    - 2006/02/13    - Ver 1.9 .. Changed compilation to static for better compatibility.

    - 2010/02/17    - Ver 1.10 .. revised offsets per new GE header files
 ******************************************************************************/

#include <stdio.h>
#include <errno.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <limits.h>
#include <iostream>


#define VERSION             "1.9"
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
#define BIG_END		    1              // Big endian architetcture system

// Definitions for field offsets in the input file header.
// These were obtained with the "Get_filed_offset.cpp" utility
#define RDBM_REV_OFFSET     0x00        // size 4 - float
#define XRES_OFFSET         0x66        // size 2 - short

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define XRES_OFFSET_20x     0x6E        // size 2 - short
#define XRES_OFFSET_20x     0x66        // size 2 - short
//end of correction

// end of added code

#define NEX_OFFSET          0xE8        // size 4 - float  // May give wrong value... it's a user4 filed

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define NEX_OFFSET_20x      0x100        // size 4 - float
#define NEX_OFFSET_20x      0xE8        // size 4 - float
//end of correction

// end of added code

#define DWELL_OFFSET        0x170       // size 4 - float

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define DWELL_OFFSET_20x    0x18C       // size 4 - float
#define DWELL_OFFSET_20x    0x170       // size 4 - float
//end of correction

// end of added code

#define MAIN_FREQ_OFFSET    0x1A8       // size 4 - long

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define MAIN_FREQ_OFFSET_20x    0x1D8       // size 4 - long
#define MAIN_FREQ_OFFSET_20x    0x1A8      // size 4 - long
//end of correction

// end of added code

#define HOSP_NAM_OFFSET_8x          0x9012      // size 33 - char[]
#define HOSP_NAM_OFFSET_9x_11x      0xE012      // size 33 - char[]
#define HOSP_NAM_OFFSET_12x         0xF19B      // size 33 - char[]

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define HOSP_NAM_OFFSET_20x         0x100D2      // size 33 - char[]
#define HOSP_NAM_OFFSET_20x         0x2332F      // size 33 - char[]
//end of correction

// end of added code

#define PAT_NAM_OFFSET_8x           0x906D      // size 25 - char[]
#define PAT_NAM_OFFSET_9x_11x       0xE06D      // size 25 - char[]
#define PAT_NAM_OFFSET_12x          0xF26E      // size 25 - char[]

// added by jd, July 10, 2009

// N.B. (nota bena): patname -> patnameff in Get_field_offsets.cpp
// corrected after obtaining new header files form GE

//#define PAT_NAM_OFFSET_20x          0x1012D      // size 25 - char[]
#define PAT_NAM_OFFSET_20x          0x233DC      // size 65 - char[]
//end of correction

// end of added code


#define EXAM_DATE_OFFSET_8x         0x90DC      // size 4 - int
#define EXAM_DATE_OFFSET_9x_11x     0xE0DC      // size 4 - int
#define EXAM_DATE_OFFSET_12x        0xF080      // size 4 - int

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define EXAM_DATE_OFFSET_20x        0x1019C      // size 4 - int
#define EXAM_DATE_OFFSET_20x        0x23034      // size 4 - int
//end of correction

// end of added code

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
/*
#define VOX1_OFFSET         0x17C       // size 4 - float
#define VOX2_OFFSET         0x180       // size 4 - float
#define VOX3_OFFSET         0x184       // size 4 - float
*/
#define VOX1_OFFSET         0x17C       // size 4 - float
#define VOX2_OFFSET         0x180       // size 4 - float
#define VOX3_OFFSET         0x184       // size 4 - float
//end of correction

// added by jd, July 10, 2009
#define VOX1_OFFSET_20x     0x198       // size 4 - float
#define VOX2_OFFSET_20x     0x19C       // size 4 - float
#define VOX3_OFFSET_20x     0x1A0       // size 4 - float
// end of added code

#define POS1_OFFSET         0x188       // size 4 - float
#define POS2_OFFSET         0x18C       // size 4 - float
#define POS3_OFFSET         0x190       // size 4 - float

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
/*
#define POS1_OFFSET_20x     0x1A4       // size 4 - float
#define POS2_OFFSET_20x     0x1A8       // size 4 - float
#define POS3_OFFSET_20x     0x1AC       // size 4 - float
*/
#define POS1_OFFSET_20x     0x188       // size 4 - float
#define POS2_OFFSET_20x     0x18C       // size 4 - float
#define POS3_OFFSET_20x     0x190       // size 4 - float
//end of correction

// end of added code

#define R1_OFFSET           0x19C       // size 4 - long
#define R2_OFFSET           0x1A0       // size 4 - long
#define GAIN_OFFSET         0x1A4       // size 4 - long

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define GAIN_OFFSET_20x        0x1f0       // size 4 - long
#define GAIN_OFFSET_20x        0x1B4       // size 4 - long
//end of correction

// end of added code

#define PULSE_NAM_OFFSET_8x    0x995C      // size 33 - char[]
#define PULSE_NAM_OFFSET_9x    0xE95C      // size 33 - char[]
#define PULSE_NAM_OFFSET_11x   0xEB58      // size 33 - char[]
#define PULSE_NAM_OFFSET_12x   0xFF5E      // size 33 - char[]

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define PULSE_NAM_OFFSET_20x   0x10C50      // size 33 - char[]
#define PULSE_NAM_OFFSET_20x   0x245FC      // size 33 - char[]
//end of correction

// end of added code

#define TE_OFFSET_8x           0x98EC      // size 4 - int
#define TE_OFFSET_9x           0xE8EC      // size 4 - int
#define TE_OFFSET_11x          0xEAE8      // size 4 - int
#define TE_OFFSET_12x          0xFE08      // size 4 - int

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define TE_OFFSET_20x          0x10BE0      // size 4 - int
#define TE_OFFSET_20x          0x243C0      // size 4 - int
//end of correction

// end of added code

#define TR_OFFSET_8x           0x98E4      // size 4 - int
#define TR_OFFSET_9x           0xE8E4      // size 4 - int
#define TR_OFFSET_11x          0xEAE0      // size 4 - int
#define TR_OFFSET_12x          0xFE00      // size 4 - int

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define TR_OFFSET_20x          0x10BD8      // size 4 - int
#define TR_OFFSET_20x          0x243B8      // size 4 - int
//end of correction

// end of added code

#define NFRAMES_OFFSET         0x4A        // size 2 - short  // Total FIDs

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define NFRAMES_OFFSET_20x     0x52        // size 2 - short  // Total FIDs
#define NFRAMES_OFFSET_20x     0x4A        // size 2 - short  // Total FIDs
//end of correction

// end of added code

#define NUM_WTR_FID_OFFSET     0x124       // size 4 - float  // May give wrong value... it's a user19 filed

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define NUM_WTR_FID_OFFSET_20x 0x13C       // size 4 - float
#define NUM_WTR_FID_OFFSET_20x 0x124       // size 4 - float\
//end of correction

// end of added code

#define POINTSIZE_OFFSET       0x52        // size 2 - short

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define POINTSIZE_OFFSET_20x   0x5A        // size 2 - short
#define POINTSIZE_OFFSET_20x   0x52        // size 2 - short
//end of correction

// end of added code

#define RAW_PASS_SIZE_OFFSET   0x74        // size 4 - long

// added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define RAW_PASS_SIZE_OFFSET_20x 0x80      // size 4 - long
#define RAW_PASS_SIZE_OFFSET_20x 0x680      // size 8 - long
//end of correction

// end of added code

//#define FILE_VER_OFFSET      0xE4CC      // size 2 - char[]

#define HEADER_SIZE_8X          39984       // The 8x header size
#define HEADER_SIZE_9X          60464       // The 9x header size
#define HEADER_SIZE_11X         61464       // The 11x header size
#define HEADER_SIZE_12X         66072       // The 12x header size

//added by jd, July 10, 2009

// corrected after obtaining new header files form GE
// by jd, Feb 16, 2010
//#define HEADER_SIZE_20X         69944      // The 20x header size

//#define HEADER_SIZE_20X         149808      // The 20x header size
#define HEADER_SIZE_20X         149788      // The 20x header size

//end of correction

//end of added code

// Definitions for argument handling.
#define FIRST_ARG_NUM          1           // The number of the frist argument.
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
    float   R1;
    float   R2;
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
    int     num_channels;       // Number of channels.
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
    int     bc;				// NO for no baseline correct,...
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
    char    in_procpar[256];            // procpar associated with input FID
    char    ref_procpar[256];           // procpar associated with ref FID
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
} InFile_struct;

typedef struct {                  // 0-Little endian, 1-Big endian
    int      systemStruct;        // System architecture.
    int      fileStruct;          // File structure.
} Endian_Check;

// ge2fitman_com_line.cpp
int command_line(Preprocess *preprocess, IOFiles *file, Procpar_info *procpar_info,
                    int argc, char **argv, int *fid, int *arg_read, int *forced_swap,
                    bool *overwrite, bool *verbose);
void undo_ecc(Preprocess *preprocess, int *fid);


// ge2fitman_read_procpar.cpp
int read_procpar(Procpar_info *procpar_info, char *procpar_string, FILE *in_file
                , bool *swap_bytes, InFile_struct *infile_struct
                , Data_file_header *main_header);
int read_field(FILE * in_file, char *var_pointer, int var_size 
                , long int hdr_field_offset, int hdr_field_size
                , bool swap_bytes);

// ge2fitman_fmtext_o.cpp
int read_data(int *fid, Preprocess *preprocess, IOFiles *file, 
                Data_file_header *main_header, 
                Data_block_header *block_header, Precision2 *switch_data,
                FILE **in_file, Procpar_info *procpar_info,
                Precision1 *in_data, float **out_data, 
                float **scratch_data, int swap_bytes, InFile_struct *infile_struct,
                bool verbose);
void fwrite_asc(char *outfile_name, float *data, Data_file_header *main_header,
                Data_block_header *block_header, int index1,
                Procpar_info *procpar_info, Preprocess *preprocess);
void get_phase(float *phase, FILE **in_file, Data_file_header *main_header,
			   InFile_struct *infile_struct, long header_size, IOFiles *file,
			   int swap_bytes, Procpar_info *procpar_info);
void fix_phase(float phase_applied, int num_points, Precision1 *in_data, int fid,
			   int countFID);

// ge2fitman_preproc.cpp
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


// ge2fitman_sup.cpp
bool isNumber(char *string);
int isBigEndian();
void endianCheck_system(Endian_Check *endian_check, bool verbose);
int endianCheck_file(FILE *in_file, Endian_Check *endian_check, bool *swap_bytes
                    ,char *filename, bool verbose);
void swapBytes(char *theVarChar, int size);
int getNumChannels(char *filename) ;
bool promptYN();
int promptSUBN();
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

// ge2fitman_error.cpp
void filter_zero_set(FILE **in_file, InFile_struct *infile_struct, 
                    Preprocess *preprocess, int *fid, bool verbose,
                    Procpar_info *procpar_info, int *s_u_out);
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
void exit_29(FILE **in_file);
void exit_30(FILE **in_file);
void exit_31(FILE **in_file);
void exit_32(FILE **in_file);
