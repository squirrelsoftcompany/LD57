extends Node3D


@export var distance_range := Vector2(4, 20)
@export var altitude_max := 10


@onready var _circleAzimuthDistance : MeshInstance3D = $circleAzimuthDistance
@onready var _lineAzimuthDistance : MeshInstance3D = $lineAzimuthDistance
@onready var _lineAltitude : MeshInstance3D = $lineAltitude
@onready var _lineResult : MeshInstance3D = $lineResult
@onready var _circleResult : MeshInstance3D = $circleResult


var _candidate_azimuth_distance := Vector3(0,0,0)
var _candidate_position := Vector3(0,0,0)
var _candidate_altitude := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_circleAzimuthDistance.scale = Vector3.ONE * distance_range.y * 2
	_circleAzimuthDistance.set_instance_shader_parameter("MainRadius", distance_range.y)
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
		var distance : float = position3d.distance_to(position)
		if distance < distance_range.x or distance > distance_range.y:
			var direction = (position3d-position).normalized()
			position3d = position + direction * clamp(distance, distance_range.x, distance_range.y)
		_candidate_azimuth_distance = position3d
		_candidate_position = _candidate_azimuth_distance + Vector3.UP * _candidate_altitude
		_update_drawings()


func _compute_altitude(mouse_pos:Vector2):
	var camera := get_viewport().get_camera_3d()
	#var plane_normal = camera.transform.basis.z.normalized()
	var plane_normal = camera.transform.basis.x.normalized().cross(Vector3.UP)
	var plane := Plane(plane_normal, _candidate_azimuth_distance)
	var position3d = plane.intersects_ray(
						camera.project_ray_origin(mouse_pos),
						camera.project_ray_normal(mouse_pos))
	if position3d != null:
		_candidate_altitude = position3d.y - position.y
		if abs(_candidate_altitude) > distance_range.y:
			_candidate_altitude = sign(_candidate_altitude) * distance_range.y
		_candidate_position = _candidate_azimuth_distance + Vector3.UP * _candidate_altitude
		_update_drawings()


func _update_drawings():
	_circleAzimuthDistance.set_instance_shader_parameter("InteractionRadius", _candidate_azimuth_distance.distance_to(position))
	#_draw_line(_lineAzimuthDistance.mesh, position, _candidate_azimuth_distance, Color.RED)
	#_draw_line(_lineAltitude.mesh, _candidate_azimuth_distance, _candidate_position, Color.GREEN)
	#_draw_line(_lineResult.mesh, position, _candidate_position, Color.BLUE)
	_draw_cylinder(_lineAzimuthDistance, position, _candidate_azimuth_distance)
	_draw_cylinder(_lineAltitude, _candidate_azimuth_distance, _candidate_position)
	_draw_cylinder(_lineResult, position, _candidate_position)
	_circleResult.global_position = _candidate_position + Vector3.UP * 0.1


func _draw_line(mesh : ImmediateMesh, pointA : Vector3, pointB : Vector3, color : Color):
	mesh.clear_surfaces()
	if pointA.is_equal_approx(pointB): return
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(pointA)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(pointB)
	mesh.surface_end()


# thanks copilot
func _draw_cylinder(meshInstance: MeshInstance3D, point_a: Vector3, point_b: Vector3, radius: float = 0.1, segments: int = 36):
	if meshInstance.mesh is not ImmediateMesh: return
	var mesh : ImmediateMesh = meshInstance.mesh
	mesh.clear_surfaces()
	if point_a.is_equal_approx(point_b): return
	
	var direction = (point_b - point_a).normalized()
	var height = point_a.distance_to(point_b)
	var mesh_transform = Transform3D()
	mesh_transform.origin = point_a
	var left = direction.cross(Vector3.UP)
	if left.is_zero_approx():
		left = direction.cross(Vector3.LEFT)
	mesh_transform.basis = Basis(left, direction, direction.cross(left))
	meshInstance.global_transform = mesh_transform

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(segments):
		var angle1 = 2.0 * PI * i / segments
		var angle2 = 2.0 * PI * (i + 1) / segments

		var v1_base = Vector3(cos(angle1) * radius, 0, sin(angle1) * radius)
		var v2_base = Vector3(cos(angle2) * radius, 0, sin(angle2) * radius)
		var v1_top = v1_base + Vector3(0, height, 0)
		var v2_top = v2_base + Vector3(0, height, 0)

		# Base inférieure
		mesh.surface_add_vertex(v1_base)
		mesh.surface_add_vertex(v2_base)
		mesh.surface_add_vertex(Vector3(0, 0, 0))

		# Base supérieure
		mesh.surface_add_vertex(v1_top)
		mesh.surface_add_vertex(v2_top)
		mesh.surface_add_vertex(Vector3(0, height, 0))

		# Parois
		mesh.surface_add_vertex(v1_base)
		mesh.surface_add_vertex(v2_base)
		mesh.surface_add_vertex(v1_top)

		mesh.surface_add_vertex(v1_top)
		mesh.surface_add_vertex(v2_base)
		mesh.surface_add_vertex(v2_top)
	mesh.surface_end()
