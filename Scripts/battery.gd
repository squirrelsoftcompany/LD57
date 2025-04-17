extends MeshInstance3D

@onready var max_charge : float = GlobalPlayerStates.maxEnergy 
@onready var charge : float = GlobalPlayerStates.current_energy 

func _ready():
	material_override.set_shader_parameter("charge",charge)
	material_override.set_shader_parameter("max_charge",max_charge)
	GlobalEventHolder.connect("energy_state_changed", _energy_change)

func _energy_change(val: int, maximum: int):
	charge = (val *  max_charge ) / maximum
	material_override.set_shader_parameter("charge",charge)
