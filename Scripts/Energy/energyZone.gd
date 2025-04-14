extends Node

@export var energy_value = 10
@export var cooldown : float = 10000000 # in µs (10^-6s)

@onready  var mesh = $MultiMeshInstance3D
@onready  var energy_sound = $EnergySound
@onready var uses : Array[float] = [-cooldown]

func _ready():
	GlobalEventHolder.connect("player_start_heatmap",func(_x): update_from_tp(GlobalArchive.get_last_tp()))
	GlobalEventHolder.connect("player_navigate_archive",func(_x,_tp): update_from_tp(_tp))
	GlobalEventHolder.connect("player_quit_navigating_archive",func(_x,_tp): update_from_tp(_tp))

func used() -> int :
	var _tp : Archive.TimePoint = GlobalArchive.get_last_tp()
	var instant : float = (Time.get_ticks_usec()-_tp.time_of_departure)+_tp.scaled_time
	if uses.back() + cooldown < instant :
		uses.append(instant)
		energy_sound.play()
		mesh.hide()
		return energy_value
	return 0

func update_from_tp(_tp : Archive.TimePoint):
	var i : int = uses.size()-1
	while i>=0 :
		if _tp.scaled_time >= uses[i]:
			if _tp.scaled_time >= uses[i]+cooldown:
				mesh.show()
			else:
				mesh.hide()
			i = -1
		else:
			i-=1
