extends Node3D


@export var layer_mini_sonar:=Vector2(10, -10)
@export var layer_huge_sonar:=Vector2(20, -20)
@export var range_mini_sonar:= 50.0
@export var range_huge_sonar:= 100.0


@onready var _shader_globals_override : ShaderGlobalsOverride = $"../ShaderGlobalsOverride"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalEventHolder.connect("player_start_moving", _on_player_start_moving)
	GlobalEventHolder.connect("player_finish_moving", _on_player_finish_moving)
	GlobalEventHolder.connect("player_navigate_archive", _on_player_navigate_archive)
	GlobalEventHolder.connect("player_quit_navigating_archive", _on_player_quit_navigating_moving)
	GlobalEventHolder.connect("ask_sonar", func(): _animate_huge_sonar(global_position))
	self.omni_range = 0
	_animate_mini_sonar(global_position)


func _on_player_start_moving(_player_position: Vector3, _player_rotation: Vector3):
	_animate_no_sonar()


func _on_player_finish_moving(player_position: Vector3, _player_rotation: Vector3):
	_animate_mini_sonar(player_position)


func _on_player_navigate_archive(_idx: int, tp: Archive.TimePoint):
	_set_sonar_state(tp.sonar_state, tp.player_position)


func _on_player_quit_navigating_moving(_idx: int, tp: Archive.TimePoint):
	_set_sonar_state(tp.sonar_state, tp.player_position)


func _animate_no_sonar():
	GlobalEventHolder.emit_signal("player_start_scanning", Archive.SonarState.SONAR_NONE)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "omni_range", 0, 0.1)
	tween.tween_callback(_shader_globals_override.set.bind("params/sonar_layer", Vector2.ZERO))
	tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_scanning", Archive.SonarState.SONAR_NONE))


func _animate_mini_sonar(player_position: Vector3):
	GlobalEventHolder.emit_signal("player_start_scanning", Archive.SonarState.SONAR_MINI)
	var base_sonar_layer := Vector2(player_position.y, player_position.y)
	var tween := get_tree().create_tween()
	tween.tween_callback(_shader_globals_override.set.bind("params/sonar_layer", base_sonar_layer + layer_mini_sonar))
	tween.tween_property(self, "omni_range", range_mini_sonar, 2)
	tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_scanning", Archive.SonarState.SONAR_MINI))


func _animate_huge_sonar(player_position: Vector3):
	GlobalEventHolder.emit_signal("player_start_scanning", Archive.SonarState.SONAR_HUGE)
	var base_sonar_layer := Vector2(player_position.y, player_position.y)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "omni_range", 0, 0.5)
	tween.tween_callback(_shader_globals_override.set.bind("params/sonar_layer", base_sonar_layer + layer_huge_sonar))
	tween.tween_property(self, "omni_range", range_huge_sonar, 1.5)
	tween.tween_callback(GlobalEventHolder.emit_signal.bind("player_finish_scanning", Archive.SonarState.SONAR_HUGE))


func _set_sonar_state(state : Archive.SonarState, player_position : Vector3):
	var base_sonar_layer := Vector2(player_position.y, player_position.y)
	match state:
		Archive.SonarState.SONAR_MINI:
			self.omni_range = range_mini_sonar
			_shader_globals_override.set("params/sonar_layer", base_sonar_layer + layer_mini_sonar)
		Archive.SonarState.SONAR_HUGE:
			self.omni_range = range_huge_sonar
			_shader_globals_override.set("params/sonar_layer", base_sonar_layer + layer_huge_sonar)
