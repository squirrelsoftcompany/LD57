extends Node3D


@export var material : Material


@onready var _path3d : Path3D = $Path3D


var _polygon : CSGPolygon3D = null


func _ready():
	GlobalArchive.connect("tp_cleared", _on_tp_cleared)
	GlobalArchive.connect("tp_added", _on_tp_added)
	GlobalArchive.connect("last_tp_updated", _on_last_tp_updated)
	GlobalEventHolder.connect("ask_prev_entry", navigate_back)
	GlobalEventHolder.connect("ask_next_entry", navigate_forward)
	GlobalEventHolder.connect("ask_present", quit_navigation)
	for i in GlobalArchive._archive.size():
		_on_tp_added(i, GlobalArchive._archive[i])
	GlobalEventHolder.connect("reload_game", _on_reload_game)


func _on_reload_game():
	_on_tp_cleared()


var _visiting_idx := -1
func navigate_back():
	if _visiting_idx <= 0: return
	_visiting_idx -= 1
	GlobalEventHolder.emit_signal("player_navigate_archive", _visiting_idx, GlobalArchive._archive[_visiting_idx])


func navigate_forward():
	if _visiting_idx >= GlobalArchive._archive.size()-2:
		quit_navigation()
		return
	_visiting_idx += 1
	GlobalEventHolder.emit_signal("player_navigate_archive", _visiting_idx, GlobalArchive._archive[_visiting_idx])


func quit_navigation():
	if _visiting_idx == GlobalArchive._archive.size()-1:
		return
	_visiting_idx = GlobalArchive._archive.size()-1
	GlobalEventHolder.emit_signal("player_quit_navigating_archive", _visiting_idx, GlobalArchive._archive[_visiting_idx])


func _on_tp_cleared() -> void:
	_polygon.queue_free()
	_polygon = null
	_path3d.curve.clear_points()
	_visiting_idx = -1


func _on_tp_added(_idx: int, tp: Archive.TimePoint) -> void:
	_path3d.curve.add_point(tp.player_position)
	if _polygon == null and is_path_valid_for_polygon():
		generate_polygon()
	if !GlobalEventHolder._navigating_archive:
		_visiting_idx = _path3d.curve.point_count-1


func _on_last_tp_updated(_idx: int, tp: Archive.TimePoint) -> void:
	_path3d.curve.set_point_position(_path3d.curve.point_count-1, tp.player_position)
	if _polygon == null and is_path_valid_for_polygon():
		generate_polygon()


func generate_polygon():
	_polygon = CSGPolygon3D.new()
	_polygon.mode = CSGPolygon3D.MODE_PATH
	_polygon.path_node = _path3d.get_path()
	_polygon.material = material
	_polygon.polygon = generate_circle_points(36, 0.1)
	_polygon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_polygon)


func is_path_valid_for_polygon() -> bool:
	if _path3d.curve.point_count >= 2:
		var distance = _path3d.curve.get_point_position(0).distance_to(_path3d.curve.get_point_position(1))
		if distance > 0.2:
			return true
	return false


# thanks copilot
func generate_circle_points(segments: int, radius: float) -> Array:
	var points = []
	for i in range(segments):
		var angle = 2.0 * PI * i / segments
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	return points
