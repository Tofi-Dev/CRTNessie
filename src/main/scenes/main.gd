extends Control


# Saving and loading buttons.
@onready var select_image_button = get_node("%SelectIMG")
@onready var save_image_button = get_node("%SaveIMG")
@onready var loadfile = $LoadFile
@onready var savefile = $SaveFile
@onready var close_current = get_node("%CloseFile")

# Image and the scaling nodes.
@onready var color_rect = get_node("%ColorRect")
@onready var subviewport = get_node("%SubViewport")
@onready var image_scale = get_node("%Scale")

@onready var logo = get_node("%StartingContainer")
@onready var image = $Image

@onready var theme_picker = get_node("%ThemePicker")
@onready var grid = get_node("Grid")

@export var logo_textures : Array[Texture2D]
@export var grid_textures : Array[Texture2D]

#Shader Editor
@onready var shader_editor = get_node("%ShaderEditor")
@onready var shader_editor_button = get_node("%ShaderEditorButton")

var aspect_ratio = 1

var allowed = ["*.png", "*.jpg", "*.jpeg", "*.bmp"]

var file_loaded = false

# Settings
var theme_id = 0

func _ready():
	# Load Settings
	load_settings()
	load_uniform_cache()

	# Allowed Format List
	loadfile.set_filters(PackedStringArray(allowed))
	savefile.set_filters(PackedStringArray(allowed))
	select_image_button.connect("pressed", Callable(self, "_on_select_image_button_pressed"))
	save_image_button.connect("pressed", Callable(self, "_on_save_image_button_pressed"))
	shader_editor_button.connect("pressed", Callable(self, "_on_shader_editor_button_pressed"))
	close_current.connect("pressed", Callable(self, "unload_image"))

	loadfile.connect("file_selected", Callable(self, "_on_file_selected"))
	savefile.connect("file_selected", Callable(self, "_on_file_saved"))
	


func _on_file_selected(path):
	load_image(path)

func _on_file_saved(path):
	var subviewport_image = subviewport.get_texture().get_image()
	subviewport_image.save_png(path)
	print("Saved image to: " + path)

func _on_select_image_button_pressed():
	loadfile.popup_centered()

func _on_save_image_button_pressed():
	savefile.popup_centered()
	

func load_image(path):
	file_loaded = true

	var texture = Image.new()
	texture.load(path)
	var texture_final = ImageTexture.create_from_image(texture)
	
	color_rect.visible = true
	color_rect.size = texture.get_size()
	color_rect.material.set_shader_parameter("resolution", Vector2(texture.get_width(), texture.get_height()))
	color_rect.material.set_shader_parameter("SCREEN_TEXTURE", texture_final)
	
	update_size(image_scale.value)

func unload_image():
	color_rect.visible = false
	file_loaded = false

func _Scale_Changed(value: float) -> void:
	update_size(value)

func update_size(value):
	var viewport_size = get_viewport_rect().size
	
	color_rect.scale = Vector2(value, value) * Vector2(aspect_ratio, 1)
	#color_rect.position = (viewport_size / 2 - color_rect.size * color_rect.scale / 2)
	color_rect.position = Vector2.ZERO
	subviewport.size = color_rect.size * color_rect.scale
	subviewport.get_parent().size = (color_rect.size * color_rect.scale)
	subviewport.get_parent().position = (viewport_size / 2 - color_rect.size * color_rect.scale / 2)

func _aspect_ratio(value: float) -> void:
	aspect_ratio = value
	update_size(image_scale.value)

func _process(delta: float) -> void:
	if file_loaded:
		logo.visible = false
		save_image_button.disabled = false
		close_current.disabled = false
		shader_editor_button.disabled = false
		
	else:
		save_image_button.disabled = true
		logo.visible = true
		close_current.disabled = true
		shader_editor_button.disabled = true

func _Theme_Changed(index:int) -> void:
	change_theme(index)
	theme_id = index
	save_settings()

func _on_shader_editor_button_pressed():
	shader_editor.visible = !shader_editor.visible

func change_theme(index:int) -> void:
	logo.get_child(0).texture = logo_textures[index]
	grid.texture = grid_textures[index]
	match index:
		0:
			theme = load("res://src/main/themes/default.tres")
		1:
			theme = load("res://src/main/themes/hd.tres")
		2:
			theme = load("res://src/main/themes/95.tres")

func save_settings():
	var config = ConfigFile.new()
	print("Saving...")
	config.set_value("settings", "theme", theme_id)
	config.save("user://settings.cfg")


func load_settings():
	var config = ConfigFile.new()
	if not config.load("user://settings.cfg") == OK:
		print("Invaild Save")

		theme_id = 0
		theme_picker.select(theme_id)
		change_theme(theme_id)
		return

	theme_id = config.get_value("settings", "theme", 0)
	theme_picker.select(theme_id)

	change_theme(theme_id)

func save_uniform_cache():
	var uniform_cache = ConfigFile.new()
	for i in shader_editor.uniform_cache:
		uniform_cache.set_value("uniforms", i, color_rect.material.get_shader_parameter(i))
		print("Saving uniform: " + i)
	uniform_cache.save("user://uniform_cache_" + str(color_rect.material.shader.get_rid()) + ".cfg")

func load_uniform_cache():
	var uniform_cache = ConfigFile.new()
	if not uniform_cache.load("user://uniform_cache_" + str(color_rect.material.shader.get_rid()) + ".cfg") == OK:
		print("Invaild cache file")
		return

	for i in uniform_cache.get_section_keys("uniforms"):
		shader_editor.uniform_cache[i] = uniform_cache.get_value("uniforms", i)

	for i in shader_editor.uniform_cache:
		shader_editor.load_uniform(i)