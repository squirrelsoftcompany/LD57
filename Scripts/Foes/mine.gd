extends Node

@onready var multimesh = $MultiMeshInstance3D
@onready var area = $Area3D
@onready var explosion_sound = $ExplosionSound

var deathTime = -1.0

func _ready():
	multimesh.multimesh.mesh.material.set_shader_parameter("DistortionVector", Vector3(1.0,2.0,1.0))

func _process(delta):
	#multimesh.material.set_shader_parameter("DistortionVector", Vector3(2.0,1.0,3.0))
	return

func explode():
	# Death time allow to know if we have to hide or show the mine when we look at the history
	deathTime = Time.get_ticks_msec()
	explosion_sound.play()
	# Send the area 3D to th ghost layer (to disable collision with the submarine)
	area.set_collision_layer_value(3,false)
	area.set_collision_layer_value(9,true)
