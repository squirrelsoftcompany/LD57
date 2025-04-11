extends Node

# moving
@warning_ignore("unused_signal")
signal player_start_mi()
@warning_ignore("unused_signal")
signal player_finish_mi()
@warning_ignore("unused_signal")
signal player_spawn()
signal player_start_moving(start_position:Vector3, player_rotation : Vector3)
signal player_finish_moving(finish_position:Vector3, player_rotation : Vector3)
#archive
signal player_navigate_archive(idx: int, tp: Archive.TimePoint)
signal player_quit_navigating_archive(idx: int, tp: Archive.TimePoint)
#scanner
signal player_start_sonar(state: Archive.SonarState)
signal player_finish_sonar(state: Archive.SonarState)
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
#game state changed
@warning_ignore("unused_signal")
signal mine_state_changed()
@warning_ignore("unused_signal")
signal mine_state_changed_really(val: int, maximum: int)
@warning_ignore("unused_signal")
signal gameover(win: bool)
#player state changed
@warning_ignore("unused_signal")
signal energy_state_changed(val: int, maximum: int)
@warning_ignore("unused_signal")
signal life_state_changed(val: int, maximum: int)
@warning_ignore("unused_signal")
signal beacon_state_changed(val: int, maximum: int)


var _moving := false
var _sonar := false
var _sonar_done := false
var _heatmap := false
var _heatmap_done := false
var _asking_beacon := false
var _beacon_available := true
var _navigating_archive := false
var _gameover := false


func _Animating() -> bool: return _moving or _sonar or _heatmap or _asking_beacon
func CanMove() -> bool: return !_Animating() and !_navigating_archive and !_gameover
func CanNavigate() -> bool: return !_Animating() and !_gameover
func _CanScan() -> bool: return !_Animating() and !_navigating_archive and !_gameover
func CanSonar() -> bool: return _CanScan() and !_sonar_done
func CanHeatmap() -> bool: return _CanScan() and !_heatmap_done
func CanBeacon() -> bool: return !_moving and !_sonar and !_heatmap and !_navigating_archive and !_gameover and _beacon_available


func _ready() -> void:
	connect("player_start_moving", func(_x, _y): _moving = true)
	connect("player_finish_moving", func(_x, _y): _moving = false)
	connect("player_navigate_archive", func(_x, _y): _navigating_archive = true)
	connect("player_quit_navigating_archive", func(_x, _y): _navigating_archive = false)
	connect("player_start_sonar", func(_x): _sonar = true)
	connect("player_finish_sonar", func(_x): _sonar = false)
	GlobalArchive.connect("tp_added", func(_x, _y): _sonar_done = false)
	GlobalArchive.connect("tp_cleared", func(): _sonar_done = false)
	GlobalArchive.connect("last_tp_updated", func(_x, tp: Archive.TimePoint): _sonar_done = tp.sonar_state == Archive.SonarState.SONAR_HUGE)
	connect("player_start_heatmap", func(_x): _heatmap = true)
	connect("player_finish_heatmap", func(_x): _heatmap = false)
	GlobalArchive.connect("tp_added", func(_x, _y): _heatmap_done = false)
	GlobalArchive.connect("tp_cleared", func(): _heatmap_done = false)
	GlobalArchive.connect("last_tp_updated", func(_x, tp: Archive.TimePoint): _heatmap_done = tp.magnet_state == Archive.MagnetState.ON)
	connect("ask_beacon_start", func(): _asking_beacon = true)
	connect("ask_beacon_finish", func(): _asking_beacon = false)
	connect("beacon_state_changed", func(val, _x): _beacon_available = val > 0)
	connect("gameover", func(_x): _gameover = true)
