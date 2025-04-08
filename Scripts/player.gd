extends Node3D

class_name Player

@export var speed := 10.0 # m/s
@export var angular_speed := 20 # deg/s
@export var launch_max_charge := 20
@export var launch_speed := 20
@export var beacon_scene_path: String = "res://Scenes/beacon.tscn"
@export var bonk_knockback_distance := 0.5

@onready var _moving_interaction : MovingInteraction = $MovingInteraction
@onready var _beacon_cooldown : Timer = $BeaconCooldown
@onready var _moving_sound : AudioStreamPlayer = $MovingSound

var _selecting_movement := false
var _launch_is_charging := false
var _launch_charge_power := 0.0
var _move_tween : Tween = null
var _final_position : Vector3

func _ready() -> void:
	position = get_tree().get_first_node_in_group("Map").cavities.pick_random().position
	GlobalEventHolder.emit_signal("player_spawn")
	GlobalArchive.clear()
	GlobalArchive.add_timepoint(position, rotation)
	GlobalEventHolder.connect("player_navigate_archive", _on_player_navigate_archive)
	GlobalEventHolder.connect("player_quit_navigating_archive", _on_player_quit_navigating_archive)


func _input(event: InputEvent) -> void:
	if !GlobalEventHolder.CanMove(): return

	if event is InputEventKey:
		if event.is_action_pressed("mi_toggle", false, true):
			_toggle_selecting_movement()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and _selecting_movement:
			_finish_selecting_movement()
			_move_player(_moving_interaction._candidate_position)


func _move_player(final_position : Vector3) -> void:
	GlobalEventHolder.emit_signal("player_start_moving", position, $Submarine.rotation)
	var duration := position.distance_to(final_position) / speed
	var angular_duration := position.distance_to(final_position) / angular_speed
	var forward := (final_position-position).normalized()
	var left := Vector3.UP.cross(forward).normalized()
	var up := forward.cross(left).normalized()
	var final_quaternion := Quaternion(Basis(left,up,forward))
	var tween := get_tree().create_tween()
	_move_tween = tween
	_final_position = final_position
	tween.set_parallel()
	tween.tween_property(self, "global_position", final_position, duration)
	tween.tween_property($Submarine, "quaternion", final_quaternion, angular_duration)
	tween.chain()
	tween.tween_callback(func (): GlobalEventHolder.emit_signal("player_finish_moving", final_position, $Submarine.rotation))
	_moving_sound.play()

func _process(_delta: float) -> void:
	if GlobalEventHolder._asking_beacon:
		_launch_is_charging = true
		if _launch_charge_power < launch_max_charge:
			_launch_charge_power += _delta
	else:
		if _launch_is_charging:
			launch_beacon(_launch_charge_power)
			_launch_is_charging = false
			_launch_charge_power = 0.0
	pass

func _on_player_navigate_archive(_idx: int, tp: Archive.TimePoint) -> void:
	global_position = tp.player_position
	$Submarine.global_rotation = tp.player_rotation


func _on_player_quit_navigating_archive(_idx: int, tp: Archive.TimePoint) -> void:
	global_position = tp.player_position
	$Submarine.global_rotation = tp.player_rotation


func _toggle_selecting_movement() -> void:
	if _selecting_movement:
		_finish_selecting_movement()
	else:
		_start_selecting_movement()


func _start_selecting_movement() -> void:
	_moving_interaction.visible = true
	_selecting_movement = true


func _finish_selecting_movement() -> void:
	_moving_interaction.visible = false
	_selecting_movement = false
	
func launch_beacon(power : float) -> void: 
	if GlobalPlayerStates.get_beacon() > 0:
		# Load beacon scene and create instance
		var beacon_scene = load(beacon_scene_path)
		var beacon_instance = beacon_scene.instantiate()
		get_parent().add_child(beacon_instance)
		beacon_instance.global_transform.origin = global_transform.origin
		var total_force = (power * launch_speed)
		var direction = $Submarine.global_transform.basis.z.normalized()
		beacon_instance.apply_central_impulse(direction * total_force)
		_beacon_cooldown.start()
		GlobalPlayerStates.remove_beacon()
	return
	
func bonk():
	if _move_tween != null and _move_tween.is_valid():
		# Player knockback on hit
		var direction = (_final_position-position).normalized()
		position = position - (direction * bonk_knockback_distance)
		# Stop and delete the tween
		_move_tween.stop()
		GlobalEventHolder.emit_signal("player_finish_moving", position, $Submarine.rotation)
		_move_tween.tween_callback(queue_free)
		_move_tween = null
		# Player take damage
		GlobalPlayerStates.take_damage()
		_moving_sound.stop()


func _on_beacon_cooldown_timeout() -> void:
	GlobalPlayerStates.add_beacon()
	_beacon_cooldown.stop()
	if (not GlobalPlayerStates.is_beacon_full()):
		_beacon_cooldown.start()
