extends HBoxContainer

func _ready():
	update_result()

func update_result():
	var x = $"../Equations/VBoxContainer/HBoxContainer2/X".value
	var y = $"../Equations/VBoxContainer/HBoxContainer2/Y".value

	var result = ( 2 * x ) + y
	
	$"../Equations/VBoxContainer/HBoxContainer/ResultLabel".text = str(result)
	var label = get_node("../Equations/VBoxContainer/EqnDecompose/Label")
	
	var line_1 = "2X + Y"
	var line_2 = "2(" + str(x) + ") + " + str(y)
	var line_3 = str(2 *x) + " + " + str(y)
	var line_4 = str(result)
	
	label.text = line_1 + "\n" + line_2 + "\n" + line_3 + "\n" + line_4 + "\n"
	

func _on_X_value_changed(value: float) -> void:
	update_result()

func _on_Y_value_changed(value: float) -> void:
	update_result()
