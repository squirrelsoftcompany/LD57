extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalEventHolder.ask_show_help.connect(func (): visible = !visible)
