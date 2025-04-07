extends Node

# moving
@warning_ignore("unused_signal")
signal player_start_mi()
@warning_ignore("unused_signal")
signal player_finish_mi()
signal player_start_moving(start_position:Vector3, player_rotation : Vector3)
signal player_finish_moving(finish_position:Vector3, player_rotation : Vector3)
#archive
signal player_navigate_archive(idx: int, tp: Archive.TimePoint)
signal player_quit_navigating_archive(idx: int, tp: Archive.TimePoint)
#scanner
signal player_start_scanning(state: Archive.SonarState)
signal player_finish_scanning(state: Archive.SonarState)
#heatmap
signal player_start_heatmap(state: Archive.MagnetState)
signal player_finish_heatmap(state: Archive.MagnetState)
#ask
@warning_ignore("unused_signal")
signal ask_sonar()
@warning_ignore("unused_signal")
signal ask_heatmap()
@warning_ignore("unused_signal")
signal ask_beacon_start()
@warning_ignore("unused_signal")
signal ask_beacon_finish()
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
@warning_ignore("unused_signal")
signal mine_state_changed()
@warning_ignore("unused_signal")
signal energy_state_changed()


var _moving := false
var _navigating_archive := false
var _scanning := false
var _asking_beacon := false
var _heatmap := false


func CanMove() -> bool: return !_moving and !_navigating_archive and !_scanning and !_asking_beacon
func CanNavigate() -> bool: return !_moving and !_scanning and !_asking_beacon
func CanScan() -> bool: return !_moving and !_navigating_archive and !_scanning and !_asking_beacon
func CanBeacon() -> bool: return !_moving and !_navigating_archive and !_scanning


func _ready() -> void:
	connect("player_start_moving", func(_x, _y): _moving = true)
	connect("player_finish_moving", func(_x, _y): _moving = false)
	connect("player_navigate_archive", func(_x, _y): _navigating_archive = true)
	connect("player_quit_navigating_archive", func(_x, _y): _navigating_archive = false)
	connect("player_start_scanning", func(_x): _scanning = true)
	connect("player_finish_scanning", func(_x): _scanning = false)
	connect("player_start_heatmap", func(_x): _heatmap = true)
	connect("player_finish_heatmap", func(_x): _heatmap = false)
	connect("ask_beacon_start", func(): _asking_beacon = true)
	connect("ask_beacon_finish", func(): _asking_beacon = false)
