extends Control


@onready var _move_button : SpecialButton = $Control/VBoxContainer/HBoxContainer/MoveButton
@onready var _switch_button : SpecialButton = $Control/VBoxContainer/HBoxContainer3/SwitchButton
@onready var _sonar_button : SpecialButton = $Control/VBoxContainer/HBoxContainer/SonarButton
@onready var _heatmap_button : SpecialButton = $Control/VBoxContainer/HBoxContainer/HeatmapButton
@onready var _beacon_button : SpecialButton = $Control/VBoxContainer/HBoxContainer/BeaconButton
@onready var _prev_button : SpecialButton = $Control/VBoxContainer2/HBoxContainer2/PrevButton
@onready var _next_button : SpecialButton = $Control/VBoxContainer2/HBoxContainer2/NextButton
@onready var _present_button : SpecialButton = $Control/VBoxContainer2/HBoxContainer2/PresentButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_switch_button.visible = false
	_switch_button.disabled = true
	GlobalEventHolder.connect("ask_move", func(): _switch_button.visible = true)
	GlobalEventHolder.connect("ask_move", func(): _switch_button.disabled = false)
	GlobalEventHolder.connect("player_start_moving", func(_x, _y): _switch_button.visible = false)
	GlobalEventHolder.connect("player_start_moving", func(_x, _y): _switch_button.disabled = true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_move_button.disabled = !GlobalEventHolder.CanMove()
	_sonar_button.disabled = !GlobalEventHolder.CanScan()
	_heatmap_button.disabled = !GlobalEventHolder.CanScan()
	_beacon_button.disabled = !GlobalEventHolder.CanScan()
	_prev_button.disabled = !GlobalEventHolder.CanNavigate()
	_next_button.disabled = !GlobalEventHolder.CanNavigate()
	_present_button.disabled = !GlobalEventHolder.CanNavigate()
