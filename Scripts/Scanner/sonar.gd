extends Node3D


@export var layer_mini_sonar:=Vector2(10, -10)
@export var layer_huge_sonar:=Vector2(20, -20)
@export var range_mini_sonar:= 50.0
@export var range_huge_sonar:= 100.0
@export var range_magnet := 75

@export var huge_sonar_cost := 10
@export var magnet_cost := 10

@onready var _shader_globals_override : ShaderGlobalsOverride = $"../ShaderGlobalsOverride"
@onready var no_energy_sound = $NoEnergy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalEventHolder.connect("player_start_moving", _on_player_start_moving)
	GlobalEventHolder.connect("player_finish_moving", _on_player_finish_moving)
	GlobalEventHolder.connect("player_navigate_archive", _on_player_navigate_archive)
	GlobalEventHolder.connect("player_quit_navigating_archive", _on_player_quit_navigating_moving)
	GlobalEventHolder.connect("ask_sonar", func(): _animate_huge_sonar(global_position))
	GlobalEventHolder.connect("ask_heatmap", _animate_magnet)
	GlobalEventHolder.connect("player_spawn",_initialize)
	self.omni_range = 0


func _initialize():
	_animate_mini_sonar(global_position)


func _on_player_start_moving(_player_position: Vector3, _player_rotation: Vector3):
	_animate_no_sonar()
	_animate_no_magnet()


func _on_player_finish_moving(player_position: Vector3, _player_rotation: Vector3):
	_animate_mini_sonar(player_position)


func _on_player_navigate_archive(_idx: int, tp: Archive.TimePoint):
	_set_sonar_state(tp.sonar_state, tp.player_position)
	_set_magnet_state(tp.magnet_state)


func _on_player_quit_navigating_moving(_idx: int, tp: Archive.TimePoint):
	_set_sonar_state(tp.sonar_state, tp.player_position)
	_set_magnet_state(tp.magnet_state)


func _animate_no_sonar():
	GlobalEventHolder.emit_signal("player_start_sonar", Archive.SonarState.SONAR_NONE)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "omni_range", 0, 0.1)
	tween.tween_callback(_shader_globals_override.set.bind("params/sonar_layer", Vector2.ZERO))
	tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_sonar", Archive.SonarState.SONAR_NONE))


func _animate_mini_sonar(player_position: Vector3):
	GlobalEventHolder.emit_signal("player_start_sonar", Archive.SonarState.SONAR_MINI)
	var base_sonar_layer := Vector2(player_position.y, player_position.y)
	var tween := get_tree().create_tween()
	tween.tween_callback(_shader_globals_override.set.bind("params/sonar_layer", base_sonar_layer + layer_mini_sonar))
	tween.tween_property(self, "omni_range", range_mini_sonar, 2)
	tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_sonar", Archive.SonarState.SONAR_MINI))


func _animate_huge_sonar(player_position: Vector3):
	if GlobalPlayerStates.get_energy() >= huge_sonar_cost:
		GlobalPlayerStates.remove_energy(huge_sonar_cost)
		GlobalEventHolder.emit_signal("player_start_sonar", Archive.SonarState.SONAR_HUGE)
		var base_sonar_layer := Vector2(player_position.y, player_position.y)
		var tween := get_tree().create_tween()
		tween.tween_property(self, "omni_range", 0, 0.5)
		tween.tween_callback(_shader_globals_override.set.bind("params/sonar_layer", base_sonar_layer + layer_huge_sonar))
		tween.tween_property(self, "omni_range", range_huge_sonar, 1.5)
		tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_sonar", Archive.SonarState.SONAR_HUGE))
	else:
		no_energy_sound.play()
		pass


func _set_sonar_state(state : Archive.SonarState, player_position : Vector3):
	var base_sonar_layer := Vector2(player_position.y, player_position.y)
	match state:
		Archive.SonarState.SONAR_MINI:
			self.omni_range = range_mini_sonar
			_shader_globals_override.set("params/sonar_layer", base_sonar_layer + layer_mini_sonar)
		Archive.SonarState.SONAR_HUGE:
			self.omni_range = range_huge_sonar
			_shader_globals_override.set("params/sonar_layer", base_sonar_layer + layer_huge_sonar)


func _set_magnet_state(state : Archive.MagnetState):
	match state :
		Archive.MagnetState.ON :
			$Magnetometer.omni_range = range_magnet
		Archive.MagnetState.OFF :
			$Magnetometer.omni_range = 0


func _animate_no_magnet():
	GlobalEventHolder.emit_signal("player_start_heatmap", Archive.MagnetState.ON)
	var tween := get_tree().create_tween()
	tween.tween_property($Magnetometer, "omni_range",0, 1)
	tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_heatmap", Archive.MagnetState.OFF))


func _animate_magnet():
	if GlobalPlayerStates.get_energy() >= magnet_cost:
		GlobalPlayerStates.remove_energy(magnet_cost)
		GlobalEventHolder.emit_signal("player_start_heatmap", Archive.MagnetState.ON)
		var tween := get_tree().create_tween()
		tween.tween_property($Magnetometer, "omni_range", range_magnet, 1.5)
		tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_heatmap", Archive.MagnetState.ON))
	else:
		no_energy_sound.play()
		pass
