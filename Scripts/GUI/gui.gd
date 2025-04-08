extends Control


@onready var _move_button : SpecialButton = $MainControl/VBoxContainer/HBoxContainer/MoveButton
@onready var _advanced_move_button : Control = $MainControl/VBoxContainer/AdvancedMoveHelp
@onready var _sonar_button : SpecialButton = $MainControl/VBoxContainer/HBoxContainer/SonarButton
@onready var _heatmap_button : SpecialButton = $MainControl/VBoxContainer/HBoxContainer/HeatmapButton
@onready var _beacon_button : SpecialButton = $MainControl/VBoxContainer/HBoxContainer/BeaconButton
@onready var _beacon_true_button : Button = $MainControl/VBoxContainer/HBoxContainer/BeaconButton/Button
@onready var _prev_button : SpecialButton = $MainControl/VBoxContainer2/HBoxContainer2/PrevButton
@onready var _next_button : SpecialButton = $MainControl/VBoxContainer2/HBoxContainer2/NextButton
@onready var _present_button : SpecialButton = $MainControl/VBoxContainer2/HBoxContainer2/PresentButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_advanced_move_button.visible = false
	GlobalEventHolder.connect("player_start_mi", func(): _advanced_move_button.visible = true)
	GlobalEventHolder.connect("player_finish_mi", func(): _advanced_move_button.visible = false)
	GlobalEventHolder.connect("player_finish_mi", func(): _move_button.button_pressed = false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_move_button.disabled = !GlobalEventHolder.CanMove()
	_sonar_button.disabled = !GlobalEventHolder.CanScan()
	_heatmap_button.disabled = !GlobalEventHolder.CanScan()
	_beacon_button.disabled = !GlobalEventHolder.CanBeacon()
	_prev_button.disabled = !GlobalEventHolder.CanNavigate()
	_next_button.disabled = !GlobalEventHolder.CanNavigate()
	_present_button.disabled = !GlobalEventHolder.CanNavigate()


func _input(event: InputEvent) -> void:
	if _beacon_button.disabled: return
	if event is InputEventKey:
		if event.is_action("mi_launch"):
			_beacon_true_button.button_pressed = event.pressed
