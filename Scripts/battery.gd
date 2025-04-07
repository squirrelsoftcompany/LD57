extends MeshInstance3D

var max_charge : float = 10
var charge : float = 0

#TODO : signals

func _ready():
	max_charge = GlobalPlayerStates.maxEnergy
	charge = GlobalPlayerStates.current_energy
	material_override.set_shader_parameter("charge",charge)
	material_override.set_shader_parameter("max_charge",max_charge)

func _energy_change():
	material_override.set_shader_parameter("charge",charge)
