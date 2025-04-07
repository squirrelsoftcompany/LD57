extends Node

class_name Mine

@onready var multimesh = $MultiMeshInstance3D
@onready var area = $Area3D
@onready var explosion_sound = $ExplosionSound

var _deathTime : float = -1.0
var _disableStack : int = 0
var _isDisable : bool = false

func _ready():
	multimesh.multimesh.mesh.material.set_shader_parameter("DistortionVector", Vector3(1.0,2.0,1.0))

func _process(delta):
	#multimesh.material.set_shader_parameter("DistortionVector", Vector3(2.0,1.0,3.0))
	return

func explode():
	# Death time allow to know if we have to hide or show the mine when we look at the history
	_deathTime = Time.get_ticks_msec()
	explosion_sound.play()
	_isDisable = true
	# Send the area 3D to th ghost layer (to disable collision with the submarine)
	area.set_collision_layer_value(3,false)
	area.set_collision_layer_value(9,true)
	GlobalEventHolder.mine_state_changed.emit()
	
func disable():
	_disableStack = _disableStack + 1
	_isDisable = false
	GlobalEventHolder.mine_state_changed.emit()
	
func activate():
	_disableStack = _disableStack -1
	if _disableStack == 0:
		_isDisable = true
	GlobalEventHolder.mine_state_changed.emit()

func is_active():
	return not _isDisable
