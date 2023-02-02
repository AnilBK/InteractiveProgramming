extends Node

static func _parse_circle(params) -> Dictionary:
	#Line       =    circle	  	10 	20 	5
	#params (4) =    funcname 	x  	y   radius	
	var valid : bool = true
	var x : float = 0.0
	var y : float = 0.0
	var rad : float = 0.0
		
	if params.size() != 4:
		valid = false
	else:
		x = float(params[1])
		y = float(params[2])
		rad = float(params[3])
				
	return {"valid" : valid, "x" : x, "y" : y, "rad" : rad}

	
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
	var x1 : float = 0.0
	var y1 : float = 0.0
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
			x1 = float(left_params[1])
			y1 = float(left_params[2])
			string = line.get_slice("\"", 1)
		else:	
			valid = false
	else:
		valid = false

	return {"valid" : valid, "x1" : x1, "y1" : y1, "string" : string}
		
	
