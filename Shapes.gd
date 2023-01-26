extends Control

var origin_x = 490
var origin_y = 20
var start_pos = Vector2(origin_x, origin_y)

var live = false
var should_update = false

onready var debug_line_parent = $StackDecomposeVbox/DebugLineStack
onready var program_node : TextEdit = $Program

var font = DynamicFont.new()

var code = [
	"circle 10 20 5"
]

func local_pos(from : Vector2):
	return from - start_pos

func global_pos(from : Vector2):
	return from + start_pos
	
func current_line():	
	return program_node.cursor_get_line()
		
func process_code():
	var codes = program_node.text
	var lines = codes.split("\n")
	
	code = []
	
	for line in lines:
		code.append(line)
		#print(line)
	
func _ready():
	font.font_data = load("res://Alaska.ttf")
	font.size = 28
	live = $HBoxContainer/Live.pressed
	$HBoxContainer/Generate.visible = not live
		
func _input(event):
	if Input.is_action_just_pressed("insert_mouse_position"):
		var l_pos = local_pos(get_global_mouse_position())
		var position_to_add = str(l_pos.x) + " " + str(l_pos.y) + " "
		program_node.insert_text_at_cursor(position_to_add)

func _process(delta):
	var m_pos = get_global_mouse_position()
	var l_pos = str(local_pos(m_pos))
#	$HBoxContainer/Label.text = str(m_pos) + " local pos: " + l_pos
	$HBoxContainer/Label.text = "local pos: " + l_pos
	
	if live or should_update:
		update()

func _parse_circle(params) -> Dictionary:
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
	
func _parse_rect(params) -> Dictionary:
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

func _parse_line(params) -> Dictionary:
	#Line       =    line	  	10 	20 	30	40
	#params (5) =    funcname 	x1	y1	x2	y2	
	var valid : bool = true
	var x1 : float = 0.0
	var y1 : float = 0.0
	var x2 : float = 0.0
	var y2 : float = 0.0
		
	if params.size() != 5:
		valid = false
	else:
		x1 = float(params[1])
		y1 = float(params[2])
		x2 = float(params[3])
		y2 = float(params[4])
				
	return {"valid" : valid, "x1" : x1, "y1" : y1, "x2" : x2, "y2" : y2}
	
func _draw():
	var c = 0
	var current_line = current_line()
	for line in code:
#		print(c)
		var params = line.split(" ") 
		var func_name = params[0]
		
		if func_name == "circle":
			var parsed_circle = _parse_circle(params)
			if parsed_circle.valid:
				var _x = parsed_circle.x
				var _y = parsed_circle.y
				var _rad = parsed_circle.rad
			
				var pos = global_pos(Vector2(_x, _y))
				draw_circle(pos, _rad, Color.red)
				
				if c == current_line:
					$StackDecomposeVbox/Label.text = "Circle: \n" + "x : " + str(_x) + "\n" + "y : " + str(_y) + "\n" + "radius : " + str(_rad)
		elif func_name == "rect":
			var parsed_rect = _parse_rect(params)
			if parsed_rect.valid:
				var _x = parsed_rect.x
				var _y = parsed_rect.y 
				var _w = parsed_rect.w 
				var _h = parsed_rect.h
				
				var pos = global_pos(Vector2(_x, _y))
				var size = Vector2(_w, _h)

				var color = Color.blue
				draw_rect(Rect2(pos, size), color)
		elif func_name == "line":
			var parsed_line = _parse_line(params)
			if parsed_line.valid:
				var _x1 = parsed_line.x1
				var _y1 = parsed_line.y1
				var _x2 = parsed_line.x2
				var _y2 = parsed_line.y2
				
				var line_start_pos = global_pos(Vector2(_x1, _y1))
				var line_end_pos = global_pos(Vector2(_x2, _y2))
				
				var color = Color.green
				draw_line(line_start_pos, line_end_pos, color)
		elif func_name == "text":
			if params.size() >= 3:
				var _x = float(params[1])
				var _y = float(params[2])
				var pos = global_pos(Vector2(_x, _y))
				
				#Make sure we have two " " to properly get the string.
				var quotes_count = line.count("\"")
				
				var _string = ""
				if params.size() > 3 and quotes_count == 2:
					#We need to get the string.
					_string = line.get_slice("\"", 1)
				
				draw_string(font, pos, _string)		
			
		c += 1		
		
	#Draw Grid and Gizmos.
	draw_circle(start_pos, 2, Color.red)
	draw_line(start_pos, Vector2(OS.get_window_size().x, start_pos.y), Color.red)
	draw_line(start_pos, Vector2(start_pos.x, OS.get_window_size().y), Color.green)
		
	should_update = false		

func _on_Generate_pressed():
	should_update = true
	process_code()

func _on_Live_toggled(button_pressed):
	live = button_pressed	
	$HBoxContainer/Generate.visible = not button_pressed

func _on_Program_text_changed():
	if live:
		process_code()

func update_initial_code(line_no, new_text):
#	code[0] = modified_line + "\n"
#	print(modified_line + "\n")
	should_update = true
	$Program.set_line(line_no, new_text)
	$Program.update()		

func get_parameters_of_circle(line):
	var params = line.split(" ")
	return params

func update_x(new_value):
	# get the first line directly.
	var line = code[current_line()]
	#Line  =     circle	  	10 	20 	5
	#params =    funcname 	x  	y   radius	
	var params = get_parameters_of_circle(line)
	
	var func_name = params[0]
	var x = new_value #float(params[1])
	var y = float(params[2])
	var rad = float(params[3])
	
	var modified_line = func_name + " " + str(x) + " " + str(y)+ " " + str(rad)
	update_initial_code(current_line(), modified_line)
	
func update_y(new_value):
	# get the first line directly.
	var line = code[current_line()]
	#Line  =     circle	  	10 	20 	5
	#params =    funcname 	x  	y   radius	
	var params = get_parameters_of_circle(line)
	
	var func_name = params[0]
	var x = float(params[1])
	var y = new_value #float(params[2])
	var rad = float(params[3])
	
	var modified_line = func_name + " " + str(x) + " " + str(y)+ " " + str(rad)
	update_initial_code(current_line(), modified_line)

func update_radius(new_value):
	# get the first line directly.
	var line = code[current_line()]
	#Line  =     circle	  	10 	20 	5
	#params =    funcname 	x  	y   radius	
	var params = get_parameters_of_circle(line)
	
	var func_name = params[0]
	var x = float(params[1])
	var y = float(params[2])
	var rad = new_value #float(params[3])
	
	var modified_line = func_name + " " + str(x) + " " + str(y)+ " " + str(rad)
	update_initial_code(current_line(), modified_line)
	
func add_debug_circle_hbox(x, y, rad):
	# Add all these buttons that manipulate the lines.
	var x_label = Label.new()
	x_label.text = "X : " 
	var x_spinbox = SpinBox.new()
	x_spinbox.allow_greater = true
	x_spinbox.allow_lesser = true
	x_spinbox.min_value = -INF
	x_spinbox.max_value = INF
	x_spinbox.value = x

	var y_label = Label.new()
	y_label.text = "Y : " 
	var y_spinbox = SpinBox.new()
	y_spinbox.allow_greater = true
	y_spinbox.allow_lesser = true
	y_spinbox.min_value = -INF
	y_spinbox.max_value = INF
	y_spinbox.value = y

	var radius_label = Label.new()
	radius_label.text = "Radius : " 
	var radius_spinbox = SpinBox.new()
	radius_spinbox.allow_greater = true
	radius_spinbox.allow_lesser = true
	radius_spinbox.min_value = -INF
	radius_spinbox.max_value = INF
	radius_spinbox.value = rad
	
	############################################
	############################################
					
	var ValueHBox = HBoxContainer.new()
	ValueHBox.add_child(x_label)
	ValueHBox.add_child(x_spinbox)
	ValueHBox.add_child(y_label)
	ValueHBox.add_child(y_spinbox)
	ValueHBox.add_child(radius_label)
	ValueHBox.add_child(radius_spinbox)
	debug_line_parent.add_child(ValueHBox)
					
	x_spinbox.connect("value_changed", self, "update_x")
	y_spinbox.connect("value_changed", self, "update_y")
	radius_spinbox.connect("value_changed", self, "update_radius")

func add_debug_line_hbox(x1, y1, x2, y2):
	# Add all these buttons that manipulate the lines.
	var x_label = Label.new()
	x_label.text = "X : " 
	var x_spinbox = SpinBox.new()
	x_spinbox.allow_greater = true
	x_spinbox.allow_lesser = true
	x_spinbox.min_value = -INF
	x_spinbox.max_value = INF
	x_spinbox.value = x1

	var y_label = Label.new()
	y_label.text = "Y : " 
	var y_spinbox = SpinBox.new()
	y_spinbox.allow_greater = true
	y_spinbox.allow_lesser = true
	y_spinbox.min_value = -INF
	y_spinbox.max_value = INF
	y_spinbox.value = y1

	
	############################################
	############################################
					
	var ValueHBox = HBoxContainer.new()
	ValueHBox.add_child(x_label)
	ValueHBox.add_child(x_spinbox)
	ValueHBox.add_child(y_label)
	ValueHBox.add_child(y_spinbox)
	debug_line_parent.add_child(ValueHBox)
					
#	x_spinbox.connect("value_changed", self, "update_x")
#	y_spinbox.connect("value_changed", self, "update_y")
#	radius_spinbox.connect("value_changed", self, "update_radius")
	
func delete_children(node):
	var children = node.get_children()
	for child in children:
		node.remove_child(child)
		
func _on_DebugLine_pressed():
	#Clear all childrens.
	delete_children(debug_line_parent)
	
	var c = 0
	var current_line = current_line()
	for line in code:
		if c != current_line:
			c += 1
			continue
			
		var params = line.split(" ") 
		var func_name = params[0]
		
		if func_name == "circle":
			var parsed_circle  = _parse_circle(params)
			if parsed_circle.valid:
				var _x = parsed_circle.x
				var _y = parsed_circle.y
				var _rad = parsed_circle.rad
				add_debug_circle_hbox(_x, _y, _rad)
		elif func_name == "line":
			var parsed_line = _parse_line(params)
			if parsed_line.valid:
				var _x1 = parsed_line.x1
				var _y1 = parsed_line.y1
				var _x2 = parsed_line.x2
				var _y2 = parsed_line.y2
				add_debug_line_hbox(_x1, _y1, _x2, _y2)
		break		
