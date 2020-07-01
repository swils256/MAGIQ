//#include </home/van/fitMan/Include/variable.h>
//#include </people/r/rbartha/temp/Linux_compile/src/variable.h>
#include <variable.h>

CVariable::CVariable(){

    // Dynamically allocate the correct amount of memory.
    variable_list = new Variable[MAX_NUMBER_VARIABLES];

	number_variables = 0;
	maximum_variables = MAX_NUMBER_VARIABLES;
}


void CVariable::initialize(int max_variables){

	// Delete current allocation
    delete[] variable_list;

    // Dynamically allocate the correct amount of memory.
    variable_list = new Variable[max_variables];

	number_variables = 0;

    
}



CVariable::~CVariable(){

    // Deallocate the memory that was previously reserved
    //  for the variable_list.
    delete[] variable_list;
}


int CVariable::put_variable(char *var_label, double var_value){

	if(exists(var_label))
		return(0);

	if(number_variables < maximum_variables){
		strcpy(variable_list[number_variables].label, var_label);
		variable_list[number_variables++].value = var_value;
		return(1);
	}
	else
		return(0);

}


int CVariable::get_value(char *var_label, double &var_value){

	int index;

	for(index=0;index<number_variables;index++)
		if(strcmp(variable_list[index].label, var_label)==0){
			var_value = variable_list[index].value;
			return(1);
		}
	
	return(0);



}


int CVariable::exists(char *var_label){

	int index;

	for(index=0;index<number_variables;index++)
		if(strcmp(variable_list[index].label, var_label)==0){
			return(TRUE);
		}
	
	return(FALSE);



}




int CVariable::update_variable(char *var_label, double var_value){

	int index;

	for(index=0;index<number_variables;index++)
		if(strcmp(variable_list[index].label, var_label)==0){
			variable_list[index].value = var_value;
			return(1);
		}
	
	return(0);



}

int CVariable::get_value(char *var_label, float &var_value){

	int index;

	for(index=0;index<number_variables;index++)
		if(strcmp(variable_list[index].label, var_label)==0){
			var_value = (float)variable_list[index].value;
			return(1);
		}
	
	return(0);



}



int CVariable::get_value(char *var_label, int &var_value){

	int index;

	for(index=0;index<number_variables;index++)
		if(strcmp(variable_list[index].label, var_label)==0){
			var_value = (int)variable_list[index].value;
			return(1);
		}
	
	return(0);



}


int CVariable::get_variable(int index, char *var_label, int &var_value){

	if(index >= number_variables)
		return(0);
	else{
		var_value = (int)variable_list[index].value; 
		strcpy(var_label,variable_list[index].label); 
		return(1);
	}
			


}


int CVariable::get_variable(int index, char *var_label, double &var_value){


	if(index >= number_variables)
		return(0);
	else{
		var_value = (double)variable_list[index].value;
		strcpy(var_label,variable_list[index].label); 
		return(1);
	}
			


}


int CVariable::get_variable(int index, char *var_label, float &var_value){


	if(index >= number_variables)
		return(0);
	else{
		var_value = (float)variable_list[index].value;
		strcpy(var_label,variable_list[index].label); 
		return(1);
	}
			


}
