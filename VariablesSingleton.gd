extends Node

var variables = {
}

func get_variables_if_exits(var_name):
	if var_name in variables:
		#print("variable exist with value: " + str(variables[var_name]))
		return [true, variables[var_name]]
	else:
		return [false, 0]    

