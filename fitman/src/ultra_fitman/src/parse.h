#include <string.h>
#include <ctype.h>
#include <math.h>
//#include <variable.h>
#include "variable.h" //V

#define NONE			0
#define END				0
#define OPEN_BRACKET	1
#define CLOSE_BRACKET	2
#define PLUS			3
#define MINUS			4
#define MULTIPLY		5
#define DIVIDE			6
#define EXPONENT		7


class CParse{

public:
			CParse(char *string, CVariable *variable);
			~CParse();
	int		get_token_type() {return	current_type;}	// token type,	0 = end, 
												//			1 = bracket  ')'
												//			2 = bracket  '('								//						1 = bracket  '('
												//			3 = plus     '+'
												//			4 = minus    '-'
												//			5 = multiply '*'
												//			6 = divide   '/'
												//			7 = exponent '^"
												//			-1 = value
												//			-2 = variable
												//			99 = unknown
																
	double	get_token_value(){return current_value;}	// return token value, 0 if non-numeric
	char	*get_token_label(){return current_label;}	// return token label
	int		get_error(){ return error_code;}
	
	void	next_token();				// Increment index
	void	reset();
	double	expn();
	double	term();
	double	exponent();
	double	primary();
	double	answer();

private:
	char		*token_string;
	CVariable	*variable_list;
	int			index;
	int			string_index;
	int			error_code;			// 0 = no errors
									// 1 = unknown operator
									// 2 = unknown variable 
									// 3 = 

	int		  current_type;
	char	  current_label[20];
	double	  current_value;
	
};

