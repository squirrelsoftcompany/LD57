extends Node

class_name Player_States


@export var energy: int = 0
@export var life: int = 0

func get_energy() -> int:
	return energy

func set_energy(value: int) -> void:
	if value < 0:
		value = 0
	energy = value

# Getter pour life
func get_life() -> int:
	return life

# Setter pour life
func set_life(value: int) -> void:
	if value <= 0:
		value = 0
		# TODO : Death
	life = value
	
func take_damage():
	set_life(get_life()-1)
	
func add_energy(value : int):
	set_energy(get_energy()+value)
