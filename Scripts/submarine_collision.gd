extends Node3D

var present : bool = true

@onready var bonk_sound = $BonkSound

func _on_area_entered(area: Area3D) -> void:
	if present:
		if(area.is_in_group("Mine") && not area.get_collision_layer_value(9)):
			GlobalPlayerStates.take_damage(4)
			area.get_parent().explode()
		elif(area.is_in_group("Energy")):
			GlobalPlayerStates.add_energy(area.get_parent().used())


func _on_innerBody_body_entered(_body: Node3D) -> void:
	if present:
		bonk_sound.play()
		var parent = get_parent()
		if parent is Player :
			parent.bonk()
