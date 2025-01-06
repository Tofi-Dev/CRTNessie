extends Panel

@onready var color_rect = get_node("%ColorRect")
@onready var vbox_container = $ScrollContainer/VBoxContainer

@export var property_silder : PackedScene


func _ready():
	list_shader_properties()


func list_shader_properties():
	print(color_rect.material.shader.get_shader_uniform_list())
	for i in color_rect.material.shader.get_shader_uniform_list():
		print(string_splitter(i.hint_string))

		if i.type == 3:
			var silder = property_silder.instantiate()
			silder.get_node("HBoxContainer/Label").text = prettyify_names(i.name)
			silder.get_node("HBoxContainer/HSlider").value = color_rect.material.get_shader_parameter(i.name)
			silder.get_node("HBoxContainer/HSlider").min_value = float(string_splitter(i.hint_string)[0])
			silder.get_node("HBoxContainer/HSlider").max_value = float(string_splitter(i.hint_string)[1])
			silder.property = i.name
			vbox_container.add_child(silder)
		else:
			print("Ignoring.")

func string_splitter(string : String):
	return string.split(",", false)

func prettyify_names(string : String):
	var temp : String = string
	temp = temp.replace("_", " ")
	return temp[0].to_upper() + temp.substr(1)