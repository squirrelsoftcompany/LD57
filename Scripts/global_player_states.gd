extends Node

class_name Player_States


@export var current_energy: int = 0
@export var current_beacon: int = 0
@export var current_life: int = 0

var maxLife : int = ProjectSettings.get_setting("Game/Global/MaxLife")
var maxBeacon : int = ProjectSettings.get_setting("Game/Global/MaxBeacon")
var maxEnergy : int = ProjectSettings.get_setting("Game/Global/MaxEnergy")
var minesArray: Array = ProjectSettings.get_setting("Game/Global/Mines")

func _ready() -> void:
	current_energy = maxEnergy
	current_beacon = maxBeacon
	current_life = maxLife
	GlobalEventHolder.connect("mine_state_changed", _on_mine_state_changed)


func get_energy() -> int:
	return current_energy

func set_energy(value: int) -> void:
	if value < 0:
		value = 0
	current_energy = value
	GlobalEventHolder.energy_state_changed.emit(value, maxEnergy)


func get_beacon() -> int:
	return current_beacon

func set_beacon(value: int) -> void:
	if value < 0:
		value = 0
	current_beacon = value
	GlobalEventHolder.beacon_state_changed.emit(value, maxBeacon)


func get_life() -> int:
	return current_life

func set_life(value: int) -> void:
	if value <= 0:
		value = 0
		game_over()
	current_life = value
	GlobalEventHolder.life_state_changed.emit(value, maxLife)


func _on_mine_state_changed() -> void:
	var _minesArray: Array = ProjectSettings.get_setting("Game/Global/Mines")
	var mineLeft = 0
	for _mine in _minesArray:
		var mine: Mine = _mine
		if not mine.is_active():
			mineLeft = mineLeft+1
	if(mineLeft == 0):
		win()

func take_damage(value: int = 1):
	set_life(get_life()-value)

func add_energy(value: int):
	set_energy(get_energy()+value)

func remove_energy(value: int):
	set_energy(get_energy()-value)

func add_beacon(value: int = 1):
	set_beacon(get_beacon()+value)

func remove_beacon(value: int = 1):
	set_beacon(get_beacon()-value)

func is_beacon_full() -> bool:
	return current_beacon >= maxBeacon

func game_over():
	# TODO : Game is over... send a signal ?
	GlobalEventHolder.gameover.emit(false)
	pass

func win():
	GlobalEventHolder.gameover.emit(true)
	pass
