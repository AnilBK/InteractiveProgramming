extends Control

var origin_x = 490
var origin_y = 20
var start_pos = Vector2(origin_x, origin_y)

var live = false
var should_update = false

onready var debug_line_parent = $StackDecomposeVbox/DebugLineStack
onready var program_node : TextEdit = $Program
const Parser = preload("Parser.gd")

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
		
func _input(_event):
	if Input.is_action_just_pressed("insert_mouse_position"):
		var l_pos = local_pos(get_global_mouse_position())
		var position_to_add = str(l_pos.x) + " " + str(l_pos.y) + " "
		program_node.insert_text_at_cursor(position_to_add)

func _process(_delta):
	var m_pos = get_global_mouse_position()
	var l_pos = str(local_pos(m_pos))
#	$HBoxContainer/Label.text = str(m_pos) + " local pos: " + l_pos
	$HBoxContainer/Label.text = "local pos: " + l_pos
	
	if live or should_update:
		update()

func _draw():
	for line in code:
#		print(c)
		var params = line.split(" ") 
		var func_name = params[0]
		
		if func_name == "circle":
			var parsed_circle = Parser._parse_circle(params)
			if parsed_circle.valid:
				var _x = parsed_circle.x
				var _y = parsed_circle.y
				var _rad = parsed_circle.rad
			
				var pos = global_pos(Vector2(_x, _y))
				draw_circle(pos, _rad, Color.red)
		elif func_name == "rect":
			var parsed_rect = Parser._parse_rect(params)
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
			var parsed_line = Parser._parse_line(params)
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
			var parsed_text = Parser._parse_text(line)
			if parsed_text.valid:
				var _x = parsed_text.x1
				var _y = parsed_text.y1 
				var _string = parsed_text.string

				var pos = global_pos(Vector2(_x, _y))
				draw_string(font, pos, _string)		
			
		
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

func get_parameters(line):
	var params = line.split(" ")
	return params

func update_circle(new_value, item_name):
	# get the first line directly.
	var line = code[current_line()]
	#Line  =     circle	  	10 	20 	5
	#params =    funcname 	x  	y   radius	
	var params = get_parameters(line)

	if params.size() < 4:
		return
	
	var func_name = params[0]
	var x = params[1]
	var y = params[2]
	var rad = params[3]

	if func_name != "circle":
		return	

	if item_name == "x":
		x = new_value
	elif item_name == "y":
		y = new_value
	elif item_name == "rad":
		rad = new_value

	var modified_line = func_name + " " + str(x) + " " + str(y)+ " " + str(rad)
	update_initial_code(current_line(), modified_line)	

func update_x(new_value):
	update_circle(new_value, "x")
	
func update_y(new_value):
	update_circle(new_value, "y")

func update_radius(new_value):
	update_circle(new_value, "rad")
	
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

func update_line(new_value, item_name):
	# get the first line directly.
	var line = code[current_line()]
	#Line  =     line	  	10 	20 	50	60
	#params =    funcname 	x1 	y1  x2	y2	
	var params = get_parameters(line)

	if params.size() < 5:
		return
	
	var func_name = params[0]
	var x1 = params[1]
	var y1 = params[2]
	var x2 = params[3]
	var y2 = params[4]

	if func_name != "line":
		return	

	if item_name == "x1":
		x1 = new_value
	elif item_name == "y1":
		y1 = new_value
	elif item_name == "x2":
		x2 = new_value
	elif item_name == "y2":
		y2 = new_value

	var modified_line = func_name + " " + str(x1) + " " + str(y1)+ " " + str(x2) + " " + str(y2)
	update_initial_code(current_line(), modified_line)	

func update_x1(new_value):
	update_line(new_value, "x1")

func update_y1(new_value):
	update_line(new_value, "y1")

func update_x2(new_value):
	update_line(new_value, "x2")

func update_y2(new_value):
	update_line(new_value, "y2")
	
func add_debug_line_hbox(x1, y1, x2, y2):
	# Add all these buttons that manipulate the lines.
	var x1_label = Label.new()
	x1_label.text = "X1 : " 
	var x1_spinbox = SpinBox.new()
	x1_spinbox.allow_greater = true
	x1_spinbox.allow_lesser = true
	x1_spinbox.min_value = -INF
	x1_spinbox.max_value = INF
	x1_spinbox.value = x1

	var y1_label = Label.new()
	y1_label.text = "Y1 : " 
	var y1_spinbox = SpinBox.new()
	y1_spinbox.allow_greater = true
	y1_spinbox.allow_lesser = true
	y1_spinbox.min_value = -INF
	y1_spinbox.max_value = INF
	y1_spinbox.value = y1

	var x2_label = Label.new()
	x2_label.text = "X2 : " 
	var x2_spinbox = SpinBox.new()
	x2_spinbox.allow_greater = true
	x2_spinbox.allow_lesser = true
	x2_spinbox.min_value = -INF
	x2_spinbox.max_value = INF
	x2_spinbox.value = x2

	var y2_label = Label.new()
	y2_label.text = "Y2 : " 
	var y2_spinbox = SpinBox.new()
	y2_spinbox.allow_greater = true
	y2_spinbox.allow_lesser = true
	y2_spinbox.min_value = -INF
	y2_spinbox.max_value = INF
	y2_spinbox.value = y2

	############################################
	############################################
					
	var ValueHBox = HBoxContainer.new()
	ValueHBox.add_child(x1_label)
	ValueHBox.add_child(x1_spinbox)
	ValueHBox.add_child(y1_label)
	ValueHBox.add_child(y1_spinbox)
	ValueHBox.add_child(x2_label)
	ValueHBox.add_child(x2_spinbox)
	ValueHBox.add_child(y2_label)
	ValueHBox.add_child(y2_spinbox)
	debug_line_parent.add_child(ValueHBox)
					
	x1_spinbox.connect("value_changed", self, "update_x1")
	y1_spinbox.connect("value_changed", self, "update_y1")
	x2_spinbox.connect("value_changed", self, "update_x2")
	y2_spinbox.connect("value_changed", self, "update_y2")
	
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
			var circle = Parser._parse_circle(params)
			if circle.valid:
				add_debug_circle_hbox(circle.x, circle.y, circle.rad)
		elif func_name == "line":
			var _line = Parser._parse_line(params)
			if  _line.valid:
				add_debug_line_hbox(_line.x1, _line.y1, _line.x2, _line.y2)
		break		
