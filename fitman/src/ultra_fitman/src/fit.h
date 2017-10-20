//*****************************************************************
//*                           FIT.H                                * 
//*                                                                *
//*  This file contains all data structures, macros and function   *
//*  prototypes used by the FIT program                            *                        *
//*                                                                *   
   
//********************   
//*     Macros       *   
//********************   
   
#define	INFO	0   
#define	WARNING	1   
#define	FATAL	2   
#define	TRUE	1   
#define	FALSE	0   
// Units   
#define PPM		0   
#define HERTZ	1   
#define PI		3.141592653589793   
	   
   
#define NUMBER_PARAMETERS					6   
#define NUMBER_FIT_PARAMETERS_CONSTRAINTS	27   
#define NUMBER_FIT_PARAMETERS_GUESS			2   
#define MAX_NUMBER_LINKS					999   
   
// Parameters Frequency and Time Domains   
#define SHIFT			0   
#define WIDTH_LORENZ	1   
#define AMPLITUDE		2   
#define PHASE			3   
#define DELAY_TIME		4   
#define WIDTH_GAUSS		5   
   
   
// Parameters T2 and T1 domains   
#define IMAGE_T2		1   
#define IMAGE_M0		2   
#define IMAGE_PHASE		3   
#define IMAGE_T1 		4   
#define IMAGE_TE		5   
   
   
// Link type    
#define OFFSET			1   
#define RATIO			2   
#define FIXED	       -1   
   
// Fit Info Defaults   
#define DEFAULT_TOLERENCE			0.001   
#define DEFAULT_MAXIMUM_ITERATIONS	50   
#define DEFAULT_MINIMUM_ITERATIONS	5	   
#define DEFAULT_SHIFT_UNITS			PPM   
#define DEFAULT_FIRST_POINT			1   
#define DEFAULT_LAST_POINT			256   
#define DEFAULT_FILTER			    0   
#define DEFAULT_GAUSSIAN_FILTER			    0   
#define DEFAULT_ALAMBDA_INC			10   
#define DEFAULT_ALAMBDA_DEC			0.1   
#define DEFAULT_SPIKE				0   
#define DEFAULT_NOISE_POINTS		32   
#define DEFAULT_DWELL_TIME			0.00025   
#define DEFAULT_ZERO_FILL_TO		1024   
#define DEFAULT_FIXED_NOISE			FALSE   
#define DEFAULT_QRT_SIN_FIRST_POINT	0   
#define DEFAULT_QRT_SIN_END_POINT	0   
#define DEFAULT_MAX_CON_ALAMBDA_INC 10   
   
// Domains   
#define TIME_DOMAIN			0   
#define FREQUENCY_DOMAIN	1   
#define T1_DOMAIN			2   
#define T2_DOMAIN			3   
   
//********************   
//*    STRUCTURES    *   
//********************   
   
// Complex Structure   
#ifndef _COMPLEX2_DEFINED   
typedef struct { double	real,   
						imag;   
				}Complex;   
   
#define _COMPLEX2_DEFINED   
#endif   
   
   
   
//************************   
// Paramter Structure   
//************************   
typedef struct  {double	value;			// value of parameter if not linked   
										// otherwise value of master    
				int		linked;			// -1 means fixed, n means linked to peak n   
				double	modifier;		// if linked, contains constant or   
										// factor which is applied to *value   
										// to give actual value of parameter   
				int		link_type;		// flag for type of link =	OFFSET   
										//						RATIO   
				double  standard_deviation;   
				double  max_bound;		// maximum value that a parametrer can have   
				double  min_bound;		// minmum value that a parameter can have   
				}Parameter2;   
   
   
   
//************************   
// New Peak Structure   
//************************   
typedef struct  {Parameter2	*parameter;   
				 int		number_parameters;   
				}Peak2;   
   
   
   
   
   
   
// Point Structure   
typedef struct {    
				double	x;		// Real x coordinate   
				Complex	y;		// Complex y coordinate   
				} Point;   
   
   
// Complex Float   
typedef struct{   
	float real;   
	float imag;   
}Complexf;   
   
   
   
   
// Error return code structure    
   
typedef struct	{   
				int line,   
					element,   
					code;   
				} Error;   
   
// Guess Variable structure   
#ifndef _VARIABLE_DEFINED   
typedef struct {    
				char	label[32];   
				double	value;   
				}Variable;   
#define _VARIABLE_DEFINED   
#endif   
    
   
//*****************   
//*  NMR Header   *   
//*****************   
   
// Switch to single byte alignment for NMR286 header format   
//#pragma pack(push, 1)   
   
typedef struct{   
	char		keyname[8];   	/*  Key word to check for validity  */   
	signed char	fileversion;  	/*  File format version numbewr */   
	char		offsets[8];		/*  Offsets, in blocks of SECSIZE  */   
	unsigned short 	si,			/*  Size of the data set  */   
					td,			/*  Number of points collected  */   
					nrecs,		/*  Number of componets in file  */   
					dstatus,	/*  Current state of file   */   
					ns;			/*  Number of scans  */   
	double			sf,			/*  Spectrometer frequency  */   
					o1,			/*  Obs. offset  */   
					dw;			/*  Dwell period (s)  */   
	float			de;			/*  Preacquisiti	on delay  */   
	char	filename[30], 		/*  Name of file when stored  */   
			machineid[30],		/*  Name of acq. machine  */   
			date[31],			/*  some text comments  */   
			comment1[41],   
			comment2[41];   
	float	vd;				/*  variable delay  */   
	double	in2d,				/*  Minimal 2D param. set  */   
			sf1,				/*  SF in f1  */   
			o11;				/*  O1 in f1  */   
   
	}NMR_Header;   
   
// Return alignment to whatever previous   
//#pragma pack(pop)   
   
   
//*********************************   
//*    FIT PARAMETER STRUCTURE    *   
//*********************************   
   
   
typedef struct{   
				char	label[50];   
				int		number_arguments;   
				char	argument_type[2];    // I - integer, D - double, S - string, M<n> - mask   
				union{   
						double	*d[5];   
						int		*i[5];   
						char	*s[5];   
				}pointer;   
   
}Fit_Parameter;   
   
   
   
/******************/   
/*    Fit Info    */   
/******************/   
typedef struct{   
				int		 number_peaks;   
				char	 shift_units_constraints[6];	// PPM or HERTZ   
				char	 shift_units_guess[6];			// PPM or HERTZ   
				char	 output_shift_units[10];// PPM or HERTZ shift units for ouput file   
				double	 tolerence;				// Marquardt convergence tol.   
				int		 positive_amplitudes;	// TRUE= amplitudes must be positive   
				int		 maximum_iterations;   
				int		 minimum_iterations;   
				int		 first_point;			// Data point to start fit   
				int		 last_point;			// Data point to end fit   
				double	 chi_squared;			// Chi squared value return from Marquardt   
				Complex	 noise_std;				// Noise standard deviation for real and imag   
				char	 domain[20];				// TIME_DOMAIN=0, FREQUENCY_DOMAIN   
				double   filter;				// filter=0 means no filter applied   
				double	 first_point_frequency;	// Data point to start fit in freq. domain   
				double	 last_point_frequency;	// Data point to end fit in freq. domain   
				double	 alambda_inc;			// marqu. parameter Alambda increment    
				double	 alambda_dec;			// marqu. parameter Alambda decrement   
				int		 spike;   
				char	 filename_constraints[255];	// Filename for constraints file   
				int		 noise_points,			// Number of points from end of file used to calc. noise   
						 noise_equal;			// When true real and imaginary channel have same noise values   
												//		equal to the average of the channels   
				int		 zero_fill;   
				int		 total_fit_parameters;  // The number of parameters actually fit   
				int		 *lista;   
				double	 dwell_time;			// the dwell time needed for frequency domain fitting   
				int		 zero_fill_to;   
				double	 fixed_noise;			// sets noise std to some known level   
				int		 qrt_sin_first_point;   // point where quarter sine wave window starts   
				int      qrt_sin_last_point;    // point where quarter sine wave window ends   
				int		 fix_all;				// Masked variable for fixing parameters   
				int		 number_peaks_guess;	// Number of peaks in guess file   
				int		 max_con_alambda_inc;   // limits the number of alambda increments   
				char     output_file_system[10];    // allow user to specify output specifically for UNIX          
				Fit_Parameter *fit_parameter_con;	// Pointer to fit parameter structure constraint   
				Fit_Parameter *fit_parameter_guess;	// Pointer to fit parameter structure guess
				double   gaussian_filter;			// gauss_filter=0 means no guassian filter applied     
				}Fit_info;   
   
   
   
//********************   
//*    PROTOTYPES    *   
//********************   
   
   
int fit(	    Point	 *data,				// array of data points   
				Complex	 *sig,				// array of error for each point   
				Peak2	 *peak2,			// array of peaks in model   
				double	 **covar,			// covariance matrix   
				Fit_info *fit_info,         // Fit information structure:   
				Complex	 *window			// array of window scaling factors	   
				);							//	tolerance   
							   
////////////////////////   
//	Fitmain prototypes   
////////////////////////   
   
   
// Data Transformation   
int fft(Point *data, int number_points);   
int PhaseData(Point *Input, Point *Output, int N, double Phase, double DelayTime);   
Complex signal_function(Peak2 *peak, double time);   
double Magnitude(Complex c);   
int WindowQSin(Point *data, double dwell_time, int start_point, int end_point);   
int WindowExp(Point *data, int number_points, double dwell_time, double number_lb);   
   
// Data Transformation FLOAT   
int PhaseData_float(Complexf *Input, Complexf *Output, int N, double Phase, double DelayTime, double HzPerPoint);   
Complexf signal_function_float(Peak2 *peak, double time);   
int WindowExp_float(Complexf *data, int number_points, double dwell_time, double number_lb);   
int WindowQSin_float(Complexf *data, double dwell_time, int start_point, int end_point);   
int fft_float(Complexf *data, int number_points);   
   
   
   
   
// Fileio prototypes   
class CVariable;   
   
int		read_nmr_binary(char *filename, Point **data, NMR_Header *nmr_rec);   
int		read_nmr_text(char *filename, Point **data, NMR_Header *header);   
Error	read_guess_file(char *filename, Peak2 **peak, Fit_info *fit_info, CVariable *variable);   
Error	read_constraints_file(char *filename, Peak2 **peak, Fit_info *fit_info, CVariable *variable);   
int		write_guess_file(char *filename, Peak2 *peak, double ** covariance, Fit_info *fit_info, CVariable *variable);   
int		write_covariance_file(char *filename_covariance, double **covariance, Fit_info *fit_info);   
   
void	error_message(char *message_string, int level);   
char	*string_to_upper( char *string);   
int		parse_item(char *string, CVariable *vars, double &value);   
int		parse_item(char *string, CVariable *vars, int &value);   
int		get_link(char *string, char *link_label, int &operator_code, char *constant_modifier);   
Complex	standard_deviation(int start, int end, Point *data);   
void	error_trap(Error error, Fit_info fit_info);   
void	output_trap(int output_type, char *message, int iteration_conter, double chi_squared,double alamda, double  shift,    
				 double width_L, double width_G,double amplitude, double phase, double delay);   
int		filter(Point *data, int number_points, double dwell_time, double number_lb);   
int		spike(Point *data, int number_points, double spike);   
   
   
// prototypes from file "nr.h" of numerical recipes   
   
float **convert_matrix(float *a, int nrl, int nrh, int ncl, int nch);   
double **dmatrix(int nrl, int nrh, int ncl, int nch);   
double *dvector(int nl, int nh);   
void covsrt(double **covar, int ma, int *lista, int mfit);   
void dam_exp(double x, double *a, Complex *y, Complex *dyda, int ma, int *link,    
			 Peak2 *peak2, int k, Fit_info *fit_info, Complex window);   
void dam_exp2(double x, double *a, Complex *y, Complex *dyda, int ma, int *link,    
			  Peak2 *peak2, int k, Fit_info *fit_info, Complex window);   
void freq_exp(double x, double *a, Complex *y, Complex *dyda, int ma, int *link,    
			  Peak2 *peak2, int k, Fit_info *fit_info, Complex window);   
void T2_function(double x, double *a, Complex *y, Complex *dyda, int ma, int *link,    
				 Peak2 *peak2, int k, Fit_info *fit_info, Complex window);   
void T1_function(double x, double *a, Complex *y, Complex *dyda, int ma, int *link,    
				 Peak2 *peak2, int k, Fit_info *fit_info, Complex window);   
/*void fitt(Point *point, Complex *sig,Peak2 *peak2,double **covar, Fit_info *fit_info);*/   
/*void fgauss(double x, double *a, Complex *y, Complex *dyda, int ma, int *link, Peak *peak);*/   
void free_convert_matrix(float **b, int nrl, int nrh, int ncl, int nch);   
void free_dmatrix(double **m, int nrl, int nrh, int ncl, int nch);   
void free_dvector(double *v, int nl, int nh);   
void free_imatrix(int **m, int nrl, int nrh, int ncl, int nch);   
void free_ivector(int *v, int nl, int nh);   
void free_matrix(float **m, int nrl, int nrh, int ncl, int nch);   
void free_submatrix(float **b, int nrl, int nrh, int ncl, int nch);   
void free_vector(float *v, int nl, int nh);   
void *funcs(double, double *, Complex *, Complex *, int, int *, Peak2 *peak2, Complex);   
float gasdev(int *idum);   
int gaussj(double **a, int n, double **b, int m);   
int **imatrix(int nrl, int nrh, int ncl, int nch);   
int *ivector(int nl, int nh);   
float **matrix(int nrl, int nrh, int ncl, int nch);   
void mrqcof(Point *point, Complex *sig, double *a, int ma, int *lista,int mfit,   
			double **alpha, double *beta,void (*funcs)(double, double *,Complex *,   
			Complex *, int, int *, Peak2 *, int k, Fit_info *fit_info, Complex),   
			int *link, Peak2 *peak2, Fit_info *fit_info, Complex *window);   
int mrqmin(Point *point, Complex *sig, double *a, int ma, int *lista, int mfit,   
			double **covar,double **alpha, void (*funcs)(double, double *,Complex *,Complex *,   
			int,int *,Peak2 *, int k, Fit_info *fit_info, Complex),double *alamda,int *link,   
			Peak2 *peak2,Fit_info *fit_info, Complex *window);   
void nrerror(char *error_text);   
float ran1(int *idum);   
float **submatrix(float **a, int oldrl, int oldrh, int oldcl, int oldch, int newrl, int newcl);   
float *vector(int nl, int nh);
