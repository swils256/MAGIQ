#include <stdlib.h>
#include <malloc.h>
//#include </home/van/fitMan/Include/parse.h>
//#include </people/r/rbartha/temp/Linux_compile/src/parse.h>
#include <parse.h>


// Define the constructor.
CParse::CParse( char *string, CVariable *variable){

    // Dynamically allocate the correct amount of memory.
    token_string = new char[strlen( string ) + 1];

	// Keep pointer to variable list
	variable_list = variable;

	index = 0;
	string_index = 0;
	error_code = 0;

    // If the allocation succeeds, copy the initialization string.
    if( token_string )
       strcpy( token_string, string );

	// Set to first token
	next_token();
}


// Define the destructor.
CParse::~CParse(){

    // Deallocate the memory that was previously reserved
    //  for this string.
    delete[] token_string;
}

void CParse::reset(){

	string_index = 0;
	error_code = 0;
	next_token();

}

  
void CParse::next_token(){

	int sign;

	switch(token_string[string_index]){
		case 0	 :  current_type = END;
					break;
		case '(' :	string_index++;
					current_type = OPEN_BRACKET;
					strcpy(current_label,"(");
					current_value = 0.0f;
					break;
		case ')' :  string_index++;
					current_type = CLOSE_BRACKET;
					strcpy(current_label,")");
					current_value = 0.0f;
					break;
		case '*' :  string_index++;
					current_type = MULTIPLY;
					strcpy(current_label,"*");
					current_value = 0.0f;
					break;
		case '/' :  string_index++;
					current_type = DIVIDE;
					strcpy(current_label,"/");
					current_value = 0.0f;
					break;
		case '^' :  string_index++;
					current_type = EXPONENT;
					strcpy(current_label,"^");
					current_value = 0.0f;
					break;
		case '+' :  
		case '-' :  if(current_type < OPEN_BRACKET && string_index){
						current_value = 0.0f;
						current_label[0] = token_string[string_index]; 
						current_label[1] = 0; 

						current_type =	(token_string[string_index] == '+') ? PLUS : MINUS;

						string_index++;
						break;
					}
		default	 :	sign = 1;
					if(!isalnum(token_string[string_index]) &&
					    token_string[string_index] != '.'   &&
						token_string[string_index] != '+'   &&
						token_string[string_index] != '-'){
						error_code = 1;          // unknown operator
						break;
					}
					if(!isalnum(token_string[string_index]) &&
					    token_string[string_index] != '.' )
						sign =	(token_string[string_index++] == '+') ? 1 : -1;
					index = 0;
					while(isalnum(token_string[string_index]) ||
						  token_string[string_index] == '.' ||
						  token_string[string_index] == '_'){
						if(token_string[string_index] == 'E'){
							current_label[index++] = token_string[string_index++];
							if(!isalpha(current_label[0]))
								current_label[index++] = token_string[string_index++];
							continue;

						}
						current_label[index++] = token_string[string_index++];
					}

					current_label[index] = 0;
					
					if(isalpha(current_label[0])){
						current_type = -2;
						if(!variable_list->get_value(current_label, current_value))
							error_code = 2;           // error variable not found
						current_value *= (double)sign;
					}
					else{
						current_value = (double)sign * (double)atof(current_label);
						current_type = -1;
					}

					break;
					
					

	}


}



// Mutual Recursive Parsing 

double CParse::expn(){

	double	nextValue;
	double	eValue;
	int		type;

	eValue = term();

	while(current_type == PLUS || current_type == MINUS){

		type = current_type;
		next_token();
		nextValue = term();

		eValue += type == PLUS ? nextValue : -nextValue;

	}

	return(eValue);
}



double CParse::term(){

	double nextValue;
	double tValue;
	int		type;

	tValue = exponent();

	while(current_type == MULTIPLY || current_type == DIVIDE){

		type = current_type;
		next_token();
		nextValue = exponent();

		tValue *= type == MULTIPLY ? nextValue : (1.0f/nextValue);

	}

	return(tValue);
}

double CParse::exponent(){

	double nextValue;
	double exValue;

	exValue = primary();

	while(current_type == EXPONENT){

		next_token();
		nextValue = primary();

		exValue = (double)pow(exValue, nextValue);

	}

	return(exValue);
}




double CParse::primary(){

	double pValue;

	if(current_type == OPEN_BRACKET){
		next_token();
		pValue = expn();
	}
	else{
		if(current_type >= 0)
			error_code = 1;

		pValue = current_value;
	}
	
	next_token();

	return(pValue);
}





double CParse::answer(){


	reset();
	return(expn());



}
