extends Node

@onready var multimesh = $MultiMeshInstance3D


func _ready():
	multimesh.multimesh.mesh.material.set_shader_parameter("DistortionVector", Vector3(1.0,2.0,1.0))

func _process(delta):
	#multimesh.material.set_shader_parameter("DistortionVector", Vector3(2.0,1.0,3.0))
	return
