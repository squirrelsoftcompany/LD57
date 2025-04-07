extends Node

# moving
signal player_start_moving(start_position:Vector3, player_rotation : Vector3)
signal player_finish_moving(finish_position:Vector3, player_rotation : Vector3)
#archive
signal player_navigate_archive(idx: int, tp: Archive.TimePoint)
signal player_quit_navigating_archive(idx: int, tp: Archive.TimePoint)
#scanner
signal player_start_scanning(state: Archive.SonarState)
signal player_finish_scanning(state: Archive.SonarState)
#ask
@warning_ignore("unused_signal")
signal ask_sonar()
@warning_ignore("unused_signal")
signal ask_heatmap()
@warning_ignore("unused_signal")
signal ask_beacon()
@warning_ignore("unused_signal")
signal ask_move()
@warning_ignore("unused_signal")
signal ask_switch()
@warning_ignore("unused_signal")
signal ask_prev_entry()
@warning_ignore("unused_signal")
signal ask_next_entry()
@warning_ignore("unused_signal")
signal ask_present()
@warning_ignore("unused_signal")
signal ask_show_help()


var _moving := false
var _navigating_archive := false
var _scanning := false


func CanMove() -> bool: return !_moving and !_navigating_archive and !_scanning
func CanNavigate() -> bool: return !_moving and !_scanning
func CanScan() -> bool: return !_moving and !_navigating_archive and !_scanning


func _ready() -> void:
	connect("player_start_moving", func(_x, _y): _moving = true)
	connect("player_finish_moving", func(_x, _y): _moving = false)
	connect("player_navigate_archive", func(_x, _y): _navigating_archive = true)
	connect("player_quit_navigating_archive", func(_x, _y): _navigating_archive = false)
	connect("player_start_scanning", func(_x): _scanning = true)
	connect("player_finish_scanning", func(_x): _scanning = false)
