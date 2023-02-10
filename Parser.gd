extends Node

# Our function parameters are separated by a space.
# If there are no strings in a function then we can just split the string,
# to get the parameters directly.	
# For functions like:
#	 line 10 20 40 50
static func _no_string_split(line : String):
	var params = line.split(" ")
	return params

# For functions like # text 10 20 "hello world"
# single space based splitting doesn't work, as there can be spaces
# in between strings.
static func _string_split(line : String):
	# TESTS for this function:
	# All this examples work for this.
	#	_string_split("Hello    World")
	#	_string_split("Hello  World")
	#	_string_split("10 20 Hello World")
	#	_string_split("Hello \"Hello World")
	#	_string_split("Hello \"Hello World\"")
	
	#Maybe use things like string.left(), get_slice() etc ??
	
	var params = []

	var inside_quotes = false
	var temp_param = ""
	
	for ch in line:
		if (not inside_quotes) and (ch == " "):
			#If there are two space in a row,
			#then it is appended to the array.
			if temp_param != "":
				params.append(temp_param)
			#temp_param can now store another param.
			temp_param = ""
		elif ch == "\"":
			inside_quotes = not inside_quotes
		else:			
			temp_param += ch
	
	#In This Case, text 20 25 "Hello World"\n
	#There is no space in the last for line string to split.
	#So, perform that now.
	if temp_param != "":
		params.append(temp_param)

	return params	

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

# Returns the function name and parameters.
# For eg:
# 	line 10 20 40 50 -> [line, 10, 20, 40, 50]
#   text 10 20 \"Hello World\" -> [text, 10, 20, Hello World]
static func parse_line(line : String):
	line = line.strip_edges()

	# Get the color directly from a string,
	# Just Hacky Workaround, because this parser is really bad.
	# that means we don't really care where this color function is called in a line,
	# we just directly parse it immediately.
	var parsed_color = parse_color(line)
	if parsed_color.valid:
		#temporarily remove the color from string,
		#so we shouldn't parse in the next steps below.
		line.erase(parsed_color.start, parsed_color.len)
		line = line.strip_edges(false, true)

	var contents = []	

	var line_contains_string = "\"" in line
	if line_contains_string:
		contents = _string_split(line)
	else:
		contents = _no_string_split(line)

	if parsed_color.valid:
		contents.append(parsed_color.colors_str)	

	return contents	

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
	var _color : Color = Color(255, 255, 255)

	var line = String(" ").join(params)
	var parsed_color = parse_color(line)
	if parsed_color.valid:
		_color = parsed_color.color
		
	if params.size() < 4:
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
		
	if params.size() != 5:
		valid = false
	else:
		x = float(params[1])
		y = float(params[2])
		w = float(params[3])
		h = float(params[4])
				
	return {"valid" : valid, "x" : x, "y" : y, "w" : w, "h" : h}


static func _parse_line(params) -> Dictionary:
	#Line       =    line	  	10 	20 	30	40
	#params (5) =    funcname 	x1	y1	x2	y2	
	var valid : bool = true
	var x1 : float = 0.0
	var y1 : float = 0.0
	var x2 : float = 0.0
	var y2 : float = 0.0
	var w : float = 1.0 #Optional
		
	#w is an additional param, so we check sizes 5 and 6.	
	if not (params.size() == 5 or params.size() == 6):
		valid = false
	else:
		x1 = float(params[1])
		y1 = float(params[2])
		x2 = float(params[3])
		y2 = float(params[4])

		if params.size() == 6:
			w = float(params[5])
				
	return {"valid" : valid, "x1" : x1, "y1" : y1, "x2" : x2, "y2" : y2, "w" : w}

		
static func _parse_text(line : String) -> Dictionary:
	#Line         =    text	  	10 	20 	" Some String "
	#params       =   funcname 	x1	y1	" string      "	
	var valid : bool = true
	var x : float = 0.0
	var y : float = 0.0
	var string : String = ""

	#Make sure we have just two quotes.
	var quotes_count = line.count("\"")
	if quotes_count == 2:
		var pos_of_first_quote = line.find("\"")
		#text	  	10 	20 	" Some String "
		#                   ^ pos_of_first_quote 
		#1 			2	3 = 3 parameters on the left.
		var left_string = line.left(pos_of_first_quote)
		left_string = left_string.rstrip(" ")

		var left_params = left_string.split(" ")
		if left_params.size() == 3:
			x = float(left_params[1])
			y = float(left_params[2])
			string = line.get_slice("\"", 1)
		else:	
			valid = false
	else:
		valid = false

	return {"valid" : valid, "x" : x, "y" : y, "string" : string}
		
	
