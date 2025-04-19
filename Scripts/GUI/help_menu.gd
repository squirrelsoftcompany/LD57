extends VBoxContainer


@export_custom(PROPERTY_HINT_ARRAY_TYPE, "HelpData") var helpDatum : Array[HelpData]


@onready var _help_page : HelpPage = $HelpPage


func _ready() -> void:
	var current_help : int = ProjectSettings.get_setting("Game/Global/Current_Help", -1)
	if current_help < 0 or current_help >= helpDatum.size():
		current_help = 0
		ProjectSettings.set_setting("Game/Global/Current_Help", current_help)
	_help_page.set_help_data(helpDatum[current_help])
	$HBoxContainer/PrevButton.pressed.connect(_on_PrevButton_pressed)
	$HBoxContainer/NextButton.pressed.connect(_on_NextButton_pressed)
	var first_time_help:bool= ProjectSettings.get_setting("Game/Global/First_Time_Help", true)
	if first_time_help:
		ProjectSettings.set_setting("Game/Global/First_Time_Help", false)
		GlobalEventHolder.ask_show_help.emit.call_deferred()


func _on_PrevButton_pressed():
	var current_help : int = ProjectSettings.get_setting("Game/Global/Current_Help")
	current_help = max(current_help-1, 0)
	_help_page.set_help_data(helpDatum[current_help])
	ProjectSettings.set_setting("Game/Global/Current_Help", current_help)


func _on_NextButton_pressed():
	var current_help : int = ProjectSettings.get_setting("Game/Global/Current_Help")
	current_help = min(current_help+1, helpDatum.size()-1)
	_help_page.set_help_data(helpDatum[current_help])
	ProjectSettings.set_setting("Game/Global/Current_Help", current_help)
