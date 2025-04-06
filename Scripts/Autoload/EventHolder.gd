extends Node

# moving
signal player_start_moving(start_position:Vector3, player_rotation : Vector3)
signal player_finish_moving(finish_position:Vector3, player_rotation : Vector3)
@warning_ignore("unused_signal")
signal player_moving(current_position:Vector3, player_rotation : Vector3)
#archive
signal player_navigate_archive(idx: int, tp: Archive.TimePoint)
signal player_quit_navigating_archive(idx: int, tp: Archive.TimePoint)


var _moving := false
var _navigating_archive := false


func _ready() -> void:
	connect("player_start_moving", func(_x, _y): _moving = true)
	connect("player_finish_moving", func(_x, _y): _moving = false)
	connect("player_navigate_archive", func(_x, _y): _navigating_archive = true)
	connect("player_quit_navigating_archive", func(_x, _y): _navigating_archive = false)
