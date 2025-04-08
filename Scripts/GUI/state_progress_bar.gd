extends ProgressBar


@export var initial_value_project_settings_name := ""
@export var state_changed_signal_name := ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = ProjectSettings.get_setting(initial_value_project_settings_name, 100)
	value = max_value
	GlobalEventHolder.connect(state_changed_signal_name, _on_state_changed)
	pass # Replace with function body.


func _on_state_changed(val: int, maximum: int):
	max_value = maximum
	value = val
	pass
