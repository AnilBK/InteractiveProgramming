extends Control

var origin_x = 490
var origin_y = 20
var start_pos = Vector2(origin_x, origin_y)

var live = false
var should_update = false

var currently_debugged_line = -1

onready var debug_line_parent = $StackDecomposeVbox/DebugLineStack
onready var program_node : TextEdit = $Program
const Parser = preload("Parser.gd")

var font = DynamicFont.new()

var built_in_types = [
{
	"name" : "circle",
	"x" : 1,
	"y" : 2,
	"rad" : 3,
	"color[OPTIONAL]" : 4
},
{
	"name" : "rect",
	"x" : 1,
	"y" : 2,
	"w" : 3,
	"h" : 4
},
{
	"name" : "line",
	"x1" : 1,
	"y1" : 2,
	"x2" : 3,
	"y2" : 4
},
{
	"name" : "text",
	"x" : 1,
	"y" : 2
}
]

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

func replace_nth_word(string : String, index, new_value):
	var strings_splitted = string.split(" ")
	strings_splitted[index] = str(new_value)
	var final_str = String(" ").join(strings_splitted)
	return final_str

func add_syntax_highlighting():
	program_node.syntax_highlighting = true

	#Register built in keywords.
	for type in built_in_types:
		var keyword = type.name
		program_node.add_keyword_color(keyword, Color("ff7085"))

	#Strings.	
	program_node.add_color_region("\"", "\"", Color("ffeca1"))
	#Comments.
	program_node.add_color_region("#", "", Color("80c1cdd0"), true)

func _ready():
	font.font_data = load("res://Alaska.ttf")
	font.size = 28
	live = $HBoxContainer/Live.pressed
	$HBoxContainer/Generate.visible = not live

	var str1 = "circle 10 20 40 Color(10,20,255)"
	print(Parser.parse_color(str1))
	
	_on_Program_text_changed()

	add_syntax_highlighting()

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

	var curr_line = current_line()
	if curr_line != currently_debugged_line:
		# That means line numbers have changed.
		# If we were debugging another line, then remove those debug symbols.
		delete_children(debug_line_parent)
		currently_debugged_line = curr_line
	
	if live or should_update:
		update()

func _draw():
	for line in code:
#		print(c)
		line = line.strip_edges()

		# Comment line.
		if line.begins_with("#"):
			continue

		var params = Parser.parse_line(line)
		var func_name = params[0]
		
		if func_name == "circle":
			var parsed_circle = Parser._parse_circle(params)
			if parsed_circle.valid:
				var _x = parsed_circle.x
				var _y = parsed_circle.y
				var _rad = parsed_circle.rad
				var _col = parsed_circle.color
			
				var pos = global_pos(Vector2(_x, _y))
				draw_circle(pos, _rad, _col)
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
				var _w = parsed_line.w
				
				var line_start_pos = global_pos(Vector2(_x1, _y1))
				var line_end_pos = global_pos(Vector2(_x2, _y2))
				
				var color = Color.green

				"""
				if _w == 1.0f:
					#We have some width.
					draw_line(line_start_pos, line_end_pos, color)
				else:
					draw_line(line_star
					draw_line(line_start_pos, line_end_pos, color, _w)
				"""		
				#We can do the thing above but remove the extra if i guess.
				draw_line(line_start_pos, line_end_pos, color, _w)
		elif func_name == "text":
			var parsed_text = Parser._parse_text(line)
			if parsed_text.valid:
				var _x = parsed_text.x
				var _y = parsed_text.y 
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


func update_param(param_to_modify, new_value):
	#As of now, we directly access the current line,
	#so we don't need to pass the line no.
	var line = code[current_line()].strip_edges()
	#Line  =     circle	  	10 	20 	5
	#params =    funcname 	x  	y   radius	
	var params = Parser.parse_line(line)

	var func_name = params[0]

	for shape in built_in_types:
		if func_name == shape.name:
			if true or params.size() == shape.size():#Maybe not this check required ??
				if param_to_modify in shape.keys():	
					# circle x y rad
					#	"x" : 1 -> From built_in_types.
					# Means we have to replace the 1th word after a space, whenever we have to modify the "x" value.
					var index = shape.get(param_to_modify)
					var modified_line = replace_nth_word(line, index, new_value)
					update_initial_code(current_line(), modified_line)
					return

##############################################################
##############################################################
##############################################################

func add_number_debug(parent, num_label, num_value, value_changed_signal_target : String):
	var label = Label.new()
	label.text = num_label # "X :" 
	
	var spinbox = SpinBox.new()
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.min_value = -INF
	spinbox.max_value = INF
	spinbox.value = num_value # x

	parent.add_child(label)
	parent.add_child(spinbox)

	spinbox.connect("value_changed", self, value_changed_signal_target)

##############################################################
##############################################################
##############################################################

func circle_update_x(new_value):
	update_param("x", new_value)
	
func circle_update_y(new_value):
	update_param("y", new_value)

func circle_update_radius(new_value):
	update_param("rad", new_value)
	
func add_debug_circle_hbox(x, y, rad):
	# Add all these buttons that manipulate the circles.
	var ValueHBox = HBoxContainer.new()
	add_number_debug(ValueHBox, "X : ", x, "circle_update_x")
	add_number_debug(ValueHBox, "Y : ", y, "circle_update_y")
	add_number_debug(ValueHBox, "Radius : ", rad, "circle_update_radius")

	debug_line_parent.add_child(ValueHBox)
					
##############################################################
##############################################################
##############################################################

func rect_update_x(new_value):
	update_param("x", new_value)
		
func rect_update_y(new_value):
	update_param("y", new_value)
	
func rect_update_w(new_value):
	update_param("w", new_value)
		
func rect_update_h(new_value):
	update_param("h", new_value)

func add_debug_rect_hbox(x, y, w, h):
	var ValueHBox = HBoxContainer.new()
	add_number_debug(ValueHBox, "X : ", x, "rect_update_x")
	add_number_debug(ValueHBox, "Y : ", y, "rect_update_y")
	add_number_debug(ValueHBox, "W : ", w, "rect_update_w")
	add_number_debug(ValueHBox, "H : ", h, "rect_update_h")

	debug_line_parent.add_child(ValueHBox)

##############################################################
##############################################################
##############################################################

func line_update_x1(new_value):
	update_param("x1", new_value)

func line_update_y1(new_value):
	update_param("y1", new_value)

func line_update_x2(new_value):
	update_param("x2", new_value)

func line_update_y2(new_value):
	update_param("y2", new_value)

func add_debug_line_hbox(x1, y1, x2, y2):
	var ValueHBox = HBoxContainer.new()
	add_number_debug(ValueHBox, "X1 : ", x1, "line_update_x1")
	add_number_debug(ValueHBox, "Y1 : ", y1, "line_update_y1")
	add_number_debug(ValueHBox, "X2 : ", x2, "line_update_x2")
	add_number_debug(ValueHBox, "Y2 : ", y2, "line_update_y2")

	debug_line_parent.add_child(ValueHBox)

##############################################################
##############################################################
##############################################################

func text_update_x(new_value):
	update_param("x", new_value)
	
func text_update_y(new_value):
	update_param("y", new_value)

func add_debug_text_hbox(x, y):
	var ValueHBox = HBoxContainer.new()
	add_number_debug(ValueHBox, "X : ", x, "text_update_x")
	add_number_debug(ValueHBox, "Y : ", y, "text_update_y")

	debug_line_parent.add_child(ValueHBox)

##############################################################
##############################################################
##############################################################

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
			
		line = line.strip_edges()

		var params = Parser.parse_line(line)
		var func_name = params[0]
		
		if func_name == "circle":
			var circle = Parser._parse_circle(params)
			if circle.valid:
				add_debug_circle_hbox(circle.x, circle.y, circle.rad)
		elif func_name == "rect":
			var _rect = Parser._parse_rect(params)
			if  _rect.valid:
				add_debug_rect_hbox(_rect.x, _rect.y, _rect.w, _rect.h)
		elif func_name == "line":
			var _line = Parser._parse_line(params)
			if  _line.valid:
				add_debug_line_hbox(_line.x1, _line.y1, _line.x2, _line.y2)#, _line.w)
		elif func_name == "text":
			var _text = Parser._parse_text(line)
			if  _text.valid:
				add_debug_text_hbox(_text.x, _text.y)
		break		
