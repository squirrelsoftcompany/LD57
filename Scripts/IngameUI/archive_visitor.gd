extends Node3D


@export var material : Material


@onready var _path3d : Path3D = $Path3D


var _polygon : CSGPolygon3D = null


func _ready():
	GlobalArchive.connect("tp_cleared", _on_tp_cleared)
	GlobalArchive.connect("tp_added", _on_tp_added)
	GlobalArchive.connect("last_tp_updated", _on_last_tp_updated)


func _on_tp_cleared() -> void:
	_path3d.curve.clear_points()


func _on_tp_added(_idx: int, tp: Archive.TimePoint) -> void:
	_path3d.curve.add_point(tp.player_position)
	if _polygon == null and is_path_valid_for_polygon():
		generate_polygon()


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
	add_child(_polygon)


func is_path_valid_for_polygon() -> bool:
	if _path3d.curve.point_count >= 2:
		if _path3d.curve.get_point_position(0).distance_to(_path3d.curve.get_point_position(1)) > 0.2:
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
