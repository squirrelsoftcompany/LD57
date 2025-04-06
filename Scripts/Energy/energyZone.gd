extends Node

var charged : bool = true

@export var energy_value = 10

@onready  var timer = $Timer
@onready  var mesh = $MultiMeshInstance3D

func used() -> int :
	charged = false
	mesh.hide()
	timer.start()
	return energy_value

func _on_timer_timeout() -> void:
	charged = true
	mesh.show()
