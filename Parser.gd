extends Node

static func parse_color(line : String):
	var valid : bool = true
	var color : Color = Color(255, 255, 255)
	var color_start : int = -1
	var color_len : int = -1
	var colors_str : String = ""

	if "Color(" in line:
		color_start = line.find("Color(")
		var color_end = line.find(")", color_start)
		if color_end == -1:
			valid = false
		else:
			color_len = color_end - color_start + 1
			colors_str = line.substr(color_start, color_len)
			var colors_arr = colors_str.split(",")
			if colors_arr.size() != 3:
				valid = false
			else:
				var r = int(colors_arr[0])
				var g = int(colors_arr[1])
				var b = int(colors_arr[2])
				color = Color8(r, g, b)		
	else:
		valid = false
		
	return {"valid" : valid, "color" : color, "start" : color_start, "len" : color_len,
			"colors_str" : colors_str}			
##############################################################
##############################################################
##############################################################

var built_in_types = {
	"circle" : "x,y,rad,color[optional]",
	"rect" : "x,y,w,h,color[optional]",
	"line" : "x1,y1,x2,y2,color[optional]",
	"text" : "x,y,string,color[optional]"
}

func _parse_shape(p_params) -> Dictionary:
	# p_params : [circle, 10, 20, 40, Color(10,20,255)]
	#             ^^^^^^ shape_name
	var shape_name = p_params[0]
	# "x,y,rad,color[optional]"
	# ^^^^^^^^^^^^^^^^^^^^^^^^ params_required
	var params_required = built_in_types[shape_name]
	var params = params_required.split(",")
	
	var required : int = 0
	var optional : int = 0

	var valid : bool = true
	var result = {"valid" : valid}

	# Default Initialize all the expected parameters.
	for param in params:
		if "[optional]" in param:
			optional += 1
			param = param.rstrip("[optional]")

		if param == "color":
			result[param] = Color.white
		elif param == "string":
			result[param] = ""
		else:
			# All others are float as of now.	
			result[param] = 0.0

	required = params.size() - optional

	# 1 is func name, so remove that		
	if (p_params.size() - 1 == required or p_params.size() - 1 == params.size()):
		var c : int = 1
		# p_params[0] is func name,
		# and actual parameters begin from 1.
		for param in params:
			if c >= p_params.size():
				break

			if "[optional]" in param:
				param = param.rstrip("[optional]")
				
			if param == "color":
				var parsed_color = parse_color(p_params[c])
				if parsed_color.valid:
					result[param] = parsed_color.color
			elif param == "string":
				var string = p_params[c]
				string = string.lstrip("\"")
				string = string.rstrip("\"")
				result[param] = string
			else:	
				var var_data = VariablesSingleton.get_variables_if_exits(p_params[c])
				var var_exits = var_data[0]
				if var_exits:
					result[param] = float(var_data[1])
				else:	
					result[param] = float(p_params[c])
			c += 1 
	else:
		valid = false

	result["valid"] = valid	
	return result				

