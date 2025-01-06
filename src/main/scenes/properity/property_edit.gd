extends Panel

@onready var property_silder = $HBoxContainer/HSlider

var property = null
@onready var property_amount_label = $HBoxContainer/PropertyLabel
@onready var color_rect = get_tree().get_first_node_in_group("image")

func _ready():
	property_amount_label.text = str(property_silder.value)

func _HValue_Changed(value: float) -> void:
	color_rect.material.set_shader_parameter(property, value)
	property_amount_label.text = str(value)