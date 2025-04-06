extends Node3D


@export var speed := 10.0 # m/s
@export var angular_speed := 20 # deg/s


@onready var _moving_interaction : MovingInteraction = $MovingInteraction


var _selecting_movement := false


func _ready() -> void:
	GlobalArchive.add_timepoint(position)
	pass


func _input(event: InputEvent) -> void:
	if GlobalEventHolder._moving:
		return

	if event is InputEventKey:
		if event.is_action_pressed("mi_toggle", false, true):
			_toggle_selecting_movement()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and _selecting_movement:
			_finish_selecting_movement()
			_move_player(_moving_interaction._candidate_position)


func _move_player(final_position : Vector3) -> void:
	GlobalEventHolder.emit_signal("player_start_moving", position)
	var duration := position.distance_to(final_position) / speed
	var angular_duration := position.distance_to(final_position) / angular_speed
	var forward := (final_position-position).normalized()
	var left := Vector3.UP.cross(forward).normalized()
	var up := forward.cross(left).normalized()
	var final_quaternion := Quaternion(Basis(left,up,forward))
	var tween := get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", final_position, duration)
	tween.tween_method(func(x): GlobalEventHolder.emit_signal("player_moving", x),
							position, final_position, duration)
	tween.tween_property($Submarine, "quaternion", final_quaternion, angular_duration)
	tween.chain().tween_callback(func (): GlobalEventHolder.emit_signal("player_finish_moving", final_position))


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
