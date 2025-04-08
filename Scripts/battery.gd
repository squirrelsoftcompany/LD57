extends MeshInstance3D

var max_charge : float = 10
var charge : float = 0

func _ready():
	max_charge = (GlobalPlayerStates.maxEnergy *  max_charge ) / GlobalPlayerStates.maxEnergy
	charge = (GlobalPlayerStates.current_energy *  max_charge ) / GlobalPlayerStates.maxEnergy
	material_override.set_shader_parameter("charge",charge)
	material_override.set_shader_parameter("max_charge",max_charge)
	GlobalEventHolder.connect("energy_state_changed", _energy_change)

func _energy_change(val: int, maximum: int):
	charge = (val *  max_charge ) / maximum
	material_override.set_shader_parameter("charge",charge)
