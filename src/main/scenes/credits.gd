extends Panel

@onready var ok_button = get_node("OKBtn")
@onready var quit_buttom = get_node("QuitBtn")

func _ready():
	ok_button.connect("pressed", Callable(self, "hide"))
	quit_buttom.connect("pressed", Callable(self, "hide"))
