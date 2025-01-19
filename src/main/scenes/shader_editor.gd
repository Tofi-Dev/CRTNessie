extends Panel

@onready var color_rect = get_node("%ColorRect")
@onready var vbox_container = $ScrollContainer/MarginContainer/VBoxContainer

@export var property_silder : PackedScene
@export var property_vector2 : PackedScene

@onready var save_button = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/SavePreset
@onready var load_button = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/LoadPreset
@onready var save_preset_dialogue = get_node("%SavePreset")
@onready var load_preset_dialogue = get_node("%LoadPreset")
@onready var load_user_shader_folder = get_node("%LoadUserShaderFolder")

@onready var shader_selector = get_node("%ShaderSelector")

var uniform_cache = {}

var shader_cache = {}


func _ready():
	list_shader_properties()

	save_button.connect("pressed", Callable(self, "_save_preset_dialogue"))
	load_button.connect("pressed", Callable(self, "_load_preset_dialogue"))
	save_preset_dialogue.connect("file_selected", Callable(self, "_on_file_selected"))
	load_preset_dialogue.connect("file_selected", Callable(self, "_load_preset"))

	load_user_shader_folder.connect("pressed", Callable(self, "_load_user_shader_folder_in_file_manager"))

	shader_selector.connect("item_selected", Callable(self, "load_new_shader"))

func list_shader_properties():
	print(color_rect.material.shader.get_shader_uniform_list())
	for i in color_rect.material.shader.get_shader_uniform_list():
		#print(string_splitter(i.hint_string))
		if i.type == 5:
			var vector2 = property_vector2.instantiate()
			vector2.get_node("HBoxContainer/Label").text = prettyify_names(i.name)
			vector2.property = i.name
			vector2.get_node("HBoxContainer/X").value = color_rect.material.get_shader_parameter(i.name)[0]
			vector2.get_node("HBoxContainer/Y").value = color_rect.material.get_shader_parameter(i.name)[1]

			#vector2.get_node("HBoxContainer/HSlider").value = color_rect.material.get_shader_parameter(i.name)
			vbox_container.add_child(vector2)
		if i.type == 3:
			var silder = property_silder.instantiate()
			silder.get_node("HBoxContainer/Label").text = prettyify_names(i.name)

			print(color_rect.material.get_shader_parameter(i.name))
			if color_rect.material.get_shader_parameter(i.name) != null:
				silder.get_node("HBoxContainer/HSlider").value = color_rect.material.get_shader_parameter(i.name)
			else:
				print("It's null, setting to 1")
				silder.get_node("HBoxContainer/HSlider").value = 1
			silder.get_node("HBoxContainer/HSlider").min_value = float(string_splitter(i.hint_string)[0])
			silder.get_node("HBoxContainer/HSlider").max_value = float(string_splitter(i.hint_string)[1])
			silder.property = i.name
			vbox_container.add_child(silder)

			uniform_cache[i.name] = i
		else:
			print("Ignoring.")

	#print("Cached:" + str(uniform_cache))

func deload_shader_properties():
	for i in vbox_container.get_children():
		if i is PropertyEdit:
			vbox_container.remove_child(i)
		if i is PropertyVector2:
			vbox_container.remove_child(i)

func load_new_shader(index : int) -> void:
	deload_shader_properties()
	uniform_cache = {}
	color_rect.material.shader = shader_cache[shader_selector.get_item_text(index)]
	list_shader_properties()

func load_new_shader_from_path(path : String) -> void:
	deload_shader_properties()
	uniform_cache = {}
	color_rect.material.shader = load(path)

func _load_user_shader_folder_in_file_manager() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://shaders/"))
	

func load_uniform(key):
	color_rect.material.set_shader_parameter(key, uniform_cache[key])
	for i in vbox_container.get_children():
		if i is PropertyEdit:
			if i.property == key:
				i.get_node("HBoxContainer/HSlider").value = uniform_cache[key]
		if i is PropertyVector2:
			if i.property == key:
				i.get_node("HBoxContainer/X").value = uniform_cache[key][0]
				i.get_node("HBoxContainer/Y").value = uniform_cache[key][1]

func string_splitter(string : String):
	return string.split(",", false)

func prettyify_names(string : String):
	var temp : String = string
	temp = temp.replace("_", " ")
	return temp[0].to_upper() + temp.substr(1)

func _save_preset_dialogue():
	save_preset_dialogue.popup_centered()

func _load_preset_dialogue():
	load_preset_dialogue.popup_centered()

func _on_file_selected(path : String) -> void:
	get_owner().save_uniform_cache(path)

func _load_preset(path : String) -> void:
	deload_shader_properties()
	var config_file = ConfigFile.new()
	var id_to_load = 0
	config_file.load(path)

	for i in shader_cache:
		if shader_cache[i].resource_path == config_file.get_value("shader", "shader"):
			print("Found shader: " + i)
			id_to_load = shader_selector.get_item_index(id_to_load)
			break
		id_to_load += 1

	color_rect.material.shader = shader_cache[shader_selector.get_item_text(id_to_load)]

	list_shader_properties()
	
	for i in config_file.get_section_keys("uniforms"):
		reconstruct_uniform_cache(path)
		load_uniform(i)
#func _notification(what: int) -> void:
	#print("unused.")
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#print("Saving uniform cache...")
		#get_owner().save_uniform_cache()

func reconstruct_uniform_cache(path) -> void:

	var config_file = ConfigFile.new()
	config_file.load(path)

	for i in config_file.get_section_keys("uniforms"):
		uniform_cache[i] = config_file.get_value("uniforms", i)

func scan_for_shaders():
	var bulit_in_shader_folder = "res://src/main/shaders/bulitin"
	var custom_shaders_folder = "user://shaders"
	var shader_id = 0

	for i in DirAccess.get_files_at(bulit_in_shader_folder):
		print(i)
		shader_selector.add_item(i)
		shader_cache[i] = load(bulit_in_shader_folder + "/" + i)


	for i in DirAccess.get_files_at(custom_shaders_folder):
		print(i)
		shader_selector.add_item(i)
		shader_cache[i] = load(custom_shaders_folder + "/" + i)

	print("Loaded " + str(shader_id) + " Shaders.")

	print(shader_cache)
