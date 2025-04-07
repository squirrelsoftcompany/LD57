extends Node3D

@onready var beacon_sound = $BeaconSound

func _ready() -> void:
	beacon_sound.play()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if(area.is_in_group("Mine") && not area.get_collision_layer_value(9)):
		area.get_parent().disable()


func _on_area_3d_area_exited(area: Area3D) -> void:
	if(area.is_in_group("Mine") && not area.get_collision_layer_value(9)):
		area.get_parent().activate()
