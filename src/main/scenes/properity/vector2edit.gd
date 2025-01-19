extends Panel
class_name PropertyVector2

@onready var property_x = $HBoxContainer/X
@onready var property_y = $HBoxContainer/Y

var property = null
@onready var property_amount_label = $HBoxContainer/PropertyLabel
@onready var color_rect = get_tree().get_first_node_in_group("image")

func _ready():
	print("Ready")


func _on_y_value_changed(value:float) -> void:
	color_rect.material.set_shader_parameter(property, Vector2(property_x.value, property_y.value))

func _on_x_value_changed(value:float) -> void:
	color_rect.material.set_shader_parameter(property, Vector2(property_x.value, property_y.value))
