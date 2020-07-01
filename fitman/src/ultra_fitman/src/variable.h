#include <string.h>

#define MAX_NUMBER_VARIABLES	100
#define TRUE  1
#define FALSE 0


// Define structures
/*
#ifndef _COMPLEX2_DEFINED
typedef struct { double	real,
						imag;
				}Complex;
#define _COMPLEX2_DEFINED
#endif
*/

#ifndef _VARIABLE_DEFINED
typedef struct { 
				char	label[32];
				double	value;
				}Variable;
#define _VARIABLE_DEFINED
#endif



class CVariable{

public:
			CVariable();
			~CVariable();
	void	initialize(int max_variables);
	int		get_value(char *var_label, double &value);
	int		get_value(char *var_label, float &value);
	int		get_value(char *var_label, int &value);
	int		put_variable(char *var_label, double var_value);
	int		get_number_variables(){ return number_variables; }
	int		update_variable(char *var_label, double var_value);
	int		exists(char *var_label);
	int		get_variable(int index, char *var_label, int &var_value);
	int		get_variable(int index, char *var_label, double &var_value);
	int		get_variable(int index, char *var_label, float &var_value);

private:
	Variable  *variable_list;

	int		  number_variables;
	int		  maximum_variables;
	
};

