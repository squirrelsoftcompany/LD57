extends RichTextLabel


@export var initial_value_project_settings_name := ""
@export var state_changed_signal_name := ""
@export var template_text := ""
@export var initial_value_at_max := true

var _max_value := 0
var _value := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_max_value = ProjectSettings.get_setting(initial_value_project_settings_name, 4)
	_value = _max_value if initial_value_at_max else 0
	compute_text()
	GlobalEventHolder.connect(state_changed_signal_name, _on_state_changed)


@warning_ignore("shadowed_global_identifier")
func _on_state_changed(val: int, maximum: int):
	_max_value = maximum
	_value = val
	compute_text()


func compute_text():
	text = template_text % [_value,_max_value]
