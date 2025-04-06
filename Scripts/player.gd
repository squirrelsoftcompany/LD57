extends Node3D


@onready var _moving_interaction : MovingInteraction = $MovingInteraction


var _selecting_movement := false


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("mi_toggle", false, true):
			_toggle_selecting_movement()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and _selecting_movement:
			_finish_selecting_movement()
			#_moving_interaction._candidate_position


func _process(_delta: float) -> void:
	pass


func _toggle_selecting_movement() -> void:
	if _selecting_movement:
		_finish_selecting_movement()
	else:
		_start_selecting_movement()


func _start_selecting_movement() -> void:
	_moving_interaction.visible = true
	_selecting_movement = true


func _finish_selecting_movement() -> void:
	_moving_interaction.visible = false
	_selecting_movement = false
