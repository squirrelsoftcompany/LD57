@tool
extends VBoxContainer
class_name SpecialButton


@export var key:="A" : set = set_key
@export_multiline var help:="do\nsomething" : set = set_help
@export var shortcut : Shortcut = null : set = set_shortcut
@export var ask_signal_name : String = "ask_something"
@export var disabled : bool = false : set = set_disabled


func set_key(value):
	key = value
	$"Button/Label".text = key


func set_help(value):
	help = value
	$Label.text = help


func set_shortcut(value):
	shortcut = value
	$Button.shortcut = shortcut


func set_disabled(value):
	disabled = value
	$Button.disabled = disabled

