extends Node

var charged : bool = true

@export var energy_value = 10

@onready  var timer = $Timer
@onready  var mesh = $MultiMeshInstance3D
@onready  var energy_sound = $EnergySound

#func _ready():
	#GlobalEventHolder.connect("player_start_scanning", _magnet_map)
	#GlobalEventHolder.connect("player_finish_scanning", _magnet_map)

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

func _magnet_map(_x:int) -> void:
	if _x == Archive.SonarState.MAGNET:
		$Aura.show()
		$MultiMeshInstance3D.show()
	else:
		$Aura.hide()
		$MultiMeshInstance3D.hide()
