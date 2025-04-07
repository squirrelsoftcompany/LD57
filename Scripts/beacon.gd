extends Node3D

@onready var beacon_sound = $BeaconSound

func _ready() -> void:
	beacon_sound.play()
