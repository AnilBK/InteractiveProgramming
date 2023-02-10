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

static func _parse_circle(params) -> Dictionary:
	#Line       =    circle	  	10 	20 	5
	#params (4) =    funcname 	x  	y   radius	
	var valid : bool = true
	var x : float = 0.0
	var y : float = 0.0
	var rad : float = 0.0
	var _color : Color = Color.white

	if params.size() == 5:
		# 5th means color.
		var col_str = params[4]
		var parsed_color = parse_color(col_str)
		if parsed_color.valid:
			_color = parsed_color.color

	if not(params.size() != 4 or params.size() != 5):
		valid = false
	else:
		x = float(params[1])
		y = float(params[2])
		rad = float(params[3])
				
	return {"valid" : valid, "x" : x, "y" : y, "rad" : rad, "color" : _color}

	
static func _parse_rect(params) -> Dictionary:
	#Line       =    rect	  	10 	20 	30	40
	#params (5) =    funcname 	x	y	w	h	
	var valid : bool = true
	var x : float = 0.0
	var y : float = 0.0
	var w : float = 0.0
	var h : float = 0.0
	var _color : Color = Color.white

	if params.size() == 6:
		# 6th means color.
		var col_str = params[5]
		var parsed_color = parse_color(col_str)
		if parsed_color.valid:
			_color = parsed_color.color
		
	if not(params.size() != 5 or params.size() != 6):
		valid = false
	else:
		x = float(params[1])
		y = float(params[2])
		w = float(params[3])
		h = float(params[4])
				
	return {"valid" : valid, "x" : x, "y" : y, "w" : w, "h" : h, "color" : _color}


static func _parse_line(params) -> Dictionary:
	#Line       =    line	  	10 	20 	30	40
	#params (5) =    funcname 	x1	y1	x2	y2	
	var valid : bool = true
	var x1 : float = 0.0
	var y1 : float = 0.0
	var x2 : float = 0.0
	var y2 : float = 0.0
	var w : float = 1.0 #Optional
	var _color : Color = Color.white
		
	if params.size() == 6:
		# 6th means color.
		var col_str = params[5]
		var parsed_color = parse_color(col_str)
		if parsed_color.valid:
			_color = parsed_color.color

	#Color is an additional param, so we check sizes 5 and 6.	
	if not (params.size() == 5 or params.size() == 6):
		valid = false
	else:
		x1 = float(params[1])
		y1 = float(params[2])
		x2 = float(params[3])
		y2 = float(params[4])

		if params.size() == 6:
			w = float(params[5])
				
	return {"valid" : valid, "x1" : x1, "y1" : y1, "x2" : x2, "y2" : y2, "w" : w, "color" : _color}

		
static func _parse_text(params) -> Dictionary:
	#Line         =    text	  	10 	20 	" Some String "
	#params       =   funcname 	x1	y1	" string      "	
	var valid : bool = true
	var x : float = 0.0
	var y : float = 0.0
	var string : String = ""
	var _color : Color = Color.white

	if params.size() == 5:
		# 5th means color.
		var col_str = params[4]
		var parsed_color = parse_color(col_str)
		if parsed_color.valid:
			_color = parsed_color.color
		
	if not(params.size() != 4 or params.size() != 5):
		valid = false
	else:
		x = float(params[1])
		y = float(params[2])
		string = params[3]
		string = string.lstrip("\"")
		string = string.rstrip("\"")

	return {"valid" : valid, "x" : x, "y" : y, "string" : string, "color" : _color}
	
