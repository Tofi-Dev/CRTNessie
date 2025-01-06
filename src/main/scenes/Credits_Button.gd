extends Button

@export var credits_node : Panel

func _ready():
	connect("pressed", Callable(credits_node, "show"))