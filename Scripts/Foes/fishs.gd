
extends Node3D

# Speed of the fish school's movement
@export var speed = 2.0

# PathFollow3D node to follow the path
@onready var path_follow = $Path3D/PathFollow3D
@onready var body = $RigidBody3D
@onready var multimesh = $RigidBody3D/MultiMeshInstance3D

func _ready():
	# Initialize the PathFollow3D position to the start of the path
	path_follow.set_h_offset(0.0)
	# Todo : generate procedural path here ?

func _process(delta):
	var next_step_ratio = path_follow.get_progress_ratio() + speed * delta
	
	# Move the PathFollow3D along the path
	if (next_step_ratio >= 1.0):
		path_follow.set_progress_ratio(1.0)
		speed = -speed
	elif (next_step_ratio  <= 0):
		path_follow.set_progress_ratio(0.0)
		speed = -speed
	else:
		path_follow.set_progress_ratio(next_step_ratio)

	# Update the fish school's position
	var old_position = body.global_transform.origin
	body.global_transform.origin = path_follow.global_transform.origin
	
	var fish_direction = (body.global_transform.origin-old_position).normalized()
	multimesh.multimesh.mesh.material.set_shader_parameter("DistortionVector",fish_direction * 5.0)
