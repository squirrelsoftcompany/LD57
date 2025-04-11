extends Node

var charged : bool = true

@export var energy_value = 10

@onready  var timer = $Timer
@onready  var mesh = $MultiMeshInstance3D
@onready  var energy_sound = $EnergySound

func used() -> int :
	if(not charged):
		return 0
		
	energy_sound.play()
	mesh.hide()
	timer.start()
	charged = false
	return energy_value

func _on_timer_timeout() -> void:
	charged = true
	mesh.show()
	# TODO instead of a timer use the timepoint structure
	# energyZone should reset according to scaled time not engine time
