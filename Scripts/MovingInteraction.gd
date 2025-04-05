extends Node3D


@onready var _circleAzimuthDistance : MeshInstance3D = $circleAzimuthDistance
@onready var _lineAzimuthDistance : MeshInstance3D = $lineAzimuthDistance
@onready var _lineAltitude : MeshInstance3D = $lineAltitude
@onready var _lineResult : MeshInstance3D = $lineResult


var _candidate_azimuth_distance := Vector3(0,0,0)
var _candidate_position := Vector3(0,0,0)
var _candidate_altitude := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("mi_switch"):
			_compute_altitude(event.position)
		else:
			_compute_azimuth_distance(event.position)
		get_viewport().set_input_as_handled()


func _compute_azimuth_distance(mouse_pos:Vector2):
	var plane := Plane(Vector3.UP, position.y)
	var camera := get_viewport().get_camera_3d()
	var position3d = plane.intersects_ray(
						camera.project_ray_origin(mouse_pos),
						camera.project_ray_normal(mouse_pos))
	if position3d != null:
		_candidate_azimuth_distance = position3d
		_candidate_position = _candidate_azimuth_distance + Vector3.UP * _candidate_altitude
		_update_drawings()


func _compute_altitude(mouse_pos:Vector2):
	var camera := get_viewport().get_camera_3d()
	var plane := Plane(Vector3.LEFT, _candidate_azimuth_distance.x)
	var position3d = plane.intersects_ray(
						camera.project_ray_origin(mouse_pos),
						camera.project_ray_normal(mouse_pos))
	if position3d != null:
		_candidate_altitude = position3d.y - position.y
		_candidate_position = _candidate_azimuth_distance + Vector3.UP * _candidate_altitude
		_update_drawings()


func _update_drawings():
	_circleAzimuthDistance.set_instance_shader_parameter("InteractionRadius", _candidate_azimuth_distance.distance_to(position)/2)
	_draw_line(_lineAzimuthDistance.mesh, position, _candidate_azimuth_distance, Color.RED)
	_draw_line(_lineAltitude.mesh, _candidate_azimuth_distance, _candidate_position, Color.GREEN)
	_draw_line(_lineResult.mesh, position, _candidate_position, Color.BLUE)


func _draw_line(mesh : ImmediateMesh, pointA : Vector3, pointB : Vector3, color : Color):
	mesh.clear_surfaces()
	if pointA.is_equal_approx(pointB): return
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(pointA)
	mesh.surface_add_vertex(pointB)
	mesh.surface_end()
