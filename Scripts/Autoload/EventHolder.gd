extends Node

signal player_start_moving(start_position:Vector3)
signal player_finish_moving(finish_position:Vector3)
@warning_ignore("unused_signal")
signal player_moving(current_position:Vector3)


var _moving := false


func _ready() -> void:
	connect("player_start_moving", func(_x): _moving = true)
	connect("player_finish_moving", func(_x): _moving = false)
