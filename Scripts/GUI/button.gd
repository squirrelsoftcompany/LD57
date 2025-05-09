@tool
extends VBoxContainer
class_name SpecialButton


@export var force_key_text := "" : set = set_force_key_text
#@export var key:="A" : set = set_key
@export_multiline var help:="do\nsomething" : set = set_help
@export var icon: Texture2D = null : set = set_icon
@export var shortcut : Shortcut = null : set = set_shortcut
@export var ask_signal_name : String = ""
@export var disabled : bool = false : get = get_disabled, set = set_disabled
@export var button_pressed : bool = false : get = get_button_pressed, set = set_button_pressed
@export_enum("NORMAL:0", "HOLD:1", "TOGGLE:2") var mode : int = 0 : set = set_mode


func set_force_key_text(value):
	force_key_text = value
	compute_key_text()

func set_help(value):
	help = value
	$Label.text = help

func set_icon(value):
	icon = value
	if is_instance_valid(get_node_or_null("Button")):
		$Button.icon = icon

func set_shortcut(value):
	shortcut = value
	$Button.shortcut = shortcut
	compute_key_text()

func get_disabled(): return $Button.disabled
func set_disabled(value): $Button.disabled = value

func get_button_pressed(): return $Button.button_pressed
func set_button_pressed(value): $Button.button_pressed = value


func set_mode(value):
	mode = value
	$Button.toggle_mode = mode > 0


func _ready() -> void:
	if mode == 1: # HOLD MODE
		$Button.connect("toggled", _on_button_toggled)
	else:
		$Button.connect("pressed", _on_button_pressed)


func _on_button_pressed() -> void:
	if !ask_signal_name.is_empty():
		print(name, " pressed -> ", ask_signal_name)
		GlobalEventHolder.emit_signal(ask_signal_name)


func _on_button_toggled(toggled_on: bool) -> void:
	assert(mode == 1)
	if !ask_signal_name.is_empty():
		var ask_signal_name_full := ask_signal_name + ("_start" if toggled_on else "_finish")
		print(name, " toggled(", toggled_on, ") -> ", ask_signal_name_full)
		GlobalEventHolder.emit_signal(ask_signal_name_full)


func compute_key_text():
	if !get_node_or_null("Button/Label"):
		return
	if force_key_text:
		$Button/Label.text = force_key_text
		return
	if shortcut == null or shortcut.events.size() < 0:
		$Button/Label.text = "ERR"
		return
	var action_name := shortcut.events[0].action as String
	var inputEvents := InputMap.action_get_events(action_name)
	if !inputEvents.is_empty():
		if inputEvents[0].keycode:
			$Button/Label.text = OS.get_keycode_string(inputEvents[0].keycode).substr(0,3)
		elif inputEvents[0].physical_keycode:
			var keycode : Key = inputEvents[0].physical_keycode
			keycode = DisplayServer.keyboard_get_keycode_from_physical(keycode)
			$Button/Label.text = OS.get_keycode_string(keycode).substr(0,3)
		else:
			$Button/Label.text = "ERR"
	else:
		$Button/Label.text = "ERR"
