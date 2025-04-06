extends Area3D

func _on_area_entered(area: Area3D) -> void:
	if(area.is_in_group("Mine")):
		GlobalPlayerStates.take_damage()
		area.get_parent().explode()
	elif(area.is_in_group("Energy")):
		GlobalPlayerStates.add_energy(area.get_parent().used())
		
