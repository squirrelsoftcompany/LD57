extends Node3D


@onready var _meshAzimuthDistance : MeshInstance3D = $meshAzimuthDistance


var _switchToAltitude := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventAction:
		_switchToAltitude = event.is_action_pressed("mi_switch", true)


func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventAction:
		_switchToAltitude = event.is_action_pressed("mi_switch", true)
	
	if event is InputEventMouseMotion:
		if !_switchToAltitude:
			set_interaction_position_in_shader(event.position)


func set_interaction_position_in_shader(mouse_pos:Vector2):
	var plane := Plane(Vector3.UP, position.y)
	var camera := get_viewport().get_camera_3d()
	var position3d = plane.intersects_ray(
						camera.project_ray_origin(mouse_pos),
						camera.project_ray_normal(mouse_pos))
	if position3d != null:
		_meshAzimuthDistance.set_instance_shader_parameter("InteractionRadius", position3d.distance_to(position)/2)
