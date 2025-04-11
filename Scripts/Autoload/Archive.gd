extends Node
class_name Archive


enum SonarState {
	SONAR_NONE,
	SONAR_MINI,
	SONAR_HUGE
}


enum MagnetState {
	ON,
	OFF
}


class TimePoint:
	var time_of_arrival :int= 0
	var time_of_departure :int= int(INF)
	var scaled_time :int= 0
	var player_position:Vector3
	var player_rotation:Vector3
	var sonar_state := SonarState.SONAR_NONE
	var magnet_state := MagnetState.OFF


signal tp_cleared()
signal tp_added(int, TimePoint)
signal last_tp_updated(int, TimePoint)


var _archive : Array[TimePoint]


func _ready() -> void:
	GlobalEventHolder.connect("player_start_moving", func(_x, _y): self._leave_last_timepoint())
	GlobalEventHolder.connect("player_finish_moving", add_timepoint)
	GlobalEventHolder.connect("player_finish_sonar", _on_player_finish_sonar)
	GlobalEventHolder.connect("player_finish_heatmap", _on_player_finish_heatmap)


func _on_player_finish_sonar(sonar_state: Archive.SonarState):
	if sonar_state == Archive.SonarState.SONAR_NONE: return # ignore this one its used only for animation
	update_last_timepoint_sonar_state(sonar_state)

func _on_player_finish_heatmap(magnet_state: Archive.MagnetState):
	if magnet_state == Archive.MagnetState.OFF: return # ignore this one its used only for animation
	update_last_timepoint_magnet_state(magnet_state)

func clear():
	_archive.clear()
	emit_signal("tp_cleared")


func _leave_last_timepoint():
	if _archive.is_empty():
		#push_error("Trying to leave last timepoint but _archive is empty")
		return
	var back_tp := _archive.back() as TimePoint
	back_tp.time_of_departure = Time.get_ticks_usec()


func add_timepoint(player_position : Vector3, player_rotation : Vector3):
	var tp := TimePoint.new()
	tp.time_of_arrival = Time.get_ticks_usec()
	tp.player_position = player_position
	tp.player_rotation = player_rotation
	if _archive.is_empty():
		tp.scaled_time = 0
	else:
		var last_tp : TimePoint = _archive.back()
		tp.scaled_time = last_tp.scaled_time + (tp.time_of_arrival - last_tp.time_of_departure)
	_archive.push_back(tp)
	emit_signal("tp_added", _archive.size()-1, _archive.back())


func update_last_timepoint(player_position : Vector3, player_rotation : Vector3):
	if _archive.is_empty():
		push_error("Trying to update last timepoint but _archive is empty")
		return
	var back_tp := _archive.back() as TimePoint
	back_tp.player_position = player_position
	back_tp.player_rotation = player_rotation
	var neo_engine_time_of_arrival = Time.get_ticks_usec()
	back_tp.scaled_time += neo_engine_time_of_arrival - back_tp.time_of_arrival
	back_tp.time_of_arrival = neo_engine_time_of_arrival
	emit_signal("last_tp_updated", _archive.size()-1, _archive.back())


func update_last_timepoint_sonar_state(sonar_state: Archive.SonarState):
	if _archive.is_empty():
		push_error("Trying to update sonar in last timepoint but _archive is empty")
		return
	var back_tp := _archive.back() as TimePoint
	back_tp.sonar_state = sonar_state
	emit_signal("last_tp_updated", _archive.size()-1, _archive.back())


func update_last_timepoint_magnet_state(magnet_state: Archive.MagnetState):
	if _archive.is_empty():
		push_error("Trying to update magnet in last timepoint but _archive is empty")
		return
	var back_tp := _archive.back() as TimePoint
	back_tp.magnet_state = magnet_state
	emit_signal("last_tp_updated", _archive.size()-1, _archive.back())

func get_timepoint_by_index(idx : int) -> TimePoint:
	if idx < 0:
		push_error("Trying to get a negative timepoint (", idx, ")")
		return null
	if _archive.size() <= idx:
		push_error("Trying to get the ", idx, "th timepoint but _archive has only ", _archive.size(), "timepoint")
		return null
	return _archive[idx]


func get_timepoint_by_time(time : float) -> TimePoint:
	var idx := _archive.find_custom(func (x:TimePoint): is_equal_approx(x.scaled_time,time))
	if idx < 0:
		push_error("No timepoint corresponding to time ", time, "ms.")
		return null
	return get_timepoint_by_index(idx)

func get_last_tp() -> TimePoint:
	return _archive.back()
