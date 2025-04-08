
extends Node3D

# Speed of the fish school's movement
@export var speed = 2.0

# PathFollow3D node to follow the path
@onready var path_follow = $Path3D/PathFollow3D
@onready var body = $Path3D/PathFollow3D/Area3D
@onready var multimesh = $Path3D/PathFollow3D/Area3D/MultiMeshInstance3D

func _ready():
	# Initialize the PathFollow3D position to the start of the path
	path_follow.set_h_offset(0.0)
	GlobalEventHolder.connect("player_finish_moving",func(_x,_y): _set_pos(GlobalArchive.get_last_tp()))
	GlobalEventHolder.connect("player_navigate_archive",func(_x,_y): _set_pos(_y))
	GlobalEventHolder.connect("player_quit_navigating_archive",func(_x,_y): _set_pos(_y))

func _set_pos(time_point : Archive.TimePoint):
	var length = $Path3D.curve.get_baked_length()
	var step = speed * time_point.scaled_time
	var dir : bool = true
	while step > length:
		step -= length
		dir = !dir
	if dir :
		path_follow.progress = step
	else :
		path_follow.progress = length-step

	# Update the fish school's position
	var old_position = body.global_transform.origin
	body.global_transform.origin = path_follow.global_transform.origin
	
	var fish_direction = (body.global_transform.origin-old_position).normalized()
	multimesh.multimesh.mesh.material.set_shader_parameter("DistortionVector",fish_direction * 5.0)
